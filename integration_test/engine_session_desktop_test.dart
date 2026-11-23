import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/engine_session_client.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/domain/engine_session.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/core/app_text.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workspace_view.dart';

import '../test/support/engine_mcp_peer.dart';
import '../test/support/temporary_directory.dart';

const _fixture = 'integration_test/fixtures/witch_fireball.xml';
const _initial = 'Fireball';
const _fromMcp = 'Переименовано через MCP';
const _fromUi = 'Переименовано в PoB II';
const _profile = 'desktop-test';
const _session = 'fireball';
const _ringSlot = 'Ring 1';
const _ringText =
    'Rarity: NORMAL\nLazuli Ring\nImplicits: 1\n+25 to maximum Mana';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PoB II и MCP правят одну XML-сборку через gRPC', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final executable = Platform.environment['POB2_ENGINE_TEST_EXECUTABLE'];
    if (executable == null ||
        !Platform.environment.containsKey('POB2_UI_HOME')) {
      throw StateError('Задайте POB2_ENGINE_TEST_EXECUTABLE и POB2_UI_HOME');
    }
    final root = await Directory.systemTemp.createTemp('pob2-shared-desktop-');
    addTearDown(() => removeTemporaryDirectory(root));
    final original = await File(_fixture).readAsString();
    final model = await _openBuild(root);
    final flags = _profileFlags(root);
    addTearDown(() => _stopEngine(executable, flags, root));
    addTearDown(model.close);
    await model.initialize();
    expect(model.state.error, isNull);
    expect(model.state.report, isNotNull);
    await _seedEngine(executable, flags);
    await tester.pumpWidget(PobApp(model: model));
    await tester.pumpAndSettle();

    await _connect(tester, executable);
    await _waitForHeading(tester, model, _initial, 1);
    final mcp = await _attachMcp(executable, flags);
    await mcp.call('rename_build', {
      'build_name': _fromMcp,
      'expected_revision': 1,
      'request_id': 'desktop-mcp',
    });
    await _waitForHeading(tester, model, _fromMcp, 2);
    expect(model.state.library.activeId, '$_fromMcp.xml');

    await _renameFromUi(tester);
    await _waitForHeading(tester, model, _fromUi, 3);
    final snapshot = await mcp.call('get_snapshot');
    expect(snapshot['build_name'], _fromUi);
    expect(snapshot['revision'], 3);
    expect((snapshot['build'] as Map<String, dynamic>)['xml'], isNotEmpty);
    expect((await model.library.load()).active?.title, _fromUi);
    expect(model.state.error, isNull);

    final local = File.fromUri(root.uri.resolve('builds/$_fromUi.xml'));
    final localBefore = await local.readAsString();
    await _openSharedBuild(tester);
    await _editSharedLevel(mcp, 42, 3);
    await _waitFor(tester, find.text('Уровень персонажа: 42'));

    await _openLevelEditor(tester);
    await _editSharedLevel(mcp, 43, 4);
    await _submitLevel(tester, 44);
    await _waitFor(tester, find.byKey(const Key('engine-build-error')));
    expect(find.textContaining('Сборка изменилась'), findsOneWidget);
    await _waitFor(tester, find.text('Уровень персонажа: 43'));

    await _openLevelEditor(tester);
    await _submitLevel(tester, 44);
    await _waitFor(tester, find.text('Уровень персонажа: 44'));
    expect(_level(await mcp.call('get_snapshot')), 44);

    await tester.tap(find.byKey(const Key('engine-calculate')));
    await _waitFor(tester, find.byKey(const Key('engine-build-life')));
    final calculated =
        (await mcp.call('get_snapshot'))['build'] as Map<String, dynamic>;
    _checkCalculation(tester, calculated);
    final checkSupport =
        Platform.environment['POB2_ENGINE_TEST_SUPPORT'] == '1';
    final revision = checkSupport ? await _checkSupports(tester, mcp) : 7;
    if (checkSupport) {
      await _previewSupport(tester, 'Rapid Attacks I', compatible: false);
    }
    await mcp.close();
    await _checkReconnect(model, executable, flags, root, revision);
    if (checkSupport) await _checkStalePreviewAfterReconnect(tester);
    await _waitFor(tester, find.byKey(const Key('engine-build-life')));

    if (Platform.environment['POB2_ENGINE_TEST_EQUIPMENT'] == '1') {
      final equipmentMcp = await _attachMcp(executable, flags);
      await _checkEquipment(tester, equipmentMcp);
      await equipmentMcp.close();
    }
    expect(await local.readAsString(), localBefore);
    expect(await File(_fixture).readAsString(), original);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 3)));
}

