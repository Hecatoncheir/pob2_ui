import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/appearance_repository.dart';
import 'package:pob2_ui/domain/appearance.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/tree_view.dart';
import 'package:pob2_ui/ui/tree_hover_card.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/node_power_panel.dart';
import 'package:pob2_ui/ui/app_update_cubit.dart';
import 'package:pob2_ui/data/language_preferences.dart';
import 'package:pob2_ui/data/game_dictionary_repository.dart';
import 'package:pob2_ui/domain/app_language.dart';
import 'package:pob2_ui/ui/language_cubit.dart';
import 'package:pob2_ui/ui/core/spark_art.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Настоящее дерево, иконки, путь Lua и XML в новом интерфейсе', (
    tester,
  ) async {
    final root = InstallationStore.defaultRoot();
    if (!Platform.environment.containsKey('POB2_UI_HOME')) {
      throw StateError(
        'Задайте отдельный профиль POB2_UI_HOME с установленными компонентами',
      );
    }
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(root)),
      McpClient(),
    );
    addTearDown(model.close);
    final updates = AppUpdateCubit(root: root);
    addTearDown(updates.close);
    final language = LanguageCubit(
      LanguagePreferences(root),
      GameDictionaryRepository(root),
    );
    addTearDown(language.close);
    await model.initialize();
    expect(model.state.error, isNull);
    expect(model.engine.connected, isTrue);
    final witch = model.state.classes.firstWhere(
      (entry) => entry['name'] == 'Witch',
    );
    await model.createBuild(
      witch['id'] as int,
      90,
      name: 'Проверка интерфейса Lua',
    );
    await _addRealSkill(model);
    final life = model.state.report!.stats['Life'];
    expect(life, greaterThan(0));
    expect(model.state.document!.tree!.nodes.length, greaterThan(1000));
    expect(model.state.document!.tree!.icons.length, greaterThan(100));
    expect(model.state.document!.tree!.iconError, isNull);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('review-image'),
        child: PobApp(model: model, updates: updates, language: language),
      ),
    );
    await tester.pumpAndSettle();
    await _waitForImages(tester);
    await tester.pumpAndSettle();
    expect(model.state.document!.tree!.original, isNotNull);
    await _capture(tester);
    expect(find.byType(TreeView), findsOneWidget);
    await _searchAndAllocate(tester, model);
    await tester.pumpAndSettle();
    await _selectAttribute(tester, model);
    await _switchTheme(tester);
    await _searchNodePower(tester, model);
    expect(model.state.error, isNull);
    expect(model.state.report!.stats['Life'], greaterThan(0));
    final xml = await model.exportXml();
    final stats = model.state.report!.stats;
    await model.importXml(xml!);
    expect(model.state.report!.stats, stats);
    for (final tab in [
      'items',
      'skills',
      'conditions',
      'calculations',
      'tree',
    ]) {
      await tester.tap(find.byKey(ValueKey('tab-$tab')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await _localizeTree(tester, model, language);
    await tester.tap(find.byKey(const ValueKey('page-library')));
    await tester.pumpAndSettle();
    expect(find.text('Проверка интерфейса Lua'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<void> _capture(WidgetTester tester, {String suffix = ''}) async {
  final path = Platform.environment['POB2_UI_SCREENSHOT'];
  if (path == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('review-image')),
  );
  final image = await boundary.toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final output = File(path.replaceFirst('.png', '$suffix.png'));
  await output.parent.create(recursive: true);
  await output.writeAsBytes(data!.buffer.asUint8List());
  image.dispose();
}

Future<void> _switchTheme(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('appearance-settings')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Тёмная'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Готово'));
  await tester.pumpAndSettle();
  expect(
    Theme.of(tester.element(find.byType(Scaffold))).brightness,
    Brightness.dark,
  );
  await _capture(tester, suffix: '-dark');
  final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(find.byKey(const Key('passive-tree'))));
  await _waitForHover(tester);
  await _capture(tester, suffix: '-dark-hover');
  await mouse.moveTo(const Offset(4, 4));
  await mouse.removePointer();
  await tester.pumpAndSettle();
  final saved = await AppearanceRepository(InstallationStore.defaultRoot())
      .load();
  expect(saved, AppTheme.dark);
}

Future<void> _searchNodePower(WidgetTester tester, WorkshopCubit model) async {
  expect(model.engine.tools, contains('pob_node_power'));
  await tester.tap(find.byTooltip('Найти узлы по характеристике'));
  await tester.pump();
  expect(_powerButton(tester).selected, isTrue);
  final panel = find.byType(NodePowerPanel);
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (tester.widget<NodePowerPanel>(panel).model.state.metrics.isNotEmpty)
      break;
  }
  final power = tester.widget<NodePowerPanel>(panel).model;
  expect(power.state.error, isNull);
  final xml = await model.exportXml();
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('node-power-calculate')));
  for (
    var attempt = 0;
    attempt < 1800 && power.state.report == null;
    attempt++
  ) {
    await tester.pump(const Duration(milliseconds: 100));
    if (power.state.error != null) fail(power.state.error!);
  }
  expect(power.state.report!.entries, isNotEmpty);
  await tester.pumpAndSettle();
  final target = power.state.report!.entries.first['id'] as int;
  final viewer = tester.widget<InteractiveViewer>(
    find.byKey(const Key('passive-tree')),
  );
  final before = viewer.transformationController!.value.clone();
  await tester.tap(find.byKey(ValueKey('power-node-$target')));
  await tester.pumpAndSettle();
  expect(viewer.transformationController!.value, isNot(before));
  expect(await model.exportXml(), xml);
  await tester.pumpAndSettle();
  await _capture(tester, suffix: '-power');
  expect(tester.takeException(), isNull);
  await model.treeAction(target, false);
  await tester.pumpAndSettle();
  expect(power.state.report, isNull);
  await model.treeAction(target, true);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Найти узлы по характеристике'));
  await tester.pumpAndSettle();
  expect(_powerButton(tester).selected, isFalse);
}

