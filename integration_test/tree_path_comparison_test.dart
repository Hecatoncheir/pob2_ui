import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/xml_file_service.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/tree_path_comparison.dart';
import 'package:pob2_ui/installer_check.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/tree_path_panel.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import '../test/support/file_fakes.dart';

const _pureEnergy = 2254;
const _rawDestruction = 51184;
const _dpsBefore = 12.817708333333;
const _dpsAfter = 19.482916666667;
const _notes = 'Два пути Ведьмы';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Два пути Ведьмы в оригинальном Lua, применение, Undo/Redo и XML',
    (tester) async {
      final root = await _profile();
      final dialogs = SelectPaths();
      final model = await _open(tester, root, dialogs);
      final baseline = await _prepare(model);
      await _chooseTargets(tester);
      stdout.writeln('Выбраны два узла Ведьмы в дереве.');
      final preview = await _calculate(tester);
      await _verifyPreview(model, preview, baseline);
      stdout.writeln('Оба предпросмотра совпали с прямым расчётом Lua.');
      await _expectStale(tester, model, preview);
      final current = await _calculate(tester);
      final appliedXml = await _applyAndCheckHistory(tester, model, current);
      stdout.writeln('Проверены применение одного пути и Undo/Redo.');
      await _reopen(tester, model, root, dialogs, appliedXml);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<Directory> _profile() async {
  expect(Platform.environment['POB2_UI_HOME'], isNotNull);
  final prepared = InstallationStore.defaultRoot();
  final root = await prepared.createTemp('tree-paths-');
  addTearDown(() => root.delete(recursive: true));
  final builds = await Directory.fromUri(root.uri.resolve('builds/')).create();
  await File.fromUri(prepared.uri.resolve('components.json'))
      .copy(File.fromUri(root.uri.resolve('components.json')).path);
  await PobBuildLibrary(root).configure(builds.path);
  return root;
}

Future<WorkshopCubit> _open(
  WidgetTester tester,
  Directory root,
  SelectPaths dialogs,
) async {
  final model = WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    McpClient(),
    library: PobBuildLibrary(root),
    files: XmlFileService(dialogs: dialogs),
  );
  addTearDown(() async {
    if (!model.isClosed) await model.close();
  });
  await model.initialize();
  expect(model.luaReady, isTrue, reason: model.state.error);
  await tester.pumpWidget(PobApp(model: model));
  await tester.pumpAndSettle();
  // В изолированном профиле тест сам управляет всеми изменениями XML.
  model.modalOpen = () => true;
  return model;
}

Future<String> _prepare(WorkshopCubit model) async {
  final fixture = await File('integration_test/fixtures/witch_fireball.xml')
      .readAsString();
  await model.importXml(fixture);
  expect(model.state.error, isNull);
  expect((await model.setCondition('enemyLevel', 68)).committed, isTrue);
  await model.undo();
  expect(model.state.history, (undo: 0, redo: 1));
  final id = model.state.library.activeId!;
  await model.buildNotes.readNotes(id);
  await model.buildNotes.saveNotes(id, _notes);
  return _export(model);
}

Future<String> _export(WorkshopCubit model) async {
  final xml = await model.exportXml();
  expect(
    xml,
    isNotNull,
    reason: model.state.error ?? model.state.log.join('\n'),
  );
  return xml!;
}

Future<void> _chooseTargets(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await _tap(tester, 'tab-tree');
  await _tap(tester, 'tree-path-toggle');
  final field = find.byKey(const Key('tree-search'));
  for (final id in [_pureEnergy, _rawDestruction]) {
    await tester.tap(field);
    await tester.enterText(field, '$id');
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }
  final state = tester
      .widget<TreePathPanel>(find.byType(TreePathPanel))
      .cubit
      .state;
  expect(
    (state.first, state.second),
    (_pureEnergy, _rawDestruction),
    reason: state.error,
  );
}

Future<TreePathComparison> _calculate(WidgetTester tester) async {
  final panel = tester.widget<TreePathPanel>(find.byType(TreePathPanel));
  final previous = panel.cubit.state.comparison;
  await _press(tester, 'calculate-tree-paths');
  await _wait(tester, () {
    final state = panel.cubit.state;
    return !state.busy && (state.comparison != previous || state.error != null);
  });
  expect(panel.cubit.state.error, isNull);
  final preview = panel.cubit.state.comparison!;
  final painter = tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((widget) => widget.painter)
      .whereType<TreePainter>()
      .single;
  expect(painter.comparisonPaths.$1, preview.reports.first.nodes);
  expect(painter.comparisonPaths.$2, preview.reports.second.nodes);
  return preview;
}

Future<void> _verifyPreview(
  WorkshopCubit model,
  TreePathComparison preview,
  String baseline,
) async {
  expect(preview.reports.baseline.dps, closeTo(_dpsBefore, 0.00001));
  expect(preview.reports.baseline.life, 1187);
  final session = McpClient();
  try {
    await session.connect(model.components.active);
    for (final option in [preview.reports.first, preview.reports.second]) {
      await _verifyWithOriginal(session, baseline, option);
    }
  } finally {
    await session.close();
  }
  expect(preview.reports.first.stats.life, 1218);
  expect(preview.reports.first.stats.dps, closeTo(_dpsBefore, 0.00001));
  expect(preview.reports.second.stats.life, 1187);
  expect(preview.reports.second.stats.dps, closeTo(_dpsAfter, 0.00001));
  final id = model.state.library.activeId!;
  expect(await _export(model), baseline);
  expect(await model.buildNotes.readNotes(id), _notes);
  expect(model.state.history, (undo: 0, redo: 1));
}

