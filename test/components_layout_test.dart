import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_window_repository.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/components_view.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/pob_bridge_cubit.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

void main() {
  const mcp = Installation(tag: '', commit: '', directory: '');

  test('При нескольких установках мост ждёт явного выбора папки', () async {
    final repository = _WindowRepository(['C:/PoB', 'D:/PoB']);
    final cubit = PobBridgeCubit(repository, mcp);
    addTearDown(cubit.close);
    await cubit.discover();
    expect(cubit.state.target.directory, isNull);
    await cubit.install();
    expect(repository.installed, isNull);
    cubit.select('E:/Portable PoB');
    await cubit.install();
    expect(repository.installed, 'E:/Portable PoB');
    expect(cubit.state.target.candidates, containsAll(['C:/PoB', 'D:/PoB']));
  });

  testWidgets('Мост находит PoB и устанавливается только по кнопке', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _WindowRepository();
    final components = ComponentRepository(
      store: InstallationStore(Directory('unused-bridge-test')),
    );
    components.active = {Component.mcp: mcp};
    final model = WorkshopCubit(components, McpClient(), pobWindow: repository);
    addTearDown(model.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: Spark.theme(),
        home: Scaffold(body: ComponentsView(model: model)),
      ),
    );
    await tester.tap(find.text('Настроить мост PoB'));
    await tester.pumpAndSettle();
    expect(find.text('C:/PoB'), findsOneWidget);
    expect(repository.installed, isNull);
    expect(find.text('Перезапустить PoB'), findsNothing);
    await tester.tap(find.text('Подключить мост'));
    await tester.pumpAndSettle();
    expect(repository.installed, 'C:/PoB');
    expect(find.textContaining('Перезапустите PoB'), findsOneWidget);
    await tester.tap(find.text('Проверить связь'));
    await tester.pumpAndSettle();
    expect(repository.checked, 'C:/PoB');
    expect(
      find.text('Связь с открытой сборкой PoB подтверждена'),
      findsOneWidget,
    );
    final restart = find.text('Перезапустить PoB');
    repository.rejectRestart = true;
    await tester.tap(restart);
    await tester.pumpAndSettle();
    expect(find.text('PoB ещё открыт'), findsOneWidget);
    expect(restart, findsOneWidget);
    repository.rejectRestart = false;
    await tester.tap(restart);
    await tester.pumpAndSettle();
    expect(repository.restarted, 'C:/PoB');
    expect(find.textContaining('Связь с PoB подтверждена'), findsOneWidget);
    expect(restart, findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [420.0, 1200.0]) {
    testWidgets('Карточки компонентов адаптируются к ширине $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(Directory('unused-components-test')),
        ),
        McpClient(),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: Spark.theme(),
          home: Scaffold(body: ComponentsView(model: model)),
        ),
      );
      await tester.pumpAndSettle();
      final pob = tester.getRect(find.byKey(const Key('component-card-pob')));
      final mcp = tester.getRect(find.byKey(const Key('component-card-mcp')));
      if (width > 760) {
        expect(pob.top, mcp.top);
        expect(mcp.left, greaterThan(pob.right));
      } else {
        expect(mcp.top, greaterThan(pob.bottom));
        expect(pob.left, mcp.left);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await model.close();
    });
  }
}

class _WindowRepository extends PobWindowRepository {
  _WindowRepository([this.directories = const ['C:/PoB']]);

  final List<String> directories;
  String? installed;
  String? checked;
  String? restarted;
  bool rejectRestart = false;

  @override
  bool get supported => true;

  @override
  Future<List<String>> findInstallations(Installation mcp) async => directories;

  @override
  Future<void> installBridge(Installation mcp, String directory) async {
    installed = directory;
  }

  @override
  Future<void> checkBridge(Installation mcp, String directory) async {
    checked = directory;
  }

  @override
  Future<void> restartAndCheckBridge(Installation mcp, String directory) async {
    if (rejectRestart) throw StateError('PoB ещё открыт');
    restarted = directory;
  }
}
