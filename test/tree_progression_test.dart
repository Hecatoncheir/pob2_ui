import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/tree_progression_repository.dart';
import 'package:pob2_ui/data/tree_progression_exchange.dart';
import 'package:pob2_ui/domain/tree_progression.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/shell_bloc.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/tree_progression_bloc.dart';
import 'package:pob2_ui/ui/tree_progression_panel.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';
import 'package:pob2_ui/ui/workspace_view.dart';

import 'support/workshop_fixture.dart' as fixture;

const _key = (
  folder: 'PoB',
  build: 'build.xml',
  version: '0_5',
  characterClass: 'Witch',
);

void main() {
  test(
    'XML переносит этапы с одинаковым уровнем и сохраняет исходную сборку',
    () {
      const xml = '<?xml version="1.0"?>\r\n<PathOfBuilding2/>\r\n';
      final plan = (
        version: _key.version,
        characterClass: _key.characterClass,
        steps: [
          TreeProgressionStep(12, [10, 20]),
          TreeProgressionStep(
            12,
            [20, 30],
            title: 'Акт 2',
            note: 'Новые камни\nПроверить сопротивления',
          ),
        ],
      );
      expect(attachTreeProgression(xml, null), xml);
      expect(splitTreeProgression(xml), (xml: xml, progression: null));
      final restored = splitTreeProgression(
        '${attachTreeProgression(xml, plan)}\r\n',
      );
      expect(restored.xml, xml);
      expect(restored.progression!.steps.first.details, (
        level: 12,
        title: '',
        note: '',
      ));
      expect(
        encodeProgressionSteps(restored.progression!.steps),
        encodeProgressionSteps(plan.steps),
      );
      expect(
        () => splitTreeProgression('$xml\n<!-- PoB II progression: % -->'),
        throwsFormatException,
      );
    },
  );

  test('Этапы сохраняются по уровням отдельно для каждой сборки', () async {
    final profile = await Directory.systemTemp.createTemp('pob-progression');
    addTearDown(() => profile.delete(recursive: true));
    final repository = TreeProgressionRepository(profile, _key);
    final bloc = TreeProgressionBloc(repository);
    addTearDown(bloc.close);

    final lateStep = TreeProgressionStep(25, [2, 3]);
    final earlyStep = TreeProgressionStep(10, [1, 2]);
    final sameLevel = TreeProgressionStep(25, [2, 3, 4]);
    final saved = bloc.stream.firstWhere((state) => state.steps.length == 3);
    bloc
      ..add(const TreeProgressionOpened())
      ..add(TreeProgressionRecorded(lateStep))
      ..add(TreeProgressionRecorded(earlyStep))
      ..add(TreeProgressionRecorded(sameLevel));
    expect((await saved).steps, [earlyStep, lateStep, sameLevel]);

    final reopened = await TreeProgressionRepository(profile, _key).load();
    expect(reopened.map((step) => step.level), [10, 25, 25]);
    final change = treeProgressionChange(reopened, 1);
    expect(change.added, {3});
    expect(change.removed, {1});

    final other = (
      folder: 'PoB',
      build: 'copy.xml',
      version: '0_5',
      characterClass: 'Witch',
    );
    expect(await TreeProgressionRepository(profile, other).load(), isEmpty);

    final named = bloc.stream.firstWhere(
      (state) => state.steps[1].title == 'Акт 2',
    );
    bloc.add(
      TreeProgressionEdited(lateStep, (
        level: 25,
        title: 'Акт 2',
        note: 'Взять новый камень',
      )),
    );
    final updated = await named;
    expect(updated.steps[2], sameLevel);
    final namedStep = updated.steps[1];

    final changed = bloc.stream.firstWhere(
      (state) => state.steps.first.level == 5,
    );
    bloc.add(
      TreeProgressionEdited(namedStep, (
        level: 5,
        title: namedStep.title,
        note: namedStep.note,
      )),
    );
    final edited = await changed;
    expect(edited.selected, 0);
    expect(edited.steps.first.nodes, lateStep.nodes);
    final persisted = await repository.load();
    expect(persisted.map((step) => step.level), [5, 10, 25]);
    expect(persisted.first.details, (
      level: 5,
      title: 'Акт 2',
      note: 'Взять новый камень',
    ));

    final deleted = bloc.stream.firstWhere((state) => state.steps.length == 2);
    bloc.add(TreeProgressionRemoved(edited.steps.first));
    await deleted;
    expect((await repository.load()).last.nodes, {2, 3, 4});
  });

  testWidgets('Этап открывает список изменений и позволяет перейти к узлу', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    final bloc = TreeProgressionBloc(repository)
      ..add(const TreeProgressionOpened());
    addTearDown(bloc.close);
    int? focused;
    final nodes = {for (final node in fixture.tree.nodes) node.id: node};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: TreeProgressionPanel(
              nodes: nodes,
              level: 90,
              enabled: true,
              onFocus: (id) => focused = id,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Уровень 12'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Узел'));
    expect(focused, 2);
    expect(nodes[2]!.allocated, isFalse);

    await tester.tap(find.byTooltip('Изменить этап'));
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('progression-level'));
    expect(find.text('12'), findsOneWidget);
    await tester.enterText(field, '20');
    await tester.enterText(find.byKey(const Key('progression-title')), 'Акт 2');
    await tester.enterText(
      find.byKey(const Key('progression-note')),
      'Взять новый камень',
    );
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Уровень 20'), findsOneWidget);
    expect(find.text('Акт 2'), findsOneWidget);
    expect(find.text('Взять новый камень'), findsOneWidget);
    expect(repository.steps.single.nodes, {2});

    await tester.tap(find.byTooltip('Сохранить этап'));
    await tester.pumpAndSettle();
    await tester.enterText(field, '101');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите уровень от 1 до 100'), findsOneWidget);
    await tester.enterText(field, '5');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Уровень 5'), findsOneWidget);
    expect(find.text('Взять новый камень'), findsNothing);
    expect(repository.steps.first.nodes, isEmpty);
  });

  testWidgets('В узком окне переход к узлу закрывает панель плана', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 650);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(Directory.systemTemp)),
      McpClient(),
      initialState: WorkshopState(
        document: (
          report: fixture.fixture,
          tree: fixture.tree,
          stale: false,
          treeError: null,
        ),
      ),
    );
    final shell = ShellBloc();
    final repository = _MemoryRepository()
      ..steps = [
        TreeProgressionStep(12, [1, 2]),
      ];
    final plan = TreeProgressionBloc(repository)
      ..add(const TreeProgressionOpened());
    addTearDown(model.close);
    addTearDown(shell.close);
    addTearDown(plan.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: Spark.theme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: plan,
            child: WorkspaceView(model: model, shell: shell),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-statistics')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inspector-plan')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Уровень 12'));
    await tester.pumpAndSettle();
    final frame = _treePainter(tester);
    final center = frame.transform.toScene(frame.viewport.center(Offset.zero));
    final midpoint = (frame.scene.points[1]! + frame.scene.points[2]!) / 2;
    expect((center - midpoint).distance, lessThan(.01));
    final chip = find.widgetWithText(ActionChip, 'Узел');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(chip));
    await tester.pumpAndSettle();
    expect(_treePainter(tester).planHovered, 2);
    expect(frame.transform.toScene(frame.viewport.center(Offset.zero)), center);
    await mouse.moveTo(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(_treePainter(tester).planHovered, isNull);
    await mouse.removePointer();
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final tree = _treePainter(tester);
    expect(tree.selected, 2);
    expect(tree.progression?.added, {1, 2});
  });
}

TreePainter _treePainter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((paint) => paint.painter)
    .whereType<TreePainter>()
    .single;

class _MemoryRepository extends TreeProgressionRepository {
  _MemoryRepository() : super(Directory.systemTemp, _key);

  List<TreeProgressionStep> steps = [
    TreeProgressionStep(12, [2]),
  ];

  @override
  Future<List<TreeProgressionStep>> load() async => steps;

  @override
  Future<void> save(List<TreeProgressionStep> steps) async =>
      this.steps = steps;
}
