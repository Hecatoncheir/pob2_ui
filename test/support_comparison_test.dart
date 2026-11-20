import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/game_catalog_repository.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/skill_gem.dart';
import 'package:pob2_ui/ui/skill_group_cubit.dart';
import 'package:pob2_ui/ui/skill_socket_summary.dart';
import 'package:pob2_ui/ui/skills_view.dart';
import 'package:pob2_ui/ui/support_comparison_cubit.dart';
import 'package:pob2_ui/ui/support_comparison_dialog.dart';

import 'editor_widget_test.dart' show application;
import 'support/editor_fakes.dart';
import 'skill_workspace_widget_test.dart' show workspaceReport, settle;

const _ice = {'id': 'ice', 'name': 'Ice Nova'};
const _a = {'id': 'a', 'name': 'Controlled Destruction', 'support': true};
const _b = {'id': 'b', 'name': 'Rapid Casting', 'support': true};
const _c = {'id': 'c', 'name': 'Broken Support', 'support': true};
const _group = {
  'id': 2,
  'gems': [
    {...fireball, 'level': 5, 'quality': 10, 'enabled': true, 'sourceIndex': 1},
    {..._ice, 'level': 9, 'quality': 0, 'enabled': true, 'sourceIndex': 2},
  ],
};

class _Engine extends EditorCatalogEngine {
  _Engine() : super(gemEntries: const [fireball, _ice, _a, _b, _c]) {
    tools.addAll({'pob_preview_support', 'pob_compare_supports'});
  }
  final pending = Completer<JsonMap>();
  JsonMap? comparisonRequest, compatibilityRequest;
  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    if (name == 'pob_compare_supports') {
      comparisonRequest = arguments;
      return pending.future;
    }
    if (name == 'pob_gem_supports') {
      compatibilityRequest = arguments;
      return {
        'source': 'original-lua',
        'supportIds': ['a', 'b', 'c'],
        'sockets': {
          'supportCount': 0,
          'enabledSupportCount': 0,
          'scope': 'group',
          'supportsAllowed': true,
          'capacity': null,
          'capacityStatus': 'unavailable',
        },
        'warnings': ['Lua warning'],
      };
    }
    return super.call(name, arguments);
  }
}

SkillGroupCubit _editor(
  _Engine engine, {
  Object? Function()? version,
  Stream<Object?>? changes,
}) => SkillGroupCubit(
  GameCatalogRepository(engine),
  (_, _) async => throw StateError('Сравнение не должно сохранять группу'),
  initial: groupGemDrafts(_group),
  groupId: 2,
  group: _group,
  contextVersion: version,
  contextChanges: changes,
);

Future<void> _ready(SkillGroupCubit editor) async {
  await editor.load();
  await editor.stream.firstWhere(
    (state) => !state.loading && !state.support.loading,
  );
}

JsonMap _result(List<JsonMap> entries) => {
  'source': 'original-lua',
  'xmlHash': 'a' * 64,
  'baseRevision': 7,
  'entries': entries,
};
JsonMap _entry(String id, num? delta) => {
  'supportId': id,
  'source': 'original-lua',
  'before': delta == null ? null : 100,
  'after': delta == null ? null : 100 + delta,
  'delta': delta,
  'warnings': <String>[],
};

