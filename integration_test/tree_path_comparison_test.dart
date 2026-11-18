import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

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
import 'package:pob2_ui/domain/tree_allocation_mode.dart';
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

  for (final weapon in [1, 2]) {
    testWidgets('Пути I/II при активном оружии $weapon, Undo/Redo и XML', (
      tester,
    ) async {
      final root = await _profile();
      final dialogs = SelectPaths();
      final model = await _open(tester, root, dialogs);
      await _prepare(model, fixture: 'witch_weapon_paths');
      await model.selectWeaponSet(weapon);
      for (final mode in [
        TreeAllocationMode.weaponOne,
        TreeAllocationMode.weaponTwo,
      ]) {
        await model.selectTreeMode(mode);
        await _chooseTargets(tester);
        final baseline = await _export(model);
        final history = model.state.history;
        var preview = await _calculate(tester);
        await _verifyWeaponPreview(model, preview, baseline);
        await _capture(tester, '$weapon-${mode.luaValue}');
        expect(model.state.history, history);
        await _staleWeaponMode(tester, model, preview);
        preview = await _calculate(tester);
        await _applyWeaponPath(tester, model, preview, baseline, first: true);
        await model.undo();
        await _chooseTargets(tester);
        preview = await _calculate(tester);
        await _applyWeaponPath(tester, model, preview, baseline, first: false);
        if (mode == TreeAllocationMode.weaponOne) await model.undo();
      }
      final applied = await _export(model);
      await _reopen(
        tester,
        model,
        root,
        dialogs,
        applied,
        expectedDps: model.state.report!.stats['TotalDPS'] as num,
      );
      expect(tester.takeException(), isNull);
    }, timeout: const Timeout(Duration(minutes: 12)));
  }

  testWidgets('Потеря ответа применения пути I сохраняет сборку без повтора', (
    tester,
  ) async {
    final root = await _profile();
    final engine = _LostPathReply();
    final model = await _open(tester, root, SelectPaths(), engine: engine);
    await _prepare(model, fixture: 'witch_weapon_paths');
    await model.selectTreeMode(TreeAllocationMode.weaponOne);
    final baseline = await _export(model);
    await _chooseTargets(tester);
    final preview = await _calculate(tester);
    final history = model.state.history;
    final saved = await model.library.read(model.state.library.activeId!);
    engine.dropNext = true;
    final result = await model.applyTreePath(preview, first: false);
    expect(result.committed, isFalse);
    expect(result.error, contains('ответ MCP'));
    expect(
      engine.appliedNodes,
      PobBuildDocument(preview.reports.second.xml).allocationModes,
    );
    expect(model.state.history, history);
    expect(model.state.document!.stale, isTrue);
    expect(await model.library.read(model.state.library.activeId!), saved);
    await model.connect();
    expect(model.state.error, isNull);
    expect(
      PobBuildDocument(await _export(model)).allocationModes,
      PobBuildDocument(baseline).allocationModes,
    );
    expect(engine.repeated, 1);
    expect(
      await model.buildNotes.readNotes(model.state.library.activeId!),
      _notes,
    );
  }, timeout: const Timeout(Duration(minutes: 8)));

  testWidgets('Запоздавшее сравнение I отклоняется после смены оружия', (
    tester,
  ) async {
    final root = await _profile();
    final trial = _PausedPathSession();
    final model = await _open(
      tester,
      root,
      SelectPaths(),
      createEngine: () => trial,
    );
    await _prepare(model, fixture: 'witch_weapon_paths');
    await model.selectTreeMode(TreeAllocationMode.weaponOne);
    final pending = expectLater(
      model.compareTreePaths(_pureEnergy, _rawDestruction),
      throwsStateError,
    );
    await trial.started.future.timeout(const Duration(seconds: 30));
    await model.selectWeaponSet(2);
    final xml = await _export(model);
    final history = model.state.history;
    trial.resume.complete();
    await pending;
    expect(model.state.report!.weaponSet, 2);
    expect(await _export(model), xml);
    expect(model.state.history, history);
  }, timeout: const Timeout(Duration(minutes: 5)));
}

class _PausedPathSession extends McpClient {
  final started = Completer<void>();
  final resume = Completer<void>();

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    final result = await super.call(name, arguments);
    if (name == 'pob_tree_options' && !started.isCompleted) {
      started.complete();
      await resume.future;
    }
    return result;
  }
}

class _LostPathReply extends McpClient {
  var dropNext = false;
  String? attempted;
  Map<int, int>? appliedNodes;
  var repeated = 0;

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    final result = await super.call(name, arguments);
    if (name != 'pob_import_xml') return result;
    final xml = arguments['xml'] as String;
    if (dropNext) attempted = xml;
    if (xml == attempted) repeated++;
    if (!dropNext) return result;
    dropNext = false;
    final exported = await super.call('pob_export_xml');
    appliedNodes = PobBuildDocument(exported['xml'] as String).allocationModes;
    await close();
    final error = StateError('Потерян ответ MCP во время применения пути');
    onDisconnected?.call(error);
    throw error;
  }
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
  SelectPaths dialogs, {
  McpClient? engine,
  McpClient Function()? createEngine,
}) async {
  final model = WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    engine ?? McpClient(),
    library: PobBuildLibrary(root),
    files: XmlFileService(dialogs: dialogs),
    createEngine: createEngine,
  );
  addTearDown(() async {
    if (!model.isClosed) await model.close();
  });
  await model.initialize();
  expect(model.luaReady, isTrue, reason: model.state.error);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('path-review'),
      child: PobApp(model: model),
    ),
  );
  await tester.pumpAndSettle();
  // В изолированном профиле тест сам управляет всеми изменениями XML.
  model.modalOpen = () => true;
  return model;
}

