import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pob2_ui/data/engine_components.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/shell_bloc.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workspace_view.dart';
import 'package:xml/xml.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('MCP создаёт и правит сборки с Undo и Redo', (tester) async {
    if (!Platform.environment.containsKey('POB2_UI_HOME')) {
      throw StateError('Для проверки нужен отдельный профиль POB2_UI_HOME.');
    }
    final profile = InstallationStore.defaultRoot();
    final root = await profile.createTemp('editor-builds-');
    final components = EngineComponents(store: InstallationStore(root));
    await components.load();
    final builds = await Directory.fromUri(root.uri.resolve('builds/'))
        .create();
    final library = PobBuildLibrary(root);
    await library.configure(builds.path);
    final model = WorkshopCubit(
      components,
      WorkbenchClient(),
      library: library,
    );
    addTearDown(model.close);
    await model.initialize();
    expect(model.state.report, isNull);
    expect(model.state.error, isNull);

    await tester.pumpWidget(PobApp(model: model));
    await tester.pumpAndSettle();
    await _enable(tester);
    expect(model.mcpEditor.enabled, isTrue);
    final shell = tester.element(find.byType(WorkspaceView)).read<ShellBloc>();
    final client = await _ExternalEditor.connect(
      tester,
      root,
      components.executable,
    );
    addTearDown(client.close);
    final hasSkillControls = await _checkSkillControlSchema(client);

    await _createBuilds(tester, client, model);
    await tester.pumpAndSettle();
    await _enableFromLibrary(tester, model, shell);
    final node = await _node(client);
    await _checkNode(tester, client, model, shell, node);
    await _checkItem(tester, client, model, shell);
    await _checkSkills(tester, client, model, shell);
    final stale = await client.call('pob_tree_action', {
      'id': node,
      'action': 'refund',
    });
    expect(stale['isError'], isTrue);
    expect(
      jsonRows(stale['content']).single['text'],
      contains('STALE_REVISION'),
    );

    if (hasSkillControls) {
      await _checkSkillVariants(tester, client, model, shell);
    }
    await _checkApplicationTools(tester, client, model);
    await model.openBuild(model.state.library.entries.last.id);
    await tester.pumpAndSettle();
    expect(model.mcpEditor.enabled, isFalse);
    final disabled = await client.call('pob_check_build');
    expect(disabled['isError'], isTrue);
    expect(
      jsonRows(disabled['content']).single['text'],
      contains('EDITOR_DISABLED'),
    );
  }, timeout: const Timeout(Duration(minutes: 10)));
}

