import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/xml_file_service.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/comparison_stats_table.dart';
import 'package:pob2_ui/ui/components_view.dart';
import 'package:pob2_ui/ui/exit_protection.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/appearance_bloc.dart';
import 'package:pob2_ui/ui/gem_medallion.dart';
import 'package:pob2_ui/ui/core/frosted_surface.dart';
import 'package:pob2_ui/data/appearance_repository.dart';
import 'package:pob2_ui/domain/appearance.dart';

import '../test/support/file_fakes.dart';

const _witchScenario = 'Ведьма из XML: предпросмотр DPS, применение и история';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Группа камней и новое условие: UI, Lua, отказ, Undo/Redo и XML',
    (tester) async {
      if (!Platform.environment.containsKey('POB2_UI_HOME')) {
        throw StateError('Для проверки нужен отдельный профиль POB2_UI_HOME');
      }
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(InstallationStore.defaultRoot()),
        ),
        McpClient(),
      );
      addTearDown(model.close);
      final appearance = AppearanceBloc(
        AppearanceRepository(model.components.store.root),
        initialTheme: AppTheme.dark,
      );
      addTearDown(appearance.close);
      addTearDown(() async {
        await tester.pumpWidget(
          RepaintBoundary(
            key: const Key('editor-review-image'),
            child: ExitProtection(model: model, child: const SizedBox.shrink()),
          ),
        );
        await tester.pumpAndSettle();
      });
      await model.initialize();
      expect(model.state.error, isNull);
      final witch = model.state.classes.firstWhere(
        (entry) => entry['name'] == 'Witch',
      );
      await model.createBuild(
        witch['id'] as int,
        90,
        name: 'Проверка редакторов Lua',
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('editor-review-image'),
          child: ExitProtection(
            model: model,
            child: PobApp(model: model, appearance: appearance),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _addGroup(tester, model);
      await _hoverDescriptions(tester, model);
      await _previewDraft(tester, model);
      await _workspaceEditing(tester, model);
      await _setCondition(tester, model);
      final stats = model.state.report!.stats;
      final groups = model.state.report!.groups;
      final xml = await model.exportXml();
      await model.importXml(xml!);
      expect(model.state.error, isNull);
      expect(model.state.report!.stats, stats);
      expect(model.state.report!.groups, groups);
      expect(model.state.report!.config['conditionEnemyMoving'], isTrue);
      expect(model.state.report!.raw['source'], 'original-lua');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('editor-review-image'),
          child: ExitProtection(model: model, child: const SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
    },
    timeout: Timeout(Duration(minutes: Platform.isWindows ? 4 : 8)),
  );
  testWidgets(
    _witchScenario,
    _witchSupportWorkflow,
    timeout: const Timeout(Duration(minutes: 8)),
  );
  testWidgets(
    'Сохранённые сборки: дерево, экипировка, сравнение и восстановление Lua',
    _savedBuildsWorkflow,
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Future<({WorkshopCubit model, SelectPaths dialogs})> _prepareFileWorkshop(
  WidgetTester tester,
  McpClient engine,
) async {
  if (!Platform.environment.containsKey('POB2_UI_HOME')) {
    throw StateError('Для проверки нужен отдельный профиль POB2_UI_HOME');
  }
  final profile = InstallationStore.defaultRoot();
  final root = await profile.createTemp('file-editors-');
  addTearDown(() => root.delete(recursive: true));
  final manifest = File.fromUri(profile.uri.resolve('components.json'));
  await manifest.copy(File.fromUri(root.uri.resolve('components.json')).path);
  final dialogs = SelectPaths();
  final library = PobBuildLibrary(root);
  final builds = await Directory.fromUri(root.uri.resolve('builds/')).create();
  await library.configure(builds.path);
  final model = WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    engine,
    library: library,
    files: XmlFileService(dialogs: dialogs),
  );
  addTearDown(model.close);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  await model.initialize();
  expect(model.state.error, isNull);
  expect(model.engine.connected, isTrue);
  await tester.pumpWidget(
    ExitProtection(
      model: model,
      child: PobApp(model: model),
    ),
  );
  await tester.pumpAndSettle();
  return (model: model, dialogs: dialogs);
}

File _fixture(String name) =>
    File('integration_test/fixtures/$name.xml').absolute;

Future<void> _witchSupportWorkflow(WidgetTester tester) async {
  final (:model, :dialogs) = await _prepareFileWorkshop(tester, McpClient());
  expect(
    model.engine.tools,
    contains('pob_preview_support'),
    reason: 'Для предпросмотра нужен PoB MCP v0.21.0 или новее',
  );
  final source = _fixture('witch_fireball');
  final original = await source.readAsString();
  final saved = File.fromUri(
    model.components.store.root.uri.resolve('witch-with-support.xml'),
  );
  dialogs
    ..openPath = source.path
    ..savePath = saved.path;
  await _tapEditorAction(tester, model, find.text('Открыть XML'));
  expect(model.state.library.active!.title, 'witch_fireball');
  _expectWitch(model, applied: false);
  final before = (await model.exportXml())!;
  final statsBefore = model.state.report!.stats;
  final historyBefore = model.state.history;

  final support = await _previewWitchSupport(tester, model);
  expect(model.state.report!.stats, statsBefore);
  expect(await model.exportXml(), before);
  expect(model.state.history, historyBefore);
  _expectWitch(model, applied: false);

  await tester.tap(find.byKey(ValueKey('catalog-gem-$support')).hitTestable());
  await tester.pump();
  await _submitGroup(tester);
  await _wait(tester, () => !model.state.busy);
  await tester.pumpAndSettle();
  expect(model.state.error, isNull);
  expect(find.byKey(const Key('skill-group-save')), findsNothing);
  _expectWitch(model, applied: true);
  expect(model.state.history, (undo: 1, redo: 0));

  final undo = find.byKey(const Key('undo-build'));
  await _tapEditorAction(tester, model, undo);
  _expectWitch(model, applied: false);
  expect(model.state.history, (undo: 0, redo: 1));
  await _tapEditorAction(tester, model, find.byKey(const Key('redo-build')));
  _expectWitch(model, applied: true);
  final applied = model.state.report!;

  await _tapEditorAction(tester, model, find.byTooltip('Экспорт XML'));
  expect(model.state.status, 'XML сохранён');
  expect(await saved.readAsString(), contains('Controlled Destruction'));
  await _tapEditorAction(tester, model, undo);
  _expectWitch(model, applied: false);
  dialogs.openPath = saved.path;
  await _tapEditorAction(tester, model, find.byTooltip('Открыть XML'));
  expect(model.state.library.active!.title, 'witch-with-support');
  _expectWitch(model, applied: true);
  expect(model.state.report!.stats, applied.stats);
  expect(model.state.report!.groups, applied.groups);
  expect(model.state.history, (undo: 0, redo: 0));
  expect(await source.readAsString(), original);
  expect(tester.takeException(), isNull);
}

Future<String> _previewWitchSupport(
  WidgetTester tester,
  WorkshopCubit model,
) async {
  await tester.tap(find.byKey(const ValueKey('tab-skills')));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Редактировать группу'));
  await tester.pumpAndSettle();
  final target = find.descendant(
    of: find.byKey(const Key('composer-support-target')),
    matching: find.byType(DropdownButton<int>),
  );
  await tester.tap(target);
  await tester.pumpAndSettle();
  final fireball = find.descendant(
    of: find.byKey(const ValueKey('support-target-1')),
    matching: find.byType(Text),
  );
  await tester.tap(fireball.hitTestable().last);
  await tester.pumpAndSettle();
  expect(tester.widget<DropdownButton<int>>(target).value, 1);
  await tester.tap(find.text('Подходящие поддержки'));
  await tester.pump();
  const name = 'Controlled Destruction';
  await tester.enterText(find.byKey(const Key('gem-search')), name);
  final support = (await model.catalogs.gems()).firstWhere(
    (gem) => gem.name == name,
  );
  final preview = find.byKey(ValueKey('preview-support-${support.id}'));
  await _wait(tester, () => preview.evaluate().isNotEmpty);
  await tester.ensureVisible(preview);
  await tester.tap(preview);
  await _wait(tester, () => find.text('DPS до').evaluate().isNotEmpty);
  expect(find.text('12,8177'), findsOneWidget);
  expect(find.text('15,3333'), findsOneWidget);
  expect(find.text('+2,5156'), findsOneWidget);
  await tester.tap(find.text('Закрыть'));
  await tester.pumpAndSettle();
  return support.id;
}

Future<void> _tapEditorAction(
  WidgetTester tester,
  WorkshopCubit model,
  Finder control,
) async {
  await tester.tap(control);
  await _wait(tester, () => !model.state.busy);
  await tester.pumpAndSettle();
  expect(model.state.error, isNull);
}

Future<void> _savedBuildsWorkflow(WidgetTester tester) async {
  final engine = _LostEditReply();
  final (:model, :dialogs) = await _prepareFileWorkshop(tester, engine);
  final warrior = _fixture('warrior_rolling_slam');
  final sorceress = _fixture('sorceress_spark');
  final warriorXml = await warrior.readAsString();
  final sorceressXml = await sorceress.readAsString();

  dialogs.openPath = warrior.path;
  await _tapEditorAction(tester, model, find.text('Открыть XML'));
  await _allocateWarriorNode(tester, model);

  dialogs.openPath = sorceress.path;
  await _tapEditorAction(tester, model, find.byTooltip('Открыть XML'));
  expect(model.state.report!.mainSkill, 'Spark');
  expect(model.state.report!.config['enemyLevel'], 79);
  expect(model.state.report!.config['enemyIsBoss'], 'Pinnacle');
  expect(model.state.report!.stats['EnergyShield'], 64);
  await _selectRobe(tester);
  await _tapEditorAction(
    tester,
    model,
    find.byKey(const Key('equipment-remove')),
  );
  expect(model.state.report!.stats['EnergyShield'], 0);
  await _tapEditorAction(tester, model, find.byKey(const Key('undo-build')));
  expect(model.state.report!.stats['EnergyShield'], 64);

  final active = model.state.library.activeId!;
  const notes = 'Рабочие заметки для проверки восстановления';
  await model.buildNotes.readNotes(active);
  await model.buildNotes.saveNotes(active, notes);
  final working = await model.library.read(active);
  final report = model.state.report!;
  final history = model.state.history;
  expect(history, (undo: 0, redo: 1));
  await _compareFixtures(tester, dialogs, warrior, sorceress);
  expect(model.state.library.activeId, active);
  expect(model.state.report, same(report));
  expect(model.state.history, history);
  expect(await model.library.read(active), working);
  expect(await model.buildNotes.readNotes(active), notes);

  await _recoverAfterDroppedReply(tester, model, engine);
  expect(model.state.library.activeId, active);
  expect(model.state.report!.stats, report.stats);
  expect(model.state.report!.slots, report.slots);
  expect(model.state.history, (undo: 0, redo: 0));
  expect(await model.library.read(active), working);
  expect(await model.buildNotes.readNotes(active), notes);
  expect(await warrior.readAsString(), warriorXml);
  expect(await sorceress.readAsString(), sorceressXml);
  expect(tester.takeException(), isNull);
}

Future<void> _allocateWarriorNode(
  WidgetTester tester,
  WorkshopCubit model,
) async {
  const id = 3936;
  final report = model.state.report!;
  final dps = report.stats['TotalDPS'] as num;
  expect(report.mainSkill, 'Rolling Slam');
  expect(report.stats['Life'], 1067);
  expect(_warriorNodeAllocated(model, id), isFalse);
  await tester.enterText(find.byKey(const Key('tree-search')), '$id');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await _tapEditorAction(tester, model, find.byKey(const Key('passive-tree')));
  expect(_warriorNodeAllocated(model, id), isTrue);
  expect(model.state.report!.stats['TotalDPS'], greaterThan(dps));
  await _tapEditorAction(tester, model, find.byKey(const Key('undo-build')));
  expect(_warriorNodeAllocated(model, id), isFalse);
  expect(model.state.report!.stats['TotalDPS'], closeTo(dps, 0.00001));
}

bool _warriorNodeAllocated(WorkshopCubit model, int id) => model
    .state
    .document!
    .tree!
    .nodes
    .singleWhere((node) => node.id == id)
    .allocated;

Future<void> _selectRobe(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('tab-items')));
  await tester.pumpAndSettle();
  final slot = find.byKey(const ValueKey('equipment-slot-Body Armour'));
  await tester.ensureVisible(slot);
  await tester.tap(slot);
  await tester.pumpAndSettle();
}

