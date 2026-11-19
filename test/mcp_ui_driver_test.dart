import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/mcp_editor_gateway.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/mcp_ui_driver.dart';

Future<JsonMap> drive(WidgetTester tester, Future<JsonMap> future) async {
  var complete = false;
  final result = future.whenComplete(() => complete = true);
  unawaited(result.catchError((Object _) => <String, dynamic>{}));
  for (var i = 0; i < 100 && !complete; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  return result;
}

Future<void> rejects(Future<JsonMap> Function() operation, String code) async {
  Object? error;
  try {
    await operation();
  } catch (value) {
    error = value;
  }
  expect(error, isA<McpEditorFault>().having((e) => e.code, 'code', code));
}

JsonMap node(JsonMap snapshot, String label, String action) =>
    jsonRows(snapshot['nodes']).firstWhere(
      (n) =>
          (n['label'] as String).contains(label) &&
          jsonStrings(n['actions']).contains(action),
      orElse: () => throw StateError('$label / $action: $snapshot'),
    );

Future<JsonMap> perform(
  WidgetTester tester,
  McpUiDriver driver,
  JsonMap snapshot,
  String label,
  String action, {
  Object? value,
}) => drive(
  tester,
  driver.perform({
    'snapshotId': snapshot['snapshotId'],
    'nodeId': node(snapshot, label, action)['id'],
    'operation': action,
    if (value != null) 'value': value,
  }),
);

void main() {
  testWidgets('MCP открывает и закрывает окно поверх поля поиска', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final driver = McpUiDriver(navigator);
    addTearDown(driver.dispose);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Поиск'),
                ),
                TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Полный DPS'),
                      content: SelectableText('1234'),
                    ),
                  ),
                  child: const Text('Открыть DPS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    var snapshot = await drive(tester, driver.snapshot());
    snapshot = await perform(tester, driver, snapshot, 'Открыть DPS', 'tap');
    expect(find.text('Полный DPS'), findsOneWidget);
    expect(snapshot['dialogOpen'], isTrue);
    await drive(tester, driver.closeDialog());
    await tester.pumpAndSettle();
    expect(find.text('Полный DPS'), findsNothing);
    expect(navigator.currentState!.canPop(), isFalse);
    driver.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('MCP заполняет форму, сохраняет и отклоняет устаревший снимок', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final driver = McpUiDriver(navigator);
    final text = TextEditingController();
    addTearDown(driver.dispose);
    addTearDown(text.dispose);
    String? saved;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialog) => AlertDialog(
                  content: TextField(
                    controller: text,
                    decoration: const InputDecoration(labelText: 'Название'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        saved = text.text;
                        Navigator.pop(dialog);
                      },
                      child: const Text('Сохранить'),
                    ),
                  ],
                ),
              ),
              child: const Text('Открыть форму'),
            ),
          ),
        ),
      ),
    );
    var snapshot = await drive(tester, driver.snapshot());
    snapshot = await perform(tester, driver, snapshot, 'Открыть форму', 'tap');
    snapshot = await perform(tester, driver, snapshot, 'Название', 'tap');
    snapshot = await perform(
      tester,
      driver,
      snapshot,
      'Название',
      'setText',
      value: 'Русское имя ✓',
    );
    expect(text.text, 'Русское имя ✓');
    await rejects(() => drive(tester, driver.closeDialog()), 'DIALOG_INPUT');
    expect(text.text, 'Русское имя ✓');
    snapshot = await drive(tester, driver.snapshot());
    final old = snapshot;
    text.text = 'Новое имя';
    await tester.pumpAndSettle();
    await rejects(
      () => perform(
        tester,
        driver,
        old,
        'Название',
        'setText',
        value: 'Устаревшее имя',
      ),
      'STALE_UI',
    );
    snapshot = await drive(tester, driver.snapshot());
    await perform(tester, driver, snapshot, 'Сохранить', 'tap');
    await tester.pumpAndSettle();
    expect(saved, 'Новое имя');
    expect(navigator.currentState!.canPop(), isFalse);
    snapshot = await drive(tester, driver.snapshot());
    await perform(tester, driver, snapshot, 'Открыть форму', 'tap');
    await drive(tester, driver.closeDialog(discard: true));
    await tester.pumpAndSettle();
    expect(navigator.currentState!.canPop(), isFalse);
    expect(saved, 'Новое имя');
    driver.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'MCP нажимает, перетаскивает, прокручивает и отправляет клавиши',
    (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      final driver = McpUiDriver(navigator);
      final scroll = ScrollController();
      addTearDown(driver.dispose);
      addTearDown(scroll.dispose);
      var taps = 0;
      var dragged = 0.0;
      var shortcuts = 0;
      var modifiedTaps = 0;
      var functionKeys = 0;
      var doubleTaps = 0;
      var longPresses = 0;
      var secondaryTaps = 0;
      const dragKey = Key('drag-area');
      await tester.pumpWidget(
        RepaintBoundary(
          key: driver.surface,
          child: MaterialApp(
            navigatorKey: navigator,
            home: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.f1): () =>
                    functionKeys++,
                const SingleActivator(
                  LogicalKeyboardKey.keyK,
                  control: true,
                ): () =>
                    shortcuts++,
              },
              child: Focus(
                autofocus: true,
                child: Scaffold(
                  body: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          taps++;
                          if (HardwareKeyboard.instance.isShiftPressed)
                            modifiedTaps++;
                        },
                        child: const Text('Нажать'),
                      ),
                      GestureDetector(
                        key: dragKey,
                        onDoubleTap: () => doubleTaps++,
                        onLongPress: () => longPresses++,
                        onSecondaryTap: () => secondaryTaps++,
                        onPanUpdate: (event) => dragged += event.delta.dx,
                        child: Container(
                          width: 200,
                          height: 80,
                          color: Colors.amber,
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scroll,
                          children: [
                            for (var i = 0; i < 40; i++)
                              SizedBox(height: 80, child: Text('Строка $i')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> gesture(
        String operation,
        Offset from, {
        Offset? to,
        Object? value,
        List<String> modifiers = const [],
        String button = 'primary',
      }) async {
        final snapshot = await drive(tester, driver.snapshot());
        await drive(
          tester,
          driver.interact({
            'action': 'gesture',
            'snapshotId': snapshot['snapshotId'],
            'operation': operation,
            'modifiers': modifiers,
            'button': button,
            'from': {'x': from.dx, 'y': from.dy},
            if (to != null) 'to': {'x': to.dx, 'y': to.dy},
            if (value != null) 'value': value,
          }),
        );
      }

      await gesture('tap', tester.getCenter(find.text('Нажать')));
      expect(taps, 1);
      await gesture(
        'tap',
        tester.getCenter(find.text('Нажать')),
        modifiers: ['shift'],
      );
      expect(modifiedTaps, 1);
      expect(HardwareKeyboard.instance.logicalKeysPressed, isEmpty);
      final from = tester.getCenter(find.byKey(dragKey));
      await gesture('doubleTap', from);
      expect(doubleTaps, 1);
      await gesture('longPress', from);
      expect(longPresses, 1);
      await gesture('tap', from, button: 'secondary');
      expect(secondaryTaps, 1);
      await gesture('drag', from, to: from + const Offset(70, 0));
      expect(dragged, greaterThan(30));
      await gesture(
        'scroll',
        tester.getCenter(find.byType(ListView)),
        value: {'x': 0, 'y': 300},
      );
      expect(scroll.offset, greaterThan(100));
      final snapshot = await drive(tester, driver.snapshot());
      await drive(
        tester,
        driver.interact({
          'action': 'key',
          'snapshotId': snapshot['snapshotId'],
          'key': 'k',
          'modifiers': ['control'],
        }),
      );
      expect(shortcuts, 1);
      final keys = await drive(tester, driver.snapshot());
      await drive(
        tester,
        driver.interact({
          'action': 'key',
          'snapshotId': keys['snapshotId'],
          'key': 'f1',
        }),
      );
      expect(functionKeys, 1);
      expect(HardwareKeyboard.instance.logicalKeysPressed, isEmpty);
      await rejects(
        () => gesture(
          'tap',
          const Offset(-1, 0),
          modifiers: ['control'],
        ).then((_) => <String, dynamic>{}),
        'INVALID_ARGUMENTS',
      );
      expect(HardwareKeyboard.instance.logicalKeysPressed, isEmpty);
      driver.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
