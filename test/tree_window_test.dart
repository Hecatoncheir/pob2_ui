import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/interface_scale_repository.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/core/tree_glass.dart';
import 'package:pob2_ui/ui/interface_scale_bloc.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/tree_view.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/workshop_fixture.dart';
import 'support/dispose_widget_bloc.dart';

void main() {
  for (final (size, percent) in [
    (const Size(360, 850), 100),
    (const Size(1280, 800), 100),
    (const Size(1920, 1080), 100),
    (const Size(1264, 681), 135),
    (const Size(1264, 681), 200),
  ]) {
    testWidgets(
      'Одна камера во всём окне и интерактивный центр: ${size.width}, $percent%',
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
        final scale = InterfaceScaleBloc(
          InterfaceScaleRepository(Directory('unused-tree-window')),
          initialPercent: percent,
        );
        await tester.pumpWidget(PobApp(model: model, interfaceScale: scale));
        await tester.pumpAndSettle();
        expect(find.byType(TreeView), findsOneWidget);
        final canvas = find.byKey(const Key('passive-tree'));
        final viewport = find.byKey(const Key('tree-interaction-viewport'));
        await tester.ensureVisible(viewport);
        await tester.pumpAndSettle();
        final canvasBox = tester.renderObject<RenderBox>(canvas);
        final viewportBox = tester.renderObject<RenderBox>(viewport);
        expect(tester.getSize(canvas), size / (percent / 100));
        final frost = tester.widget<TreeFrost>(find.byType(TreeFrost));
        final fullViewport = MatrixUtils.transformRect(
          viewportBox.getTransformTo(canvasBox),
          Offset.zero & viewportBox.size,
        );
        expect(frost.viewport!.intersect(fullViewport), frost.viewport);
        expect(
          frost.viewport!.intersect(Offset.zero & canvasBox.size),
          frost.viewport,
        );
        expect(frost.viewport!.height, lessThan(size.height));

        final camera = tester
            .widget<InteractiveViewer>(canvas)
            .transformationController!;
        final before = camera.value.clone();
        await tester.dragFrom(
          canvasBox.localToGlobal(frost.viewport!.center),
          const Offset(55, 20),
        );
        await tester.pumpAndSettle();
        expect(camera.value.storage[12], isNot(before.storage[12]));
        final search = find.byKey(const Key('tree-search'));
        await tester.ensureVisible(search);
        await tester.pumpAndSettle();
        await tester.enterText(search, '2');
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        await tester.ensureVisible(viewport);
        await tester.pumpAndSettle();
        final painter = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((widget) => widget.painter)
            .whereType<TreePainter>()
            .single;
        final nodePosition = canvasBox.localToGlobal(
          MatrixUtils.transformPoint(camera.value, painter.scene.points[2]!),
        );
        final visible = tester.widget<TreeFrost>(find.byType(TreeFrost));
        final center = canvasBox.localToGlobal(visible.viewport!.center);
        expect((nodePosition - center).distance, lessThan(.01));
        final mouse = await tester.createGesture(
          kind: ui.PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(center);
        await tester.pump();
        expect(
          tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .map((widget) => widget.painter)
              .whereType<TreePainter>()
              .single
              .hovered,
          2,
        );
        await mouse.removePointer();
        await tester.pumpAndSettle();
        final focus = camera.toScene(visible.viewport!.center);
        final items = find.byKey(const ValueKey('tab-items'));
        await tester.ensureVisible(items);
        await tester.tap(items);
        await tester.pumpAndSettle();
        expect(find.byType(TreeFrost), findsNothing);
        final treeTab = find.byKey(const ValueKey('tab-tree'));
        await tester.ensureVisible(treeTab);
        await tester.tap(treeTab);
        await tester.pumpAndSettle();
        await tester.ensureVisible(viewport);
        await tester.pumpAndSettle();
        expect(find.byType(TreeFrost), findsOneWidget);
        final restored = tester.widget<TreeFrost>(find.byType(TreeFrost));
        expect(
          (camera.toScene(restored.viewport!.center) - focus).distance,
          lessThan(.01),
        );
        expect(model.state.report, same(fixture));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await disposeWidgetBloc(tester, scale);
      },
    );
  }
}