Future<void> _checkApplicationTools(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
) async {
  await tester.tap(find.byKey(const Key('mcp-editor-settings')));
  await tester.pumpAndSettle();
  final opened = await client.success('pob_editor_status');
  expect(opened['dialogOpen'], isTrue);
  expect(opened['canCloseDialog'], isTrue);
  await client.success('pob_check_build');
  await client.success('pob_editor_app', {'action': 'close_dialog'});
  await tester.pumpAndSettle();
  expect((await client.success('pob_editor_status'))['dialogOpen'], isFalse);
  await _checkProtectedDialog(tester, client);
  await _checkDpsDialog(tester, client);

  await client.success('pob_editor_library', {
    'action': 'rename',
    'title': 'Расширенный MCP',
  });
  final id = model.state.library.activeId;
  await client.success('pob_editor_notes', {
    'action': 'write',
    'text': 'Кириллица: раскалывающая смесь ✓',
  });
  expect(
    (await client.success('pob_editor_notes', {'action': 'read'}))['text'],
    contains('Кириллица'),
  );
  final xml = await client.success('pob_editor_files', {
    'action': 'export_xml',
  });
  expect(xml['xml'], contains('Кириллица'));
  final code = await client.success('pob_editor_files', {
    'action': 'export_code',
  });
  expect(code['code'], isNotEmpty);
  await _checkNinjaProfileImport(client, model);
  await client.success('pob_editor_library', {'action': 'copy'});
  expect(model.state.library.activeId, isNot(id));
  expect(model.mcpEditor.enabled, isTrue);
  await client.success('pob_editor_library', {'action': 'open', 'id': id});
  expect(model.state.library.activeId, id);

  final history = await client.success('pob_editor_history', {
    'action': 'status',
  });
  if ((history['undo'] as int) > 0) {
    await client.success('pob_editor_history', {'action': 'undo'});
    await client.success('pob_editor_history', {'action': 'redo'});
  }
  await client.success('pob_editor_progression', {
    'action': 'capture',
    'title': 'Первый этап',
  });
  final plan = await client.success('pob_editor_progression', {
    'action': 'update',
    'index': 0,
    'completed': true,
  });
  expect(jsonRows(plan['steps']).first['completed'], isTrue);
  await client.success('pob_editor_progression', {
    'action': 'apply',
    'index': 0,
    'parts': ['tree', 'skills', 'equipment'],
  });
  await client.success('pob_editor_progression', {
    'action': 'delete',
    'index': 0,
  });

  await client.success('pob_editor_ui', {
    'action': 'navigate',
    'page': 'components',
  });
  expect(
    (await client.success('pob_editor_ui', {'action': 'status'}))['page'],
    'components',
  );
  await client.success('pob_editor_ui', {
    'action': 'preferences',
    'scale': 1.1,
    'motion': false,
  });
  final ui = await client.success('pob_editor_ui', {'action': 'status'});
  expect(ui['scale'], 1.1);
  expect(ui['motion'], isFalse);
  await client.success('pob_editor_ui', {
    'action': 'preferences',
    'scale': 1.0,
    'motion': true,
  });
  await client.success('pob_editor_ui', {
    'action': 'navigate',
    'page': 'workspace',
    'tab': 'skills',
  });
  await tester.pumpAndSettle();

  await client.success('pob_editor_components', {'action': 'status'});
  await client.success('pob_editor_components', {'action': 'check_updates'});
  final hasPrevious = model.canRollback;
  await client.success('pob_editor_components', {'action': 'rollback'});
  expect(
    (await _waitJob(client))['state'],
    hasPrevious ? 'complete' : 'failed',
  );
  expect(model.mcpEditor.enabled, isTrue);
  expect(model.state.library.activeId, id);
  await client.success('pob_editor_components', {
    'action': 'select_installed',
    'component': 'pob',
    'commit': 'b' * 40,
  });
  expect((await _waitJob(client))['state'], 'failed');
  expect(model.mcpEditor.enabled, isTrue);
  await client.success('pob_editor_app', {'action': 'disconnect'});
  expect((await client.success('pob_editor_status'))['connected'], isFalse);
  expect(model.mcpEditor.enabled, isTrue);
  await client.success('pob_editor_app', {'action': 'connect'});
  expect(model.engine.connected, isTrue);
  expect(model.state.library.activeId, id);
  await client.success('pob_editor_app', {'action': 'save'});

  final image = await client.call('pob_render_image', {'view': 'overview'});
  if (Platform.isWindows) {
    expect(image['isError'], isFalse, reason: '$image');
    expect(
      jsonRows(image['content']).where((b) => b['type'] == 'image'),
      hasLength(1),
    );
  } else {
    expect(image['isError'], isTrue);
    expect(jsonRows(image['content']).first['text'], contains('Windows'));
  }
  final lifecycle = <String>[];
  model.mcpEditor.lifecycleAction = (action) async {
    lifecycle.add(action);
  };
  await client.success('pob_editor_app', {'action': 'restart'});
  expect(lifecycle, ['restart']);
  model.mcpEditor.lifecycleAction = null;
}

Future<void> _checkNinjaProfileImport(
  _ExternalEditor client,
  WorkshopCubit model,
) async {
  final id = model.state.library.activeId!;
  final before = await model.library.read(id);
  final history = model.state.history;
  for (final link in [
    'https://poe.ninja/poe2/profile/Example-1234/standard/character/ExampleCharacter',
    'https://poe.ninja/poe2/builds/standard/character/account-1234/character',
  ]) {
    final result = await client.success('pob_editor_files', {
      'action': 'import_link',
      'text': link,
    });
    expect(result['imported'], isFalse);
    expect(result['requires'], 'pob_code');
    expect(result['sourceUrl'], link);
    expect(result['nextAction'], 'import_code');
    expect(model.state.library.activeId, id);
    expect(await model.library.read(id), before);
    expect(model.state.history, history);
  }
}