ArtIconButton _powerButton(WidgetTester tester) => tester
    .widgetList<ArtIconButton>(find.byType(ArtIconButton))
    .firstWhere((button) => button.icon == 'chart');

Future<void> _localizeTree(
  WidgetTester tester,
  WorkshopCubit model,
  LanguageCubit language,
) async {
  final xml = await model.exportXml();
  final stats = model.state.report!.stats;
  await language.selectLanguage(AppLanguage.russian);
  expect(language.state.error, isNull);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('tree-search')));
  await tester.pump();
  await tester.enterText(find.byKey(const Key('tree-search')), 'Интеллект');
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  final painter = tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((widget) => widget.painter)
      .whereType<TreePainter>()
      .first;
  expect(painter.matches, isNotEmpty);
  expect(painter.query, 'Интеллект');
  expect(painter.scene.nodes[painter.selected]!.name, 'Intelligence');
  final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(find.byKey(const Key('passive-tree'))));
  await _waitForHover(tester);
  expect(
    find.descendant(
      of: find.byType(TreeHoverCard),
      matching: find.text('Интеллект'),
    ),
    findsOneWidget,
  );
  await _capture(tester, suffix: '-ru');
  await mouse.moveTo(const Offset(4, 4));
  await mouse.removePointer();
  await language.selectLanguage(AppLanguage.japanese);
  expect(language.state.error, isNull);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('tree-search')));
  await tester.pump();
  await tester.enterText(find.byKey(const Key('tree-search')), '知性');
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await _capture(tester, suffix: '-ja');
  expect(model.state.report!.stats, stats);
  expect(await model.exportXml(), xml);
  await language.selectLanguage(AppLanguage.russian);
  await tester.pumpAndSettle();
  expect(
    await LanguagePreferences(InstallationStore.defaultRoot()).load(),
    AppLanguage.russian,
  );
  expect(tester.takeException(), isNull);
}

Future<void> _selectAttribute(WidgetTester tester, WorkshopCubit model) async {
  final catalog = await model.engine.call('pob_catalog', {
    'kind': 'nodes',
    'query': 'Attribute',
    'limit': 200,
  });
  final candidates = jsonRows(catalog['entries'])
      .where(
        (node) =>
            node['allocated'] != true &&
            jsonRows(node['attributeOptions']).isNotEmpty,
      )
      .toList();
  candidates.sort((a, b) => (a['points'] as num).compareTo(b['points'] as num));
  final target = candidates.first['id'] as int;
  final before = model.state.report!.stats['Dex'];
  await tester.tap(find.byKey(const Key('tree-search')));
  await tester.pump();
  await tester.enterText(find.byKey(const Key('tree-search')), '$target');
  await tester.pump();
  final input = find.descendant(
    of: find.byKey(const Key('tree-search')),
    matching: find.byType(EditableText),
  );
  expect(tester.widget<EditableText>(input).controller.text, '$target');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getCenter(find.byKey(const Key('passive-tree'))));
  for (
    var attempt = 0;
    attempt < 100 && find.byKey(const Key('attribute-2')).evaluate().isEmpty;
    attempt++
  ) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (find.byKey(const Key('attribute-2')).evaluate().isEmpty) {
    await _capture(tester, suffix: '-attribute-error');
  }
  await tester.tap(find.byKey(const Key('attribute-2')));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await _capture(tester, suffix: '-attributes');
  await tester.tap(find.text('Выбрать путь'));
  await _waitForIdle(tester, model);
  final allocated = model.state.document!.tree!.nodes.firstWhere(
    (node) => node.id == target,
  );
  expect(allocated.allocated, isTrue);
  expect(allocated.name, 'Dexterity');
  expect(model.state.report!.stats['Dex'], greaterThan(before as num));
  await tester.pumpAndSettle();
  final nodes = model.state.report!.raw['allocatedNodes'];
  final points = model.state.report!.points;
  await tester.tapAt(tester.getCenter(find.byKey(const Key('passive-tree'))));
  await _waitForAttributePicker(tester);
  await tester.tap(find.byKey(const Key('attribute-3')));
  await tester.tap(find.text('Применить'));
  await _waitForIdle(tester, model);
  await tester.pumpAndSettle();
  final changed = model.state.document!.tree!.nodes.firstWhere(
    (node) => node.id == target,
  );
  expect(changed.allocated, isTrue);
  expect(changed.name, 'Intelligence');
  expect(model.state.report!.raw['allocatedNodes'], nodes);
  expect(model.state.report!.points, points);
  await tester.tapAt(tester.getCenter(find.byKey(const Key('passive-tree'))));
  await _waitForAttributePicker(tester);
  await tester.tap(find.text('Вернуть очко'));
  await _waitForIdle(tester, model);
  await tester.pumpAndSettle();
  expect(
    model.state.document!.tree!.nodes
        .firstWhere((node) => node.id == target)
        .allocated,
    isFalse,
  );
}

