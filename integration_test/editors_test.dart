import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/exit_protection.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/appearance_cubit.dart';
import 'package:pob2_ui/ui/gem_medallion.dart';
import 'package:pob2_ui/data/appearance_repository.dart';
import 'package:pob2_ui/domain/appearance.dart';

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
      final appearance = AppearanceCubit(
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
