import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

import '../domain/build_report.dart';
import '../domain/library_entry.dart';
import '../domain/tree_progression.dart';
import 'atomic_text_file.dart';
import 'build_library.dart';
import 'pob_build_document.dart';
import 'session_repository.dart';
import 'tree_progression_repository.dart';

typedef PobBuildVersion = ({
  LibraryEntry entry,
  String xml,
  PobBuildDocument document,
});

class PobBuildSaveConflict extends StateError {
  PobBuildSaveConflict(this.copy)
    : super(
        'Сборка изменена в PoB. Правки PoB II сохранены отдельно: ${copy.title}',
      );
  final LibraryEntry copy;
}

class PobBuildLibrary implements BuildStorage, BuildNotesStorage {
  PobBuildLibrary(this._profile)
    : _settings = File(path.join(_profile.path, 'pob-builds.json')),
      _recovery = Directory(path.join(_profile.path, 'pob-build-recovery')),
      _legacy = BuildLibrary(_profile),
      _legacySession = SessionRepository(_profile);

  final Directory _profile;
  final File _settings;
  final Directory _recovery;
  final BuildLibrary _legacy;
  final SessionRepository _legacySession;
  final _files = AtomicTextFile();
  Directory? _directory;
  String? _active;
  bool _migrated = false;
  String? get directory => _directory?.path;
  final _notes = <String, String>{};
  final _pendingNotes = <String, String>{};
  Future<void> _notesQueue = Future.value();
  Future<void> _writes = Future.value();

