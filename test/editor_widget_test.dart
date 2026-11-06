import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/game_dictionary.dart';
import 'package:pob2_ui/ui/condition_dialog.dart';
import 'package:pob2_ui/ui/conditions_view.dart';
import 'package:pob2_ui/ui/core/language_scope.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/skill_group_dialog.dart';
import 'package:pob2_ui/domain/condition_definition.dart';

import 'support/editor_fakes.dart';
import 'support/workshop_fixture.dart';

import 'package:pob2_ui/domain/build_report.dart';

Widget application(Widget child) => MaterialApp(
  theme: Spark.theme(),
  builder: (context, child) => LanguageScope(
    dictionary: GameDictionary(
      'ru',
      {'gem': 'Fireball'},
      {'gem': 'Огненный шар'},
    ),
    child: child!,
  ),
  home: Scaffold(body: child),
);

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Перетаскивание из каталога и перестановка без потери полей: $brightness',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final model = EditorWorkshop(
          EditorCatalogEngine(
            gemEntries: const [
              fireball,
              {
                'id': 'support',
                'name': 'Controlled Destruction',
                'support': true,
              },
              {'id': 'support2', 'name': 'Added Cold', 'support': true},
            ],
          ),
        );
        addTearDown(model.close);
        await tester.pumpWidget(
          MaterialApp(
            theme: Spark.theme(brightness: brightness),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSkillGroupEditor(context, model),
                  child: const Text('Открыть редактор'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Открыть редактор'));
        await tester.pumpAndSettle();
        final gem = find.byKey(const ValueKey('catalog-gem-gem-fireball'));
        final empty = find.byKey(const Key('empty-gem-socket'));
        await tester.dragFrom(
          tester.getCenter(gem),
          tester.getCenter(empty) - tester.getCenter(gem),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('gem-socket-0')), findsOneWidget);
        await tester.enterText(find.byKey(const ValueKey('gem-level-0')), '7');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        final support = find.byKey(const ValueKey('catalog-gem-support'));
        final append = find.byKey(const Key('append-gem-socket'));
        await tester.dragFrom(
          tester.getCenter(support),
          tester.getCenter(append) - tester.getCenter(support),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        final support2 = find.byKey(const ValueKey('catalog-gem-support2'));
        await tester.dragFrom(
          tester.getCenter(support2),
          tester.getCenter(append) - tester.getCenter(support2),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        final first = find.byKey(const ValueKey('gem-socket-0'));
        final second = find.byKey(const ValueKey('gem-socket-1'));
        final third = find.byKey(const ValueKey('gem-socket-2'));
        expect(find.byKey(const ValueKey('gem-quality-1')), findsNothing);
        await tester.tap(second);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('gem-quality-1')), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('gem-quality-1')),
          '15',
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        await tester.dragFrom(
          tester.getCenter(second),
          tester.getCenter(first) - tester.getCenter(second),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(first).dx,
          lessThan(tester.getTopLeft(second).dx),
        );
        await tester.dragFrom(
          tester.getCenter(third),
          tester.getCenter(second) - tester.getCenter(third),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(third).dx,
          lessThan(tester.getTopLeft(second).dx),
        );
        await tester.dragFrom(
          tester.getCenter(second),
          const Offset(-800, -700),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(third).dx,
          lessThan(tester.getTopLeft(second).dx),
        );
        await tester.tap(find.byKey(const Key('skill-group-save')));
        await tester.pumpAndSettle();
        expect(model.savedGems!.map((gem) => gem['id']), [
          'gem-fireball',
          'support2',
          'support',
        ]);
        expect(model.savedGems!.first['level'], 7);
        expect(model.savedGems!.last['quality'], 15);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in [360.0, 1280.0]) {
    testWidgets(
      'Поиск по переводу, поля камня и отказ Lua без потери ввода: $width',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 850));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final model = EditorWorkshop(EditorCatalogEngine());
        addTearDown(model.close);
        await tester.pumpWidget(
          application(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showSkillGroupEditor(context, model),
                child: const Text('Открыть редактор'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Открыть редактор'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('gem-search')), 'огненный');
        await tester.pump();
        await tester.tap(
          find.byKey(const ValueKey('catalog-gem-gem-fireball')),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const ValueKey('gem-level-0')), '5');
        await tester.enterText(
          find.byKey(const ValueKey('gem-quality-0')),
          '20',
        );
        await tester.ensureVisible(find.byKey(const ValueKey('gem-enabled-0')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('gem-enabled-0')));
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.cancel,
        );
        await tester.pumpAndSettle();
        model.result = (committed: false, error: 'Lua отклонил группу');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('skill-group-save')));
        await tester.pumpAndSettle();
        expect(find.text('Lua отклонил группу'), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(find.byKey(const ValueKey('gem-level-0')))
              .initialValue,
          '5',
        );
        expect(model.savedGems!.single['enabled'], isFalse);
        expect(tester.takeException(), isNull);
        model.result = (committed: true, error: null);
        await tester.tap(find.byKey(const Key('skill-group-save')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('skill-group-save')), findsNothing);
        expect(model.savedGems!.single['quality'], 20);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Условие, которого нет в config, доступно из полного каталога', (
    tester,
  ) async {
    final model = EditorWorkshop(EditorCatalogEngine());
    addTearDown(model.close);
    await tester.pumpWidget(application(ConditionsView(model: model)));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('condition-search')),
      'conditionEnemyMoving',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('condition-conditionEnemyMoving')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('condition-toggle')));
    expect(await tester.binding.handleRequestAppExit(), AppExitResponse.cancel);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('condition-save')));
    await tester.pumpAndSettle();
    expect(model.savedCondition, ('conditionEnemyMoving', true));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Устаревшее значение списка не вызывает assertion; повторы вариантов объединены',
    (tester) async {
      final model = EditorWorkshop(
        EditorCatalogEngine(),
        report: BuildReport.fromJson({
          ...fixture.raw,
          'config': {'enemyIsBoss': 'old-value'},
        }),
      );
      addTearDown(model.close);
      final definition = ConditionDefinition.fromJson(boss);
      await tester.pumpWidget(
        application(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showConditionEditor(context, model, definition),
              child: const Text('Изменить'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Изменить'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<DropdownButtonFormField<Object>>(
              find.byKey(const Key('condition-choice')),
            )
            .initialValue,
        isNull,
      );
      await tester.tap(find.byKey(const Key('condition-choice')));
      await tester.pumpAndSettle();
      expect(find.text('Duplicate'), findsNothing);
      await tester.tap(find.text('No').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('condition-save')));
      await tester.pumpAndSettle();
      expect(model.savedCondition, ('enemyIsBoss', 'None'));
    },
  );
}
