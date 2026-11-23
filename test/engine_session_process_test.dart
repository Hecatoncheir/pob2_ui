import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/engine_session_client.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/domain/condition_definition.dart';
import 'package:pob2_ui/domain/engine_session.dart';
import 'package:pob2_ui/ui/condition_editor_cubit.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/engine_mcp_peer.dart';
import 'support/temporary_directory.dart';

void main() {
  final executable = Platform.environment['POB2_ENGINE_TEST_EXECUTABLE'];
  test(
    'Настоящие CLI/MCP доставляют правки Dart-клиенту, повтор и перезапуск не теряют события',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'pob2-engine-process-',
      );
      final options = EngineOptions(
        executable: executable!,
        profile: 'test',
        runtimeDirectory: root.uri.resolve('runtime').toFilePath(),
        dataDirectory: root.uri.resolve('data').toFilePath(),
      );
      final args = [
        '--profile',
        options.profile,
        '--runtime-dir',
        options.runtimeDirectory,
        '--data-dir',
        options.dataDirectory,
      ];
      addTearDown(() async {
        await Process.run(executable, ['shutdown', ...args]);
        await _waitForShutdown(options);
        await removeTemporaryDirectory(root);
      });
      var connection = await EngineSessionClient.open(options);
      addTearDown(() => connection.close());
      await connection.create('main', 'Начальная', 'create');
      final xml = await File('integration_test/fixtures/witch_fireball.xml')
          .readAsString();
      final imported = await connection.create(
        'workshop',
        'Ведьма',
        'create-with-xml',
        xml: xml,
      );
      expect(imported.revision, 1);
      expect(imported.buildName, 'Ведьма');
      expect(imported.build?.xml, contains('<PathOfBuilding2>'));
      expect(
        (await connection.snapshot('workshop')).build?.xml,
        imported.build?.xml,
      );
      var events = StreamIterator(connection.watch('main', 1));
      addTearDown(() => events.cancel());
      await _cli(executable, [
        'session',
        'rename',
        '--session',
        'main',
        '--name',
        'CLI',
        '--revision',
        '1',
        '--request-id',
        'cli',
        ...args,
      ]);
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.buildName, 'CLI');
      final process = await Process.start(executable, [
        'mcp',
        '--attach',
        'main',
        ...args,
      ]);
      final mcp = EngineMcpPeer(process);
      addTearDown(mcp.close);
      await mcp.initialize();
      final command = {
        'name': 'rename_build',
        'arguments': {
          'build_name': 'MCP',
          'expected_revision': 2,
          'request_id': 'mcp',
        },
      };
      for (var i = 0; i < 2; i++) {
        expect(
          (await mcp.request('tools/call', command))['isError'],
          isNot(true),
        );
      }
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.revision, 3);
      expect(events.current.previousName, 'CLI');
      await events.cancel();
      await connection.close();
      await _cli(executable, [
        'session',
        'rename',
        '--session',
        'main',
        '--name',
        'Пропущенная',
        '--revision',
        '3',
        '--request-id',
        'missed',
        ...args,
      ]);
      // Новый helper и новая аренда читают историю с последней применённой ревизии.
      connection = await EngineSessionClient.open(options);
      events = StreamIterator(connection.watch('main', 3));
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.buildName, 'Пропущенная');
      expect(events.current.snapshot.revision, 4);
      await events.cancel();
      await connection.close();
      await mcp.close();
      await _waitForShutdown(options);
      connection = await EngineSessionClient.open(options);
      events = StreamIterator(connection.watch('main', 3));
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.buildName, 'Пропущенная');
      expect(events.current.snapshot.revision, 4);
      await events.cancel();
      await connection.close();
    },
    skip: executable == null
        ? 'Нужен POB2_ENGINE_TEST_EXECUTABLE; CI запускает этот сценарий на Linux'
        : false,
    timeout: const Timeout(Duration(seconds: 35)),
  );
  test(
    'Штатное условие в общей сборке сохраняется в XML и переживает перезапуск',
    () => _checkSharedCondition(executable!),
    skip: executable == null || Platform.environment['POB2_UI_HOME'] == null
        ? 'Нужен отдельный профиль PoB II с Lua и MCP и бинарник движка'
        : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _checkSharedCondition(String executable) async {
  final root = await Directory.systemTemp.createTemp(
    'pob2-workshop-condition-',
  );
  final options = EngineOptions(
    executable: executable,
    profile: 'test',
    runtimeDirectory: root.uri.resolve('runtime').toFilePath(),
    dataDirectory: root.uri.resolve('data').toFilePath(),
  );
  final flags = [
    '--profile',
    options.profile,
    '--runtime-dir',
    options.runtimeDirectory,
    '--data-dir',
    options.dataDirectory,
  ];
  addTearDown(() async {
    await Process.run(executable, ['shutdown', ...flags]);
    await _waitForShutdown(options);
    await removeTemporaryDirectory(root);
  });
  final model = await _openWorkshop(root);
  addTearDown(model.close);
  await model.initialize();
  expect(model.state.error, isNull);
  expect(model.state.report!.config['enemyLevel'], 67);
  await model.connectEngine(
    options,
    createName: 'Fireball',
    bindCurrentBuild: true,
    importOpenBuild: true,
  );
  final mcp = EngineMcpPeer(
    await Process.start(executable, ['mcp', '--attach', 'main', ...flags]),
  );
  addTearDown(mcp.close);
  await mcp.initialize();
  await _editWorkshopCondition(model, mcp);
  await mcp.close();
  await model.disconnectEngine();
  await Process.run(executable, ['shutdown', ...flags]);
  await _waitForShutdown(options);
  await model.connectEngine(
    options,
    bindCurrentBuild: true,
    useSessionXml: true,
  );
  expect(model.state.report!.config['enemyLevel'], 79);
  final binaryExport = await Process.run(executable, [
    'build',
    'export',
    '--session',
    'main',
    '--raw',
    ...flags,
  ], stdoutEncoding: utf8);
  expect(binaryExport.exitCode, 0, reason: '${binaryExport.stderr}');
  final file = File.fromUri(root.uri.resolve('builds/Fireball.xml'));
  final saved = await file.readAsString();
  expect(binaryExport.stdout, saved);
  await _rejectDivergedFile(model, file, saved);
}

Future<void> _rejectDivergedFile(
  WorkshopCubit model,
  File file,
  String saved,
) async {
  final form = _conditionForm(model)..text('81');
  final external = saved.replaceFirst(
    'name="enemyLevel" number="79"',
    'name="enemyLevel" number="80"',
  );
  expect(external, isNot(saved));
  await file.writeAsString(external);
  final revision = model.engineSession.state.snapshot!.revision;
  expect(await form.save(), isFalse);
  expect(await file.readAsString(), external);
  expect(model.engineSession.state.snapshot!.revision, revision);
  expect(model.engineSession.state.snapshot!.build!.xml, saved);
}

Future<WorkshopCubit> _openWorkshop(Directory root) async {
  final builds = await Directory.fromUri(root.uri.resolve('builds/')).create();
  await File('integration_test/fixtures/witch_fireball.xml')
      .copy(builds.uri.resolve('Fireball.xml').toFilePath());
  await File.fromUri(
    InstallationStore.defaultRoot().uri.resolve('components.json'),
  ).copy(root.uri.resolve('components.json').toFilePath());
  final library = PobBuildLibrary(root);
  await library.configure(builds.path);
  await library.activate('Fireball.xml');
  return WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    McpClient(),
    library: library,
  );
}

