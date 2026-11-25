import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/engine_session_client.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/domain/build_edit_result.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/engine_session.dart';
import 'package:pob2_ui/domain/equipment_item.dart';
import 'package:pob2_ui/domain/library_entry.dart';
import 'package:pob2_ui/domain/original_tree_scene.dart';
import 'package:pob2_ui/domain/tree_geometry.dart';
import 'package:pob2_ui/domain/tree_progression.dart';
import 'package:pob2_ui/ui/report_views.dart';
import 'package:pob2_ui/ui/shell_bloc.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/engine_connection_fake.dart';
import 'support/legacy/component_repository.dart';
import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

const _rootNode = 54447;
const _firstNode = 51184;
const _nextNode = 4739;
const _oldDps = 12.82;
const _editedDps = 19.48;
const _latestDps = 21.40;
const _otherDps = 24.26;
const _timeout = Duration(seconds: 8);

void main() {
  testWidgets('Новый DPS виден после записи XML, пока дерево загружается', (
    tester,
  ) async {
    final scenario = (await tester.runAsync(_Scenario.open))!;
    final model = scenario.model;
    final initialTree = model.state.document!.tree!;
    await _showStatistics(tester, model);
    expect(_visibleDps(_oldDps), findsOneWidget);

    final (:saving, :geometry) = (await tester.runAsync(
      () async =>
          (saving: scenario.pauseSave(), geometry: scenario.pauseGeometry(2)),
    ))!;
    late Future<BuildEditResult> applying;
    await tester.runAsync(() async {
      applying = scenario.allocate(_firstNode);
      await saving.started;
    });
    await tester.pumpAndSettle();
    expect(_visibleDps(_editedDps), findsNothing);
    expect(scenario.file.readAsStringSync(), scenario.initialXml);

    await tester.runAsync(() async {
      saving.resume();
      await geometry.started;
      expect((await applying.timeout(_timeout)).committed, isTrue);
    });
    await tester.pumpAndSettle();
    expect(_visibleDps(_editedDps), findsOneWidget);
    expect(
      scenario.file.readAsStringSync(),
      scenario.connection.current.build!.xml,
    );
    expect(model.state.document!.stale, isFalse);
    expect(model.state.document!.tree, same(initialTree));
    expect(model.treeGeometryPending, isTrue);

    await tester.runAsync(() => scenario.finishGeometry(geometry));
    await tester.pumpAndSettle();
    expect(_allocated(model), {_rootNode, _firstNode});
    expect(model.treeGeometryPending, isFalse);
    expect(_visibleDps(_editedDps), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Запоздалое дерево не заменяет геометрию новой ревизии', () async {
    final scenario = await _Scenario.open();
    final model = scenario.model;
    final initialTree = model.state.document!.tree!;
    final older = scenario.pauseGeometry(2);
    await scenario.applyAndWait(_firstNode, older);
    final oldRequest = model.requestTree();

    final newer = scenario.pauseGeometry(3);
    expect(
      (await scenario.allocate(_nextNode).timeout(_timeout)).committed,
      isTrue,
    );
    expect(model.state.report!.stats['TotalDPS'], _latestDps);
    older.resume();
    await oldRequest.timeout(_timeout);
    await newer.started;
    expect(model.state.document!.tree, same(initialTree));

    await scenario.finishGeometry(newer);
    expect(_allocated(model), {_rootNode, _firstNode, _nextNode});
    expect(model.state.report!.stats['TotalDPS'], _latestDps);
    expect(model.treeGeometryPending, isFalse);
  });

  test('Запоздалое дерево не заменяет дерево другой сборки', () async {
    final scenario = await _Scenario.open();
    final model = scenario.model;
    final older = scenario.pauseGeometry(2);
    await scenario.applyAndWait(_firstNode, older);
    final oldRequest = model.requestTree();

    await model.openBuild('Other.xml').timeout(_timeout);
    await model.requestTree().timeout(_timeout);
    final otherTree = model.state.document!.tree!;
    expect(model.state.library.activeId, 'Other.xml');
    expect(model.state.report!.stats['TotalDPS'], _otherDps);
    expect(_allocated(model), {_rootNode});

    older.resume();
    await oldRequest.timeout(_timeout);
    expect(model.state.document!.tree, same(otherTree));
    expect(model.state.report!.stats['TotalDPS'], _otherDps);
    expect(model.treeGeometryPending, isFalse);
  });

  test(
    'Ошибка фоновой загрузки сохраняет записанную правку и прежнее дерево',
    () async {
      final scenario = await _Scenario.open();
      final model = scenario.model;
      final initialTree = model.state.document!.tree!;
      final geometry = scenario.pauseGeometry(2);
      await scenario.applyAndWait(_firstNode, geometry);
      final request = model.requestTree();
      geometry.fail(StateError('Ошибка проверки дерева'));
      await request.timeout(_timeout);

      expect(model.state.report!.stats['TotalDPS'], _editedDps);
      expect(
        await scenario.file.readAsString(),
        scenario.connection.current.build!.xml,
      );
      expect(model.state.document!.tree, same(initialTree));
      expect(model.state.document!.stale, isFalse);
      expect(
        model.state.document!.treeError,
        contains('Ошибка проверки дерева'),
      );
      expect(model.treeGeometryPending, isFalse);
    },
  );
}

Finder _visibleDps(double value) => find.text(formatStat(value)).hitTestable();

Future<void> _showStatistics(WidgetTester tester, WorkshopCubit model) async {
  final shell = ShellBloc();
  addTearDown(shell.close);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: BlocBuilder<WorkshopCubit, WorkshopState>(
            bloc: model,
            builder: (context, state) =>
                StatisticsPanel(model: model, shell: shell),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Set<int> _allocated(WorkshopCubit model) => {
  for (final node in model.state.document!.tree?.nodes ?? const <TreeNode>[])
    if (node.allocated) node.id,
};

class _Scenario {
  _Scenario(
    this.model,
    this.connection,
    this.library,
    this.file,
    this.initialXml,
  );

  final WorkshopCubit model;
  final _TreeConnection connection;
  final _PausingLibrary library;
  final File file;
  final String initialXml;

  static Future<_Scenario> open() async {
    final root = await Directory.systemTemp.createTemp('pob-tree-refresh-');
    addTearDown(() => removeTemporaryDirectory(root));
    final builds = await Directory.fromUri(root.uri.resolve('builds/'))
        .create();
    final file = File.fromUri(builds.uri.resolve('Fireball.xml'));
    final initial = await File('integration_test/fixtures/witch_fireball.xml')
        .readAsString();
    await file.writeAsString(initial);
    await File.fromUri(builds.uri.resolve('Other.xml'))
        .writeAsString(initial.replaceFirst('level="90"', 'level="91"'));
    final library = _PausingLibrary(root);
    await library.configure(builds.path);
    await library.activate('Fireball.xml');
    final connection = _TreeConnection(initial);
    addTearDown(connection.events.close);
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(root)),
      _TreeWorkbench(initial),
      library: library,
      openEngineSession: (_) async => connection,
      deferTree: true,
      initialState: WorkshopState(
        library: await library.scan(),
        document: (
          report: _report(initial),
          tree: null,
          stale: false,
          treeError: null,
        ),
      ),
    );
    model.modalOpen = () => true;
    addTearDown(model.close);
    await model.connectEngine(
      const EngineOptions(),
      bindCurrentBuild: true,
      useSessionXml: true,
    );
    await model.waitForTreeArtwork();
    return _Scenario(model, connection, library, file, initial);
  }

  _Pause pauseSave() => library.nextSave = _Pause();

  _Pause pauseGeometry(int revision) => connection.pauses[revision] = _Pause();

  Future<BuildEditResult> allocate(int id) async {
    final preview = await model.previewSharedTreeNode(id);
    return model.applySharedTreeNode(preview);
  }

  Future<void> applyAndWait(int id, _Pause geometry) async {
    expect((await allocate(id).timeout(_timeout)).committed, isTrue);
    await geometry.started;
  }

  Future<void> finishGeometry(_Pause geometry) async {
    final request = model.requestTree();
    geometry.resume();
    await request.timeout(_timeout);
  }
}

class _Pause {
  _Pause() {
    addTearDown(resume);
  }

  final _started = Completer<void>();
  final _resumed = Completer<void>();

  Future<void> get started => _started.future.timeout(_timeout);

  Future<void> stop() async {
    if (!_started.isCompleted) _started.complete();
    await _resumed.future;
  }

  void resume() {
    if (!_resumed.isCompleted) _resumed.complete();
  }

  void fail(Object error) => _resumed.completeError(error);
}

class _PausingLibrary extends PobBuildLibrary {
  _PausingLibrary(super.profile);

  _Pause? nextSave;

  @override
  Future<LibraryState> save(
    LibraryState state,
    BuildReport report,
    String xml, {
    String? title,
    TreeProgressionKey? progressionSource,
    String? expectedXml,
  }) async {
    final pause = nextSave;
    nextSave = null;
    await pause?.stop();
    return super.save(
      state,
      report,
      xml,
      title: title,
      progressionSource: progressionSource,
      expectedXml: expectedXml,
    );
  }
}

class _TreeConnection extends FakeEngineConnection
    implements EngineWorkshopReader {
  _TreeConnection(String xml) : super(_snapshot(xml, 1));

  final pauses = <int, _Pause>{};

  @override
  bool get supportsTreePreview => true;

  @override
  bool get supportsTreeAllocationModes => true;

  @override
  Future<EngineTreePreview> previewTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
  ) async {
    const calculation = EngineCalculation(status: 'complete', warnings: []);
    return (
      comparison: (
        revision: current.revision,
        before: calculation,
        after: calculation,
        deltas: const <EngineStatDelta>[],
      ),
      added: [edit.nodeId],
      removed: const <int>[],
      attributes: const <EnginePassiveAttributeChange>[],
      allocations: const <EnginePassiveAllocationChange>[],
      points: null,
    );
  }

  @override
  Future<EngineSnapshot> editTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
    String requestId,
  ) async {
    final source = current.build!.xml;
    final nodes = {...PobBuildDocument(source).allocatedNodes, edit.nodeId};
    final updated = source.replaceFirst(
      RegExp(r'nodes="[^"]*"'),
      'nodes="${nodes.join(',')}"',
    );
    final snapshot = this.current = _snapshot(updated, current.revision + 1);
    final event = EngineChange(
      snapshot: snapshot,
      kind: 'build_changed',
      requestId: requestId,
    );
    history.add(event);
    events.add(event);
    return snapshot;
  }

  @override
  Future<BuildReport> readReport(EngineSnapshot snapshot) async =>
      _report(snapshot.build!.xml);

  @override
  Future<TreeGeometry> readTree(
    EngineSnapshot snapshot, {
    bool includeScene = true,
  }) async {
    await pauses[snapshot.build!.inputRevision]?.stop();
    return TreeGeometry.fromJson(_treeJson(snapshot.build!.xml, includeScene));
  }

  @override
  Future<ItemInspection?> readEquipmentDetails(
    EngineSnapshot snapshot, {
    String? slot,
    String? raw,
    int? itemId,
    required bool compare,
  }) async => null;

  @override
  Future<Uint8List?> readTreeTexture(TreeTextureReference reference) async =>
      null;

  @override
  Stream<Uint8List>? readTreeTextures(List<TreeTextureReference> references) =>
      null;

  @override
  Future<JsonMap?> readNodeTooltip(
    EngineSnapshot snapshot,
    int id,
    bool compare, {
    bool includeScene = false,
  }) async => null;
}

