import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/data/component_ownership.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/profile_cleanup.dart';
import 'package:pob2_ui/data/profile_use.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/domain/library_entry.dart';

const _commit = '0123456789abcdef0123456789abcdef01234567';

void main() {
  late Directory root;
  late InstallationStore store;
  late ProfileCleanup cleanup;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-profile-unit-');
    addTearDown(() => root.delete(recursive: true));
    store = InstallationStore(root);
    cleanup = ProfileCleanup(store);
  });

  test('Перед удалением проверяется актуальная пара компонентов', () async {
    final obsolete = await _component(root);
    final selected = (await cleanup.preview()).toSet();
    expect(selected, hasLength(1));

    await store.save({Component.pob: obsolete}, {});
    final use = await ProfileUse.open(root);
    if (use == null) fail('Не удалось открыть профиль');
    addTearDown(use.close);
    final result = await ComponentRepository(
      store: store,
      profileUse: use,
    ).cleanProfile(selected);
    expect(result.bytes, 0);
    expect(result.skipped, hasLength(1));
    expect(await Directory(obsolete.directory).exists(), isTrue);
  });

  test('Папка сборок из резервных настроек защищена от очистки', () async {
    final obsolete = await _component(root);
    final preview = (await cleanup.preview()).toSet();
    await _file(
      root,
      'pob-builds.json.bak',
      jsonEncode({'directory': obsolete.directory}),
    );
    expect(await cleanup.preview(), isEmpty);
    expect((await cleanup.apply(preview)).bytes, 0);
    expect(await Directory(obsolete.directory).exists(), isTrue);
  });

  test(
    'При ошибке удаления сохраняется метка компонента для повтора',
    () async {
      final obsolete = await _component(root);
      final kept = File(path.join(obsolete.directory, 'пакет.bin'));
      final keptPath = await kept.resolveSymbolicLinks();
      final extra = await _file(
        Directory(obsolete.directory),
        'extra.txt',
        'test',
      );
      final failing = ProfileCleanup(
        store,
        remove: (entity) async {
          if (entity.path == keptPath)
            throw const FileSystemException('Путь занят');
          await entity.delete();
        },
      );

      final result = await failing.apply((await failing.preview()).toSet());
      expect(result.bytes, 4);
      expect(result.skipped, hasLength(1));
      expect(await kept.exists(), isTrue);
      expect(await extra.exists(), isFalse);
      final retry = await cleanup.preview();
      expect(retry, hasLength(1));
      expect((await cleanup.apply(retry.toSet())).skipped, isEmpty);
      expect(await Directory(obsolete.directory).exists(), isFalse);
    },
  );

  test(
    'Ссылка или точка соединения не позволяет удалить внешние файлы',
    () async {
      final outside = await Directory.systemTemp.createTemp(
        'pob2-profile-outside-',
      );
      addTearDown(() => outside.delete(recursive: true));
      final xml = await _file(outside, '${'a' * 64}.png', 'внешние данные');
      final versions = Directory(
        path.join(root.path, 'tree-cache', '$_commit-$_commit'),
      );
      await versions.create(recursive: true);
      final link = path.join(versions.path, '0_5');

      if (Platform.isWindows) {
        final command = await Process.run('cmd.exe', [
          '/c',
          'mklink',
          '/J',
          link,
          outside.path,
        ]);
        expect(
          command.exitCode,
          0,
          reason: '${command.stdout}\n${command.stderr}',
        );
      } else {
        await Link(link).create(outside.path);
      }
      expect(await cleanup.preview(), isEmpty);
      expect(await xml.readAsString(), 'внешние данные');
    },
  );

  test(
    'Очистка ревизий сохраняет оба индекса и восстановление сборки',
    () async {
      final revisions = await _revisions(root);
      final expected = await cleanup.preview();
      expect(expected.map((entry) => entry.relativePath), [
        path.join('builds', 'revisions', '${'c' * 32}.xml'),
      ]);
      final result = await cleanup.apply(expected.toSet());
      expect(result.skipped, isEmpty);
      expect(await revisions.orphan.exists(), isFalse);
      final library = BuildLibrary(root);
      expect(await library.read('d' * 32), 'current');
      await File(path.join(library.root.path, 'index.json')).writeAsString('{');
      expect(await library.read('d' * 32), 'backup');
    },
  );

  for (final index in ['index.json', 'index.json.bak']) {
    test('Повреждённый $index запрещает удалять ревизии', () async {
      final revisions = await _revisions(root);
      final oldPlan = await cleanup.preview();
      await _file(BuildLibrary(root).root, index, '{');
      expect(await cleanup.preview(), isEmpty);
      expect((await cleanup.apply(oldPlan.toSet())).bytes, 0);
      expect(await revisions.current.exists(), isTrue);
      expect(await revisions.backup.exists(), isTrue);
      expect(await revisions.orphan.exists(), isTrue);
    });
  }
}

Future<Installation> _component(Directory root) async {
  final directory = Directory(path.join(root.path, 'versions', 'pob-obsolete'));
  await _file(directory, 'пакет.bin', 'payload');
  final item = Installation(
    tag: 'v0.6.0',
    commit: _commit,
    directory: directory.path,
  );
  await recordComponent(directory, Component.pob, item);
  return item;
}

Future<({File current, File backup, File orphan})> _revisions(
  Directory root,
) async {
  final library = BuildLibrary(root);
  final folder = Directory(path.join(library.root.path, 'revisions'));
  final current = await _file(folder, '${'a' * 32}.xml', 'current');
  final backup = await _file(folder, '${'b' * 32}.xml', 'backup');
  final orphan = await _file(folder, '${'c' * 32}.xml', 'orphan');
  await library.writeIndex(_index('b'), backup: false);
  await library.writeIndex(_index('a'));
  return (current: current, backup: backup, orphan: orphan);
}

LibraryState _index(String revision) => LibraryState(
  activeId: 'd' * 32,
  entries: [
    LibraryEntry(
      id: 'd' * 32,
      title: 'Ведьма',
      characterClass: 'Witch',
      level: 90,
      updated: DateTime.utc(2026),
      revision: revision * 32,
    ),
  ],
);

Future<File> _file(Directory directory, String name, String text) async {
  await directory.create(recursive: true);
  return File(path.join(directory.path, name)).writeAsString(text);
}
