import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/shell_bloc.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workspace_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Команды внешнего MCP меняют открытую сборку с Undo и Redo', (
    tester,
  ) async {
    if (!Platform.environment.containsKey('POB2_UI_HOME')) {
      throw StateError('Для проверки нужен отдельный профиль POB2_UI_HOME.');
    }
    final profile = InstallationStore.defaultRoot();
    final root = await profile.createTemp('editor-builds-');
    await File.fromUri(profile.uri.resolve('components.json'))
        .copy(File.fromUri(root.uri.resolve('components.json')).path);
    final components = ComponentRepository(store: InstallationStore(root));
    final model = WorkshopCubit(components, McpClient());
    addTearDown(model.close);
    await model.initialize();
    await model.createBuild(1, 90, name: 'Правки MCP');
    expect(model.state.error, isNull);

    await tester.pumpWidget(PobApp(model: model));
    await tester.pumpAndSettle();
    await _enable(tester);
    expect(model.mcpEditor.enabled, isTrue);
    final shell = tester.element(find.byType(WorkspaceView)).read<ShellBloc>();
    final client = await _ExternalEditor.connect(
      root,
      components.active[Component.mcp]!,
    );
    addTearDown(client.close);

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

    await model.mcpEditor.disable();
    final disabled = await client.call('pob_check_build');
    expect(disabled['isError'], isTrue);
    expect(
      jsonRows(disabled['content']).single['text'],
      contains('EDITOR_DISABLED'),
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}

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
  _ExternalEditor(this.process)
    : _lines = StreamIterator(
        process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
      );
  final Process process;
  final StreamIterator<String> _lines;
  int _counter = 0;

  static Future<_ExternalEditor> connect(
    Directory root,
    Installation mcp,
  ) async {
    final endpoint = File.fromUri(root.uri.resolve('mcp-editor/endpoint.json'));
    final process = await Process.start(await ProcessService().python(), [
      '-X',
      'utf8',
      'run.py',
      'serve',
      '--mode',
      'editor',
      '--editor-endpoint',
      endpoint.path,
    ], workingDirectory: mcp.directory);
    unawaited(process.stderr.drain<void>());
    final client = _ExternalEditor(process);
    await client._rpc('initialize', {});
    return client;
  }

  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) =>
      _rpc('tools/call', {'name': name, 'arguments': arguments});

  Future<JsonMap> success(String name, [JsonMap arguments = const {}]) async {
    final result = await call(name, arguments);
    expect(result['isError'], isFalse, reason: '$result');
    return jsonMap(jsonMap(result['structuredContent'])['result']);
  }

  Future<JsonMap> _rpc(String method, JsonMap params) async {
    process.stdin.writeln(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': ++_counter,
        'method': method,
        'params': params,
      }),
    );
    expect(
      await _lines.moveNext().timeout(const Duration(seconds: 60)),
      isTrue,
    );
    return jsonMap(jsonMap(jsonDecode(_lines.current))['result']);
  }

  Future<void> close() async {
    await process.stdin.close();
    await _lines.cancel();
    await process.exitCode;
  }
}
