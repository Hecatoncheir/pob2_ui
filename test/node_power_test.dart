import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/node_power_cubit.dart';
import 'package:pob2_ui/ui/node_power_panel.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/workshop_fixture.dart';

class PowerEngine extends McpClient {
  PowerEngine() {
    tools = {'pob_node_power'};
  }
  final requests = <JsonMap>[];
  Completer<JsonMap>? delayedPoll;
  Completer<JsonMap>? delayedCancel;
  int nextJob = 0;
  late JsonMap result = _report();
  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    requests.add(arguments);
    return switch (arguments['action']) {
      'catalog' => {
        'entries': [
          {'id': 'Evasion', 'label': 'Evasion'},
          {'id': 'Life', 'label': 'Life'},
        ],
      },
      'start' => {'job': ++nextJob},
      'cancel' => delayedCancel?.future ?? Future.value({'cancelled': true}),
      'poll' => delayedPoll?.future ?? Future.value(result),
      _ => throw StateError('Неизвестное действие'),
    };
  }
}

JsonMap _report() => {
  'complete': true,
  'progress': 100,
  'entries': [
    {
      'id': 1,
      'name': 'Уклонение',
      'powerStr': '^x33FF7716',
      'pathDist': 2,
      'pathPowerStr': '^x33FF778',
      'sd': ['+16 to Evasion'],
    },
  ],
  'scene': {
    'scale': 1,
    'offsetX': 0,
    'offsetY': 0,
    'width': 100,
    'height': 100,
    'commands': [],
  },
};