Future<JsonMap> _waitJob(_ExternalEditor client) async {
  for (var attempt = 0; attempt < 300; attempt++) {
    final job = await client.success('pob_editor_job');
    if (job['state'] != 'running') return job;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError('Фоновая задача не завершилась');
}

Future<void> _checkProtectedDialog(
  WidgetTester tester,
  _ExternalEditor client,
) async {
  final context = tester.element(find.byType(WorkspaceView));
  unawaited(
    showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(content: Text('Несохранённый ввод')),
    ),
  );
  await tester.pumpAndSettle();
  expect((await client.success('pob_editor_status'))['canCloseDialog'], isTrue);
  final refused = await client.call('pob_editor_notes', {
    'action': 'write',
    'text': 'Нельзя',
  });
  expect(refused['isError'], isTrue);
  expect(jsonRows(refused['content']).first['text'], contains('APP_BUSY'));
  await client.success('pob_check_build');
  await client.success('pob_editor_app', {'action': 'close_dialog'});
  await tester.pumpAndSettle();
  expect(find.text('Несохранённый ввод'), findsNothing);
}

Future<void> _checkDpsDialog(
  WidgetTester tester,
  _ExternalEditor client,
) async {
  tester.view.devicePixelRatio = 1;
  try {
    for (final width in [1024.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 800);
      await _checkDpsAtCurrentSize(tester, client);
    }
  } finally {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}

Future<void> _checkDpsAtCurrentSize(
  WidgetTester tester,
  _ExternalEditor client,
) async {
  await client.success('pob_editor_ui', {
    'action': 'navigate',
    'page': 'workspace',
    'tab': 'calculations',
  });
  final panelOpened = await _openDps(tester, client);
  expect((await client.success('pob_editor_status'))['dialogOpen'], isTrue);
  expect((await client.success('pob_editor_status'))['canCloseDialog'], isTrue);
  await _checkScreenshot(client);
  await client.success('pob_editor_app', {'action': 'close_dialog'});
  await tester.pumpAndSettle();
  expect(
    (await client.success('pob_editor_status'))['dialogOpen'],
    panelOpened,
  );
  await _uiPerform(tester, client, 'Полный DPS', 'tap');
  final snapshot = await client.success('pob_editor_ui', {
    'action': 'snapshot',
  });
  await client.success('pob_editor_ui', {
    'action': 'key',
    'snapshotId': snapshot['snapshotId'],
    'key': 'escape',
  });
  await tester.pumpAndSettle();
  if (panelOpened) {
    await client.success('pob_editor_app', {'action': 'close_dialog'});
    await tester.pumpAndSettle();
  }
  expect((await client.success('pob_editor_status'))['dialogOpen'], isFalse);
}

Future<bool> _openDps(WidgetTester tester, _ExternalEditor client) async {
  await tester.pumpAndSettle();
  final snapshot = await client.success('pob_editor_ui', {
    'action': 'snapshot',
  });
  final visible = jsonRows(snapshot['nodes']).any(
    (node) =>
        '${node['label']}'.contains('Полный DPS') &&
        jsonStrings(node['actions']).contains('tap'),
  );
  if (!visible) await _uiPerform(tester, client, 'Показатели', 'tap');
  await _uiPerform(tester, client, 'Полный DPS', 'tap');
  return !visible;
}

Future<void> _checkScreenshot(_ExternalEditor client) async {
  final screenshot = await client.call('pob_editor_ui', {
    'action': 'screenshot',
  });
  expect(screenshot['isError'], isFalse);
  final png = jsonRows(screenshot['content'])
      .firstWhere((item) => item['type'] == 'image');
  final bytes = base64Decode(png['data'] as String);
  expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
  final result = jsonMap(jsonMap(screenshot['structuredContent'])['result']);
  final viewport = jsonMap(result['viewport']);
  final width = (viewport['width'] as num).ceil();
  expect(bytes.buffer.asByteData().getUint32(16), width);
  expect(
    bytes.buffer.asByteData().getUint32(20),
    (viewport['height'] as num).ceil(),
  );
  final file = File(
    'build/review/mcp-full-dps-$width-${Platform.operatingSystem}.png',
  );
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
}

Future<JsonMap> _uiPerform(
  WidgetTester tester,
  _ExternalEditor client,
  String label,
  String operation, {
  Object? value,
}) async {
  await tester.pumpAndSettle();
  final snapshot = await client.success('pob_editor_ui', {
    'action': 'snapshot',
  });
  final node = jsonRows(snapshot['nodes']).firstWhere(
    (node) =>
        '${node['label']}'.contains(label) &&
        jsonStrings(node['actions']).contains(operation),
    orElse: () => throw StateError('$label / $operation: $snapshot'),
  );
  return client.success('pob_editor_ui', {
    'action': 'perform',
    'snapshotId': snapshot['snapshotId'],
    'nodeId': node['id'],
    'operation': operation,
    if (value != null) 'value': value,
  });
}

Future<void> _createBuilds(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
) async {
  final disabledCheck = await client.call('pob_check_build');
  expect(disabledCheck['isError'], isTrue);
  expect(
    jsonRows(disabledCheck['content']).single['text'],
    contains('NO_BUILD'),
  );
  final classes = await client.success('pob_catalog', {'kind': 'classes'});
  expect(jsonRows(classes['entries']).map((entry) => entry['id']), contains(1));

  await _uiPerform(tester, client, 'Новая сборка', 'tap');
  await _uiPerform(
    tester,
    client,
    'Название',
    'setText',
    value: 'Первая сборка MCP',
  );
  final refused = await client.call('pob_editor_ui', {
    'action': 'close_dialog',
  });
  expect(refused['isError'], isTrue);
  expect(jsonRows(refused['content']).first['text'], contains('DIALOG_INPUT'));
  expect(find.text('Первая сборка MCP'), findsOneWidget);
  await client.success('pob_editor_ui', {
    'action': 'close_dialog',
    'discard': true,
  });
  expect(model.state.report, isNull);
  await _uiPerform(tester, client, 'Новая сборка', 'tap');
  await _uiPerform(
    tester,
    client,
    'Название',
    'setText',
    value: 'Первая сборка MCP',
  );
  await _uiPerform(tester, client, 'Warrior', 'tap');
  await _uiPerform(tester, client, 'Создать сборку', 'tap');
  expect(model.mcpEditor.enabled, isTrue);
  final first = await client.success('pob_check_build');
  final second = await _create(client, 'Правки MCP');
  expect(first['id'], isNot(second['id']));
  expect(model.state.library.entries, hasLength(2));
  expect(model.state.library.activeId, second['id']);
  expect(parseBuildReport(second).level, 90);
  final library = model.sharedLibrary!;
  expect((await library.scan()).entries, hasLength(2));
  expect(model.mcpEditor.enabled, isTrue);
}

Future<JsonMap> _create(_ExternalEditor client, String name) => client.success(
  'pob_create_build',
  {'name': name, 'classId': 1, 'level': 90},
);

Future<void> _enableFromLibrary(
  WidgetTester tester,
  WorkshopCubit model,
  ShellBloc shell,
) async {
  await model.mcpEditor.disable();
  shell.add(const PageSelected(AppPage.library));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('library-search')), findsOneWidget);
  expect(find.text('Правки через MCP'), findsOneWidget);
  await _enable(tester);
  expect(model.mcpEditor.enabled, isTrue);
  shell.add(const PageSelected(AppPage.workspace));
  await tester.pumpAndSettle();
}