Future<String> _prepare(
  WorkshopCubit model, {
  String fixture = 'witch_fireball',
}) async {
  final xml = await File('integration_test/fixtures/$fixture.xml')
      .readAsString();
  await model.importXml(xml);
  expect(model.state.error, isNull);
  expect((await model.setCondition('enemyLevel', 68)).committed, isTrue);
  await model.undo();
  expect(model.state.history, (undo: 0, redo: 1));
  final id = model.state.library.activeId!;
  await model.buildNotes.readNotes(id);
  await model.buildNotes.saveNotes(id, _notes);
  return _export(model);
}

Future<void> _verifyWeaponPreview(
  WorkshopCubit model,
  TreePathComparison preview,
  String baseline,
) async {
  final session = McpClient();
  try {
    await session.connect(model.components.active);
    for (final option in [preview.reports.first, preview.reports.second]) {
      await session.call('pob_import_xml', {'xml': baseline});
      await session.call('pob_tree_options', {'mode': preview.mode.luaValue});
      await session.call('pob_tree_action', {
        'id': option.target,
        'action': 'allocate',
      });
      final report = parseBuildReport(await session.call('pob_check_build'));
      final actual = PobBuildDocument(await session.exportBuildXml());
      expect(
        actual.allocationModes,
        PobBuildDocument(option.xml).allocationModes,
      );
      expect(report.weaponSet, preview.weaponSet);
      expect(report.config['enemyLevel'], 67);
      expect(report.stats['TotalDPS'], closeTo(option.stats.dps!, 0.00001));
      expect(report.stats['Life'], option.stats.life);
    }
  } finally {
    await session.close();
  }
  expect((
    preview.reports.first.points,
    preview.reports.second.points,
  ), preview.mode == TreeAllocationMode.weaponOne ? (4, 8) : (8, 4));
  final expected = switch ((preview.weaponSet, preview.mode)) {
    (1, TreeAllocationMode.weaponOne) => (15.38125, 17.432083333333),
    (1, TreeAllocationMode.weaponTwo) => (15.38125, 15.38125),
    (2, TreeAllocationMode.weaponOne) => (19.482916666667, 19.482916666667),
    (2, TreeAllocationMode.weaponTwo) => (23.78075, 24.61),
    _ => throw StateError('Ожидался предпросмотр I/II'),
  };
  expect(preview.reports.first.stats.dps, closeTo(expected.$1, 0.00001));
  expect(preview.reports.second.stats.dps, closeTo(expected.$2, 0.00001));
  expect(await _export(model), baseline);
}

Future<void> _staleWeaponMode(
  WidgetTester tester,
  WorkshopCubit model,
  TreePathComparison old,
) async {
  final other = old.mode == TreeAllocationMode.weaponOne
      ? TreeAllocationMode.weaponTwo
      : TreeAllocationMode.weaponOne;
  await _tap(tester, 'tree-mode-${other.luaValue}');
  expect(model.isTreePathCurrent(old), isFalse);
  final before = await _export(model);
  expect((await model.applyTreePath(old, first: true)).committed, isFalse);
  expect(await _export(model), before);
  await model.selectTreeMode(old.mode);
  await tester.pumpAndSettle();
}

Future<void> _applyWeaponPath(
  WidgetTester tester,
  WorkshopCubit model,
  TreePathComparison preview,
  String baseline, {
  required bool first,
}) async {
  final option = first ? preview.reports.first : preview.reports.second;
  final panel = tester.widget<TreePathPanel>(find.byType(TreePathPanel));
  final history = model.state.history.undo;
  await _press(tester, first ? 'apply-tree-path-a' : 'apply-tree-path-b');
  await _wait(tester, () => !panel.cubit.state.busy);
  expect(panel.cubit.state.error, isNull);
  expect(model.state.history, (undo: history + 1, redo: 0));
  final applied = PobBuildDocument(await _export(model));
  expect(applied.allocationModes, PobBuildDocument(option.xml).allocationModes);
  expect(model.state.report!.weaponSet, preview.weaponSet);
  expect(
    model.state.report!.stats['TotalDPS'],
    closeTo(option.stats.dps!, 0.00001),
  );
  await model.undo();
  expect(
    PobBuildDocument(await _export(model)).allocationModes,
    PobBuildDocument(baseline).allocationModes,
  );
  await model.redo();
  expect(
    PobBuildDocument(await _export(model)).allocationModes,
    applied.allocationModes,
  );
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
  String expected, {
  num expectedDps = _dpsAfter,
}) async {
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
  expect(
    reopened.state.report!.stats['TotalDPS'],
    closeTo(expectedDps, 0.00001),
  );
  final xml = PobBuildDocument(await _export(reopened));
  expect(xml.allocatedNodes, PobBuildDocument(expected).allocatedNodes);
  expect(xml.allocationModes, PobBuildDocument(expected).allocationModes);
  expect(xml.notes, _notes);
}

Future<void> _tap(WidgetTester tester, String key) async {
  await _press(tester, key);
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String suffix) async {
  final target = Platform.environment['POB2_UI_SCREENSHOT'];
  if (target == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('path-review')),
  );
  final image = await boundary.toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(target.replaceFirst('.png', '-$suffix.png'));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data!.buffer.asUint8List());
  image.dispose();
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