Future<void> _compareFixtures(
  WidgetTester tester,
  SelectPaths dialogs,
  File warrior,
  File sorceress,
) async {
  await tester.tap(find.byKey(const ValueKey('page-library')).hitTestable());
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('compare-builds')));
  await tester.pumpAndSettle();
  await _chooseComparedFile(tester, dialogs, 'first', warrior);
  await _chooseComparedFile(tester, dialogs, 'second', sorceress);
  await tester.tap(find.byKey(const Key('build-comparison-run')));
  final table = find.byType(ComparisonStatsTable);
  await _wait(tester, () => table.evaluate().isNotEmpty);
  final ComparisonStatsTable(:before, :after) = tester.widget(table);
  expect(before.raw['source'], 'original-lua');
  expect(after.raw['source'], 'original-lua');
  expect(before.mainSkill, 'Rolling Slam');
  expect(after.mainSkill, 'Spark');
  expect(before.config['enemyLevel'], 67);
  expect(before.config['enemyIsBoss'], 'None');
  expect(after.config, before.config);
  expect(after.stats['EnergyShield'], 64);
  await tester.tap(find.text('Закрыть'));
  await tester.pumpAndSettle();
}

Future<void> _chooseComparedFile(
  WidgetTester tester,
  SelectPaths dialogs,
  String side,
  File file,
) async {
  dialogs.openPath = file.path;
  await tester.tap(find.byKey(ValueKey('build-comparison-$side')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('build-comparison-file-$side')));
  await tester.pumpAndSettle();
}