Future<bool> _checkSkillControlSchema(_ExternalEditor client) async {
  final controls = await client.mainSkillControls();
  const required = {'parts', 'statSets'};
  if (Platform.environment['POB2_UI_REQUIRE_SKILL_CONTROLS'] == 'true') {
    expect(
      controls,
      containsAll(required),
      reason: 'Закреплённый MCP должен поддерживать часть и вариант умения.',
    );
  }
  return controls.containsAll(required);
}

Future<void> _checkSkillVariants(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
  ShellBloc shell,
) async {
  await client.success('pob_check_build');
  final gems = await client.success('pob_catalog', {
    'kind': 'gems',
    'query': 'Ball Lightning',
  });
  final gem = jsonRows(gems['entries'])
      .firstWhere((gem) => gem['name'] == 'Ball Lightning');
  await client.success('pob_add_skill_group', {
    'label': 'Ball Lightning',
    'gems': [
      {'id': gem['id'], 'level': 1},
    ],
  });
  final group = model.state.report!.groups.last;
  await client.success('pob_select_main_skill', {
    'control': 'groups',
    'id': group['id'],
  });
  final initial = model.state.report!;
  final selector = initial.skillStatSetSelector;
  final base = selector['selected'] as int;
  final infused =
      jsonRows(selector['entries'])
              .singleWhere((entry) => entry['label'] == 'Fire-Infused')['id']
          as int;
  expect(infused, isNot(base));
  await client.success('pob_select_main_skill', {
    'control': 'statSets',
    'id': infused,
  });
  await tester.pumpAndSettle();
  expect(shell.state.tab, WorkshopTab.calculations);
  final infusedStats = model.state.report!.stats;
  expect(infusedStats['TotalDPS'], isNot(initial.stats['TotalDPS']));

  final dropdown = find.byKey(const ValueKey('main-skill-statSets'));
  expect(tester.widget<DropdownButton<int>>(dropdown).value, infused);
  await _selectSkillOption(tester, model, dropdown, base);
  expect(model.state.report!.stats, initial.stats);
  await _selectSkillOption(tester, model, dropdown, infused);
  expect(model.state.report!.stats, infusedStats);

  await _checkUnavailableSkillPart(tester, client, model);
  await _checkVariantRoundTrip(tester, client, model, dropdown, infused);
}

