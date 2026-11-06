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
      await _previewDraft(tester, model);
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
    timeout: Timeout(Duration(minutes: Platform.isLinux ? 8 : 4)),
  );
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
