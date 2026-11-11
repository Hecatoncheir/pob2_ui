import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/interface_scale_repository.dart';
import 'package:pob2_ui/ui/interface_scale_bloc.dart';
import 'package:pob2_ui/ui/interface_scale_picker.dart';
import 'package:pob2_ui/ui/interface_viewport.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';
import 'support/dispose_widget_bloc.dart';

class MemoryScale extends InterfaceScaleRepository {
  MemoryScale() : super(Directory('unused-scale-test'));
  int percent = 100;
  @override
  Future<void> save(int value) async => percent = value;
}

class DelayedScale extends InterfaceScaleRepository {
  DelayedScale(super.root);
  final first = Completer<void>();
  int writes = 0;
  @override
  Future<void> save(int value) async {
    if (++writes == 1) await first.future;
    return super.save(value);
  }
}

Future<void> shortcut(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Настройки закрываются после исчезновения открывшей их боковой панели',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final scale = InterfaceScaleBloc(MemoryScale());
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(Directory('unused-scale-test')),
        ),
        McpClient(),
      );
      await tester.pumpWidget(PobApp(model: model, interfaceScale: scale));
      await tester.pumpAndSettle();
      final opener = tester.element(
        find.byKey(const Key('appearance-settings')),
      );
      await tester.tap(find.byKey(const Key('appearance-settings')));
      await tester.pumpAndSettle();
      scale.add(const InterfaceScaleSet(135));
      await tester.pumpAndSettle();
      expect(opener.mounted, isFalse);
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await disposeWidgetBloc(tester, scale);
      await model.close();
    },
  );
  test('Масштаб сохраняет последний выбор и восстанавливается в допустимых границах', () async {
    final root = await Directory.systemTemp.createTemp('pob2-scale-');
    addTearDown(() => removeTemporaryDirectory(root));
    final repository = DelayedScale(root);
    final scale = InterfaceScaleBloc(repository);
    scale
      ..add(const InterfaceScaleSet(125))
      ..add(const InterfaceScaleAdjusted(10))
      ..add(const InterfaceScaleAdjusted(15));
    await Future<void>.delayed(Duration.zero);
    repository.first.complete();
    await scale.close();
    expect(await InterfaceScaleRepository(root).load(), 150);
    final next = InterfaceScaleBloc(
      InterfaceScaleRepository(root),
      initialPercent: await repository.load(),
    );
    expect(next.state.percent, 150);
    final changes = next.stream.take(2).map((state) => state.percent).toList();
    next
      ..add(const InterfaceScaleSet(999))
      ..add(const InterfaceScaleSet(-20));
    expect(await changes, [200, 75]);
    await next.close();
    await repository.file.writeAsString('{broken');
    expect(await repository.load(), 100);
  });

  testWidgets(
    'Ctrl масштабирует весь интерфейс и сохраняет ввод и нажатия, включая диалоги',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = MemoryScale();
      final scale = InterfaceScaleBloc(repository);
      final input = TextEditingController(text: 'unchanged');
      var taps = 0;
      const marker = Key('scale-marker');
      await tester.pumpWidget(
        BlocProvider.value(
          value: scale,
          child: MaterialApp(
            theme: Spark.theme(),
            builder: (context, child) =>
                InterfaceViewport(motion: false, child: child!),
            home: Scaffold(
              body: Column(
                children: [
                  TextField(controller: input),
                  GestureDetector(
                    onTap: () => taps++,
                    child: const SizedBox(
                      key: marker,
                      width: 100,
                      height: 40,
                      child: ColoredBox(color: Colors.green),
                    ),
                  ),
                  const InterfaceScalePicker(),
                  Builder(
                    builder: (context) => TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) =>
                            const AlertDialog(content: Text('Dialog')),
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await shortcut(tester, LogicalKeyboardKey.equal);
      expect(scale.state.percent, 110);
      expect(input.text, 'unchanged');
      expect(tester.getSize(find.byKey(marker)).width, closeTo(100, .1));
      expect(tester.getRect(find.byKey(marker)).width, closeTo(110, .1));
      expect(
        MediaQuery.sizeOf(tester.element(find.byKey(marker))).width,
        closeTo(1200 / 1.1, .1),
      );
      await tester.tap(find.byKey(marker));
      expect(taps, 1);
      await shortcut(tester, LogicalKeyboardKey.minus);
      expect(scale.state.percent, 100);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await shortcut(tester, LogicalKeyboardKey.equal);
      expect(scale.state.percent, 110);
      await shortcut(tester, LogicalKeyboardKey.digit0);
      expect(scale.state.percent, 100);
      expect(repository.percent, 100);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await disposeWidgetBloc(tester, scale);
      input.dispose();
    },
  );
}