Future<void> _selectSkillOption(
  WidgetTester tester,
  WorkshopCubit model,
  Finder dropdown,
  int id,
) async {
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  final option = find.byWidgetPredicate(
    (widget) => widget is DropdownMenuItem<int> && widget.value == id,
  );
  final label = find.descendant(of: option, matching: find.byType(Text));
  await tester.tap(label.hitTestable().last);
  await tester.pump();
  for (var i = 0; i < 100 && model.state.busy; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
  expect(model.state.error, isNull);
  expect(tester.widget<DropdownButton<int>>(dropdown).value, id);
}

Future<void> _checkUnavailableSkillPart(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
) async {
  expect(model.state.report!.skillPartSelector, isEmpty);
  expect(find.byKey(const ValueKey('main-skill-parts')), findsNothing);
  await client.success('pob_check_build');
  final library = model.sharedLibrary!;
  final id = model.state.library.activeId!;
  final priorXml = await library.read(id);
  final stats = model.state.report!.stats;
  final unavailable = await client.call('pob_select_main_skill', {
    'control': 'parts',
    'id': 2,
  });
  expect(unavailable['isError'], isTrue);
  expect(
    jsonRows(unavailable['content']).single['text'],
    contains('Выбор умения недоступен'),
  );
  expect(await library.read(id), priorXml);
  expect(model.state.report!.stats, stats);
  await tester.pumpAndSettle();
}

Future<void> _checkVariantRoundTrip(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
  Finder dropdown,
  int selected,
) async {
  await client.success('pob_check_build');
  final report = model.state.report!;
  final mcpXml = await client.success('pob_export_xml');
  final xml = (await model.exportXml())!;
  final expected = '$selected';
  expect(_ballLightningStatSet(mcpXml['xml'] as String), expected);
  expect(_ballLightningStatSet(xml), expected);
  final original = model.state.library.activeId;
  await model.importXml(xml);
  await tester.pumpAndSettle();
  expect(model.state.error, isNull);
  expect(model.state.report!.stats, report.stats);
  expect(model.state.report!.skillStatSetSelector, report.skillStatSetSelector);
  expect(tester.widget<DropdownButton<int>>(dropdown).value, selected);
  await model.openBuild(original!);
  await tester.pumpAndSettle();
  await _enable(tester);
  expect(model.mcpEditor.enabled, isTrue);
}

String? _ballLightningStatSet(String xml) => XmlDocument.parse(xml)
    .findAllElements('StatSetIndex')
    .singleWhere(
      (entry) => entry.getAttribute('grantedEffect') == 'BallLightningPlayer',
    )
    .getAttribute('index');

Future<void> _enable(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('mcp-editor-settings')));
  await tester.pumpAndSettle();
  final toggle = find.byKey(const Key('mcp-editor-permission'));
  expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
  expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
  await tester.tap(find.text('Закрыть'));
  await tester.pumpAndSettle();
}

Future<int> _node(_ExternalEditor client) async {
  await client.success('pob_check_build');
  final nodes = await client.success('pob_catalog', {
    'kind': 'nodes',
    'query': 'spell damage',
    'limit': 200,
  });
  return jsonRows(nodes['entries']).firstWhere(
        (node) =>
            node['type'] == 'Normal' &&
            node['allocated'] == false &&
            node['points'] is int &&
            (node['points'] as int) <= 10,
      )['id']
      as int;
}

Future<void> _checkNode(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
  ShellBloc shell,
  int node,
) async {
  shell.add(const WorkshopTabSelected(WorkshopTab.items));
  await tester.pumpAndSettle();
  await client.success('pob_tree_action', {'id': node, 'action': 'allocate'});
  await tester.pumpAndSettle();
  expect(model.state.report!.raw['allocatedNodes'], contains(node));
  expect(shell.state.tab, WorkshopTab.tree);
  final painter = tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((widget) => widget.painter)
      .whereType<TreePainter>()
      .single;
  expect(painter.selected, node);
}

