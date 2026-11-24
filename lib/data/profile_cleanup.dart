import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../domain/component.dart';
import 'build_library.dart';
import 'component_ownership.dart';
import 'installation_store.dart';

typedef CleanupEntry = ({
  String relativePath,
  String absolutePath,
  int bytes,
  bool directory,
});
typedef CleanupResult = ({int bytes, Map<String, String> skipped});
typedef _Removal = Future<void> Function(FileSystemEntity);

class ProfileCleanup {
  const ProfileCleanup(this.store, {this.active, this.remove = _remove});

  final InstallationStore store;
  final Installations Function()? active;
  final _Removal remove;

  Future<List<CleanupEntry>> preview() async {
    if (!await store.root.exists()) return const [];
    final root = await store.root.resolveSymbolicLinks();
    final protected = await _protectedPaths(root);
    final entries = [
      ...await _components(root, protected),
      ...await _treeCache(root, protected),
      ...await _archives(root, protected),
      ...await _revisions(root, protected),
    ];
    entries.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return List.unmodifiable(entries);
  }

  Future<CleanupResult> apply(Set<CleanupEntry> selected) async {
    final available = (await preview()).toSet();
    final skipped = <String, String>{};
    var bytes = 0;
    for (final entry in selected) {
      if (!available.contains(entry)) {
        skipped[entry.relativePath] =
            'Файл или папка изменились после предпросмотра.';
        continue;
      }
      bytes += await _deleteEntry(entry, skipped);
    }
    return (bytes: bytes, skipped: Map<String, String>.unmodifiable(skipped));
  }

  Future<int> _deleteEntry(
    CleanupEntry entry,
    Map<String, String> skipped,
  ) async {
    final removed = _CleanupRemoval(remove);
    if (entry.directory) {
      await removed.directory(Directory(entry.absolutePath));
    } else {
      await removed.file(File(entry.absolutePath));
    }
    if (removed.incomplete)
      skipped[entry.relativePath] = 'Часть данных занята или недоступна.';
    return removed.bytes;
  }

  Future<List<String>> _protectedPaths(String root) async {
    final pairs = await store.read();
    final paths = [
      for (final item in [
        ...pairs.active.values,
        ...pairs.previous.values,
        ...?active?.call().values,
      ])
        await _canonicalOrAbsolute(item.directory),
    ];
    for (final name in ['pob-builds.json', 'pob-builds.json.bak']) {
      final directory = await _sharedBuilds(File(path.join(root, name)));
      if (directory != null) paths.add(directory);
    }
    return paths;
  }

  Future<String?> _sharedBuilds(File settings) async {
    if (!await settings.exists()) return null;
    final data = jsonDecode(await settings.readAsString());
    if (data case {'directory': final String directory}) {
      return _canonicalOrAbsolute(directory);
    }
    if (data is! Map<String, dynamic> || data.containsKey('directory')) {
      throw const FormatException('Не удалось проверить папку сборок.');
    }
    return null;
  }

  Future<List<CleanupEntry>> _revisions(
    String root,
    List<String> protected,
  ) async {
    final builds = path.join(root, 'builds');
    if (!await _plain(builds, FileSystemEntityType.directory)) return [];
    final folder = path.join(builds, 'revisions');
    if (!await _plain(folder, FileSystemEntityType.directory)) return [];
    final referenced = await BuildLibrary(Directory(root))
        .referencedRevisions();
    if (referenced == null) return [];
    final entries = <CleanupEntry>[];
    await for (final item in Directory(folder).list(followLinks: false)) {
      if (item is File && await _unusedRevision(item, protected, referenced)) {
        entries.add(_entry(root, item, await item.length()));
      }
    }
    return entries;
  }

  Future<bool> _unusedRevision(
    File item,
    List<String> protected,
    Set<String> referenced,
  ) async =>
      path.extension(item.path) == '.xml' &&
      _revisionId.hasMatch(path.basenameWithoutExtension(item.path)) &&
      !referenced.contains(path.basenameWithoutExtension(item.path)) &&
      !_overlaps(item.path, protected) &&
      await _plain(item.path, FileSystemEntityType.file);

  Future<List<CleanupEntry>> _components(
    String root,
    List<String> protected,
  ) async {
    final entries = <CleanupEntry>[];
    await for (final dir in _directories(path.join(root, 'versions'))) {
      if (_overlaps(dir.path, protected) ||
          await managedComponentTag(dir) == null) {
        continue;
      }
      final bytes = await _measure(dir);
      if (bytes != null) entries.add(_entry(root, dir, bytes));
    }
    return entries;
  }

  Future<List<CleanupEntry>> _treeCache(
    String root,
    List<String> protected,
  ) async {
    final entries = <CleanupEntry>[];
    await for (final source in _directories(path.join(root, 'tree-cache'))) {
      if (_treeSource.hasMatch(path.basename(source.path))) {
        entries.addAll(await _treeVersions(root, source, protected));
      }
    }
    return entries;
  }

