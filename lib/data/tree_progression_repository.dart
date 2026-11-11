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

  static String _id(TreeProgressionKey key) => sha256
      .convert(
        utf8.encode(
          jsonEncode([key.folder, key.build, key.version, key.characterClass]),
        ),
      )
      .toString();

  Future<List<TreeProgressionStep>> load() async {
    final json = jsonDecode(await _files.read(_file, missing: '{"steps":[]}'));
    return switch (json) {
      {'steps': final List<Object?> entries} => decodeProgressionSteps(entries),
      _ => throw const FormatException('Некорректный план прокачки'),
    };
  }

  Future<void> restoreIfMissing(List<TreeProgressionStep> steps) async {
    if (!await _file.exists()) await save(steps);
  }

  Future<void> save(List<TreeProgressionStep> steps) =>
      _files.write(_file, jsonEncode({'steps': encodeProgressionSteps(steps)}));
}
