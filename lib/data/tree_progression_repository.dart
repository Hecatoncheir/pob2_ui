import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../domain/tree_progression.dart';
import 'atomic_text_file.dart';

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
      {'steps': final List<dynamic> entries} => entries.map(_decode).toList(),
      _ => throw const FormatException('Некорректный план прокачки'),
    };
  }

  TreeProgressionStep _decode(Object? value) => switch (value) {
    {'level': final int level, 'nodes': final List<dynamic> nodes}
        when level >= 1 && level <= 100 =>
      TreeProgressionStep(level, nodes.cast<int>()),
    _ => throw const FormatException('Некорректный план прокачки'),
  };

  Future<void> save(List<TreeProgressionStep> steps) => _files.write(
    _file,
    jsonEncode({
      'steps': [
        for (final step in steps)
          {'level': step.level, 'nodes': step.nodes.toList()},
      ],
    }),
  );
}
