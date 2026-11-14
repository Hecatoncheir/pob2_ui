import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../domain/tree_progression.dart';
import 'atomic_text_file.dart';
import 'tree_progression_exchange.dart';

class TreeProgressionRepository {
  TreeProgressionRepository(Directory profile, TreeProgressionKey key)
    : _file = File.fromUri(
        profile.uri.resolve('tree-progression/${_id(key)}.json'),
      );

  final File _file;
  final _files = AtomicTextFile();
  static Future<void>? _writes;

  static String _id(TreeProgressionKey key) => sha256
      .convert(
        utf8.encode(
          jsonEncode([key.folder, key.build, key.version, key.characterClass]),
        ),
      )
      .toString();

  Future<List<TreeProgressionStep>> load() async {
    await _writes;
    final json = jsonDecode(await _files.read(_file, missing: '{"steps":[]}'));
    return switch (json) {
      {'steps': final List<Object?> entries} => decodeProgressionSteps(entries),
      _ => throw const FormatException('Некорректный план прокачки'),
    };
  }

  Future<void> restoreIfMissing(List<TreeProgressionStep> steps) =>
      _write(() async {
        if (!await _file.exists()) await _save(steps);
      });

  Future<void> save(List<TreeProgressionStep> steps) =>
      _write(() => _save(steps));

  Future<void> _save(List<TreeProgressionStep> steps) =>
      _files.write(_file, jsonEncode({'steps': encodeProgressionSteps(steps)}));

  Future<T> transferTo<T>(
    TreeProgressionRepository destination,
    Future<T> Function() commit, {
    Future<void> Function()? restoreSource,
  }) => _write(() async {
    if (_file.path == destination._file.path) return commit();
    final source = await _readStored();
    final previous = await destination._readStored();
    await destination._store(source);
    final T result;
    try {
      result = await commit();
    } catch (_) {
      await destination._store(previous);
      rethrow;
    }
    if (restoreSource != null) {
      try {
        await _store(null);
      } catch (_) {
        await restoreSource();
        await destination._store(previous);
        rethrow;
      }
    }
    return result;
  });

  Future<String?> _readStored() async =>
      await _file.exists() ? _file.readAsString() : null;

  Future<void> _store(String? text) async {
    if (text != null) {
      await _files.write(_file, text);
    } else if (await _file.exists()) {
      await _file.delete();
    }
  }

  static Future<T> _write<T>(Future<T> Function() action) {
    final pending = _writes;
    final result = pending == null
        ? Future.sync(action)
        : pending.then((_) => action());
    late final Future<void> tail;
    void finish() {
      if (identical(_writes, tail)) _writes = null;
    }

    tail = result.then<void>(
      (_) => finish(),
      onError: (Object _, StackTrace _) => finish(),
    );
    _writes = tail;
    return result;
  }
}