Future<void> _waitForAttributePicker(WidgetTester tester) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byKey(const Key('attribute-3')).evaluate().isNotEmpty) return;
  }
  fail('Не открылся выбор атрибута');
}

Future<void> _addRealSkill(WorkshopCubit model) async {
  final result = await model.engine.call('pob_catalog', {
    'kind': 'gems',
    'query': 'Fireball',
  });
  final gem = jsonRows(result['entries']).first;
  await model.engine.call('pob_add_skill_group', {
    'label': 'Огненный шар',
    'gems': [
      {'id': gem['id'], 'level': 1},
    ],
  });
  await model.refreshReport();
}

Future<void> _waitForImages(WidgetTester tester) async {
  for (var attempt = 0; attempt < 600; attempt++) {
    final error = find.byKey(const Key('tree-decode-error'));
    if (error.evaluate().isNotEmpty) fail(tester.widget<Text>(error).data!);
    final painters = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    final tree = painters
        .map((widget) => widget.painter)
        .whereType<TreePainter>()
        .first;
    if (tree.icons.length > 100) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Flutter не декодировал иконки дерева');
}

Future<void> _searchAndAllocate(
  WidgetTester tester,
  WorkshopCubit model,
) async {
  final tree = model.state.document!.tree!;
  final candidates = await model.engine.call('pob_catalog', {
    'kind': 'nodes',
    'query': 'Damage',
    'limit': 50,
  });
  final target = jsonRows(candidates['entries']).first['id'] as int;
  final node = tree.nodes.firstWhere((node) => node.id == target);
  await tester.enterText(find.byKey(const Key('tree-search')), '${node.id}');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  final viewer = find.byKey(const Key('passive-tree'));
  final center = tester.getCenter(viewer);
  final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(center);
  await _waitForHover(tester);
  final tooltip = tester.widget<TreeHoverCard>(find.byType(TreeHoverCard));
  expect(tooltip.title, node.name);
  expect(tooltip.state.preview!.path, contains(target));
  expect(tooltip.state.preview!.scene!.commands.length, greaterThan(2));
  expect(tooltip.state.preview!.path.length, greaterThan(1));
  expect(
    model.state.document!.tree!.nodes
        .firstWhere((entry) => entry.id == target)
        .allocated,
    isFalse,
  );
  await _capture(tester);
  await mouse.moveTo(const Offset(4, 4));
  await tester.pumpAndSettle();
  await tester.tapAt(center);
  await tester.pumpAndSettle();
  await _waitForIdle(tester, model);
  expect(
    model.state.document!.tree!.nodes
        .firstWhere((entry) => entry.id == target)
        .allocated,
    isTrue,
  );
  await tester.tapAt(center);
  await _waitForIdle(tester, model);
  expect(
    model.state.document!.tree!.nodes
        .firstWhere((entry) => entry.id == target)
        .allocated,
    isFalse,
  );
  await mouse.removePointer();
}

Future<void> _waitForHover(WidgetTester tester) async {
  for (var attempt = 0; attempt < 300; attempt++) {
    final card = find.byType(TreeHoverCard);
    if (card.evaluate().isNotEmpty) {
      final state = tester.widget<TreeHoverCard>(card).state;
      if (state.error != null) fail(state.error!);
      if (state.preview != null) return;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Подсказка Lua не появилась');
}

Future<void> _waitForIdle(WidgetTester tester, WorkshopCubit model) async {
  for (var attempt = 0; attempt < 300 && model.state.busy; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(model.state.busy, isFalse);
}
