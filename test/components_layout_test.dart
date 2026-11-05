import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/components_view.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

void main() {
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