void main() {
  test('Назначение убирает только выбранный узел; остальные строки остаются до нового отчёта Lua', () async {
    final engine = PowerEngine();
    engine.result['entries'] = [
      ...jsonRows(engine.result['entries']),
      {
        ...jsonRows(engine.result['entries']).first,
        'id': 2,
        'name': 'Другой узел',
      },
    ];
    final model = NodePowerCubit(engine, (_) async => {});
    addTearDown(model.close);
    await model.load();
    await model.calculate();
    await model.cancel(preserveReport: true);
    expect(model.state.report!.entries.length, 2);
    expect(model.state.stale, isTrue);
    engine.delayedPoll = Completer<JsonMap>();
    final pending = model.refresh({1});
    while (engine.requests.where((r) => r['action'] == 'poll').length < 2) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(model.state.report!.entries.single['id'], 2);
    expect(model.state.progress, isNotNull);
    engine.delayedPoll!.complete({
      ..._report(),
      'entries': [
        {...jsonRows(_report()['entries']).first, 'id': 2, 'powerStr': '24'},
      ],
    });
    await pending;
    expect(model.state.stale, isFalse);
    expect(model.state.report!.entries.single['powerStr'], '24');
  });
  test(
    'Расстояние и фильтр передаются Lua; устаревший ответ игнорируется',
    () async {
      final engine = PowerEngine();
      final model = NodePowerCubit(engine, (_) async => {});
      addTearDown(model.close);
      await model.load();
      await model.configure((stat: 'Life', distance: null, allocation: 'all'));
      await model.calculate();
      expect(engine.requests.firstWhere((r) => r['action'] == 'start'), {
        'action': 'start',
        'stat': 'Life',
      });
      expect(engine.requests.last['allocation'], 'all');
      expect(model.state.report!.entries.single['powerStr'], '^x33FF7716');
      engine.delayedPoll = Completer<JsonMap>();
      final pending = model.calculate();
      while (engine.requests.where((r) => r['action'] == 'poll').length < 2) {
        await Future<void>.delayed(Duration.zero);
      }
      await model.configure((
        stat: 'Evasion',
        distance: 5,
        allocation: 'unallocated',
      ));
      engine.delayedPoll!.complete(_report());
      await pending;
      expect(model.state.report, isNull);
      expect(model.state.progress, isNull);
      expect(model.state.options.distance, 5);
    },
  );

  test('Медленная отмена не перезаписывает последний выбор', () async {
    final engine = PowerEngine();
    final model = NodePowerCubit(engine, (_) async => {});
    await model.load();
    await model.calculate();
    engine.delayedCancel = Completer<JsonMap>();
    final first = model.configure((
      stat: 'Life',
      distance: 15,
      allocation: 'all',
    ));
    await model.configure((
      stat: 'Evasion',
      distance: 5,
      allocation: 'unallocated',
    ));
    engine.delayedCancel!.complete({'cancelled': true});
    await first;
    expect(model.state.options, (
      stat: 'Evasion',
      distance: 5,
      allocation: 'unallocated',
    ));
    await model.close();
  });

  for (final (width, brightness) in [
    (320.0, Brightness.light),
    (700.0, Brightness.light),
    (320.0, Brightness.dark),
    (700.0, Brightness.dark),
  ]) {
    testWidgets(
      'Панель узлов: список, фокус и отмена своего расстояния, $width, $brightness',
      (tester) async {
        final model = NodePowerCubit(PowerEngine(), (_) async => {});
        await model.load();
        await model.calculate();
        int? focused;
        await tester.pumpWidget(
          MaterialApp(
            theme: Spark.theme(brightness: brightness),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  height: 250,
                  child: NodePowerPanel(
                    model: model,
                    onFocus: (id) => focused = id,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('power-node-1')));
        expect(focused, 1);
        final report = model.state.report;
        final collapse = find.byKey(const Key('node-power-collapse'));
        await tester.tap(collapse);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('node-power-results')), findsNothing);
        expect(find.byKey(const Key('node-power-stat')), findsOneWidget);
        expect(model.state.report, same(report));
        await tester.tap(collapse);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('power-node-1')), findsOneWidget);
        await tester.tap(find.byKey(const Key('node-power-stat')));
        await tester.pumpAndSettle();
        final menuText = find.text('Здоровье').last;
        final foreground = DefaultTextStyle.of(tester.element(menuText))
            .style
            .color;
        expect(
          foreground,
          Spark.theme(brightness: brightness).colorScheme.onSurface,
        );
        await tester.tap(menuText);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('node-power-distance')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Свои…').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Отмена'));
        await tester.pumpAndSettle();
        final distance = tester.widget<DropdownButton<int>>(
          find.byKey(const Key('node-power-distance')),
        );
        expect(distance.value, 10);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await model.close();
      },
    );
  }

  testWidgets('Длинный список оставляет место дереву; значки различаются', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1028, 681));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final engine = PowerEngine()
      ..tools = {'pob_node_power', 'pob_tree_textures'};
    engine.result['entries'] = [
      for (var id = 1; id <= 50; id++)
        {...jsonRows(_report()['entries']).single, 'id': id},
    ];
    final root = Directory('unused-node-power-test');
    final components = ComponentRepository(store: InstallationStore(root))
      ..active = {
        for (final component in Component.values)
          component: Installation(
            tag: 'test',
            commit: 'test',
            directory: root.path,
          ),
      };
    final model = WorkshopCubit(
      components,
      engine,
      initialState: WorkshopState(
        document: (report: fixture, tree: tree, stale: false, treeError: null),
      ),
    );
    addTearDown(model.close);
    await tester.pumpWidget(PobApp(model: model));
    await tester.pumpAndSettle();
    final treeCanvas = find.byKey(const Key('passive-tree'));
    final originalHeight = tester.getSize(treeCanvas).height;
    expect(find.byIcon(Icons.manage_search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.leaderboard_outlined), findsOneWidget);
    await tester.tap(find.byKey(const Key('node-power-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('node-power-calculate')));
    await tester.pumpAndSettle();
    final panel = find.byKey(const Key('node-power-panel'));
    final scroll = find.descendant(
      of: panel,
      matching: find.byType(Scrollable),
    );
    expect(
      tester.getTopLeft(find.text('Характеристика')).dy,
      greaterThanOrEqualTo(tester.getTopLeft(scroll).dy),
    );
    expect(find.byKey(const ValueKey('power-node-1')), findsOneWidget);
    expect(tester.getSize(panel).height, lessThanOrEqualTo(210));
    expect(tester.getSize(treeCanvas).height, greaterThan(originalHeight * .4));
    await tester.drag(
      find.byKey(const ValueKey('power-node-1')),
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(scroll).position.pixels,
      greaterThan(0),
    );
    expect(
      find.byKey(const Key('node-power-stat')).hitTestable(),
      findsOneWidget,
    );
    final expandedHeight = tester.getSize(treeCanvas).height;
    await tester.tap(find.byKey(const Key('node-power-collapse')));
    await tester.pumpAndSettle();
    expect(tester.getSize(treeCanvas).height, greaterThan(expandedHeight));
    await tester.tap(find.byKey(const ValueKey('tab-conditions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-statistics')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('statistics-header')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
