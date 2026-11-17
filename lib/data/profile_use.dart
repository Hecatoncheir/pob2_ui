import 'dart:io';

import 'package:path/path.dart' as path;

class ProfileUse {
  ProfileUse._(this._root, this._lock);

  static final _roots = <String>{};
  final String _root;
  final RandomAccessFile _lock;
  bool _closed = false;
  bool _cleaning = false;

  static Future<ProfileUse?> open(Directory directory) async {
    try {
      await directory.create(recursive: true);
      final root = await directory.resolveSymbolicLinks();
      if (!_roots.add(path.canonicalize(root))) return null;
      return await _open(root);
    } on FileSystemException {
      return null;
    }
  }

  static Future<ProfileUse?> _open(String root) async {
    RandomAccessFile? lock;
    var keep = false;
    final name = path.join(root, '.profile-use.lock');
    try {
      if (await FileSystemEntity.type(name, followLinks: false) ==
          FileSystemEntityType.link) {
        return null;
      }
      lock = await File(name).open(mode: FileMode.append);
      await lock.lock(FileLock.blockingShared);
      keep = true;
      return ProfileUse._(root, lock);
    } finally {
      if (!keep) {
        _roots.remove(path.canonicalize(root));
        await lock?.close();
      }
    }
  }

  Future<T> exclusively<T>(Directory root, Future<T> Function() action) async {
    if (_closed || _cleaning) throw StateError('Профиль уже используется.');
    _cleaning = true;
    try {
      await _lock.unlock();
      try {
        await _lockForCleanup();
        try {
          if (!path.equals(_root, await root.resolveSymbolicLinks())) {
            throw StateError('Путь профиля изменился.');
          }
          return await action();
        } finally {
          await _lock.unlock();
        }
      } finally {
        await _lock.lock(FileLock.blockingShared);
      }
    } finally {
      _cleaning = false;
    }
  }

  Future<void> _lockForCleanup() async {
    try {
      await _lock.lock(FileLock.exclusive);
    } on FileSystemException {
      throw StateError(
        'Закройте другие экземпляры PoB II и повторите очистку.',
      );
    }
  }

  Future<void> close() async {
    if (_closed) return;
    if (_cleaning) throw StateError('Профиль уже используется.');
    _closed = true;
    await _lock.close();
    _roots.remove(path.canonicalize(_root));
  }
}
