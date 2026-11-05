import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

class HistoryEngine extends McpClient {
  int value = 0;
  bool reject = false;
  final imported = <String>[];
  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    switch (name) {
      case 'pob_export_xml':
        return {'xml': '<build value="$value"/>'};
      case 'pob_import_xml':
        if (reject) throw StateError('Lua отклонил восстановление');
        final xml = arguments['xml'] as String;
        imported.add(xml);
        value = int.parse(RegExp(r'\d+').firstMatch(xml)![0]!);
        return {};
      case 'pob_tree_action':
        if (reject) throw StateError('Lua отклонил изменение');
        value++;
        return {};
      case 'pob_set_config':
        return {};
      case 'pob_check_build':
        return {'report': fixture.raw};
      default:
        throw StateError(name);
    }
  }
}

void main() {
  test('Отмена восстанавливает последовательные XML через Lua; отказ сохраняет историю', () async {
    final root = await Directory.systemTemp.createTemp('pob2-undo-');
    addTearDown(() => removeTemporaryDirectory(root));
    final engine = HistoryEngine();
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(root)),
      engine,
      initialState: WorkshopState(
        document: (report: fixture, tree: tree, stale: false, treeError: null),
      ),
    );
    addTearDown(model.close);
    await model.treeAction(1, false);
    await model.treeAction(2, false);
    expect(model.state.undoCount, 2);
    engine.reject = true;
    await model.undo();
    expect(model.state.undoCount, 2);
    expect(engine.value, 2);
    engine.reject = false;
    await model.undo();
    expect(engine.value, 1);
    expect(model.state.undoCount, 1);
    await model.undo();
    expect(engine.value, 0);
    expect(model.state.undoCount, 0);
    await model.undo();
    expect(engine.imported, ['<build value="1"/>', '<build value="0"/>']);
    await model.setCondition('noop', true);
    expect(model.state.undoCount, 0);
    final title = model.state.library.active!.title;
    await model.renameBuild('Новое название');
    expect(model.state.undoCount, 1);
    await model.undo();
    expect(model.state.library.active!.title, title);
    engine.reject = true;
    await model.treeAction(3, false);
    expect(model.state.undoCount, 0);
    engine.reject = false;
    await model.treeAction(3, false);
    await model.importXml('<build value="10"/>');
    expect(model.state.undoCount, 0);
  });
}
