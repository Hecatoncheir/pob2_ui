import 'dart:convert';
import 'dart:io';

import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/domain/component.dart';

import '../test/support/legacy/component_repository.dart';

Future<void> main(List<String> arguments) async {
  final args = [...arguments];
  final keepArchives = args.remove('--keep-archives');
  if (keepArchives && args.firstOrNull != '--install') {
    throw const FormatException('--keep-archives требует --install');
  }
  final repository = ComponentRepository(
    store: InstallationStore(InstallationStore.defaultRoot()),
    keepArchives: keepArchives,
  );
  await repository.load();
  if (args case ['--install', '--lock', final path]) {
    final releases = repository.availableReleases();
    await _verifyLock(path, releases);
    await repository.installPair(releases, stderr.writeln);
  } else if (args case ['--install']) {
    await repository.installPair(
      repository.availableReleases(),
      stderr.writeln,
    );
  } else if (args case ['--install-source']) {
    final releases = {
      for (final component in Component.values)
        component: await repository.github.latest(component),
    };
    await repository.installPair(releases, stderr.writeln);
  } else if (args.isNotEmpty) {
    throw const FormatException(
      'Используйте --install [--lock <файл>] [--keep-archives] или --install-source',
    );
  }
  stdout.writeln(
    jsonEncode({
      'legacyVersions': {
        for (final entry in repository.active.entries)
          entry.key.name: entry.value.toJson(),
      },
    }),
  );
}

Future<void> _verifyLock(String path, Map<Component, Release> releases) async {
  final data =
      jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
  for (final entry in releases.entries) {
    final release = entry.value;
    final locked = data[entry.key.name];
    if (locked is! Map ||
        locked['tag'] != release.tag ||
        locked['commit'] != release.expectedCommit) {
      throw FormatException(
        'Архив не соответствует закреплённой ревизии ${entry.key.title}',
      );
    }
  }
}