Future<void> _recoverAfterDroppedReply(
  WidgetTester tester,
  WorkshopCubit model,
  _LostEditReply engine,
) async {
  await tester.tap(find.byKey(const ValueKey('page-workspace')).hitTestable());
  await tester.pumpAndSettle();
  await _selectRobe(tester);
  final attempted = engine.equipmentEdits;
  final history = model.state.history;
  engine.dropNext = true;
  await tester.tap(find.byKey(const Key('equipment-remove')));
  await _wait(tester, () => !model.state.busy);
  expect(engine.shieldAfterLostEdit, 0);
  expect(engine.connected, isFalse);
  expect(model.state.document!.stale, isTrue);
  expect(model.state.error, contains('ответ MCP'));
  expect(model.state.history, history);
  await tester.tap(find.byKey(const ValueKey('page-components')).hitTestable());
  await tester.pumpAndSettle();
  final connect = find.text('Подключить Lua');
  await tester.scrollUntilVisible(
    connect,
    150,
    scrollable: find.descendant(
      of: find.byType(ComponentsView),
      matching: find.byType(Scrollable),
    ),
  );
  await _tapEditorAction(tester, model, connect);
  expect(engine.connected, isTrue);
  expect(model.state.document!.stale, isFalse);
  expect(engine.equipmentEdits, attempted + 1);
}

