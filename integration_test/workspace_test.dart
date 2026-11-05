import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/tree_view.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

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
        child: PobApp(model: model),
      ),
    );
    await tester.pumpAndSettle();
    await _waitForImages(tester);
    await tester.pumpAndSettle();
    expect(model.state.document!.tree!.original, isNotNull);
    await _capture(tester);
    expect(find.byType(TreeView), findsOneWidget);
    await _searchAndAllocate(tester, model);
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
    await tester.tap(find.byKey(const ValueKey('page-library')));
    await tester.pumpAndSettle();
    expect(find.text('Проверка интерфейса Lua'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<void> _capture(WidgetTester tester) async {
  final path = Platform.environment['POB2_UI_SCREENSHOT'];
  if (path == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('review-image')),
  );
  final image = await boundary.toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final output = File(path);
  await output.parent.create(recursive: true);
  await output.writeAsBytes(data!.buffer.asUint8List());
  image.dispose();
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
  for (var attempt = 0; attempt < 150; attempt++) {
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
  final start = tree.nodes.firstWhere((node) => node.allocated);
  final edge = tree.edges.firstWhere(
    (edge) => edge.$1 == start.id || edge.$2 == start.id,
  );
  final target = edge.$1 == start.id ? edge.$2 : edge.$1;
  final node = tree.nodes.firstWhere((node) => node.id == target);
  await tester.enterText(find.byKey(const Key('tree-search')), '${node.id}');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  final viewer = find.byKey(const Key('passive-tree'));
  await tester.tapAt(tester.getCenter(viewer));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Подробнее'));
  await tester.pumpAndSettle();
  await _waitFor(tester, find.text('Выбрать путь'));
  await tester.tap(find.text('Выбрать путь'));
  await tester.pumpAndSettle();
  await _waitForIdle(tester, model);
  expect(
    model.state.document!.tree!.nodes
        .firstWhere((entry) => entry.id == target)
        .allocated,
    isTrue,
  );
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 150 && finder.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget);
}

Future<void> _waitForIdle(WidgetTester tester, WorkshopCubit model) async {
  for (var attempt = 0; attempt < 300 && model.state.busy; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(model.state.busy, isFalse);
}
