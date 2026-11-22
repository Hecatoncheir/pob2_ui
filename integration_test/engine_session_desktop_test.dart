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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PoB II и MCP правят одну XML-сборку через gRPC', (tester) async {
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
    await mcp.close();
    await _checkReconnect(tester, model, executable, flags, root);

    expect(await local.readAsString(), localBefore);
    expect(await File(_fixture).readAsString(), original);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 3)));
}

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
  Directory root,
) async {
  await Process.run(executable, ['shutdown', ...flags]);
  final record = File.fromUri(
    root.uri.resolve('pob2-engine/$_profile/connection.json'),
  );
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (await record.exists()) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Сервер не завершился после отключения клиентов');
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
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
  WidgetTester tester,
  WorkshopCubit model,
  String executable,
  List<String> flags,
  Directory root,
) async {
  final lost = model.engineSession.stream.firstWhere(
    (state) => !state.connected,
  );
  await _stopEngine(executable, flags, root);
  await lost.timeout(const Duration(seconds: 12));
  if (!model.engineSession.state.connected) {
    await model.engineSession.stream
        .firstWhere((state) => state.connected)
        .timeout(const Duration(seconds: 15));
  }
  expect(model.engineSession.state.snapshot?.revision, 7);
  await _waitFor(tester, find.byKey(const Key('engine-build-life')));
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}