class _LostEditReply extends McpClient {
  bool dropNext = false;
  num? shieldAfterLostEdit;
  int equipmentEdits = 0;

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    final result = await super.call(name, arguments);
    if (name != 'pob_equip_item') return result;
    equipmentEdits++;
    if (!dropNext) return result;
    dropNext = false;
    final report = parseBuildReport(await super.call('pob_check_build'));
    shieldAfterLostEdit = report.stats['EnergyShield'] as num?;
    // Lua применил правку. Закрываем реальную сессию до передачи ответа редактору.
    await close();
    final error = StateError('Потерян ответ MCP во время правки');
    onDisconnected?.call(error);
    throw error;
  }
}

void _expectWitch(WorkshopCubit model, {required bool applied}) {
  final report = model.state.report!;
  expect(report.raw['source'], 'original-lua');
  expect(report.characterClass, 'Witch');
  expect(report.level, 90);
  expect(report.mainSkill, 'Fireball');
  expect(report.config['flameWallAddedDamage'], isTrue);
  expect(report.config['enemyLevel'], 67);
  expect(report.config['enemyIsBoss'], 'None');
  expect(
    report.stats['TotalDPS'],
    closeTo(applied ? 15.333333 : 12.817708, 0.00001),
  );
  final gems = jsonRows(report.groups.single['gems']);
  expect(gems.map((gem) => gem['name']), [
    'Flame Wall',
    'Fireball',
    'Rapid Casting I',
    if (applied) 'Controlled Destruction',
  ]);
  expect(gems[1]['quality'], 10);
}

