import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/managed_installation.dart';
import 'package:pob2_ui/data/native_runtime_installer.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/domain/component.dart';

import 'support/temporary_directory.dart';

const oldPob = Installation(tag: 'v1', commit: 'old-pob', directory: 'old-pob');
const oldMcp = Installation(tag: 'v1', commit: 'old-mcp', directory: 'old-mcp');
const previousPob = Installation(
  tag: 'v0',
  commit: 'previous-pob',
  directory: 'previous-pob',
);
const previousMcp = Installation(
  tag: 'v0',
  commit: 'previous-mcp',
  directory: 'previous-mcp',
);
const _activePair = {Component.pob: oldPob, Component.mcp: oldMcp};
const _previousPair = {Component.pob: previousPob, Component.mcp: previousMcp};

Map<Component, Map<String, dynamic>> _versions(Installations pair) => pair.map(
  (component, installation) => MapEntry(component, installation.toJson()),
);

Map<Component, Release> _releases({String pob = 'v2', String mcp = 'v2'}) => {
  Component.pob: Release(pob, '', DateTime.utc(2026)),
  Component.mcp: Release(mcp, '', DateTime.utc(2026)),
};

void _ignoreLog(String _) {}

class FailingProcesses extends ProcessService {
  @override
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) async => throw ProcessException(executable, arguments, 'Нет сети', 1);

  @override
  Future<String> python() async => 'python';
}

class _NativeRuntime extends NativeRuntimeInstaller {
  final tags = <String>[];

  @override
  Future<void> install(
    Directory candidate,
    String tag,
    ProcessService processes,
    void Function(String) log,
  ) async => tags.add(tag);
}

class _PairProcesses extends ProcessService {
  final _components = <String, Component>{};
  final _tags = {
    for (final installation in [..._activePair.values, ..._previousPair.values])
      installation.directory: installation.tag,
  };
  final checks = <(String?, String?)>[];
  final revisions = <String, String>{};
  final downloadedRevisions = <Component, String>{};
  Component? failDownload;

  @override
  Future<String> python() async => 'python';

  @override
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) {
    if (executable == 'git') {
      return _git(arguments[1], arguments.sublist(2));
    }
    if (arguments.contains('doctor')) {
      final pob = arguments[arguments.indexOf('--pob-dir') + 1];
      final pair = (_tags[pob], _tags[directory]);
      checks.add(pair);
      return Future.value(
        '{"ok": ${pair.$1 != null && pair.$1 == pair.$2}, "classes": 8}',
      );
    }
    return Future.value('');
  }

  Future<String> _git(String directory, List<String> arguments) async {
    switch (arguments.first) {
      case 'remote':
        _components[directory] = Component.values.singleWhere(
          (component) => arguments.last == '${component.url}.git',
        );
      case 'fetch':
        if (_components[directory] == failDownload) {
          throw ProcessException('git', arguments, 'Нет сети', 1);
        }
        _tags[directory] = arguments.last.split('/').last;
      case 'checkout':
        await _writeSources(Directory(directory), _components[directory]!);
      case 'rev-parse':
        if (revisions[directory] case final revision?) return revision;
        final component = _components[directory]!;
        return downloadedRevisions[component] ??
            '${component.name}-${_tags[directory]}';
    }
    return '';
  }

  Future<void> _writeSources(Directory directory, Component component) async {
    final paths = switch (component) {
      Component.pob => [
        'src/Launch.lua',
        'runtime/lua/dkjson.lua',
        'src/Modules/Main.lua',
        'runtime/lua51.dll',
      ],
      Component.mcp => ['run.py', 'pob_poe2_mcp/server.py'],
    };
    for (final path in paths) {
      await File.fromUri(directory.uri.resolve(path)).create(recursive: true);
    }
  }
}

