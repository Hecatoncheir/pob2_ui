import 'dart:async';
import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/item_art_catalog.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/tree_progression_repository.dart';
import 'package:pob2_ui/data/tree_progression_exchange.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/equipment_item.dart';
import 'package:pob2_ui/domain/progression_comparison.dart';
import 'package:pob2_ui/domain/progression_loadout_change.dart';
import 'package:pob2_ui/domain/tree_progression.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/progression_comparison_bloc.dart';
import 'package:pob2_ui/ui/shell_bloc.dart';
import 'package:pob2_ui/ui/tree_canvas.dart';
import 'package:pob2_ui/ui/tree_progression_bloc.dart';
import 'package:pob2_ui/ui/tree_progression_panel.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';
import 'package:pob2_ui/ui/workspace_view.dart';
import 'package:xml/xml.dart';

import 'support/workshop_fixture.dart' as fixture;

const _key = (
  folder: 'PoB',
  build: 'build.xml',
  version: '0_5',
  characterClass: 'Witch',
);

BuildReport _reportWith({
  JsonMap stats = const {},
  List<JsonMap> groups = const [],
  List<JsonMap> items = const [],
  List<JsonMap> slots = const [],
}) => BuildReport.fromJson({
  'source': 'original-lua',
  'stats': stats,
  'groups': groups,
  'items': items,
  'slots': slots,
});