Future<void> _hoverDescriptions(
  WidgetTester tester,
  WorkshopCubit model,
) async {
  final before = await model.exportXml();
  final groupId = model.state.report!.groups.last['id'];
  final pointer = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await pointer.addPointer(location: Offset.zero);
  for (final index in [1, 2]) {
    final gem = find.byWidgetPredicate(
      (widget) =>
          widget is GemMedallion &&
          widget.groupId == groupId &&
          widget.sourceIndex == index,
    );
    await tester.ensureVisible(gem);
    await pointer.moveTo(tester.getCenter(gem));
    await tester.pump(const Duration(milliseconds: 450));
    await _wait(
      tester,
      () => find
          .byKey(const Key('gem-tooltip-description'))
          .evaluate()
          .isNotEmpty,
    );
    final card = tester.getRect(
      find.ancestor(
        of: find.byKey(const Key('gem-tooltip-description')),
        matching: find.byType(FrostedSurface),
      ),
    );
    expect(card.top, greaterThanOrEqualTo(0));
    expect(
      card.bottom,
      lessThanOrEqualTo(
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      ),
    );
    expect(
      find.textContaining(
        index == 1 ? 'Fireball' : 'Controlled Destruction',
        findRichText: true,
      ),
      findsWidgets,
    );
    if (index == 1) {
      expect(find.textContaining('20%', findRichText: true), findsWidgets);
      await _capture(tester, '-gem-tooltip');
    }
    await pointer.moveTo(Offset.zero);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }
  await pointer.removePointer();
  expect(await model.exportXml(), before);
  expect(tester.takeException(), isNull);
  debugPrint('Готово: подсказки умения и поддержки из оригинального Lua');
}

Future<void> _addGroup(WidgetTester tester, WorkshopCubit model) async {
  debugPrint('Начало: создание группы через интерфейс');
  final count = model.state.report!.groups.length;
  await tester.tap(find.byKey(const ValueKey('tab-skills')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('add-skill-group')));
  await tester.pump();
  await tester.enterText(find.byKey(const Key('gem-search')), 'Fireball');
  final gem = (await model.catalogs.gems()).firstWhere(
    (gem) => gem.name == 'Fireball',
  );
  final row = find.byKey(ValueKey('catalog-gem-${gem.id}'));
  await _wait(tester, () => row.evaluate().isNotEmpty);
  await tester.tap(row);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('skill-group-label')),
    'Редактор умений',
  );
  await tester.enterText(find.byKey(const ValueKey('gem-level-0')), '999');
  await _submitGroup(tester);
  await _wait(tester, () => !model.state.busy);
  await tester.pumpAndSettle();
  expect(model.state.error, isNotNull);
  expect(model.state.report!.groups, hasLength(count));
  expect(find.byKey(const Key('skill-group-save')), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('gem-level-0')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('gem-level-0')), '5');
  await tester.pumpAndSettle();
  expect(
    tester
        .widget<TextFormField>(find.byKey(const ValueKey('gem-level-0')))
        .initialValue,
    '5',
  );
  await tester.enterText(find.byKey(const ValueKey('gem-quality-0')), '20');
  await tester.pumpAndSettle();
  await _addSupport(tester, model);
  await _capture(tester, '-skills-form');
  await _submitGroup(tester);
  await _wait(tester, () => !model.state.busy);
  await tester.pumpAndSettle();
  expect(model.state.error, isNull);
  expect(find.byKey(const Key('skill-group-save')), findsNothing);
  expect(model.state.report!.groups, hasLength(count + 1));
  final gems = jsonRows(model.state.report!.groups.last['gems']);
  expect(gems, hasLength(2));
  expect(gems.last['name'], 'Controlled Destruction');
  final added = gems.first;
  expect(added['name'], 'Fireball');
  expect(added['level'], 5);
  expect(added['quality'], 20);
  expect(added['enabled'], isTrue);
  await model.undo();
  expect(model.state.report!.groups, hasLength(count));
  await model.redo();
  expect(model.state.report!.groups, hasLength(count + 1));
  debugPrint('Готово: создание группы через интерфейс, отказ Lua и история');
}

