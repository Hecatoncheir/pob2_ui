import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/core/tree_glass.dart';
import 'package:pob2_ui/ui/tree_view.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/workshop_fixture.dart';

void main() {
  for (final size in [
    const Size(360, 850),
    const Size(1280, 800),
    const Size(1920, 1080),
  ]) {
    testWidgets(
      'Одна камера во всём окне и интерактивный центр: ${size.width}',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final model = WorkshopCubit(
          ComponentRepository(
            store: InstallationStore(Directory('unused-tree-window')),
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
        expect(find.byType(TreeView), findsOneWidget);
        final canvas = find.byKey(const Key('passive-tree'));
        final viewport = find.byKey(const Key('tree-interaction-viewport'));
        expect(tester.getSize(canvas), size);
        final frost = tester.widget<TreeFrost>(find.byType(TreeFrost));
        expect(frost.viewport, tester.getRect(viewport));
        expect(frost.viewport!.height, lessThan(size.height));

        final camera = tester
            .widget<InteractiveViewer>(canvas)
            .transformationController!;
        final before = camera.value.clone();
        await tester.dragFrom(tester.getCenter(viewport), const Offset(55, 20));
        await tester.pumpAndSettle();
        expect(camera.value.storage[12], isNot(before.storage[12]));
        final moved = camera.value.clone();
        final items = find.byKey(const ValueKey('tab-items'));
        await tester.ensureVisible(items);
        await tester.tap(items);
        await tester.pumpAndSettle();
        expect(find.byType(TreeFrost), findsNothing);
        final treeTab = find.byKey(const ValueKey('tab-tree'));
        await tester.ensureVisible(treeTab);
        await tester.tap(treeTab);
        await tester.pumpAndSettle();
        expect(find.byType(TreeFrost), findsOneWidget);
        expect(camera.value, moved);
        expect(model.state.report, same(fixture));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
