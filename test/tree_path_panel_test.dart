import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/legacy/component_repository.dart';

import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/domain/tree_allocation_mode.dart';
import 'package:pob2_ui/domain/tree_geometry.dart';
import 'package:pob2_ui/domain/tree_path_comparison.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/tree_path_cubit.dart';
import 'package:pob2_ui/ui/tree_path_panel.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/workshop_fixture.dart';

class _PanelWorkshop extends WorkshopCubit {
  _PanelWorkshop()
    : super(
        ComponentRepository(
          store: InstallationStore(Directory('unused-path-panel')),
        ),
        WorkbenchClient(),
      );

  @override
  bool get canCompareTreePaths => true;

  @override
  bool isTreePathCurrent(TreePathComparison comparison) => true;

  @override
  Future<TreePathComparison> compareTreePaths(int first, int second) async {
    final option = (
      target: first,
      points: 8,
      nodes: <int>[first],
      stats: (dps: 23.78075, life: 1218),
      xml: '',
    );
    return TreePathComparison(
      source: fixture,
      sourceRevision: '',
      buildId: null,
      componentSource: 'fixture',
      mode: TreeAllocationMode.weaponTwo,
      weaponSet: 2,
      reports: (
        baseline: (dps: 19.482916666667, life: 1187),
        first: option,
        second: (
          target: second,
          points: 4,
          nodes: <int>[second],
          stats: (dps: 24.61, life: 1187),
          xml: '',
        ),
      ),
    );
  }
}

void main() {
  for (final width in [360.0, 1280.0, 1920.0]) {
    for (final scale in [.75, 1.0, 2.0]) {
      testWidgets('Панель I/II доступна при ширине $width и масштабе $scale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final workshop = _PanelWorkshop();
        final cubit = TreePathCubit(workshop)..toggle();
        addTearDown(cubit.close);
        addTearDown(workshop.close);
        final nodes = {
          for (final id in [11, 22])
            id: TreeNode(
              id: id,
              x: id.toDouble(),
              y: 0,
              name: 'Длинное название целевого пассивного узла $id',
              kind: 'Normal',
              allocated: false,
            ),
        };
        for (final node in nodes.values) {
          cubit.pick(node);
        }
        await cubit.calculate();
        await tester.pumpWidget(
          MaterialApp(
            theme: Spark.theme(),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: width / scale,
                    height: 270 / scale,
                    child: TreePathPanel(cubit: cubit, nodes: nodes),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Оружие II'), findsOneWidget);
        expect(find.text('Активное оружие · II'), findsOneWidget);
        final apply = find.byKey(const Key('apply-tree-path-b'));
        await tester.ensureVisible(apply);
        await tester.pumpAndSettle();
        expect(apply.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