void main() {
  late Directory temporary;
  late InstallationStore store;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('pob2-ui-test-');
    store = InstallationStore(temporary);
  });
  tearDown(() => removeTemporaryDirectory(temporary));

  test(
    'Повторное сохранение заменяет активную пару и сохраняет предыдущую',
    () async {
      const nextPob = Installation(
        tag: 'v2',
        commit: 'next',
        directory: 'next',
      );
      final old = {Component.pob: oldPob, Component.mcp: oldMcp};
      await store.save(old, {});
      await store.save({...old, Component.pob: nextPob}, old);
      final reopened = InstallationStore(temporary);
      final current = await reopened.load();
      expect(current[Component.pob]!.commit, 'next');
      expect(reopened.previous[Component.pob]!.commit, 'old-pob');
      expect(current[Component.mcp]!.commit, 'old-mcp');
    },
  );

  test('Сбой загрузки сохраняет рабочую пару на диске', () async {
    await store.save({Component.pob: oldPob, Component.mcp: oldMcp}, {});
    final repository = ComponentRepository(
      store: store,
      processes: FailingProcesses(),
    );
    await repository.load();
    await expectLater(
      repository.install(
        Component.pob,
        Release('v2', '', DateTime.utc(2026)),
        (_) {},
      ),
      throwsA(isA<ProcessException>()),
    );
    final current = await store.load();
    expect(current[Component.pob]!.commit, 'old-pob');
    expect(repository.active[Component.pob]!.commit, 'old-pob');
  }, skip: !Platform.isWindows);

  test('Неудачная проверка отката сохраняет активную пару', () async {
    await store.save(
      {Component.pob: oldPob, Component.mcp: oldMcp},
      {Component.pob: oldPob, Component.mcp: oldMcp},
    );
    final repository = ComponentRepository(
      store: store,
      processes: FailingProcesses(),
    );
    await repository.load();
    await expectLater(repository.rollback(), throwsA(isA<ProcessException>()));
    expect((await store.load())[Component.pob]!.commit, 'old-pob');
  });

  group('Обновление пары компонентов', () {
    late _PairProcesses processes;
    late _NativeRuntime runtime;
    late ComponentRepository repository;

    setUp(() async {
      await store.save(_activePair, _previousPair);
      processes = _PairProcesses();
      runtime = _NativeRuntime();
      repository = ComponentRepository(
        store: store,
        processes: processes,
        runtimeInstaller: runtime,
      );
      await repository.load();
    });

    Future<void> expectWorkingVersions([
      Installations current = _activePair,
    ]) async {
      final reopened = InstallationStore(temporary);
      expect(_versions(await reopened.load()), _versions(current));
      expect(_versions(reopened.previous), _versions(_previousPair));
      expect(_versions(repository.active), _versions(current));
      expect(_versions(store.previous), _versions(_previousPair));
    }

    test('Две новые версии проверяются и активируются вместе', () async {
      final releases = _releases();
      for (final component in Component.values) {
        await expectLater(
          repository.install(component, releases[component]!, _ignoreLog),
          throwsStateError,
        );
      }
      await expectWorkingVersions();

      var validated = false;
      final stages = <ComponentInstallStage>[];
      await repository.installPair(
        releases,
        _ignoreLog,
        onStage: stages.add,
        validate: (candidate) async {
          expect(candidate.values.map((item) => item.tag), ['v2', 'v2']);
          await expectWorkingVersions();
          validated = true;
        },
      );
      expect(validated, isTrue);
      expect(stages, ComponentInstallStage.values);
      expect(processes.checks, [('v2', 'v1'), ('v1', 'v2'), ('v2', 'v2')]);
      expect(repository.active[Component.pob]!.commit, 'pob-v2');
      expect(repository.active[Component.mcp]!.commit, 'mcp-v2');
      final reopened = InstallationStore(temporary);
      expect(_versions(await reopened.load()), _versions(repository.active));
      expect(_versions(reopened.previous), _versions(_activePair));
    });

    test('Сбой загрузки второго компонента оставляет рабочую пару', () async {
      processes.failDownload = Component.mcp;
      await expectLater(
        repository.installPair(_releases(), _ignoreLog),
        throwsA(isA<ProcessException>()),
      );
      expect(processes.checks, isEmpty);
      await expectWorkingVersions();
    });

    test(
      'Пара с совпавшими SHA устанавливается и используется повторно',
      () async {
        const expected = {
          Component.pob: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          Component.mcp: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        };
        processes.downloadedRevisions.addAll(expected);
        final releases = {
          for (final entry in expected.entries)
            entry.key: Release(
              'v2',
              '',
              DateTime.utc(2026),
              expectedCommit: entry.value,
            ),
        };
        await repository.installPair(releases, _ignoreLog);
        await repository.installPair(releases, _ignoreLog);

        for (final entry in expected.entries) {
          expect(repository.active[entry.key]!.commit, entry.value);
        }
        expect(runtime.tags, ['v2']);
        expect(processes.checks, [('v2', 'v2')]);
        expect(_versions(store.previous), _versions(_activePair));
      },
    );

    test(
      'Изменённый тег MCP отклоняется до установки runtime и запуска Lua',
      () async {
        processes.downloadedRevisions[Component.mcp] =
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        final releases = {
          ..._releases(),
          Component.mcp: Release(
            'v2',
            '',
            DateTime.utc(2026),
            expectedCommit: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          ),
        };
        await expectLater(
          repository.installPair(releases, _ignoreLog),
          throwsStateError,
        );
        expect(runtime.tags, isEmpty);
        expect(processes.checks, isEmpty);
        await expectWorkingVersions();
      },
    );

    test('Записанный SHA сверяется с HEAD установленного компонента', () async {
      const pinnedPob = Installation(
        tag: 'v1',
        commit: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        directory: 'old-pob',
      );
      const pinnedMcp = Installation(
        tag: 'v1',
        commit: 'dddddddddddddddddddddddddddddddddddddddd',
        directory: 'old-mcp',
      );
      const current = {Component.pob: pinnedPob, Component.mcp: pinnedMcp};
      await store.save(current, _previousPair);
      await repository.load();
      processes.revisions[oldPob.directory] =
          'cccccccccccccccccccccccccccccccccccccccc';
      processes.revisions[oldMcp.directory] = pinnedMcp.commit;
      final releases = {
        for (final entry in current.entries)
          entry.key: Release(
            entry.value.tag,
            '',
            DateTime.utc(2026),
            expectedCommit: entry.value.commit,
          ),
      };
      await expectLater(
        repository.installPair(releases, _ignoreLog),
        throwsStateError,
      );
      expect(runtime.tags, isEmpty);
      expect(processes.checks, isEmpty);
      await expectWorkingVersions(current);
    });

    test('Несовместимая пара остаётся неактивной', () async {
      await expectLater(
        repository.installPair(_releases(mcp: 'v3'), _ignoreLog),
        throwsStateError,
      );
      expect(processes.checks, [('v2', 'v3')]);
      await expectWorkingVersions();
    });

    test('Отказ проверки сборки сохраняет обе прежние пары', () async {
      await expectLater(
        repository.installPair(
          _releases(),
          _ignoreLog,
          validate: (_) async => throw StateError('Сборка не открылась'),
        ),
        throwsStateError,
      );
      expect(processes.checks, [('v2', 'v2')]);
      await expectWorkingVersions();
    });

    test('Откат ждёт успешной проверки открытой сборки', () async {
      await expectLater(
        repository.rollback(
          validate: (_) async => throw StateError('Сборка не открылась'),
        ),
        throwsStateError,
      );
      await expectWorkingVersions();

      await repository.rollback(
        validate: (candidate) async {
          expect(_versions(candidate), _versions(_previousPair));
          await expectWorkingVersions();
        },
      );
      expect(processes.checks, [('v0', 'v0'), ('v0', 'v0')]);
      expect(_versions(repository.active), _versions(_previousPair));
      final reopened = InstallationStore(temporary);
      expect(_versions(await reopened.load()), _versions(_previousPair));
      expect(_versions(reopened.previous), _versions(_activePair));
    });
  }, skip: currentAppTarget() == null);
}