  Future<T> _write<T>(Future<T> Function() action) {
    final result = _writes.then((_) => action());
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  String newId() => _legacy.newId();

  @override
  Future<LibraryState> load() async {
    final saved = jsonDecode(await _files.read(_settings, missing: '{}'));
    if (saved case {'directory': final String folder}) {
      _migrated = saved['migrated'] == true;
      final root = Directory(folder);
      final builds = await _scan(root, saved['active'] as String?);
      _directory = root;
      _active = builds.activeId;
      return builds;
    }
    return LibraryState(skipSessionRecovery: true);
  }

  Future<LibraryState> configure(String folder) =>
      _write(() => _configure(folder));

  Future<LibraryState> _configure(String folder) async {
    final selected = Directory(await Directory(folder).resolveSymbolicLinks());
    final sameFolder = path.equals(selected.path, directory ?? '');
    final active = _migrated
        ? (sameFolder ? _active : null)
        : await _migrate(selected);
    final builds = await _scan(selected, active);
    await _writeSettings(selected, builds.activeId);
    if (!sameFolder) _notes.clear();
    _directory = selected;
    _migrated = true;
    _active = builds.activeId;
    return builds;
  }

  Future<LibraryState> scan() async {
    final root = _directory;
    return root == null
        ? LibraryState(skipSessionRecovery: true)
        : _scan(root, _active);
  }

  Future<LibraryState> _scan(Directory root, String? active) async {
    await _checkRoot(root);
    final entries = <LibraryEntry>[];
    await for (final file in root.list(recursive: true, followLinks: false)) {
      if (file is! File || !_isBuild(file.path)) continue;
      if (await _scanEntry(root, file) case final entry?) entries.add(entry);
    }
    entries.sort((first, second) => second.updated.compareTo(first.updated));
    return LibraryState(
      entries: entries,
      activeId: entries.any((entry) => entry.id == active) ? active : null,
      skipSessionRecovery: true,
    );
  }

  Future<LibraryEntry?> _scanEntry(Directory root, File file) async {
    try {
      return (await _readFile(root, file)).entry;
    } on XmlException {
      return null;
    } on FormatException {
      return null;
    } on PathNotFoundException {
      return null;
    }
  }

  bool _isBuild(String file) =>
      path.extension(file).toLowerCase() == '.xml' &&
      path.basename(file) != '~~temp~~.xml';

  Directory get _root =>
      _directory ??
      (throw StateError('Выберите папку сборок Path of Building.'));

  Future<void> _checkRoot(Directory root) async {
    if (!path.equals(root.path, await root.resolveSymbolicLinks()))
      throw FileSystemException('Папка сборок PoB изменилась.', root.path);
  }

  File _buildPath(Directory root, String id) {
    final file = File(path.normalize(path.join(root.path, id)));
    if (!_isBuild(file.path) || !path.isWithin(root.path, file.path)) {
      throw const FormatException('Некорректный путь к сборке PoB.');
    }
    return file;
  }

  Future<File> _file(Directory root, String id) async {
    final file = _buildPath(root, id);
    final parent = await file.parent.resolveSymbolicLinks();
    if (!path.equals(file.parent.path, parent)) {
      throw const FormatException('Некорректный путь к сборке PoB.');
    }
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (type != FileSystemEntityType.file) {
      throw StateError('Сборка PoB больше недоступна. Обновите список сборок.');
    }
    return file;
  }

  Future<PobBuildVersion> _readFile(Directory root, File file) async =>
      _version(root, file, await file.readAsString());

  Future<PobBuildVersion> _version(
    Directory root,
    File file,
    String xml,
  ) async {
    final document = PobBuildDocument(xml);
    return (
      xml: xml,
      document: document,
      entry: _entry(root, file, document, await file.lastModified()),
    );
  }

  LibraryEntry _entry(
    Directory root,
    File file,
    PobBuildDocument document,
    DateTime updated,
  ) => LibraryEntry(
    id: path.relative(file.path, from: root.path),
    title: path.basenameWithoutExtension(file.path),
    characterClass: document.characterClass,
    level: document.level,
    updated: updated,
    revision: document.revision,
  );

  Future<PobBuildVersion> open(String id) async {
    final root = _root;
    return _readFile(root, await _file(root, id));
  }

  Stream<FileSystemEvent> watchBuild(String id) async* {
    if (!FileSystemEntity.isWatchSupported) return;
    final file = _buildPath(_root, id);
    yield* file.parent.watch().where((event) => _isBuildEvent(file, event));
  }

  bool _isBuildEvent(File file, FileSystemEvent event) {
    if (path.equals(event.path, file.path)) return true;
    if (path.equals(event.path, file.parent.path)) return true;
    if (event case FileSystemMoveEvent(destination: final destination?)) {
      return path.equals(destination, file.path);
    }
    return false;
  }

  Future<PobBuildVersion?> changed(String id, String? seenXml) async {
    final root = _root;
    try {
      final file = await _file(root, id);
      final xml = await file.readAsString();
      return xml == seenXml ? null : await _version(root, file, xml);
    } on FileSystemException {
      return null;
    } on StateError {
      return null;
    } on FormatException {
      return null;
    } on XmlException {
      return null;
    }
  }

  Future<LibraryEntry?> preserveLocal(PobBuildVersion disk) => _write(() async {
    final file = await _file(_root, disk.entry.id);
    return _preserveLocal(file, disk);
  });

  File _recoveryFile(File file) {
    final key = sha256.convert(utf8.encode(path.canonicalize(file.path)));
    return File(path.join(_recovery.path, '$key.xml'));
  }

  Future<LibraryEntry?> _preserveLocal(File file, PobBuildVersion disk) async {
    final saved = _recoveryFile(file);
    if (!await saved.exists()) return null;
    final xml = await saved.readAsString();
    final document = PobBuildDocument(xml);
    if (document.revision == disk.entry.revision &&
        document.notes == disk.document.notes) {
      return null;
    }
    final copy = await _recoveryCopy(disk.entry, xml, document);
    await saved.delete();
    return copy;
  }

  Future<LibraryEntry> _recoveryCopy(
    LibraryEntry source,
    String xml,
    PobBuildDocument document,
  ) async {
    final root = _root;
    await _checkRoot(root);
    final file = await _create(
      root,
      _stem('${source.title} · правки PoB II'),
      xml,
    );
    return _entry(root, file, document, DateTime.now());
  }

  @override
  Future<String> read(String id) async => (await open(id)).xml;

  String? idForPath(String filePath) {
    final root = _directory;
    final absolute = path.normalize(path.absolute(filePath));
    if (root == null ||
        !path.isWithin(root.path, absolute) ||
        !_isBuild(absolute)) {
      return null;
    }
    return path.relative(absolute, from: root.path);
  }

  Future<void> checkExport(File file) async {
    final parent = await file.parent.resolveSymbolicLinks();
    final target = path.join(parent, path.basename(file.path));
    if (idForPath(target) != null && await _occupied(file)) {
      throw StateError(
        'Эта сборка уже есть в библиотеке PoB. Выберите другое имя для копии.',
      );
    }
  }

  Future<String> withCurrentNotes(String id, String xml) async {
    try {
      final disk = PobBuildDocument(await read(id));
      final working = PobBuildDocument(xml);
      return disk.notes == working.notes ? xml : working.withNotes(disk.notes);
    } on FileSystemException {
      return xml;
    } on StateError {
      return xml;
    }
  }

  Future<void> activate(String? id) async {
    if (_active == id) return;
    _active = id;
    try {
      await _writeSettings(_root, id);
    } on FileSystemException {
      // Выбор последней сборки не влияет на уже сохранённый XML.
    }
  }

  Future<void> _writeSettings(Directory root, String? active) => _files.write(
    _settings,
    jsonEncode({'directory': root.path, 'active': active, 'migrated': true}),
    backup: true,
  );

  @override
  Future<LibraryState> save(
    LibraryState state,
    BuildReport report,
    String xml, {
    String? title,
    TreeProgressionKey? progressionSource,
  }) => _write(() => _save(state, report, xml, title, progressionSource));

  Future<LibraryState> _save(
    LibraryState state,
    BuildReport report,
    String xml,
    String? title,
    TreeProgressionKey? progressionSource,
  ) async {
    final root = _root;
    await _checkRoot(root);
    final document = PobBuildDocument(xml);
    final previous = state.active;
    final file = previous == null
        ? await _create(
            root,
            _stem(title ?? report.name),
            xml,
            progressionSource: progressionSource,
          )
        : await _saveExisting(
            root,
            previous,
            document,
            xml,
            title,
            progressionSource,
          );
    final entry = _entry(root, file, document, DateTime.now());
    await activate(entry.id);
    return LibraryState(
      entries: [
        entry,
        ...state.entries.where(
          (item) => item.id != previous?.id && item.id != entry.id,
        ),
      ],
      activeId: entry.id,
      skipSessionRecovery: true,
    );
  }

  Future<File> _saveExisting(
    Directory root,
    LibraryEntry previous,
    PobBuildDocument document,
    String xml,
    String? title,
    TreeProgressionKey? progressionSource,
  ) async {
    final file = _buildPath(root, previous.id);
    final current = await changed(previous.id, null);
    if (current == null || current.entry.revision != previous.revision) {
      await _preserveAttempt(file, previous, xml, document);
      throw _conflict();
    }
    final updated = current.document.notes == document.notes
        ? xml
        : document.withNotes(current.document.notes);
    if (title != null && title != previous.title) {
      return _rename(
        file,
        current.xml,
        _stem(title),
        updated,
        progressionSource,
      );
    }
    if (current.entry.revision != document.revision) {
      await _saveLocal(file, current, updated);
    }
    return file;
  }

  Future<void> _preserveAttempt(
    File file,
    LibraryEntry previous,
    String xml,
    PobBuildDocument document,
  ) async {
    if (document.revision == previous.revision) return;
    final saved = _recoveryFile(file);
    final notes = await saved.exists()
        ? PobBuildDocument(await saved.readAsString()).notes
        : document.notes;
    final contents = notes == document.notes ? xml : document.withNotes(notes);
    throw PobBuildSaveConflict(
      await _recoveryCopy(previous, contents, document),
    );
  }

  Future<void> _saveLocal(File file, PobBuildVersion before, String xml) async {
    await _preserveLocal(file, before);
    // PoB может заменить общий XML сразу после нашей записи.
    await _files.write(_recoveryFile(file), xml);
    await _replace(file, before.xml, xml);
  }

  Future<File> _rename(
    File source,
    String before,
    String stem,
    String xml,
    TreeProgressionKey? progressionSource,
  ) async {
    final renamed = File(path.join(source.parent.path, '$stem.xml'));
    if (path.equals(source.path, renamed.path)) {
      await _replace(source, before, xml);
      return source;
    }
    await _writeNew(renamed, xml);
    var retired = false;
    try {
      return await _transferProgression(
        progressionSource,
        renamed,
        () async {
          await _retire(source, before);
          retired = true;
          return renamed;
        },
        restoreSource: () async {
          await _writeNew(source, before);
          retired = false;
        },
      );
    } catch (_) {
      if (!retired && await renamed.readAsString() == xml) {
        await renamed.delete();
      }
      rethrow;
    }
  }

  Future<File> _create(
    Directory root,
    String stem,
    String xml, {
    TreeProgressionKey? progressionSource,
  }) async {
    var number = 1;
    var file = File(path.join(root.path, '$stem.xml'));
    while (await _occupied(file)) {
      number++;
      file = File(path.join(root.path, '$stem ($number).xml'));
    }
    return _transferProgression(progressionSource, file, () async {
      await _writeNew(file, xml);
      return file;
    });
  }

  Future<File> _transferProgression(
    TreeProgressionKey? source,
    File target,
    Future<File> Function() commit, {
    Future<void> Function()? restoreSource,
  }) {
    if (source == null) return commit();
    final destination = (
      folder: _root.path,
      build: path.relative(target.path, from: _root.path),
      version: source.version,
      characterClass: source.characterClass,
    );
    return TreeProgressionRepository(_profile, source).transferTo(
      TreeProgressionRepository(_profile, destination),
      commit,
      restoreSource: restoreSource,
    );
  }

  Future<bool> _occupied(File file) async =>
      await FileSystemEntity.type(file.path, followLinks: false) !=
      FileSystemEntityType.notFound;

  Future<void> _writeNew(File file, String xml) async {
    if (await _occupied(file))
      throw StateError('Сборка с таким именем уже существует.');
    await file.create(exclusive: true);
    try {
      await _files.writeChecked(
        file,
        xml,
        beforeReplace: () => _check(file, ''),
      );
    } catch (_) {
      await _clearReservation(file);
      rethrow;
    }
  }

  Future<void> _clearReservation(File file) async {
    if (await FileSystemEntity.type(file.path, followLinks: false) ==
            FileSystemEntityType.file &&
        await file.length() == 0) {
      await file.delete();
    }
  }

  Future<void> _replace(File file, String before, String xml) async {
    await _files.write(File('${file.path}.bak'), before);
    await _files.writeChecked(
      file,
      xml,
      beforeReplace: () => _check(file, before),
    );
  }

  Future<void> _check(File file, String before) async {
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw _conflict();
    }
    if (await file.readAsString() != before) throw _conflict();
  }

