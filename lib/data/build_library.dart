import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../domain/build_report.dart';
import '../domain/library_entry.dart';
import 'atomic_text_file.dart';

class BuildLibrary {
  BuildLibrary(Directory data, {AtomicTextFile? files})
    : root = Directory.fromUri(data.uri.resolve('builds/')),
      files = files ?? AtomicTextFile();
  final Directory root;
  final AtomicTextFile files;
  File get _index => File.fromUri(root.uri.resolve('index.json'));
  String newId() => List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  File _xml(String id) {
    if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(id))
      throw const FormatException('Некорректный идентификатор сборки');
    return File.fromUri(root.uri.resolve('$id.xml'));
  }

  File _revision(String id) {
    _xml(id);
    return File.fromUri(root.uri.resolve('revisions/$id.xml'));
  }

  Future<LibraryState> load() async {
    if (!await _index.exists() && !await File('${_index.path}.bak').exists())
      return LibraryState();
    LibraryState state;
    try {
      state = _decode(await _index.readAsString());
    } on FileSystemException {
      state = await _recoverIndex();
    } on FormatException {
      state = await _recoverIndex();
    } on TypeError {
      state = await _recoverIndex();
    }
    return _migrateLegacy(state);
  }

  LibraryState _decode(String text) {
    final json = jsonMap(jsonDecode(text));
    if (json['schema'] != 1 || json['entries'] is! List)
      throw const FormatException('Неизвестный формат библиотеки сборок');
    final entries = (json['entries'] as List).map(_decodeEntry).toList();
    if (entries.map((entry) => entry.id).toSet().length != entries.length)
      throw const FormatException('Неизвестный формат библиотеки сборок');
    return LibraryState(
      entries: entries,
      activeId: json['activeId'] as String?,
    );
  }

  LibraryEntry _decodeEntry(dynamic value) {
    if (value is! Map<String, dynamic>)
      throw const FormatException('Неизвестный формат библиотеки сборок');
    final entry = LibraryEntry.fromJson(value);
    _xml(entry.id);
    if (entry.revision case final revision?) _revision(revision);
    return entry;
  }

  Future<LibraryState> _recoverIndex() async {
    final state = _decode(await File('${_index.path}.bak').readAsString());
    await writeIndex(state, backup: false);
    return state;
  }

  Future<LibraryState> _migrateLegacy(LibraryState state) async {
    final entries = <LibraryEntry>[];
    var migrated = false;
    for (final entry in state.entries) {
      final next = await _migrateEntry(entry);
      entries.add(next);
      if (next.revision != entry.revision) migrated = true;
    }
    final next = LibraryState(entries: entries, activeId: state.activeId);
    if (migrated) {
      await writeIndex(next);
    }
    return next;
  }

  Future<LibraryEntry> _migrateEntry(LibraryEntry entry) async {
    if (entry.revision != null) {
      _revision(entry.revision!);
      return entry;
    }
    if (!await _xml(entry.id).exists()) return entry;
    final revision = newId();
    await files.write(_revision(revision), await _xml(entry.id).readAsString());
    return entry.withRevision(revision);
  }

  Future<void> writeIndex(LibraryState state, {bool backup = true}) async {
    await files.write(
      _index,
      jsonEncode({
        'schema': 1,
        'activeId': state.activeId,
        'entries': state.entries.map((entry) => entry.toJson()).toList(),
      }),
      backup: backup,
    );
  }

  Future<LibraryState> save(
    LibraryState state,
    BuildReport report,
    String xml, {
    String? title,
  }) async {
    final id = state.activeId ?? newId();
    final entry = LibraryEntry(
      id: id,
      title: title ?? state.active?.title ?? report.name,
      characterClass: report.characterClass,
      level: report.level,
      updated: DateTime.now(),
      revision: newId(),
    );
    await files.write(_revision(entry.revision!), xml);
    await files.write(_xml(id), xml);
    final next = LibraryState(
      activeId: id,
      entries: [entry, ...state.entries.where((item) => item.id != id)],
    );
    await writeIndex(next);
    return next;
  }

  Future<String> read(String id) {
    _xml(id);
    return _readEntry(id);
  }

  Future<String> _readEntry(String id) async {
    final state = await load();
    final entry = state.entries.where((entry) => entry.id == id).firstOrNull;
    if (entry == null) throw const FormatException('Сборка не найдена');
    return (entry.revision == null ? _xml(id) : _revision(entry.revision!))
        .readAsString();
  }
}