class _TreeWorkbench extends WorkbenchClient {
  _TreeWorkbench(this.xml) {
    tools = const {'pob_get_tree'};
  }

  String xml;

  @override
  bool get connected => true;

  @override
  Future<String> exportBuildXml() async => xml;

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    switch (name) {
      case 'pob_import_xml':
        xml = arguments['xml'] as String;
        return {};
      case 'pob_check_build':
        return {'report': _report(xml).raw};
      case 'pob_get_tree':
        return _treeJson(xml, true);
      default:
        throw UnsupportedError(name);
    }
  }
}

EngineSnapshot _snapshot(String xml, int revision) => EngineSnapshot(
  'main',
  'Fireball',
  revision,
  build: EngineBuild(
    xml: xml,
    level: 90,
    inputRevision: revision,
    tree: (
      spec: 1,
      version: '0_5',
      nodes: PobBuildDocument(xml).allocatedNodes,
      attributes: {},
      allocations: {},
      jewels: {},
      weaponSet: 1,
    ),
  ),
);

BuildReport _report(String xml) {
  final nodes = PobBuildDocument(xml).allocatedNodes;
  final dps = switch (nodes) {
    _ when xml.contains('level="91"') => _otherDps,
    _ when nodes.contains(_nextNode) => _latestDps,
    _ when nodes.contains(_firstNode) => _editedDps,
    _ => _oldDps,
  };
  return BuildReport.fromJson({
    ...fixture.raw,
    'stats': {...fixture.stats, 'TotalDPS': dps},
  });
}

JsonMap _treeJson(String xml, bool scene) {
  final allocated = PobBuildDocument(xml).allocatedNodes;
  const ids = [_rootNode, _firstNode, _nextNode];
  return {
    'version': '0_5',
    'nodes': [
      for (final (index, id) in ids.indexed)
        {
          'id': id,
          'x': index * 100,
          'y': 0,
          'name': 'Узел $id',
          'type': id == _rootNode ? 'ClassStart' : 'Normal',
          'allocated': allocated.contains(id),
        },
    ],
    'edges': [
      [_rootNode, _firstNode],
      [_firstNode, _nextNode],
    ],
    if (scene)
      'scene': {'scale': 1, 'offsetX': 0, 'offsetY': 0, 'commands': []},
  };
}