Future<void> _addSupport(WidgetTester tester, WorkshopCubit model) async {
  await tester.tap(find.byKey(const Key('gem-search')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('gem-search')),
    'Controlled Destruction',
  );
  await tester.pumpAndSettle();
  final gem = (await model.catalogs.gems()).firstWhere(
    (gem) => gem.name == 'Controlled Destruction',
  );
  final tile = find.byKey(ValueKey('catalog-gem-${gem.id}'));
  await _wait(tester, () => tile.evaluate().isNotEmpty);
  final target = find.byKey(const Key('append-gem-socket'));
  await tester.dragFrom(
    tester.getCenter(tile),
    tester.getCenter(target) - tester.getCenter(tile),
  );
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('gem-socket-1')), findsOneWidget);
  await tester.tap(find.byKey(const Key('gem-search')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('gem-search')), '');
  await tester.pumpAndSettle();
}

Future<void> _previewDraft(WidgetTester tester, WorkshopCubit model) async {
  final count = model.state.report!.groups.length;
  await tester.tap(find.byKey(const Key('add-skill-group')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('gem-search')), 'Fireball');
  await tester.pumpAndSettle();
  final gem = (await model.catalogs.gems()).firstWhere(
    (gem) => gem.name == 'Fireball',
  );
  await tester.tap(find.byKey(ValueKey('catalog-gem-${gem.id}')));
  await tester.pumpAndSettle();
  await _addSupport(tester, model);
  await _wait(
    tester,
    () =>
        find
            .descendant(
              of: find.byKey(const ValueKey('gem-socket-0')),
              matching: find.byType(Image),
            )
            .evaluate()
            .isNotEmpty &&
        find
            .descendant(
              of: find.byKey(const ValueKey('gem-socket-1')),
              matching: find.byType(Image),
            )
            .evaluate()
            .isNotEmpty,
  );
  await _capture(tester, '-skills-form');
  await tester.tap(find.byKey(const Key('skill-group-cancel')));
  await tester.pumpAndSettle();
  expect(model.state.report!.groups, hasLength(count));
}

Future<void> _setCondition(WidgetTester tester, WorkshopCubit model) async {
  debugPrint('Начало: условие из полного каталога');
  final before = model.state.report!.config['conditionEnemyMoving'];
  await tester.tap(find.byKey(const ValueKey('tab-conditions')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('condition-search')),
    'conditionEnemyMoving',
  );
  final row = find.byKey(const ValueKey('condition-conditionEnemyMoving'));
  await _wait(tester, () => row.evaluate().isNotEmpty);
  await tester.tap(row);
  await tester.pumpAndSettle();
  final toggle = tester.widget<SwitchListTile>(
    find.byKey(const Key('condition-toggle')),
  );
  if (!toggle.value)
    await tester.tap(find.byKey(const Key('condition-toggle')));
  await tester.pumpAndSettle();
  await _capture(tester, '-condition-form');
  await tester.tap(find.byKey(const Key('condition-save')));
  await _wait(tester, () => !model.state.busy);
  await tester.pumpAndSettle();
  expect(model.state.error, isNull);
  expect(model.state.report!.config['conditionEnemyMoving'], isTrue);
  await model.undo();
  expect(model.state.report!.config['conditionEnemyMoving'], before);
  await model.redo();
  expect(model.state.report!.config['conditionEnemyMoving'], isTrue);
  debugPrint('Готово: условие, Undo и Redo');
}