Future<void> _verifyWithOriginal(
  McpClient session,
  String baseline,
  TreePathOption option,
) async {
  await session.call('pob_import_xml', {'xml': baseline});
  await session.call('pob_tree_action', {
    'id': option.target,
    'action': 'allocate',
  });
  final report = parseBuildReport(await session.call('pob_check_build'));
  final after = PobBuildDocument(await session.exportBuildXml()).allocatedNodes;
  expect(option.points, 5);
  expect(
    after.difference(PobBuildDocument(baseline).allocatedNodes),
    option.nodes.toSet(),
  );
  expect(report.config['enemyLevel'], 67);
  expect(report.stats['TotalDPS'], option.stats.dps);
  expect(report.stats['Life'], option.stats.life);
}

Future<void> _expectStale(
  WidgetTester tester,
  WorkshopCubit model,
  TreePathComparison old,
) async {
  expect((await model.setCondition('enemyLevel', 68)).committed, isTrue);
  await tester.pumpAndSettle();
  expect(find.text(staleTreePaths), findsOneWidget);
  final apply = tester.widget<TextButton>(
    find.byKey(const Key('apply-tree-path-a')),
  );
  expect(apply.onPressed, isNull);

  final changed = await _export(model);
  final history = model.state.history;
  final result = await model.applyTreePath(old, first: true);
  expect(result, (committed: false, error: staleTreePaths));
  expect(await _export(model), changed);
  expect(model.state.history, history);
  await model.undo();
  await tester.pumpAndSettle();
}

Future<String> _applyAndCheckHistory(
  WidgetTester tester,
  WorkshopCubit model,
  TreePathComparison preview,
) async {
  final id = model.state.library.activeId!;
  final before = model.state.history.undo;
  final panel = tester.widget<TreePathPanel>(find.byType(TreePathPanel));
  await _press(tester, 'apply-tree-path-b');
  await _wait(
    tester,
    () =>
        !panel.cubit.state.busy &&
        (model.state.history.undo > before || panel.cubit.state.error != null),
  );
  expect(panel.cubit.state.error, isNull);
  expect(model.state.error, isNull);
  expect(model.state.history, (undo: before + 1, redo: 0));
  expect(model.state.report!.stats['TotalDPS'], closeTo(_dpsAfter, 0.00001));
  final xml = await _export(model);
  final nodes = PobBuildDocument(xml).allocatedNodes;
  expect(nodes, PobBuildDocument(preview.reports.second.xml).allocatedNodes);
  await model.undo();
  expect(model.state.report!.stats['TotalDPS'], closeTo(_dpsBefore, 0.00001));
  expect(
    PobBuildDocument(await _export(model)).allocatedNodes,
    isNot(contains(_rawDestruction)),
  );
  await model.redo();
  expect(PobBuildDocument(await _export(model)).allocatedNodes, nodes);
  expect(await model.buildNotes.readNotes(id), _notes);
  return _export(model);
}

Future<void> _reopen(
  WidgetTester tester,
  WorkshopCubit model,
  Directory root,
  SelectPaths dialogs,
  String expected,
) async {
  final file = File.fromUri(root.uri.resolve('witch-path.xml'));
  dialogs.savePath = file.path;
  await model.saveXmlFile();
  expect(model.state.error, isNull);
  expect(
    PobBuildDocument(await file.readAsString()).allocatedNodes,
    PobBuildDocument(expected).allocatedNodes,
  );
  await tester.pumpWidget(const SizedBox.shrink());
  await model.close();

  final previous = HttpOverrides.current;
  HttpOverrides.global = OfflineInstallerCheck();
  addTearDown(() => HttpOverrides.global = previous);
  final reopened = await _open(tester, root, dialogs);
  dialogs.openPath = file.path;
  await reopened.openXmlFile();
  expect(reopened.state.error, isNull);
  expect(reopened.state.report!.stats['TotalDPS'], closeTo(_dpsAfter, 0.00001));
  final xml = PobBuildDocument(await _export(reopened));
  expect(xml.allocatedNodes, PobBuildDocument(expected).allocatedNodes);
  expect(xml.notes, _notes);
}

Future<void> _tap(WidgetTester tester, String key) async {
  await _press(tester, key);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, String key) async {
  final control = find.byKey(ValueKey(key));
  await tester.ensureVisible(control);
  await tester.pump();
  expect(control.hitTestable(), findsOneWidget, reason: key);
  await tester.tap(control.hitTestable());
  await tester.pump();
}

Future<void> _wait(WidgetTester tester, bool Function() done) async {
  for (var attempt = 0; attempt < 1500; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (done()) {
      await tester.pumpAndSettle();
      return;
    }
  }
  fail('Сравнение путей не завершилось.');
}
