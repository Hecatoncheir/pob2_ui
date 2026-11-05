import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/node_power_cubit.dart';
import 'package:pob2_ui/ui/node_power_panel.dart';

class PowerEngine extends McpClient {
  PowerEngine() {
    tools = {'pob_node_power'};
  }
  final requests = <JsonMap>[];
  Completer<JsonMap>? delayedPoll;
  Completer<JsonMap>? delayedCancel;
  int nextJob = 0;
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
      'poll' => delayedPoll?.future ?? Future.value(_report()),
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

  for (final width in [320.0, 700.0]) {
    testWidgets(
      'Панель узлов: список, фокус и отмена своего расстояния, $width',
      (tester) async {
        final model = NodePowerCubit(PowerEngine(), (_) async => {});
        await model.load();
        await model.calculate();
        int? focused;
        await tester.pumpWidget(
          MaterialApp(
            theme: Spark.theme(),
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
}