void main() {
  test('Экипировка этапа переносит предметы и самоцветы без конфликта ID', () {
    const saved = '''
<PathOfBuilding2>
  <Build level="25"/>
  <Tree><Spec nodes="11"><Sockets><Socket nodeId="11" itemId="2"/></Sockets></Spec></Tree>
  <Items activeItemSet="2">
    <Item id="1">Кольцо этапа</Item><Item id="2">Самоцвет этапа</Item>
    <Item id="3">Лишний предмет</Item>
    <ItemSet id="1"/><ItemSet id="2" useSecondWeaponSet="true"><Slot name="Ring 1" itemId="1"/></ItemSet>
  </Items>
</PathOfBuilding2>
''';
    const current = '''
<PathOfBuilding2>
  <Build level="90"/>
  <Tree><Spec nodes="11,15"><Sockets/></Spec></Tree>
  <Items activeItemSet="1">
    <Item id="1">Текущее кольцо</Item>
    <ItemSet id="1"><Slot name="Ring 1" itemId="1"/></ItemSet>
    <ItemSet id="2"><Slot name="Ring 2" itemId="1"/></ItemSet>
  </Items>
  <Skills><SkillSet id="1"><Skill label="Текущее умение"/></SkillSet></Skills>
</PathOfBuilding2>
''';
    final step = TreeProgressionStep(25, [
      11,
    ], equipment: PobBuildDocument(saved).progressionEquipment);
    final changed = PobBuildDocument(current)
        .withProgression(step, parts: {ProgressionPart.equipment});
    final root = XmlDocument.parse(changed).rootElement;
    final items = root.getElement('Items')!;
    final sets = items.findElements('ItemSet').toList();
    final inventory = {
      for (final item in items.findElements('Item'))
        item.getAttribute('id'): item.innerText,
    };
    final ring = sets.first.getElement('Slot')!.getAttribute('itemId');
    final socket = root
        .getElement('Tree')!
        .getElement('Spec')!
        .getElement('Sockets')!
        .getElement('Socket')!;
    expect(inventory[ring], 'Кольцо этапа');
    expect(inventory[socket.getAttribute('itemId')], 'Самоцвет этапа');
    expect(inventory, hasLength(3));
    expect(sets.first.getAttribute('useSecondWeaponSet'), 'true');
    expect(sets.last.getElement('Slot')!.getAttribute('itemId'), '1');
    expect(PobBuildDocument(changed).allocatedNodes, {11, 15});
    expect(PobBuildDocument(changed).level, 90);
    expect(changed, contains('Текущее умение'));
    expect(
      PobBuildDocument(changed)
          .withProgression(step, parts: {ProgressionPart.equipment}),
      changed,
    );
  });

  test('Этап заменяет только выбор в активном дереве и уровень', () {
    const xml = '''
<PathOfBuilding2>
  <Build level="90" characterLevelAutoMode="true"/>
  <Tree activeSpec="2">
    <Spec nodes="99"/>
    <Spec nodes="11,12" masteryEffects="{11,21},{12,22}">
      <WeaponSet2 nodes="11,12"/>
      <Sockets><Socket nodeId="11" itemId="2"/></Sockets>
    </Spec>
  </Tree>
  <Notes>Моя заметка</Notes>
</PathOfBuilding2>
''';
    final original = PobBuildDocument(xml);
    final stage = TreeProgressionStep(25, [11]);
    final changed = original.withProgression(stage);
    final root = XmlDocument.parse(changed).rootElement;
    final specs = root.getElement('Tree')!.findElements('Spec').toList();
    expect(root.getElement('Build')!.getAttribute('level'), '25');
    expect(
      root.getElement('Build')!.getAttribute('characterLevelAutoMode'),
      'false',
    );
    expect(specs.first.getAttribute('nodes'), '99');
    expect(specs.last.getAttribute('nodes'), '11');
    expect(specs.last.getAttribute('masteryEffects'), '{11,21}');
    expect(specs.last.getElement('WeaponSet2')!.getAttribute('nodes'), '11');
    expect(
      specs.last
          .getElement('Sockets')!
          .childElements
          .single
          .getAttribute('itemId'),
      '2',
    );
    expect(PobBuildDocument(changed).notes, 'Моя заметка');
  });

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
            allocation: '<Spec masteryEffects=""/>',
            skills: '<SkillSet/>',
            equipment: '<Equipment/>',
            keyNodes: [30, 20, 30, 10],
            completed: true,
            tasks: [
              (text: 'Взять узел', done: true),
              (text: 'Сменить кольцо', done: false),
            ],
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
      expect(restored.progression!.steps.first.tasks, isEmpty);
      expect(restored.progression!.steps.first.keyNodes, isEmpty);
      expect(restored.progression!.steps.last.keyNodes, [30, 20]);
      expect(
        restored.progression!.steps.last.withPartsFrom(
          TreeProgressionStep(12, [20]),
          {ProgressionPart.tree},
        ).keyNodes,
        [20],
      );
      expect(restored.progression!.steps.first.completed, isFalse);
      expect(restored.progression!.steps.last.tasks, plan.steps.last.tasks);
      expect(restored.progression!.steps.last.completed, isTrue);
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

  test('На шкале видны два заметных изменения без повторения DPS', () {
    final before = _reportWith(
      stats: {
        'FullDPS': 0,
        'TotalDPS': 10,
        'Life': 100,
        'Mana': 200,
        'Armour': 10,
      },
    );
    final after = _reportWith(
      stats: {
        'FullDPS': 0,
        'TotalDPS': 20,
        'Life': 80,
        'Mana': 200,
        'Armour': double.infinity,
      },
    );
    expect(progressionHighlights(before, after), [
      (metric: 'TotalDPS', delta: 10),
      (metric: 'Life', delta: -20),
    ]);
  });

  test('Покупки учитывают сохранённые предметы и повторные камни', () {
    const gem = {'id': 'GemA', 'name': 'Gem A', 'level': 1};
    const ring = {
      'id': 1,
      'name': 'Ember Loop',
      'raw': 'raw',
      'base': 'Lazuli Ring',
    };
    const boots = {
      'id': 2,
      'name': 'Boots',
      'raw': 'boots',
      'base': 'Iron Greaves',
    };
    const ringSlot = {'name': 'Ring 1', 'itemId': 1};
    const bootsSlot = {'name': 'Boots', 'itemId': 2};
    final current = _reportWith(
      items: [ring],
      groups: [
        {
          'gems': [gem],
        },
      ],
    );
    final first = _reportWith(
      items: [ring],
      slots: [ringSlot],
      groups: [
        {
          'gems': [
            {...gem, 'level': 3},
          ],
        },
        {
          'gems': [gem],
        },
        {
          'source': 'Item',
          'supportScope': 'slot',
          'gems': [gem],
        },
      ],
    );
    final second = _reportWith(
      items: [ring, boots],
      slots: [ringSlot, bootsSlot],
      groups: first.groups,
    );
    expect(progressionShopping(current, [first, second, second]), [
      [(name: 'Gem A', count: 1, slot: null, base: null)],
      [(name: 'Boots', count: 1, slot: 'Boots', base: 'Iron Greaves')],
      [],
    ]);
  });

  testWidgets('Порядок ключевых узлов меняется и сохраняется из панели', (
    tester,
  ) async {
    final repository = _MemoryRepository()
      ..steps = [
        TreeProgressionStep(12, [2, 3, 4], keyNodes: [2, 3]),
      ];
    final bloc = TreeProgressionBloc(repository)
      ..add(const TreeProgressionOpened());
    addTearDown(bloc.close);
    await _mountPlan(tester, bloc);
    await _tapVisible(tester, find.text('Уровень 12'));
    await _tapVisible(tester, find.byKey(const Key('progression-node-order')));
    await _tapVisible(tester, find.byTooltip('Выше').last);
    await _tapVisible(tester, find.byTooltip('Удалить').last);
    await _tapVisible(tester, find.byIcon(Icons.arrow_drop_down));
    await _tapVisible(tester, find.text('#4 · #4').last);
    await _tapVisible(tester, find.text('Сохранить'));
    expect(repository.steps.single.keyNodes, [3, 4]);
  });

  testWidgets(
    'Сравнение этапов открывает описания и предупреждения до применения',
    (tester) async {
      final earlier = TreeProgressionStep(12, [2], title: 'Акт 1');
      final later = TreeProgressionStep(25, [2], title: 'Акт 2');
      final repository = _MemoryRepository()..steps = [earlier, later];
      final bloc = TreeProgressionBloc(repository)
        ..add(const TreeProgressionOpened());
      addTearDown(bloc.close);
      await tester.runAsync(() async => ItemArtCatalog.shared);
      final before = _loadoutReport(level: 1, itemId: 1);
      final after = _loadoutReport(level: 5, itemId: 4, itemRaw: 'замена');
      final comparison = (
        before: before,
        after: after,
        nodes: (added: <int>{}, removed: <int>{}),
      );
      expect(comparison.gems.single.after!.level, 5);
      expect(
        comparison.equipment.single.before!.name,
        comparison.equipment.single.after!.name,
      );
      expect(
        (
          before: before,
          after: _loadoutReport(level: 1, itemId: 4),
          nodes: comparison.nodes,
        ).equipment,
        isEmpty,
      );
      await _mountPlan(
        tester,
        bloc,
        create: (target, {baseline}) {
          expect(target, same(later));
          expect(baseline, same(earlier));
          return ProgressionComparisonBloc(
            (_) async => comparison,
            () async {},
            describeGem: (id, level, quality) async => [
              {'text': 'Описание камня $level'},
            ],
            describeItem: (raw) async => ItemInspection.fromJson({
              'source': 'original-lua',
              'item': {'name': 'Кольцо', 'base': 'Lazuli Ring', 'raw': raw},
              'lines': [
                {'text': 'Описание предмета $raw'},
              ],
            }),
          );
        },
      );
      await tester.tap(find.text('Акт 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Сравнить с другим этапом'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SimpleDialogOption, 'Акт 1'));
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(find.text('Сравнение этапов'), findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('Применить этап')),
        findsNothing,
      );
      expect(find.text('Недостаточно интеллекта'), findsOneWidget);
      await _tapVisible(tester, find.text('Изменения умений · 1'));
      await _tapVisible(
        tester,
        find.widgetWithText(TextButton, 'Fireball').last,
      );
      expect(find.text('Описание камня 5'), findsOneWidget);
      await tester.tap(find.text('Закрыть').last);
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('Изменения экипировки · 1'));
      await _tapVisible(tester, find.widgetWithText(TextButton, 'Кольцо').last);
      await tester.runAsync(() async => ItemArtCatalog.shared);
      await tester.pumpAndSettle();
      expect(find.text('Описание предмета замена'), findsOneWidget);
      expect(find.byKey(const Key('item-artwork')), findsOneWidget);
    },
  );

  testWidgets('Обновление одной части сохраняет план и отметки прохождения', (
    tester,
  ) async {
    final earlier = TreeProgressionStep(
      12,
      [2],
      title: 'Акт 1',
      skills: 'умения этапа',
      equipment: 'кольцо этапа',
      tasks: [
        (text: 'Сменить кольцо', done: false),
        (text: 'Взять узел', done: false),
      ],
    );
    final later = TreeProgressionStep(25, [2], title: 'Акт 2');
    final repository = _MemoryRepository()..steps = [earlier, later];
    final bloc = TreeProgressionBloc(repository)
      ..add(const TreeProgressionOpened());
    addTearDown(bloc.close);
    await _mountPlan(
      tester,
      bloc,
      capture: TreeProgressionStep(
        90,
        [7],
        skills: 'новые умения',
        equipment: 'новое кольцо',
      ),
    );
    await tester.tap(find.text('Режим прохождения'));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Следующий этап'));
    expect(bloc.state.selected, 0);
    await _tapVisible(tester, find.text('Сменить кольцо'));
    await _tapVisible(tester, find.text('Взять узел'));
    await _tapVisible(tester, find.text('Этап завершён'));
    expect(repository.steps.first.completed, isTrue);
    expect(repository.steps.first.tasks.map((task) => task.done), [true, true]);
    expect(find.widgetWithText(ListTile, 'Акт 2'), findsOneWidget);
    await _tapVisible(tester, find.byTooltip('Обновить этап из сборки'));
    await _tapVisible(
      tester,
      find.widgetWithText(CheckboxListTile, 'Экипировка'),
    );
    await _tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Обновить этап'),
    );
    final saved = repository.steps.first;
    expect(saved.level, 12);
    expect(saved.nodes, {2});
    expect(saved.skills, 'умения этапа');
    expect(saved.equipment, 'новое кольцо');
    expect(saved.completed, isTrue);
    expect(saved.tasks.map((task) => task.done), [true, true]);
  });

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

  test(
    'В сравнении отображается результат последнего набора частей этапа',
    () async {
      final first = Completer<ProgressionComparison>();
      final started = Completer<void>();
      final calls = <Set<ProgressionPart>>[];
      final initial = (
        before: fixture.fixture,
        after: fixture.fixture,
        nodes: (added: {2}, removed: <int>{}),
      );
      final latest = (
        before: fixture.fixture,
        after: fixture.fixture,
        nodes: (added: <int>{}, removed: <int>{}),
      );
      final bloc = ProgressionComparisonBloc((parts) async {
        calls.add(parts);
        if (parts.contains(ProgressionPart.tree)) {
          started.complete();
          return first.future;
        }
        return latest;
      }, () async {});
      addTearDown(bloc.close);
      await started.future;
      const parts = {ProgressionPart.equipment};
      final results = bloc.stream.where((state) => state.comparison != null);
      final result = results.first;
      final selected = bloc.stream.firstWhere(
        (state) => state.parts.contains(parts.single),
      );
      bloc.add(ProgressionPartsSelected(parts));
      await selected;
      first.complete(initial);
      expect((await result).comparison, latest);
      expect(calls, [
        {ProgressionPart.tree},
        parts,
      ]);
    },
  );

  testWidgets('Этап открывает список изменений и позволяет перейти к узлу', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    final bloc = TreeProgressionBloc(repository)
      ..add(const TreeProgressionOpened());
    addTearDown(bloc.close);
    int? focused;
    TreeProgressionStep? applied;
    final nodes = {for (final node in fixture.tree.nodes) node.id: node};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: TreeProgressionPanel(
              nodes: nodes,
              enabled: true,
              onFocus: (id) => focused = id,
              onCapture: () async => TreeProgressionStep(90, []),
              createComparison: (_, {baseline}) => ProgressionComparisonBloc(
                (_) async => (
                  before: fixture.fixture,
                  after: fixture.fixture,
                  nodes: (added: {2}, removed: <int>{}),
                ),
                () async {},
              ),
              onApply: (step, parts) async {
                expect(parts, {ProgressionPart.tree});
                applied = step;
              },
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
    expect(applied, isNull);
    await tester.tap(find.text('Применить этап'));
    await tester.pumpAndSettle();
    expect(applied, isNull);
    expect(find.text('Добавятся · 1'), findsOneWidget);
    expect(find.text('Разница'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(applied, isNull);
    await tester.tap(find.text('Применить этап'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Применить этап').last);
    await tester.pumpAndSettle();
    expect(applied, repository.steps.single);

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

BuildReport _loadoutReport({
  required int level,
  required int itemId,
  String itemRaw = 'исходный',
}) => BuildReport.fromJson({
  'source': 'original-lua',
  'groups': [
    {
      'label': 'Fireball',
      'gems': [
        {'id': 'fireball', 'name': 'Fireball', 'level': level},
      ],
    },
  ],
  'items': [
    {'id': itemId, 'name': 'Кольцо', 'raw': itemRaw},
  ],
  'slots': [
    {'name': 'Ring 1', 'itemId': itemId},
  ],
  'warnings': [if (level == 5) 'Недостаточно интеллекта'],
});

Future<void> _mountPlan(
  WidgetTester tester,
  TreeProgressionBloc bloc, {
  ProgressionComparisonBloc Function(
    TreeProgressionStep, {
    TreeProgressionStep? baseline,
  })?
  create,
  TreeProgressionStep? capture,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: bloc,
          child: TreeProgressionPanel(
            nodes: const {},
            enabled: true,
            onFocus: (_) {},
            onCapture: () async => capture,
            onApply: (_, _) async => fail('Сборка не должна измениться'),
            createComparison:
                create ??
                (_, {baseline}) => throw StateError('Неожиданное сравнение'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
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