Future<void> _checkItem(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
  ShellBloc shell,
) async {
  final life = model.state.report!.stats['Life'] as num;
  await client.success('pob_equip_item', {
    'slot': 'Ring 1',
    'raw': 'Rarity: Rare\nTide Loop\nLazuli Ring\n--------\nItem Level: 80\n--------\n+75 to maximum Life\n',
  });
  await tester.pumpAndSettle();
  expect(model.state.report!.stats['Life'], greaterThan(life));
  expect(shell.state.tab, WorkshopTab.items);
}

Future<void> _checkSkills(
  WidgetTester tester,
  _ExternalEditor client,
  WorkshopCubit model,
  ShellBloc shell,
) async {
  final gems = await client.success('pob_catalog', {
    'kind': 'gems',
    'query': 'Fireball',
  });
  final gem = jsonRows(gems['entries'])
      .firstWhere((gem) => gem['name'] == 'Fireball');
  final groups = model.state.report!.groups.length;
  await client.success('pob_add_skill_group', {
    'label': 'Fireball',
    'gems': [
      {'id': gem['id'], 'level': 15},
    ],
  });
  await tester.pumpAndSettle();
  expect(shell.state.tab, WorkshopTab.skills);
  expect(model.state.report!.groups, hasLength(groups + 1));
  expect(model.state.undoCount, 3);
  await model.undo();
  expect(model.state.report!.groups, hasLength(groups));
  await model.redo();
  expect(model.state.report!.groups, hasLength(groups + 1));
}

class _ExternalEditor {
  _ExternalEditor(this.tester, this.process)
    : _lines = StreamIterator(
        process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
      );
  final Process process;
  final WidgetTester tester;
  final StreamIterator<String> _lines;
  int _counter = 0;

  static Future<_ExternalEditor> connect(
    WidgetTester tester,
    Directory root,
    String executable,
  ) async {
    final endpoint = File.fromUri(root.uri.resolve('mcp-editor/endpoint.json'));
    final process = await Process.start(executable, [
      'editor',
      '--endpoint',
      endpoint.path,
    ]);
    unawaited(process.stderr.drain<void>());
    final client = _ExternalEditor(tester, process);
    await client._rpc('initialize', {
      'protocolVersion': '2024-11-05',
      'capabilities': <String, dynamic>{},
      'clientInfo': {'name': 'pob2-ui-test', 'version': '1'},
    });
    process.stdin.writeln(
      jsonEncode({'jsonrpc': '2.0', 'method': 'notifications/initialized'}),
    );
    return client;
  }

  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) =>
      _rpc('tools/call', {'name': name, 'arguments': arguments});

  Future<Set<String>> mainSkillControls() async {
    final tools = await _rpc('tools/list', {});
    final tool = jsonRows(tools['tools'])
        .firstWhere((tool) => tool['name'] == 'pob_select_main_skill');
    final properties = jsonMap(jsonMap(tool['inputSchema'])['properties']);
    return jsonStrings(jsonMap(properties['control'])['enum']).toSet();
  }

  Future<JsonMap> success(String name, [JsonMap arguments = const {}]) async {
    var result = await call(name, arguments);
    for (var i = 0; i < 300 && _busy(result); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      result = await call(name, arguments);
    }
    expect(result['isError'], isFalse, reason: '$result');
    return jsonMap(jsonMap(result['structuredContent'])['result']);
  }

  bool _busy(JsonMap result) =>
      result['isError'] == true &&
      jsonRows(result['content'])
          .any((item) => '${item['text']}'.contains('"code": "APP_BUSY"'));

  Future<JsonMap> _rpc(String method, JsonMap params) async {
    process.stdin.writeln(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': ++_counter,
        'method': method,
        'params': params,
      }),
    );
    var completed = false;
    final next = _lines.moveNext().timeout(const Duration(minutes: 3));
    unawaited(
      next.then(
        (_) => completed = true,
        onError: (Object _) => completed = true,
      ),
    );
    while (!completed) {
      await tester.pump(const Duration(milliseconds: 20));
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(await next, isTrue);
    return jsonMap(jsonMap(jsonDecode(_lines.current))['result']);
  }

  Future<void> close() async {
    await process.stdin.close();
    await _lines.cancel();
    await process.exitCode;
  }
}