Future<int> _checkSupports(WidgetTester tester, EngineMcpPeer mcp) async {
  await _previewSupport(tester, 'Controlled Destruction');
  expect((await mcp.call('get_snapshot'))['revision'], 7);
  await tester.tap(find.byKey(const Key('engine-support-cancel')));
  await tester.pumpAndSettle();
  expect((await mcp.call('get_snapshot'))['revision'], 7);

  await _previewSupport(tester, 'Controlled Destruction');
  await _editSharedLevel(mcp, 45, 7);
  await _waitFor(
    tester,
    find.text('Выполните предпросмотр для текущей ревизии'),
  );
  final apply = find.byKey(const Key('engine-support-apply'));
  expect(tester.widget<FilledButton>(apply).onPressed, isNull);
  await tester.tap(find.byKey(const Key('engine-support-preview')));
  await tester.pump();
  await _waitFor(tester, find.text('PoB подтвердил совместимость'));
  await tester.tap(apply);
  await _waitFor(tester, _groupGem('Controlled Destruction'));
  final added = await mcp.call('get_snapshot');
  expect(added['revision'], 9);
  expect(_xml(added), contains('ControlledDestruction'));
  expect(_xml(added), contains('mainActiveSkill="2"'));
  expect(find.byKey(const Key('engine-build-life')), findsNothing);
  return _checkSupportFromMcp(tester, mcp);
}

Future<void> _previewSupport(
  WidgetTester tester,
  String support, {
  bool compatible = true,
}) async {
  await tester.tap(find.byKey(const Key('engine-open-support')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('engine-support-query')),
    support,
  );
  await tester.tap(find.byKey(const Key('engine-support-search')));
  await _waitFor(tester, find.byKey(const Key('engine-support-gem')));
  await tester.tap(find.byKey(const Key('engine-support-preview')));
  await _waitFor(tester, find.byKey(const Key('engine-support-result')));
  expect(
    find.text(
      compatible
          ? 'PoB подтвердил совместимость'
          : 'PoB не подтвердил совместимость поддержки',
    ),
    findsOneWidget,
  );
}

Future<void> _checkStalePreviewAfterReconnect(WidgetTester tester) async {
  await _waitFor(
    tester,
    find.text('Выполните предпросмотр для текущей ревизии'),
  );
  await tester.tap(find.byKey(const Key('engine-support-cancel')));
  await tester.pumpAndSettle();
}

Future<int> _checkSupportFromMcp(WidgetTester tester, EngineMcpPeer mcp) async {
  await mcp.call('edit_build', {
    'edit': {
      'add_support': {'support_id': 'Concentrated Area', 'quality': 20},
    },
    'expected_revision': 9,
    'request_id': 'desktop-mcp-support',
  });
  await _waitFor(tester, _groupGem('Concentrated Area'));
  await tester.tap(find.byKey(const Key('engine-calculate')));
  await _waitFor(tester, find.byKey(const Key('engine-build-dps')));
  final snapshot = await mcp.call('get_snapshot');
  expect(snapshot['revision'], 11);
  _checkCalculation(tester, snapshot['build'] as Map<String, dynamic>);
  return 11;
}

