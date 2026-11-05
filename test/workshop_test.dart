import 'support/workshop_fixture.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';
import 'package:pob2_ui/data/interface_scale_repository.dart';
import 'package:pob2_ui/ui/interface_scale_cubit.dart';

void main() {
  testWidgets('Рабочее дерево при масштабе 200% в небольшом окне', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final model = WorkshopCubit(
      ComponentRepository(
        store: InstallationStore(Directory('test-components')),
      ),
      McpClient(),
      initialState: WorkshopState(
        document: (report: fixture, tree: tree, stale: false, treeError: null),
      ),
    );
    final scale = InterfaceScaleCubit(
      InterfaceScaleRepository(Directory('test-components')),
      initialPercent: 200,
    );
    await tester.pumpWidget(PobApp(model: model, interfaceScale: scale));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('tree-search')));
    await tester.tap(find.byKey(const Key('tree-search')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await scale.close();
    await model.close();
  });
  for (final size in const [
    Size(360, 800),
    Size(768, 850),
    Size(1366, 768),
    Size(1920, 1080),
  ]) {
    testWidgets('Новая навигация без переполнения: ${size.width}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(Directory('test-components')),
        ),
        McpClient(),
      );
      addTearDown(model.close);
      await tester.pumpWidget(PobApp(model: model));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ваша следующая сборка'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('page-components')));
      await tester.pumpAndSettle();
      expect(find.text('Проверить обновления'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('page-library')));
      await tester.pumpAndSettle();
      expect(find.text('Здесь будут ваши сборки'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Отчёт, предупреждения и пять разделов: ${size.width}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(Directory('test-components')),
        ),
        McpClient(),
        initialState: WorkshopState(
          document: (
            report: fixture,
            tree: tree,
            stale: false,
            treeError: null,
          ),
        ),
      );
      addTearDown(model.close);
      await tester.pumpWidget(PobApp(model: model));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Предупреждения: 1'), findsOneWidget);
      await tester.tap(find.text('Предупреждения: 1'));
      await tester.pumpAndSettle();
      expect(find.text('Недостаточно интеллекта'), findsOneWidget);
      await tester.tap(find.text('Закрыть'));
      await tester.pumpAndSettle();
      for (final tab in [
        'Предметы',
        'Умения',
        'Условия',
        'Расчёты',
        'Дерево',
      ]) {
        final finder = find.text(tab).first;
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