  StateError _conflict() =>
      StateError('Сборка изменилась на диске. Дождитесь обновления из PoB.');

  Future<void> _retire(File file, String before) async {
    await _check(file, before);
    await file.rename('${file.path}.pob2-${newId()}.bak');
  }

  @override
  Future<LibraryState> remove(LibraryState state, String id) =>
      _write(() => _remove(state, id));

  Future<LibraryState> _remove(LibraryState state, String id) async {
    final expected = state.entries.firstWhere((entry) => entry.id == id);
    final file = await _file(_root, id);
    final current = await _readFile(_root, file);
    if (expected.revision != current.entry.revision) throw _conflict();
    await _retire(file, current.xml);
    if (state.activeId == id) await activate(null);
    return LibraryState(
      entries: state.entries.where((entry) => entry.id != id).toList(),
      activeId: _active,
      skipSessionRecovery: true,
    );
  }

  String _stem(String name) {
    final value = name
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
        .trim()
        .replaceFirst(RegExp(r'[ .]+$'), '');
    if (value.isEmpty) return 'PoB II';
    if (RegExp(
      r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])(\.|$)',
      caseSensitive: false,
    ).hasMatch(value)) {
      return '_$value';
    }
    return value;
  }

  Future<String?> _migrate(Directory root) async {
    final old = await _legacy.load();
    String? active;
    for (final entry in old.entries) {
      final id = await _migrateEntry(root, entry);
      if (entry.id == old.activeId) active = id;
    }
    if (old.entries.isEmpty &&
        !old.skipSessionRecovery &&
        await _legacySession.exists()) {
      final xml = await _legacySession.read();
      PobBuildDocument(xml);
      active = await _migrateFile(
        root,
        'Восстановленная сборка',
        'session',
        xml,
      );
    }
    return active;
  }

  Future<String> _migrateEntry(Directory root, LibraryEntry entry) async {
    final xml = await _legacy.read(entry.id);
    final document = PobBuildDocument(xml);
    final notes = await _legacySession.readNotes(entry.id);
    final merged = [
      document.notes,
      notes,
    ].where((text) => text.isNotEmpty).join('\n\n');
    final contents = notes.isEmpty || notes == document.notes
        ? xml
        : document.withNotes(merged);
    return _migrateFile(root, _stem(entry.title), entry.id, contents);
  }

  Future<String> _migrateFile(
    Directory root,
    String stem,
    String id,
    String xml,
  ) async {
    var destination = File(path.join(root.path, '$stem.xml'));
    if (await _occupied(destination) && !await _hasContents(destination, xml)) {
      destination = File(path.join(root.path, '$stem (PoB II $id).xml'));
    }
    if (!await _hasContents(destination, xml))
      await _writeNew(destination, xml);
    return path.relative(destination.path, from: root.path);
  }

  Future<bool> _hasContents(File file, String xml) async =>
      await FileSystemEntity.type(file.path, followLinks: false) ==
          FileSystemEntityType.file &&
      await file.readAsString() == xml;

  @override
  Future<String> readNotes(String id) async {
    final document = PobBuildDocument(await read(id));
    return _notes[id] = document.notes;
  }

  @override
  Future<void> saveNotes(String id, String text) {
    _pendingNotes[id] = text;
    return flushText();
  }

  Future<void> discardNotes(String id) async {
    await _notesQueue.catchError((Object _) {});
    _pendingNotes.remove(id);
    _notes.remove(id);
    _notesQueue = Future.value();
  }

  @override
  Future<void> flushText() {
    if (_pendingNotes.isEmpty) return _notesQueue;
    _notesQueue = _notesQueue
        .catchError((Object _) {})
        .then((_) => _write(_savePendingNotes));
    return _notesQueue;
  }

  Future<void> _savePendingNotes() async {
    while (_pendingNotes.isNotEmpty) {
      final pending = _pendingNotes.entries.first;
      await _saveNote(pending.key, pending.value);
      if (_pendingNotes[pending.key] == pending.value)
        _pendingNotes.remove(pending.key);
    }
  }

  Future<void> _saveNote(String id, String text) async {
    final file = await _file(_root, id);
    final current = await _readFile(_root, file);
    final document = current.document;
    if (document.notes != _notes[id]) throw _conflict();
    if (document.notes != text) {
      await _saveLocal(
        file,
        current,
        PobBuildDocument(current.xml).withNotes(text),
      );
    }
    _notes[id] = text;
  }
}