Future<void> _checkEquipment(WidgetTester tester, EngineMcpPeer mcp) async {
  final before = await mcp.call('get_snapshot');
  await _openEquipment(tester);
  await _previewEquipment(tester, _ringText);
  expect(await mcp.call('get_snapshot'), before);
  await tester.tap(find.byKey(const Key('engine-equipment-cancel')));
  await tester.pumpAndSettle();
  expect(await mcp.call('get_snapshot'), before);

  await _openEquipment(tester);
  final input = find.byKey(const Key('engine-equipment-text'));
  await tester.enterText(input, 'Rarity: NORMAL\nUnknown test base');
  await tester.pump();
  await tester.tap(find.byKey(const Key('engine-equipment-preview')));
  await tester.pump();
  await _waitFor(tester, find.textContaining('не распознал базу'));
  await _previewEquipment(tester, _ringText);
  await _editSharedLevel(mcp, 46, before['revision'] as int);
  await _waitFor(
    tester,
    find.text('Выполните предпросмотр для текущей ревизии'),
  );
  final apply = find.byKey(const Key('engine-equipment-apply'));
  expect(tester.widget<FilledButton>(apply).onPressed, isNull);
  await tester.tap(find.byKey(const Key('engine-equipment-preview')));
  await tester.pump();
  await _waitForEquipmentPreview(tester);
  await tester.tap(apply);
  await _waitFor(tester, _equippedRing('Lazuli Ring'));
  final applied = await mcp.call('get_snapshot');
  expect(_xml(applied), contains('Lazuli Ring'));
  final build = applied['build'] as Map<String, dynamic>;
  expect(build['calculation'], isNull);
  await _removeEquipment(tester, mcp, applied['revision'] as int);
}

Future<void> _openEquipment(WidgetTester tester) async {
  const slotKey = Key('engine-equipment-slot-$_ringSlot');
  final slot = find.byKey(slotKey);
  if (slot.evaluate().isEmpty) {
    final section = find.byKey(const Key('engine-equipment'));
    await tester.ensureVisible(section);
    await tester.tap(section);
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(slot);
  await tester.tap(slot);
  await tester.pumpAndSettle();
}

Finder _equippedRing(String name) => find.descendant(
  of: find.byKey(const Key('engine-equipment-slot-$_ringSlot')),
  matching: find.byWidgetPredicate(
    (widget) => widget is AppText && widget.data == name,
  ),
);

Future<void> _previewEquipment(WidgetTester tester, String raw) async {
  final input = find.byKey(const Key('engine-equipment-text'));
  await tester.ensureVisible(input);
  await tester.tap(input);
  await tester.pumpAndSettle();
  await tester.enterText(input, raw);
  await tester.pumpAndSettle();
  expect(tester.widget<TextField>(input).controller!.text, raw);
  final preview = find.byKey(const Key('engine-equipment-preview'));
  expect(tester.widget<TextButton>(preview).onPressed, isNotNull);
  await tester.tap(preview);
  await tester.pump();
  await _waitForEquipmentPreview(tester);
}

Future<void> _waitForEquipmentPreview(WidgetTester tester) async {
  const resultKey = Key('engine-equipment-result');
  const errorKey = Key('engine-equipment-error');
  await _waitFor(
    tester,
    find.byWidgetPredicate(
      (widget) => widget.key == resultKey || widget.key == errorKey,
    ),
  );
  final error = find.byKey(errorKey);
  if (error.evaluate().isNotEmpty) fail(tester.widget<AppText>(error).data);
}

Future<void> _removeEquipment(
  WidgetTester tester,
  EngineMcpPeer mcp,
  int revision,
) async {
  await _openEquipment(tester);
  await tester.tap(find.byKey(const Key('engine-equipment-remove')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('engine-equipment-preview')));
  await tester.pump();
  await _waitForEquipmentPreview(tester);
  await tester.tap(find.byKey(const Key('engine-equipment-apply')));
  await _waitFor(tester, _equippedRing('—'));

  await mcp.call('edit_build', {
    'edit': {
      'equipment': {'slot': _ringSlot, 'raw': 'Rarity: NORMAL\nIron Ring'},
    },
    'expected_revision': revision + 1,
    'request_id': 'desktop-mcp-ring',
  });
  await _waitFor(tester, _equippedRing('Iron Ring'));
  await tester.tap(find.byKey(const Key('engine-calculate')));
  await _waitFor(tester, find.byKey(const Key('engine-build-life')));
  final saved = await mcp.call('get_snapshot');
  _checkCalculation(tester, saved['build'] as Map<String, dynamic>);
}

String _xml(Map<String, dynamic> snapshot) =>
    (snapshot['build'] as Map<String, dynamic>)['xml'] as String;

Finder _groupGem(String name) => find.descendant(
  of: find.byKey(const Key('engine-build-gems')),
  matching: find.byWidgetPredicate(
    (widget) => widget is AppText && widget.data == name,
  ),
);

Future<WorkshopCubit> _openBuild(Directory root) async {
  final builds = await Directory.fromUri(root.uri.resolve('builds/')).create();
  await File(_fixture).copy(builds.uri.resolve('$_initial.xml').toFilePath());
  await File.fromUri(
    InstallationStore.defaultRoot().uri.resolve('components.json'),
  ).copy(root.uri.resolve('components.json').toFilePath());
  final library = PobBuildLibrary(root);
  await library.configure(builds.path);
  await library.activate('$_initial.xml');
  return WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    McpClient(),
    library: library,
    openEngineSession: (options) => EngineSessionClient.open(
      EngineOptions(
        executable: options.executable,
        profile: options.profile,
        sessionId: options.sessionId,
        runtimeDirectory: root.path,
        dataDirectory: root.path,
      ),
    ),
  );
}

