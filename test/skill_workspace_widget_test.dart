import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/skills_view.dart';
import 'package:pob2_ui/ui/report_views.dart';

import 'editor_widget_test.dart' show application;
import 'support/editor_fakes.dart';
import 'support/workshop_fixture.dart';

const support = {
  'id': 'support',
  'name': 'Controlled Destruction',
  'support': true,
};
const ice = {'id': 'ice', 'name': 'Ice Nova', 'support': false};

class _SupportPreviewEngine extends EditorCatalogEngine {
  _SupportPreviewEngine() : super(gemEntries: const [fireball, ice, support]) {
    tools.add('pob_preview_support');
  }

  final result = Completer<JsonMap>();
  JsonMap? previewRequest;

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    if (name != 'pob_preview_support') return super.call(name, arguments);
    previewRequest = arguments;
    return result.future;
  }
}

BuildReport workspaceReport() => BuildReport.fromJson({
  ...fixture.raw,
  'snapshot': {
    ...fixture.snapshot,
    'buildInfo': {
      ...fixture.character,
      'groups': {
        'selected': 1,
        'enabled': true,
        'entries': [
          {'id': 1, 'label': 'Fireball'},
          {'id': 2, 'label': 'Ice Nova'},
        ],
      },
      'skills': {
        'selected': 1,
        'enabled': true,
        'entries': [
          {'id': 1, 'label': 'Fireball'},
        ],
      },
    },
  },
  'groups': [
    {
      'id': 1,
      'label': 'Fireball',
      'customLabel': '',
      'enabled': true,
      'gems': [
        {
          ...fireball,
          'support': false,
          'sourceIndex': 1,
          'level': 5,
          'quality': 20,
          'enabled': true,
        },
      ],
    },
    {
      'id': 2,
      'label': 'Ice Nova',
      'customLabel': '',
      'enabled': true,
      'gems': [
        {...ice, 'sourceIndex': 1, 'level': 3, 'quality': 0, 'enabled': true},
      ],
    },
  ],
});

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Список, перенос в обе стороны, галочка и редактор существующей группы',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1300, 950));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = EditorWorkshop(
        EditorCatalogEngine(gemEntries: const [fireball, support, ice]),
        report: workspaceReport(),
      );
      addTearDown(model.close);
      await tester.pumpWidget(application(SkillsView(model: model)));
      await settle(tester);
      expect(find.text('Умения'), findsNothing);
      final tile = find.byKey(const ValueKey('catalog-gem-support'));
      final group = find.byKey(const ValueKey('skill-group-drop-1'));
      await tester.dragFrom(
        tester.getCenter(tile),
        tester.getCenter(group) - tester.getCenter(tile),
      );
      await settle(tester);
      expect(model.state.report!.groups.first['gems'], hasLength(2));
      expect(model.state.report!.groups, hasLength(2));
      final added = find.byKey(const ValueKey('group-gem-1-2'));
      final library = find.byKey(const Key('gem-return-target'));
      await tester.dragFrom(
        tester.getCenter(added),
        tester.getCenter(library) - tester.getCenter(added),
      );
      await settle(tester);
      expect(model.state.report!.groups.first['gems'], hasLength(1));
      expect(tile, findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('main-skill-group-2')));
      await settle(tester);
      expect(model.selectedMain, ('groups', 2));
      expect(
        tester
            .widget<Checkbox>(find.byKey(const ValueKey('main-skill-group-2')))
            .value,
        isTrue,
      );
      expect(
        tester
            .widget<Checkbox>(find.byKey(const ValueKey('main-skill-group-1')))
            .value,
        isFalse,
      );
      final row = find.byKey(const ValueKey('skill-group-2'));
      await tester.tap(
        find.descendant(
          of: row,
          matching: find.byTooltip('Редактировать группу'),
        ),
      );
      await settle(tester);
      expect(find.text('Редактор группы умений'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('gem-level-0')), '9');
      await settle(tester);
      await tester.tap(find.byKey(const Key('skill-group-save')));
      await settle(tester);
      expect(model.savedGroupId, 2);
      expect(model.state.report!.groups, hasLength(2));
      expect(
        jsonRows(model.state.report!.groups.last['gems']).first['level'],
        9,
      );
      await tester.tap(find.byKey(const ValueKey('delete-skill-group-2')));
      await settle(tester);
      expect(model.deletedGroupId, 2);
      expect(model.state.report!.groups, hasLength(1));
      await tester.tap(find.byKey(const ValueKey('delete-skill-group-1')));
      await settle(tester);
      expect(model.state.report!.groups, isEmpty);
      expect(find.byKey(const Key('add-skill-group')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await settle(tester);
    },
  );

  testWidgets('Редактор переключает активные камни и сохраняет их вместе', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1300, 950));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final model = EditorWorkshop(
      EditorCatalogEngine(gemEntries: const [fireball, support, ice]),
      report: workspaceReport(),
    );
    addTearDown(model.close);
    await tester.pumpWidget(application(SkillsView(model: model)));
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('skill-group-1')),
        matching: find.byTooltip('Редактировать группу'),
      ),
    );
    await settle(tester);

    await tester.tap(find.byKey(const ValueKey('catalog-gem-ice')));
    await settle(tester);
    final picker = find.descendant(
      of: find.byKey(const Key('composer-support-target')),
      matching: find.byType(DropdownButton<int>),
    );
    expect(tester.widget<DropdownButton<int>>(picker).value, 1);
    await tester.enterText(find.byKey(const ValueKey('gem-level-1')), '9');
    await settle(tester);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .ancestor(
            of: find.byKey(const ValueKey('support-target-0')).last,
            matching: find.byType(InkWell),
          )
          .first,
    );
    await settle(tester);
    expect(tester.widget<DropdownButton<int>>(picker).value, 0);
    expect(find.byKey(const ValueKey('gem-level-0')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('catalog-gem-support')).last);
    await settle(tester);
    await tester.tap(find.byKey(const Key('skill-group-save')));
    await settle(tester);

    expect(model.savedGroupId, 1);
    expect(
      model.savedGems!.map(
        (gem) => (gem['id'], gem['level'], gem['sourceIndex']),
      ),
      [('gem-fireball', 5, 1), ('ice', 9, null), ('support', 1, null)],
    );
    expect(find.byKey(const Key('workspace-support-target')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester);
  });

  testWidgets('Предпросмотр DPS получает полную группу и сохраняет черновик', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1300, 950));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final engine = _SupportPreviewEngine();
    final model = EditorWorkshop(engine, report: workspaceReport());
    addTearDown(model.close);
    await tester.pumpWidget(application(SkillsView(model: model)));
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('skill-group-1')),
        matching: find.byTooltip('Редактировать группу'),
      ),
    );
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('catalog-gem-ice')));
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('gem-level-1')), '9');
    await settle(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('preview-support-support')).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('preview-support-support')).last,
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(engine.previewRequest, {
      'groupId': 1,
      'targetIndex': 2,
      'supportId': 'support',
      'gems': [
        {
          'id': 'gem-fireball',
          'level': 5,
          'quality': 20,
          'enabled': true,
          'sourceIndex': 1,
        },
        {'id': 'ice', 'level': 9, 'quality': 0, 'enabled': true},
      ],
    });
    engine.result.complete({
      'source': 'original-lua',
      'before': 12.817708333333,
      'after': 15.333333333333,
      'delta': 2.515625,
    });
    await settle(tester);
    expect(find.text('DPS до'), findsOneWidget);
    expect(find.text('DPS после'), findsOneWidget);
    expect(find.text('Прирост DPS'), findsOneWidget);
    expect(find.text('12,8177'), findsOneWidget);
    expect(find.text('15,3333'), findsOneWidget);
    expect(find.text('+2,5156'), findsOneWidget);
    await tester.tap(find.text('Закрыть'));
    await settle(tester);
    expect(
      find.byKey(const ValueKey('catalog-gem-support')).last,
      findsOneWidget,
    );
    expect(model.savedGems, isNull);
    expect(model.state.report!.groups.first['gems'], hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester);
  });

  testWidgets('Умение от предмета принимает поддержку и сохраняет источник', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1300, 950));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final primary = {
      'skillId': 'CoilingBoltsPlayer',
      'name': 'Coiling Bolts',
      'sourceIndex': 1,
      'level': 20,
      'quality': 0,
      'enabled': true,
    };
    final report = BuildReport.fromJson({
      ...workspaceReport().raw,
      'groups': [
        {'id': 1, 'slotSupports': true, 'gems': []},
        {
          'id': 2,
          'label': 'Coiling Bolts',
          'source': 'Item:1:Liminal Coil',
          'supportScope': 'slot',
          'gems': [primary],
        },
      ],
    });
    final model = EditorWorkshop(
      EditorCatalogEngine(gemEntries: const [fireball, support]),
      report: report,
    );
    addTearDown(model.close);
    await tester.pumpWidget(application(SkillsView(model: model)));
    await settle(tester);
    expect(find.byKey(const ValueKey('skill-group-drop-1')), findsNothing);
    expect(find.byKey(const ValueKey('delete-skill-group-2')), findsNothing);

    final tile = find.byKey(const ValueKey('catalog-gem-support'));
    final group = find.byKey(const ValueKey('skill-group-drop-2'));
    await tester.dragFrom(
      tester.getCenter(tile),
      tester.getCenter(group) - tester.getCenter(tile),
    );
    await settle(tester);
    expect(model.savedGroupId, 2);
    expect(model.savedGems!.first, {
      'id': 'CoilingBoltsPlayer',
      'sourceIndex': 1,
    });
    expect(model.state.report!.groups.last['gems'], hasLength(2));

    final added = find.byKey(const ValueKey('group-gem-2-2'));
    final library = find.byKey(const Key('gem-return-target'));
    await tester.dragFrom(
      tester.getCenter(added),
      tester.getCenter(library) - tester.getCenter(added),
    );
    await settle(tester);
    expect(model.state.report!.groups.last['gems'], [primary]);
    await tester.tap(find.byTooltip('Редактировать группу'));
    await settle(tester);
    expect(find.text('Редактор группы умений'), findsOneWidget);
    expect(find.byKey(const ValueKey('gem-level-0')), findsNothing);
    expect(find.byKey(const Key('skill-group-label')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester);
  });

  testWidgets('Показатели не повторяют одинаковое название группы и умения', (
    tester,
  ) async {
    final model = EditorWorkshop(
      EditorCatalogEngine(),
      report: workspaceReport(),
    );
    addTearDown(model.close);
    await tester.pumpWidget(application(SkillSelectors(model: model)));
    expect(find.text('Огненный шар'), findsOneWidget);
  });
}