Future<void> _workspaceEditing(WidgetTester tester, WorkshopCubit model) async {
  debugPrint(
    'Начало: список групп, основной навык и переносы поддержек в обе стороны',
  );
  final ice = (await model.catalogs.gems()).firstWhere(
    (gem) => gem.name == 'Ice Nova',
  );
  final created = await model.addSkillGroup('Ледяная группа', [
    {'id': ice.id, 'level': 5},
  ]);
  expect(created.committed, isTrue);
  await tester.pumpAndSettle();
  final id = model.state.report!.groups.last['id'] as int;
  final checkbox = find.byKey(ValueKey('main-skill-group-$id'));
  await tester.ensureVisible(checkbox);
  await tester.pumpAndSettle();
  await tester.tap(checkbox);
  await _wait(
    tester,
    () =>
        model.state.report!.groupSelector['selected'] == id &&
        !model.state.busy,
  );
  final search = find.byKey(const Key('support-search'));
  await _wait(tester, () => search.evaluate().isNotEmpty);
  await tester.tap(search);
  await tester.pumpAndSettle();
  await tester.enterText(search, 'Controlled Destruction');
  await tester.pumpAndSettle();
  final support = (await model.catalogs.gems()).firstWhere(
    (gem) => gem.name == 'Controlled Destruction',
  );
  final tile = find.byKey(ValueKey('catalog-gem-${support.id}'));
  await _wait(tester, () => tile.evaluate().isNotEmpty);
  final row = find.byKey(ValueKey('skill-group-drop-$id'));
  await tester.dragFrom(
    tester.getCenter(tile),
    tester.getCenter(row) - tester.getCenter(tile),
  );
  await _wait(
    tester,
    () =>
        jsonRows(model.state.report!.groups.last['gems']).length == 2 &&
        !model.state.busy,
  );
  await _workspaceReady(tester);
  final added = find.byKey(ValueKey('group-gem-$id-2'));
  await tester.ensureVisible(added);
  final target = find.byKey(const Key('gem-return-target'));
  await tester.dragFrom(
    tester.getCenter(added),
    tester.getCenter(target) - tester.getCenter(added),
  );
  await _wait(
    tester,
    () =>
        jsonRows(model.state.report!.groups.last['gems']).length == 1 &&
        !model.state.busy,
  );
  expect(model.state.report!.groups, hasLength(2));
  await model.undo();
  expect(jsonRows(model.state.report!.groups.last['gems']), hasLength(2));
  await model.redo();
  expect(jsonRows(model.state.report!.groups.last['gems']), hasLength(1));
  await _workspaceReady(tester);
  final group = find.byKey(ValueKey('skill-group-$id'));
  final edit = find.descendant(
    of: group,
    matching: find.byTooltip('Редактировать группу'),
  );
  await tester.ensureVisible(edit);
  await tester.tap(edit);
  await tester.pumpAndSettle();
  expect(find.text('Редактор группы умений'), findsOneWidget);
  await tester.enterText(find.byKey(const ValueKey('gem-level-0')), '7');
  await _submitGroup(tester);
  await _wait(
    tester,
    () => find.byKey(const Key('skill-group-save')).evaluate().isEmpty,
  );
  expect(model.state.report!.groups, hasLength(2));
  expect(jsonRows(model.state.report!.groups.last['gems']).first['level'], 7);
  expect(model.state.report!.groupSelector['selected'], id);
  await _workspaceReady(tester);
  await tester.tap(search);
  await tester.pumpAndSettle();
  await tester.enterText(search, '');
  await tester.pumpAndSettle();
  await _capture(tester, '-workspace');
  await tester.tap(find.byKey(ValueKey('delete-skill-group-$id')));
  await _wait(tester, () => model.state.report!.groups.length == 1);
  await _workspaceReady(tester);
  expect(model.state.error, isNull);
  await tester.tap(find.byKey(const ValueKey('delete-skill-group-1')));
  await _wait(tester, () => model.state.report!.groups.isEmpty);
  await _workspaceReady(tester);
  expect(model.state.error, isNull);
  await model.undo();
  expect(model.state.report!.groups, hasLength(1));
  await model.undo();
  expect(model.state.report!.groups, hasLength(2));
  await model.redo();
  expect(model.state.report!.groups, hasLength(1));
  await model.undo();
  expect(model.state.report!.groups, hasLength(2));
  await _workspaceReady(tester);
  debugPrint(
    'Готово: список, галочка, двусторонний перенос, редактор, удаление, Undo/Redo',
  );
}

Future<void> _workspaceReady(WidgetTester tester) async {
  await _wait(
    tester,
    () =>
        tester
            .widget<FilledButton>(find.byKey(const Key('add-skill-group')))
            .onPressed !=
        null,
  );
  await tester.pumpAndSettle();
}

Future<void> _submitGroup(WidgetTester tester) async {
  final button = find.byKey(const Key('skill-group-save'));
  await _wait(
    tester,
    () => tester.widget<FilledButton>(button).onPressed != null,
  );
  await tester.tap(button);
}

Future<void> _wait(WidgetTester tester, bool Function() complete) async {
  for (var attempt = 0; attempt < 900; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (complete()) return;
  }
  fail('Интерфейс не завершил операцию');
}

Future<void> _capture(WidgetTester tester, String suffix) async {
  final path = Platform.environment['POB2_UI_SCREENSHOT'];
  if (path == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('editor-review-image')),
  );
  final image = await boundary.toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final output = File(path.replaceFirst('.png', '$suffix.png'));
  await output.parent.create(recursive: true);
  await output.writeAsBytes(data!.buffer.asUint8List());
  image.dispose();
}
