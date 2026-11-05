import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

void main() {
  for (final size in const [Size(360, 800), Size(1280, 900)]) {
    testWidgets('Навигация без переполнения при ширине ${size.width}', (
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
      expect(find.text('Проверить обновления'), findsOneWidget);
      await tester.tap(find.text('Сборка').last);
      await tester.pumpAndSettle();
      expect(find.text('Сборка начинается здесь'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Показатели появятся после расчёта сборки.'),
        250,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Показатели появятся после расчёта сборки.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
