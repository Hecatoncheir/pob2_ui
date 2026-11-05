import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../domain/build_report.dart';
import '../domain/library_entry.dart';

class BuildLibrary {
  BuildLibrary(Directory data)
    : root = Directory.fromUri(data.uri.resolve('builds/'));
  final Directory root;
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

  Future<LibraryState> load() async {
    if (!await _index.exists()) return LibraryState();
    final json = jsonMap(jsonDecode(await _index.readAsString()));
    if (json['schema'] != 1)
      throw const FormatException('Неизвестный формат библиотеки сборок');
    final entries = jsonRows(json['entries'])
        .map(LibraryEntry.fromJson)
        .toList();
    for (final entry in entries) {
      _xml(entry.id);
    }
    return LibraryState(
      entries: entries,
      activeId: json['activeId'] as String?,
    );
  }

  Future<void> writeIndex(LibraryState state) async {
    await root.create(recursive: true);
    final file = File('${_index.path}.tmp');
    await file.writeAsString(
      jsonEncode({
        'schema': 1,
        'activeId': state.activeId,
        'entries': state.entries.map((entry) => entry.toJson()).toList(),
      }),
      flush: true,
    );
    await file.rename(_index.path);
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
    );
    await root.create(recursive: true);
    final temporary = File('${_xml(id).path}.tmp');
    await temporary.writeAsString(xml, flush: true);
    await temporary.rename(_xml(id).path);
    final next = LibraryState(
      activeId: id,
      entries: [entry, ...state.entries.where((item) => item.id != id)],
    );
    await writeIndex(next);
    return next;
  }

  Future<String> read(String id) => _xml(id).readAsString();
}
