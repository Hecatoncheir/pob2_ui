import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/tree_allocation_mode.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/tree_point_counters.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

class ModeEngine extends McpClient {
  ModeEngine() {
    tools = {'pob_tree_options'};
  }
  int mode = 0;
  bool reject = false;
  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    switch (name) {
      case 'pob_tree_options':
        if (reject) throw StateError('Lua отклонил режим');
        mode = arguments['mode'] as int;
        return {};
      case 'pob_import_xml':
        mode = 0;
        return {};
      case 'pob_check_build':
        return {'report': fixture.raw};
      case 'pob_export_xml':
        return {'xml': '<PathOfBuilding2/>'};
      default:
        throw StateError(name);
    }
  }
}

void main() {
  test('Режим подтверждается Lua; отказ не меняет выбор, импорт восстанавливает выбранный режим', () async {
    final root = await Directory.systemTemp.createTemp('pob2-tree-mode-');
    addTearDown(() => removeTemporaryDirectory(root));
    final engine = ModeEngine();
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(root)),
      engine,
      initialState: WorkshopState(
        document: (report: fixture, tree: tree, stale: false, treeError: null),
      ),
    );
    addTearDown(model.close);
    await model.selectTreeMode(TreeAllocationMode.weaponOne);
    expect(engine.mode, 1);
    expect(model.state.treeMode, TreeAllocationMode.weaponOne);
    engine.reject = true;
    await model.selectTreeMode(TreeAllocationMode.weaponTwo);
    expect(model.state.treeMode, TreeAllocationMode.weaponOne);
    expect(model.state.error, contains('Lua отклонил режим'));
    engine.reject = false;
    await model.selectTreeMode(TreeAllocationMode.weaponTwo);
    await model.importXml('<PathOfBuilding2/>');
    expect(engine.mode, 2);
    expect(model.state.treeMode, TreeAllocationMode.weaponTwo);
    expect(model.state.error, isNull);
    await model.selectTreeMode(TreeAllocationMode.common);
    expect(engine.mode, 0);
  });

  testWidgets('Счётчики переключают только общие узлы и два набора оружия', (
    tester,
  ) async {
    var mode = TreeAllocationMode.common;
    await tester.pumpWidget(
      MaterialApp(
        theme: Spark.theme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => TreePointCounters(
              '1 / 123 2 / 24 3 / 24 0 / 8',
              mode: mode,
              onModeChanged: (value) => update(() => mode = value),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('tree-mode-1')));
    await tester.pumpAndSettle();
    expect(mode, TreeAllocationMode.weaponOne);
    await tester.tap(find.byKey(const Key('tree-mode-2')));
    await tester.pumpAndSettle();
    expect(mode, TreeAllocationMode.weaponTwo);
    await tester.tap(find.byKey(const Key('tree-mode-0')));
    await tester.pumpAndSettle();
    expect(mode, TreeAllocationMode.common);
    expect(find.byKey(const Key('tree-mode-3')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