  Future<List<CleanupEntry>> _treeVersions(
    String root,
    Directory source,
    List<String> protected,
  ) async {
    final entries = <CleanupEntry>[];
    await for (final version in _directories(source.path)) {
      if (!_treeVersion.hasMatch(path.basename(version.path)) ||
          _overlaps(version.path, protected))
        continue;
      final bytes = await _measure(version, texturesOnly: true);
      if (bytes != null) entries.add(_entry(root, version, bytes));
    }
    return entries;
  }

  Future<List<CleanupEntry>> _archives(
    String root,
    List<String> protected,
  ) async {
    final entries = <CleanupEntry>[];
    await for (final hash in _directories(
      path.join(root, 'component-downloads'),
    )) {
      if (!_digest.hasMatch(path.basename(hash.path))) continue;
      for (final name in _archiveNames) {
        final file = File(path.join(hash.path, name));
        if (await _plain(file.path, FileSystemEntityType.file) &&
            !_overlaps(file.path, protected)) {
          entries.add(_entry(root, file, await file.length()));
        }
      }
    }
    return entries;
  }

  CleanupEntry _entry(String root, FileSystemEntity entity, int bytes) => (
    relativePath: path.relative(entity.path, from: root),
    absolutePath: entity.path,
    bytes: bytes,
    directory: entity is Directory,
  );
}

final _treeSource = RegExp(r'^[a-f0-9]{40}(?:-[a-f0-9]{40})?$');
final _treeVersion = RegExp(r'^[0-9_]{1,32}$');
final _digest = RegExp(r'^[a-f0-9]{64}$');
final _revisionId = RegExp(r'^[a-f0-9]{32}$');
final _texture = RegExp(r'^[a-f0-9]{64}\.png$');
const _archiveNames = [
  'pob.zip',
  'mcp-windows-x64.zip',
  'mcp-macos-arm64.zip',
  'mcp-linux-x64.zip',
];

Stream<Directory> _directories(String folder) async* {
  if (!await _plain(folder, FileSystemEntityType.directory)) return;
  await for (final item in Directory(folder).list(followLinks: false)) {
    if (item is Directory &&
        await _plain(item.path, FileSystemEntityType.directory)) {
      yield item;
    }
  }
}

Future<bool> _plain(String name, FileSystemEntityType type) async {
  if (await FileSystemEntity.type(name, followLinks: false) != type)
    return false;
  final resolved = await File(name).resolveSymbolicLinks();
  return path.equals(resolved, name);
}

Future<String> _canonicalOrAbsolute(String name) async {
  try {
    return await Directory(name).resolveSymbolicLinks();
  } on FileSystemException {
    return path.normalize(path.absolute(name));
  }
}

bool _overlaps(String name, List<String> protected) => protected.any(
  (value) =>
      path.equals(name, value) ||
      path.isWithin(value, name) ||
      path.isWithin(name, value),
);

Future<int?> _measure(Directory folder, {bool texturesOnly = false}) async {
  var bytes = 0;
  await for (final item in folder.list(followLinks: false)) {
    final size = await _entryBytes(item, texturesOnly);
    if (size == null) return null;
    bytes += size;
  }
  return bytes;
}

Future<int?> _entryBytes(FileSystemEntity item, bool texturesOnly) async {
  if (item is Directory &&
      !texturesOnly &&
      await _plain(item.path, FileSystemEntityType.directory)) {
    return _measure(item);
  }
  if (item is! File || !await _plain(item.path, FileSystemEntityType.file))
    return null;
  if (texturesOnly && !_texture.hasMatch(path.basename(item.path))) return null;
  return item.length();
}

Future<void> _remove(FileSystemEntity entity) async {
  await entity.delete();
}

class _CleanupRemoval {
  _CleanupRemoval(this.remove);
  final _Removal remove;
  int bytes = 0;
  bool incomplete = false;

  Future<void> directory(Directory folder) async {
    try {
      await _deleteDirectory(folder);
    } on FileSystemException {
      incomplete = true;
    }
  }

  Future<void> _deleteDirectory(Directory folder) async {
    if (!await _plain(folder.path, FileSystemEntityType.directory)) {
      incomplete = true;
      return;
    }
    final marker = await _deleteChildren(folder);
    if (incomplete) return;
    if (marker != null) await file(marker);
    if (!incomplete) await remove(folder);
  }

  Future<File?> _deleteChildren(Directory folder) async {
    File? marker;
    await for (final item in folder.list(followLinks: false)) {
      if (item is File && path.basename(item.path) == componentOwnershipFile) {
        marker = item;
      } else {
        await _deleteChild(item);
      }
    }
    return marker;
  }

  Future<void> _deleteChild(FileSystemEntity item) async {
    switch (item) {
      case Directory():
        await directory(item);
      case File():
        await file(item);
      default:
        incomplete = true;
    }
  }

  Future<void> file(File target) async {
    try {
      if (!await _plain(target.path, FileSystemEntityType.file)) {
        incomplete = true;
        return;
      }
      final size = await target.length();
      await remove(target);
      bytes += size;
    } on FileSystemException {
      incomplete = true;
    }
  }
}
