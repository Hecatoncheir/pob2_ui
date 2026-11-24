import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/legacy/component_repository.dart';

import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/domain/build_edit_result.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/engine_session.dart';
import 'package:pob2_ui/domain/tree_allocation_mode.dart';
import 'package:pob2_ui/domain/tree_geometry.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/engine_connection_fake.dart';
import 'support/workshop_fixture.dart';

void main() {
  testWidgets('Клик в штатном дереве открывает предпросмотр общей правки', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final connection = FakeEngineConnection();
    final model = _PreviewWorkshop(connection);
    addTearDown(connection.events.close);
    addTearDown(model.close);
    await model.engineSession.connect(const EngineOptions());
    await tester.pumpWidget(PobApp(model: model));
    await tester.pumpAndSettle();

    final apply = find.byKey(const Key('workshop-tree-apply'));
    expect(apply, findsNothing);
    await _clickPassive(tester);
    expect(find.byKey(const Key('engine-tree-result')), findsOneWidget);
    expect(tester.widget<FilledButton>(apply).onPressed, isNotNull);

    connection.change('Из MCP');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(apply).onPressed, isNull);
    expect(model.applied, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, 'Предпросмотр'));
    await tester.pumpAndSettle();
    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(model.applied, [2]);
    expect(apply, findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'Карточка гнезда открывает редактор самоцвета и применяет примерку',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final connection = FakeEngineConnection();
      final model = _PreviewWorkshop(
        connection,
        geometry: _testTree(kind: 'Socket'),
      );
      addTearDown(connection.events.close);
      addTearDown(model.close);
      await model.engineSession.connect(const EngineOptions());
      await tester.pumpWidget(PobApp(model: model));
      await tester.pumpAndSettle();

      await _clickPassive(tester, secondary: true);
      await tester.tap(find.byKey(const Key('tree-open-jewel')));
      await tester.pumpAndSettle();
      const raw = 'Rarity: NORMAL\nRuby';
      final apply = find.byKey(const Key('tree-jewel-apply'));
      expect(tester.widget<FilledButton>(apply).onPressed, isNull);
      await tester.enterText(find.byKey(const Key('tree-jewel-raw')), raw);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tree-jewel-preview')));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(apply).onPressed, isNotNull);
      await tester.tap(apply);
      await tester.pumpAndSettle();
      expect(model.jewelEdits, [(nodeId: 2, itemId: 0, raw: raw)]);
      expect(apply, findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  for (final allocated in [false, true]) {
    testWidgets('Штатное дерево выбирает атрибут, назначен: $allocated', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final connection = FakeEngineConnection();
      final model = _PreviewWorkshop(
        connection,
        geometry: _testTree(
          kind: 'Normal',
          allocated: allocated,
          attribute: true,
        ),
      );
      addTearDown(connection.events.close);
      addTearDown(model.close);
      await model.engineSession.connect(const EngineOptions());
      await tester.pumpWidget(PobApp(model: model));
      await tester.pumpAndSettle();

      await _clickPassive(tester);
      await tester.tap(find.byKey(const Key('attribute-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Предпросмотр'));
      await tester.pumpAndSettle();
      const apply = Key('workshop-tree-apply');
      connection.change('Новая ревизия MCP');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(find.byKey(apply)).onPressed, isNull);

      await tester.tap(find.widgetWithText(TextButton, 'Предпросмотр'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(apply));
      await tester.pumpAndSettle();
      expect(
        model.appliedTreeEdits.single.action,
        allocated ? EngineTreeAction.setAttribute : EngineTreeAction.allocate,
      );
      expect(
        model.appliedTreeEdits.single.attribute,
        EnginePassiveAttribute.dexterity,
      );
      expect(model.applied, [2]);
      expect(find.byKey(const Key('attribute-2')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('Список дерева вызывает выбор, сохранённый при открытии', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final connection = FakeEngineConnection();
    final report = BuildReport.fromJson({
      ...fixture.raw,
      'activeSets': {'tree': 1},
      'sets': {
        'tree': [
          {'id': 1, 'title': 'Воин'},
          {'id': 2, 'title': 'Ведьма'},
        ],
      },
    });
    final model = _PreviewWorkshop(connection, report: report);
    addTearDown(connection.events.close);
    addTearDown(model.close);
    await tester.pumpWidget(PobApp(model: model));
    await tester.pumpAndSettle();
    final picker = find.byKey(const Key('tree-spec-picker'));
    await tester.tap(picker);
    await tester.pumpAndSettle();
    expect(model.specMenusOpened, 1);
    await tester.tap(find.widgetWithText(CheckedPopupMenuItem<int>, 'Ведьма'));
    await tester.pumpAndSettle();
    expect(model.specMenusOpened, 1);
    expect(model.selectedSpecs, [2]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

TreeGeometry _testTree({
  required String kind,
  bool allocated = true,
  bool attribute = false,
}) => TreeGeometry.fromJson({
  'version': tree.version,
  'nodes': [
    for (final node in tree.nodes)
      {
        'id': node.id,
        'x': node.x,
        'y': node.y,
        'name': node.name,
        'type': node.id == 2 ? kind : node.kind,
        'allocated': node.id != 2 || allocated,
        'isAttribute': node.id == 2 && attribute,
      },
  ],
  'edges': [
    [1, 2],
  ],
});

Future<void> _clickPassive(
  WidgetTester tester, {
  bool secondary = false,
}) async {
  final search = find.byKey(const Key('tree-search'));
  final canvas = find.byKey(const Key('passive-tree'));
  await tester.ensureVisible(search);
  await tester.tap(search);
  await tester.enterText(search, '2');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await tester.tapAt(
    tester.getCenter(canvas),
    kind: secondary ? PointerDeviceKind.mouse : PointerDeviceKind.touch,
    buttons: secondary ? kSecondaryMouseButton : kPrimaryButton,
  );
  await tester.pumpAndSettle();
}

class _PreviewWorkshop extends WorkshopCubit {
  _PreviewWorkshop(
    FakeEngineConnection connection, {
    TreeGeometry? geometry,
    BuildReport? report,
  }) : super(
         ComponentRepository(
           store: InstallationStore(Directory('test-components')),
         ),
         _TreeDialogMcp(),
         openEngineSession: (_) async => connection,
         initialState: WorkshopState(
           document: (
             report: report ?? fixture,
             tree: geometry ?? tree,
             stale: false,
             treeError: null,
           ),
         ),
       );

  int specMenusOpened = 0;
  final selectedSpecs = <int>[];

  @override
  Future<BuildEditResult> Function(int) treeSpecSelection() {
    specMenusOpened++;
    return (id) async {
      selectedSpecs.add(id);
      return (committed: true, error: null);
    };
  }

  final applied = <int>[];
  final appliedTreeEdits = <EngineTreeEdit>[];
  final jewelEdits = <EngineJewelEdit>[];

  @override
  Future<JsonMap> readTreeNode(int id) async => {
    if (state.document?.tree?.nodes
            .singleWhere((node) => node.id == id)
            .isAttribute ==
        true)
      'attributeOptions': [
        {'name': 'Strength'},
        {'name': 'Dexterity'},
        {'name': 'Intelligence'},
      ],
  };

  @override
  bool get canEditSharedJewel => true;

  @override
  Future<WorkshopJewelOffer> previewSharedJewel(EngineJewelEdit edit) async {
    const calc = EngineCalculation(status: 'complete', warnings: []);
    return (
      bindingEpoch: 1,
      inputRevision: 1,
      offer: (
        sessionId: 'main',
        connectionId: 1,
        edit: edit,
        preview: (
          revision: 1,
          before: calc,
          after: calc,
          deltas: const <EngineStatDelta>[],
        ),
      ),
    );
  }

  @override
  bool isCurrentSharedJewelOffer(WorkshopJewelOffer preview) =>
      preview.offer.preview.revision == engineSession.state.snapshot?.revision;

  @override
  Future<BuildEditResult> applySharedJewel(WorkshopJewelOffer preview) async {
    jewelEdits.add(preview.offer.edit);
    return (committed: true, error: null);
  }

  @override
  bool get hasSharedTree => true;

  @override
  Future<bool> isAttributeNode(int id) async => false;

  @override
  Future<WorkshopTreeOffer> previewSharedTreeNode(
    int nodeId, {
    EngineTreeAction? action,
    EnginePassiveAttribute? attribute,
  }) async {
    expect(nodeId, 2);
    final revision = engineSession.state.snapshot!.revision;
    const calculation = EngineCalculation(status: 'complete', warnings: []);
    return (
      bindingEpoch: 1,
      inputRevision: 1,
      offer: (
        sessionId: 'main',
        connectionId: 1,
        edit: (
          nodeId: nodeId,
          action: action ?? EngineTreeAction.allocate,
          attribute: attribute,
          allocationMode: TreeAllocationMode.common,
        ),
        preview: (
          added: [nodeId],
          removed: const <int>[],
          allocations: const <EnginePassiveAllocationChange>[],
          attributes: const <EnginePassiveAttributeChange>[],
          points: null,
          comparison: (
            revision: revision,
            before: calculation,
            after: calculation,
            deltas: const <EngineStatDelta>[],
          ),
        ),
      ),
    );
  }

  @override
  bool isCurrentSharedTreeOffer(WorkshopTreeOffer preview) =>
      preview.offer.preview.comparison.revision ==
      engineSession.state.snapshot?.revision;

  @override
  Future<BuildEditResult> applySharedTreeNode(WorkshopTreeOffer preview) async {
    applied.add(preview.offer.preview.comparison.revision);
    appliedTreeEdits.add(preview.offer.edit);
    return (committed: true, error: null);
  }
}

class _TreeDialogMcp extends WorkbenchClient {
  _TreeDialogMcp() {
    tools = const {'pob_tree_options'};
  }

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async =>
      name == 'pob_node_tooltip' ? {} : super.call(name, arguments);
}