List<String> _profileFlags(Directory root) => [
  '--profile',
  _profile,
  '--runtime-dir',
  root.path,
  '--data-dir',
  root.path,
];

Future<void> _seedEngine(String executable, List<String> flags) async {
  final result = await Process.run(
    executable,
    [
      'session',
      'create',
      '--name',
      _initial,
      '--request-id',
      'desktop-create',
      '--file',
      _fixture,
      ...flags,
      '--session',
      _session,
      '--start-server',
    ],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  expect(result.exitCode, 0, reason: '${result.stderr}');
  final snapshot = jsonDecode(result.stdout as String) as Map<String, dynamic>;
  expect(snapshot['revision'], 1);
  expect((snapshot['build'] as Map<String, dynamic>)['input_revision'], 1);
}

Future<EngineMcpPeer> _attachMcp(String executable, List<String> flags) async {
  final process = await Process.start(executable, [
    'mcp',
    '--attach',
    _session,
    ...flags,
  ]);
  final mcp = EngineMcpPeer(process);
  addTearDown(mcp.close);
  await mcp.initialize();
  return mcp;
}

Future<void> _stopEngine(
  String executable,
  List<String> flags,
  Directory root, {
  bool allowReconnect = false,
}) async {
  final record = File.fromUri(
    root.uri.resolve('pob2-engine/$_profile/connection.json'),
  );
  final previous = await _serverInstance(record);
  if (previous == null) return;
  final shutdown = await Process.run(executable, ['shutdown', ...flags]);
  if (shutdown.exitCode != 0 && await _serverInstance(record) == previous) {
    throw StateError(
      'Не удалось запросить остановку сервера: ${shutdown.stderr}',
    );
  }
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (DateTime.now().isBefore(deadline)) {
    final current = await _serverInstance(record);
    if (current == null || (allowReconnect && current != previous)) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  throw StateError('Сервер $previous не завершился после отключения клиентов');
}

Future<String?> _serverInstance(File record) async {
  try {
    final data =
        jsonDecode(await record.readAsString()) as Map<String, dynamic>;
    return data['instance_id'] as String;
  } on PathNotFoundException {
    return null;
  }
}

Future<void> _connect(WidgetTester tester, String executable) async {
  await tester.tap(find.byKey(const Key('engine-session-settings')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('engine-executable')),
    executable,
  );
  await tester.enterText(find.byKey(const Key('engine-profile')), _profile);
  await tester.enterText(find.byKey(const Key('engine-session-id')), _session);
  await tester.tap(find.byKey(const Key('engine-connect')));
}

Future<void> _waitForHeading(
  WidgetTester tester,
  WorkshopCubit model,
  String name,
  int revision,
) async {
  final heading = _heading(name);
  final status = find.textContaining('$name · ревизия $revision');
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 50));
    if (heading.evaluate().isNotEmpty && status.evaluate().isNotEmpty) return;
  }
  fail(
    'Не появилось имя $name на ревизии $revision. '
    'Сессия: ${model.engineSession.state.message}. Приложение: ${model.state.error}',
  );
}