void main() {
  testWidgets(
    'Состав и предупреждения оставляют место переносу в невысокой панели',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(720, 450));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = EditorWorkshop(_Engine(), report: workspaceReport());
      addTearDown(model.close);
      await tester.pumpWidget(application(SkillsView(model: model)));
      await settle(tester);
      final tile = find.byKey(const ValueKey('catalog-gem-a'));
      final row = find.byKey(const ValueKey('skill-group-drop-1'));
      await tester.scrollUntilVisible(
        tile,
        140,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('gem-catalog')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.dragFrom(
        tester.getCenter(tile),
        tester.getCenter(row) - tester.getCenter(tile),
      );
      await settle(tester);
      expect(model.savedGems, hasLength(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await settle(tester);
    },
  );

  testWidgets('Длинные предупреждения открываются отдельно и прокручиваются', (
    tester,
  ) async {
    final engine = _Engine();
    final editor = _editor(engine);
    addTearDown(editor.close);
    await editor.load();
    await tester.pump(const Duration(milliseconds: 350));
    final info = editor.state.compatibility!;
    final state = editor.state.copyWith(
      compatibility: (
        ids: info.ids,
        sockets: info.sockets,
        warnings: List.generate(25, (index) => 'Предупреждение Lua $index'),
      ),
    );
    await tester.pumpWidget(
      application(
        Center(
          child: SizedBox(
            width: 360,
            height: 100,
            child: SkillSocketSummary(state),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('skill-support-warnings')));
    await tester.pumpAndSettle();
    expect(find.text('Предупреждения'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Предупреждение Lua 24'),
      350,
      scrollable: find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Предупреждение Lua 24'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
  });

  test(
    'Совместимость получает полную группу и позицию выбранного камня',
    () async {
      final engine = _Engine();
      final editor = _editor(engine);
      addTearDown(editor.close);
      expect(editor.canCompareSupports, isFalse);
      await _ready(editor);
      editor.selectSupportTarget(1);
      await editor.stream.firstWhere((state) => !state.support.loading);
      expect(engine.compatibilityRequest!['gems'], hasLength(2));
      expect(engine.compatibilityRequest!['targetIndex'], 2);
      expect(editor.state.compatibility!.sockets!.count, 0);
      expect(editor.state.compatibility!.warnings, ['Lua warning']);
    },
  );

  test(
    'Ранжирование сохраняет ошибки, отрицательный и отсутствующий DPS',
    () async {
      final engine = _Engine();
      final editor = _editor(engine);
      addTearDown(editor.close);
      await _ready(editor);
      final model = SupportComparisonCubit(editor);
      addTearDown(model.close);
      for (final id in ['a', 'b', 'c']) {
        model.toggle(id);
      }
      final running = model.calculate();
      engine.pending.complete(
        _result([
          _entry('a', -5),
          _entry('b', 20),
          {
            'supportId': 'c',
            'error': {'code': 'INVALID_REQUEST', 'message': 'Причина отказа'},
          },
        ]),
      );
      await running;
      expect(model.state.result!.ranked.map((row) => row.id), ['b', 'a', 'c']);
      expect(model.state.result!.entries.last.error, 'Причина отказа');
      expect(engine.comparisonRequest!['gems'], hasLength(2));
      expect(engine.comparisonRequest!['targetIndex'], 1);
      expect(editor.state.supportTarget!.gem.id, fireball['id']);
      expect(editor.dirty, isFalse);
      final nil = _Engine();
      nil.pending.complete(_result([_entry('a', null)]));
      final unknown = await GameCatalogRepository(nil)
          .compareSupports([], targetIndex: 1, supportIds: ['a']);
      expect(unknown.entries.single.dps!.delta, isNull);
    },
  );

  test('Смена активного камня отклоняет запоздалый результат', () async {
    final engine = _Engine();
    final editor = _editor(engine);
    addTearDown(editor.close);
    await _ready(editor);
    final model = SupportComparisonCubit(editor);
    addTearDown(model.close);
    model.toggle('a');
    final running = model.calculate();
    editor.selectSupportTarget(1);
    engine.pending.complete(_result([_entry('a', 20)]));
    await running;
    expect(model.state.invalid, isTrue);
    expect(model.state.result, isNull);
    expect(model.state.error, contains('изменились'));
    expect(editor.state.supportTarget!.gem.id, 'ice');
  });

  test('Изменение сборки удаляет уже показанное сравнение', () async {
    final engine = _Engine();
    Object version = Object();
    final changes = StreamController<Object?>();
    addTearDown(changes.close);
    final editor = _editor(
      engine,
      version: () => version,
      changes: changes.stream,
    );
    addTearDown(editor.close);
    await _ready(editor);
    final model = SupportComparisonCubit(editor);
    addTearDown(model.close);
    model.toggle('a');
    engine.pending.complete(_result([_entry('a', 20)]));
    await model.calculate();
    expect(model.state.result, isNotNull);
    version = Object();
    changes.add(version);
    await Future<void>.delayed(Duration.zero);
    expect(model.state.invalid, isTrue);
    expect(model.state.result, isNull);
  });

  test(
    'Сравнение после собственного сохранения использует новое состояние',
    () async {
      final engine = _Engine();
      Object version = Object();
      final editor = SkillGroupCubit(
        GameCatalogRepository(engine),
        (_, _) async {
          version = Object();
          return (committed: true, error: null);
        },
        initial: groupGemDrafts(_group),
        groupId: 2,
        group: _group,
        contextVersion: () => version,
      );
      addTearDown(editor.close);
      await _ready(editor);
      editor.add(SkillGem.fromJson(_a));
      await editor.stream.firstWhere((state) => !state.support.loading);
      expect(await editor.save(), isTrue);
      engine.pending.complete(_result([_entry('b', 20)]));
      final result = await editor.compareSupports(['b']);
      expect(result.entries.single.id, 'b');
      expect(editor.dirty, isFalse);
    },
  );

  test('Подменённые ID и бесконечные значения отклоняются', () async {
    for (final entries in [
      [_entry('b', 1)],
      [_entry('a', double.infinity)],
    ]) {
      final engine = _Engine();
      engine.pending.complete(_result(entries));
      await expectLater(
        GameCatalogRepository(engine)
            .compareSupports([], targetIndex: 1, supportIds: ['a']),
        throwsFormatException,
      );
    }
  });

  for (final size in [const Size(1280, 800), const Size(390, 844)]) {
    testWidgets('Выбор и результаты сравнения при ширине ${size.width}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final engine = _Engine();
      final editor = _editor(engine);
      addTearDown(editor.close);
      await editor.load();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpWidget(
        application(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showSupportComparison(context, editor),
              child: const Text('Открыть'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('compare-support-a')));
      await tester.tap(find.byKey(const ValueKey('compare-support-b')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('support-comparison-calculate')));
      await tester.pump();
      engine.pending.complete(_result([_entry('a', 10), _entry('b', 20)]));
      await tester.pumpAndSettle();
      final first = find.byKey(const ValueKey('support-result-b'));
      final second = find.byKey(const ValueKey('support-result-a'));
      expect(first, findsOneWidget);
      expect(
        tester.getTopLeft(first).dy,
        lessThan(tester.getTopLeft(second).dy),
      );
      expect(editor.dirty, isFalse);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('support-comparison-close')));
      await tester.pumpAndSettle();
    });
  }
}