ConditionEditorCubit _conditionForm(WorkshopCubit model) {
  final editor = ConditionEditorCubit(
    ConditionDefinition(
      id: 'enemyLevel',
      name: 'Уровень противника',
      type: 'count',
    ),
    model.state.report!.config['enemyLevel'],
    model.conditionEditorCommit(),
  );
  addTearDown(editor.close);
  return editor;
}

Future<void> _editWorkshopCondition(
  WorkshopCubit model,
  EngineMcpPeer mcp,
) async {
  final stale = _conditionForm(model);
  final afterExternal = model.stream.firstWhere(
    (state) => !state.busy && state.report?.config['enemyLevel'] == 68,
  );
  await mcp.call('edit_build', {
    'expected_revision': 1,
    'request_id': 'condition-mcp',
    'edit': {
      'config': {
        'name': 'enemyLevel',
        'value': {'type': 'number', 'value': '68'},
      },
    },
  });
  await afterExternal.timeout(const Duration(seconds: 30));
  stale.text('69');
  expect(await stale.save(), isFalse);
  expect(stale.state.error, contains('Сборка изменилась'));
  final editor = _conditionForm(model)..text('79');
  expect(await editor.save(), isTrue, reason: editor.state.error);
  expect(model.state.report!.config['enemyLevel'], 79);
  final exported = await mcp.call('export_build');
  expect(exported['xml'], contains('name="enemyLevel" number="79"'));
  final timer = Stopwatch()..start();
  while (model.engineSession.state.snapshot?.build?.calculation == null) {
    if (timer.elapsed > const Duration(seconds: 25)) {
      fail('Движок не опубликовал расчёт новой ревизии');
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  expect(
    model.engineSession.state.snapshot?.build?.calculation?.life,
    greaterThan(0),
  );
}

Future<void> _cli(String executable, List<String> args) async {
  final result = await Process.run(executable, args);
  expect(result.exitCode, 0, reason: '${result.stderr}');
}

Future<void> _waitForShutdown(EngineOptions options) async {
  final record = File.fromUri(
    Directory(options.runtimeDirectory).uri
        .resolve('pob2-engine/test/connection.json'),
  );
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (await record.exists()) {
    if (DateTime.now().isAfter(deadline))
      throw StateError('Сервер не завершился после отключения клиентов');
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}
