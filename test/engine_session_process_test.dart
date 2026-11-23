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
import 'package:pob2_ui/domain/tree_allocation_mode.dart';
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
  final canUseWorkshop =
      executable != null && Platform.environment['POB2_UI_HOME'] != null;
  final workshopSkip = canUseWorkshop
      ? false
      : 'Нужен отдельный профиль PoB II с Lua и MCP и бинарник движка';
  test(
    'Штатное условие в общей сборке сохраняется в XML и переживает перезапуск',
    () => _checkSharedCondition(executable!),
    skip: workshopSkip,
    timeout: const Timeout(Duration(minutes: 2)),
  );
  test(
    'Штатное дерево назначает и снимает пассивы во всех режимах',
    () => _checkSharedTree(executable!),
    skip: workshopSkip,
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'Штатное дерево назначает и меняет атрибут общей сборки',
    () => _checkSharedAttributes(executable!),
    skip:
        canUseWorkshop &&
            Platform.environment['POB2_ENGINE_TEST_ATTRIBUTES'] == '1'
        ? false
        : 'Для проверки атрибутов укажите POB2_ENGINE_TEST_ATTRIBUTES=1',
    timeout: const Timeout(Duration(minutes: 2)),
  );
  test(
    'Штатное дерево редактирует пустое гнездо в общем режиме',
    () => _checkSharedSocket(executable!),
    skip:
        canUseWorkshop &&
            Platform.environment['POB2_ENGINE_TEST_SOCKETS'] == '1'
        ? false
        : 'Для проверки гнёзд укажите POB2_ENGINE_TEST_SOCKETS=1 и новый движок',
    timeout: const Timeout(Duration(minutes: 2)),
  );
  test(
    'Общая мастерская устанавливает и снимает самоцвет',
    () => _checkSharedJewel(executable!),
    skip:
        canUseWorkshop && Platform.environment['POB2_ENGINE_TEST_JEWELS'] == '1'
        ? false
        : 'Для проверки самоцветов укажите POB2_ENGINE_TEST_JEWELS=1 и новый движок',
    timeout: const Timeout(Duration(minutes: 2)),
  );
  test(
    'Спецификации общей сборки переключаются в мастерской и через MCP',
    () => _checkSharedTreeSpecs(executable!),
    skip:
        canUseWorkshop &&
            Platform.environment['POB2_ENGINE_TEST_TREE_SPECS'] == '1'
        ? false
        : 'Для проверки спецификаций укажите POB2_ENGINE_TEST_TREE_SPECS=1 и новый движок',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _checkSharedCondition(String executable) async {
  final (:model, :options, :flags, :file) = await _startWorkshop(
    executable,
    'witch_fireball',
  );
  expect(model.state.report!.config['enemyLevel'], 67);
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
  final saved = await file.readAsString();
  expect(await _cliBuildXml(executable, flags), saved);
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

typedef _SharedWorkshop = ({
  WorkshopCubit model,
  EngineOptions options,
  List<String> flags,
  File file,
});

Future<_SharedWorkshop> _startWorkshop(
  String executable,
  String fixture,
) async {
  final root = await Directory.systemTemp.createTemp('pob2-workshop-session-');
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
  final model = await _openWorkshop(root, fixture);
  addTearDown(model.close);
  await model.initialize();
  expect(model.state.error, isNull);
  await model.connectEngine(
    options,
    createName: 'Fireball',
    bindCurrentBuild: true,
    importOpenBuild: true,
  );
  return (
    model: model,
    options: options,
    flags: flags,
    file: File.fromUri(root.uri.resolve('builds/Fireball.xml')),
  );
}

const _sharedPassive = 51184;

Future<void> _checkSharedTree(String executable) async {
  final opened = await _startWorkshop(executable, 'witch_weapon_paths');
  final mcp = EngineMcpPeer(
    await Process.start(executable, [
      'mcp',
      '--attach',
      'main',
      ...opened.flags,
    ]),
  );
  addTearDown(mcp.close);
  await mcp.initialize();
  await _rejectStaleTreePreview(opened, mcp);
  for (final mode in TreeAllocationMode.values) {
    await _editWorkshopTree(opened, mcp, mode);
  }
  expect(
    await _cliBuildXml(executable, opened.flags),
    await opened.file.readAsString(),
  );
}

Future<void> _checkSharedAttributes(String executable) async {
  final opened = await _startWorkshop(executable, 'witch_fireball');
  final model = opened.model;
  const nodeId = 18407;
  expect(model.engineSession.supportsTreeAttributes, isTrue);
  final allocate = await model.previewSharedTreeNode(
    nodeId,
    action: EngineTreeAction.allocate,
    attribute: EnginePassiveAttribute.dexterity,
  );
  expect(allocate.offer.preview.added, contains(nodeId));
  final added = await model.applySharedTreeNode(allocate);
  expect(added.committed, isTrue, reason: added.error);
  final xml = await opened.file.readAsString();
  final swap = await model.previewSharedTreeNode(
    nodeId,
    action: EngineTreeAction.setAttribute,
    attribute: EnginePassiveAttribute.intelligence,
  );
  expect(swap.offer.preview.added, isEmpty);
  expect(swap.offer.preview.removed, isEmpty);
  expect(swap.offer.preview.attributes, [
    (
      nodeId: nodeId,
      before: EnginePassiveAttribute.dexterity,
      after: EnginePassiveAttribute.intelligence,
    ),
  ]);
  expect(await opened.file.readAsString(), xml);
  final applied = await model.applySharedTreeNode(swap);
  expect(applied.committed, isTrue, reason: applied.error);
  final snapshot = model.engineSession.state.snapshot!;
  expect(
    snapshot.build!.tree!.attributes[nodeId],
    EnginePassiveAttribute.intelligence,
  );
  expect(
    await _cliBuildXml(executable, opened.flags),
    await opened.file.readAsString(),
  );
}

Future<void> _checkSharedSocket(String executable) async {
  final opened = await _startWorkshop(executable, 'witch_fireball');
  final model = opened.model;
  expect(model.engineSession.supportsTreeSockets, isTrue);
  const socket = 61419;
  final mcp = EngineMcpPeer(
    await Process.start(executable, [
      'mcp',
      '--attach',
      'main',
      ...opened.flags,
    ]),
  );
  addTearDown(mcp.close);
  await mcp.initialize();
  await model.selectTreeMode(TreeAllocationMode.weaponTwo);
  final before = await mcp.call('export_build');
  final allocate = await model.previewSharedTreeNode(socket);
  expect(allocate.offer.edit.allocationMode, TreeAllocationMode.common);
  expect(allocate.offer.preview.added, contains(socket));
  expect(await mcp.call('export_build'), before);
  expect(await opened.file.readAsString(), before['xml']);
  await _applyWorkshopTree(opened, mcp, allocate, allocated: true);
  final refund = await model.previewSharedTreeNode(socket);
  expect(refund.offer.edit.allocationMode, TreeAllocationMode.common);
  expect(refund.offer.preview.removed, [socket]);
  await _applyWorkshopTree(opened, mcp, refund, allocated: false);
  expect(
    await _cliBuildXml(executable, opened.flags),
    await opened.file.readAsString(),
  );
}

const _jewelNode = 61419;
const _rubyText =
    'Rarity: RARE\nReference Ruby\nRuby\n--------\n+17% to Fire Resistance';

Future<void> _checkSharedJewel(String executable) async {
  final opened = await _startWorkshop(executable, 'witch_fireball');
  final model = opened.model;
  expect(model.canEditSharedJewel, isTrue);
  final mcp = EngineMcpPeer(
    await Process.start(executable, [
      'mcp',
      '--attach',
      'main',
      ...opened.flags,
    ]),
  );
  addTearDown(mcp.close);
  await mcp.initialize();
  await _applyWorkshopTree(
    opened,
    mcp,
    await model.previewSharedTreeNode(_jewelNode),
    allocated: true,
  );
  final fireResist = model.state.report!.stats['FireResist'] as num;
  const edit = (nodeId: _jewelNode, itemId: 0, raw: _rubyText);
  await _rejectStaleJewelPreview(opened, mcp, edit);
  final installed = await _applyWorkshopJewel(opened, mcp, edit);
  final id = model.state.report!.socketedItems[_jewelNode]!['id'] as int;
  final count = model.state.report!.items.length;
  expect(model.state.report!.stats['FireResist'], fireResist + 17);
  await _applyWorkshopJewel(opened, mcp, (
    nodeId: _jewelNode,
    itemId: 0,
    raw: '',
  ));
  expect(model.state.report!.socketedItems[_jewelNode], isNull);
  expect(model.state.report!.items.length, count);
  expect(model.state.report!.stats['FireResist'], fireResist);
  final restored = await _applyWorkshopJewel(opened, mcp, (
    nodeId: _jewelNode,
    itemId: id,
    raw: '',
  ));
  expect(restored, installed);
  expect(model.state.report!.socketedItems[_jewelNode]?['id'], id);
  expect(model.state.report!.items.length, count);
  expect(await _cliBuildXml(executable, opened.flags), restored);
}

Future<void> _rejectStaleJewelPreview(
  _SharedWorkshop opened,
  EngineMcpPeer mcp,
  EngineJewelEdit edit,
) async {
  final model = opened.model;
  final before = await mcp.call('export_build');
  final old = await model.previewSharedJewel(edit);
  final seen = model.stream.firstWhere(
    (state) => !state.busy && state.report?.config['enemyLevel'] == 68,
  );
  await mcp.call('edit_build', {
    'expected_revision': before['revision'],
    'request_id': 'jewel-outdated',
    'edit': {
      'config': {
        'name': 'enemyLevel',
        'value': {'type': 'number', 'value': '68'},
      },
    },
  });
  await seen.timeout(const Duration(seconds: 25));
  final latest = await mcp.call('export_build');
  expect(model.isCurrentSharedJewelOffer(old), isFalse);
  expect((await model.applySharedJewel(old)).committed, isFalse);
  expect(await mcp.call('export_build'), latest);
}

Future<String> _applyWorkshopJewel(
  _SharedWorkshop opened,
  EngineMcpPeer mcp,
  EngineJewelEdit edit,
) async {
  final (:model, :file, options: _, flags: _) = opened;
  final before = await mcp.call('export_build');
  final preview = await model.previewSharedJewel(edit);
  expect(await mcp.call('export_build'), before);
  expect(await file.readAsString(), before['xml']);
  final result = await model.applySharedJewel(preview);
  expect(result.committed, isTrue, reason: result.error);
  final exported = await mcp.call('export_build');
  expect(exported['revision'], preview.offer.preview.revision + 1);
  final saved = await file.readAsString();
  expect(saved, exported['xml']);
  expect(
    model.state.document!.tree!.nodes
        .singleWhere((node) => node.id == _jewelNode)
        .allocated,
    isTrue,
  );
  return saved;
}

Future<void> _checkSharedTreeSpecs(String executable) async {
  final (:model, :flags, :file, options: _) = await _startWorkshop(
    executable,
    'warrior_witch_specs',
  );
  final mcp = EngineMcpPeer(
    await Process.start(executable, ['mcp', '--attach', 'main', ...flags]),
  );
  addTearDown(mcp.close);
  await mcp.initialize();
  expect(model.state.report?.activeTreeSpec, 1);
  expect(model.state.report?.characterClass, 'Warrior');
  await _rejectStaleSpecMenu(model, mcp);
  final original = await file.readAsString();
  final result = await model.selectTreeSpec(2);
  expect(result.committed, isTrue, reason: result.error);
  expect(model.state.report?.activeTreeSpec, 2);
  expect(model.state.report?.characterClass, 'Witch');
  expect(model.state.report?.socketedItems[61419]?['id'], 2);
  expect(model.state.report?.stats['FireResist'], 27);
  expect(model.state.treeMode, TreeAllocationMode.weaponTwo);
  final selected = await mcp.call('export_build');
  expect(await file.readAsString(), selected['xml']);
  expect(selected['xml'], contains('activeSpec="2"'));
  expect(
    selected['xml'],
    contains('Обе спецификации и заметка должны сохраниться.'),
  );
  final restored = model.stream.firstWhere(
    (state) => !state.busy && state.report?.activeTreeSpec == 1,
  );
  await mcp.call('edit_build', {
    'expected_revision': selected['revision'],
    'request_id': 'spec-restore',
    'edit': {
      'selection': {
        'sets': {'tree': 1},
      },
    },
  });
  await restored.timeout(const Duration(seconds: 25));
  expect(model.state.report?.characterClass, 'Warrior');
  expect(model.state.report?.socketedItems[61419], isNull);
  expect(await file.readAsString(), original);
  expect(await _cliBuildXml(executable, flags), original);
}

Future<void> _rejectStaleSpecMenu(
  WorkshopCubit model,
  EngineMcpPeer mcp,
) async {
  await model.selectTreeMode(TreeAllocationMode.weaponTwo);
  final oldSelection = model.treeSpecSelection();
  final original = await mcp.call('export_build');
  final updated = model.stream.firstWhere(
    (state) => !state.busy && state.report?.config['enemyLevel'] == 41,
  );
  await mcp.call('edit_build', {
    'expected_revision': original['revision'],
    'request_id': 'spec-stale',
    'edit': {
      'config': {
        'name': 'enemyLevel',
        'value': {'type': 'number', 'value': '41'},
      },
    },
  });
  await updated.timeout(const Duration(seconds: 25));
  final before = await mcp.call('export_build');
  final stale = await oldSelection(2);
  expect(stale.committed, isFalse);
  expect(stale.error, contains('Сборка изменилась'));
  expect(await mcp.call('export_build'), before);
}

Future<void> _rejectStaleTreePreview(
  _SharedWorkshop opened,
  EngineMcpPeer mcp,
) async {
  final (:model, :file, options: _, flags: _) = opened;
  final before = await mcp.call('export_build');
  final old = await model.previewSharedTreeNode(_sharedPassive);
  expect(await mcp.call('export_build'), before);
  final seen = model.stream.firstWhere(
    (state) => !state.busy && state.report?.config['enemyLevel'] == 68,
  );
  await mcp.call('edit_build', {
    'expected_revision': before['revision'],
    'request_id': 'tree-outdated',
    'edit': {
      'config': {
        'name': 'enemyLevel',
        'value': {'type': 'number', 'value': '68'},
      },
    },
  });
  await seen.timeout(const Duration(seconds: 25));
  expect(model.isCurrentSharedTreeOffer(old), isFalse);
  final after = await mcp.call('export_build');
  expect((await model.applySharedTreeNode(old)).committed, isFalse);
  expect(await mcp.call('export_build'), after);
  expect(await file.readAsString(), after['xml']);
}

Future<void> _editWorkshopTree(
  _SharedWorkshop opened,
  EngineMcpPeer mcp,
  TreeAllocationMode mode,
) async {
  final (:model, :file, options: _, flags: _) = opened;
  final before = await mcp.call('export_build');
  await model.selectTreeMode(mode);
  final added = await model.previewSharedTreeNode(_sharedPassive);
  expect(added.offer.edit.allocationMode, mode);
  expect(added.offer.preview.added, contains(_sharedPassive));
  expect(added.offer.preview.points, isNotNull);
  expect(await mcp.call('export_build'), before);
  expect(await file.readAsString(), before['xml']);
  await _applyWorkshopTree(opened, mcp, added, allocated: true);
  await model.selectTreeMode(
    mode == TreeAllocationMode.common
        ? TreeAllocationMode.weaponTwo
        : TreeAllocationMode.common,
  );
  final removed = await model.previewSharedTreeNode(_sharedPassive);
  expect(removed.offer.edit.allocationMode, mode);
  expect(removed.offer.preview.removed, contains(_sharedPassive));
  await _applyWorkshopTree(opened, mcp, removed, allocated: false);
}

Future<void> _applyWorkshopTree(
  _SharedWorkshop opened,
  EngineMcpPeer mcp,
  WorkshopTreeOffer preview, {
  required bool allocated,
}) async {
  final (:model, :file, options: _, flags: _) = opened;
  final result = await model.applySharedTreeNode(preview);
  expect(result.committed, isTrue, reason: result.error);
  final node = model.state.document!.tree!.nodes.singleWhere(
    (node) => node.id == preview.offer.edit.nodeId,
  );
  expect(node.allocated, allocated);
  if (allocated)
    expect(node.allocationMode, preview.offer.edit.allocationMode!.luaValue);
  final remote = await mcp.call('export_build');
  expect(remote['revision'], preview.offer.preview.comparison.revision + 1);
  expect(await file.readAsString(), remote['xml']);
  final expected = preview.offer.preview.comparison.after.life;
  expect(expected, isNotNull);
  expect(model.state.report!.stats['Life'], expected);
}

Future<WorkshopCubit> _openWorkshop(Directory root, String fixture) async {
  final builds = await Directory.fromUri(root.uri.resolve('builds/')).create();
  await File('integration_test/fixtures/$fixture.xml')
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

Future<String> _cliBuildXml(String executable, List<String> flags) async {
  final result = await Process.run(executable, [
    'build',
    'export',
    '--session',
    'main',
    '--raw',
    ...flags,
  ], stdoutEncoding: utf8);
  expect(result.exitCode, 0, reason: '${result.stderr}');
  return result.stdout as String;
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