Future<void> _renameFromUi(WidgetTester tester) async {
  await tester.tap(_heading(_fromMcp));
  await tester.pumpAndSettle();
  final dialog = find.byType(AlertDialog);
  expect(dialog, findsOneWidget);
  await tester.enterText(
    find.descendant(of: dialog, matching: find.byType(TextField)),
    _fromUi,
  );
  await tester.tap(
    find.descendant(of: dialog, matching: find.byType(FilledButton)),
  );
}

Finder _heading(String name) => find
    .descendant(of: find.byType(WorkspaceView), matching: find.text(name))
    .hitTestable();

Future<void> _openSharedBuild(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('engine-session-settings')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('engine-open-build')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('engine-build-level')), findsOneWidget);
}

Future<void> _editSharedLevel(
  EngineMcpPeer mcp,
  int level,
  int revision,
) async {
  await mcp.call('edit_build', {
    'edit': {
      'level': {'level': level},
    },
    'expected_revision': revision,
    'request_id': 'mcp-level-$level',
  });
}

Future<void> _openLevelEditor(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('engine-edit-level')));
  await tester.pumpAndSettle();
}

Future<void> _submitLevel(WidgetTester tester, int level) async {
  await tester.enterText(find.byKey(const Key('engine-level-input')), '$level');
  await tester.tap(find.byKey(const Key('engine-save-level')));
}

int _level(Map<String, dynamic> snapshot) =>
    ((snapshot['build'] as Map<String, dynamic>)['model']
            as Map<String, dynamic>)['level']
        as int;

void _checkCalculation(WidgetTester tester, Map<String, dynamic> build) {
  final calculation = build['calculation'] as Map<String, dynamic>;
  final life = (calculation['stats'] as Map<String, dynamic>)['Life'] as num;
  expect(life, greaterThan(0));
  expect(build['calculated_from_revision'], build['input_revision']);
  expect(find.text('Жизнь: ${life.toStringAsFixed(0)}'), findsOneWidget);
  for (final issue in calculation['issues'] as List<dynamic>? ?? const []) {
    expect(
      find.text((issue as Map<String, dynamic>)['message'] as String),
      findsWidgets,
    );
  }
}

Future<void> _checkReconnect(
  WorkshopCubit model,
  String executable,
  List<String> flags,
  Directory root,
  int revision,
) async {
  final lost = model.engineSession.stream.firstWhere(
    (state) => !state.connected,
  );
  await _stopEngine(executable, flags, root, allowReconnect: true);
  await lost.timeout(const Duration(seconds: 12));
  if (!model.engineSession.state.connected) {
    await model.engineSession.stream
        .firstWhere((state) => state.connected)
        .timeout(const Duration(seconds: 15));
  }
  expect(model.engineSession.state.snapshot?.revision, revision);
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}
