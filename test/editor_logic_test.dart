import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/game_catalog_repository.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/condition_definition.dart';
import 'package:pob2_ui/ui/condition_editor_cubit.dart';
import 'package:pob2_ui/ui/skill_group_cubit.dart';

import 'support/editor_fakes.dart';

class PagedCatalog extends McpClient {
  final offsets = <int>[];
  bool broken = false;
  bool malformed = false;
  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    final offset = arguments['offset'] as int;
    offsets.add(offset);
    final rows = offset == 0
        ? [
            {...moving, if (malformed) 'name': 5},
          ]
        : [
            {...boss, if (malformed) 'name': 5},
            moving,
          ];
    return {'entries': broken ? [] : rows, 'total': 3};
  }
}

void main() {
  test(
    'Оригинальные иконки загружаются пакетами и кешируются до переподключения',
    () async {
      final engine = EditorCatalogEngine();
      final repository = GameCatalogRepository(engine);
      final icons = await Future.wait(
        List.generate(33, (id) => repository.icon('gem-$id')),
      );
      expect(engine.iconRequests.map((ids) => ids.length), [24, 9]);
      expect(icons.first.bytes.take(4), [137, 80, 78, 71]);
      expect(() => icons.first.bytes[0] = 0, throwsUnsupportedError);
      await repository.icon('gem-0');
      expect(engine.iconRequests, hasLength(2));
      repository.clear();
      await repository.icon('gem-0');
      expect(engine.iconRequests, hasLength(3));
    },
  );
  test('Повтор загрузки перечитывает каталог после ошибки схемы', () async {
    final engine = PagedCatalog()..malformed = true;
    final repository = GameCatalogRepository(engine);
    await expectLater(repository.conditions(), throwsFormatException);
    engine.malformed = false;
    expect(await repository.conditions(), hasLength(2));
    expect(engine.offsets, [0, 1, 0, 1]);
  });

  test('Каталог читает все страницы, объединяет ID и кеширует только успешное чтение', () async {
    final engine = PagedCatalog()..broken = true;
    final repository = GameCatalogRepository(engine);
    await expectLater(repository.conditions(), throwsFormatException);
    engine.broken = false;
    final entries = await repository.conditions();
    expect(entries.map((entry) => entry.id), [
      'conditionEnemyMoving',
      'enemyIsBoss',
    ]);
    expect(entries.last.choices, hasLength(2));
    expect(engine.offsets, [0, 0, 1]);
    await repository.conditions();
    expect(engine.offsets, [0, 0, 1]);
    repository.clear();
    await repository.conditions();
    expect(engine.offsets, [0, 0, 1, 0, 1]);
  });

  test('Формы различают целое, дробное, текст, флаг и значение каталога', () {
    for (final type in ['count', 'countAllowZero', 'integer']) {
      final definition = ConditionDefinition(id: type, name: type, type: type);
      expect(definition.parse('0', null), 0);
      expect(() => definition.parse('1.5', null), throwsFormatException);
    }
    final number = ConditionDefinition(id: 'x', name: '', type: 'float');
    expect(number.parse('1,25', null), 1.25);
    expect(() => number.parse('NaN', null), throwsFormatException);
    expect(() => number.parse('Infinity', null), throwsFormatException);
    expect(ConditionDefinition.fromJson(moving).parse('', true), isTrue);
    expect(
      ConditionDefinition(id: 'x', name: '', type: 'text').parse('', null),
      '',
    );
    final list = ConditionDefinition.fromJson(boss);
    expect(list.selection('old-value'), isNull);
    expect(() => list.parse('', 'old-value'), throwsFormatException);
    expect(list.parse('', 'Pinnacle'), 'Pinnacle');
  });

  test('Черновик хранит отдельные строки, не отправляет ошибочное число и сохраняется при отказе Lua', () async {
    final engine = EditorCatalogEngine();
    final requests = <List<JsonMap>>[];
    var reject = true;
    final editor = SkillGroupCubit(GameCatalogRepository(engine), (
      label,
      gems,
    ) async {
      requests.add(gems);
      return (committed: !reject, error: reject ? 'Lua отклонил группу' : null);
    });
    addTearDown(editor.close);
    await editor.load();
    editor.add(editor.state.catalog.single);
    editor.change(0, level: 'abc');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(await editor.save(), isFalse);
    expect(requests, isEmpty);
    editor.change(0, level: '5', quality: '20', enabled: false);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(await editor.save(), isFalse);
    expect(editor.state.gems.single.level, '5');
    expect(editor.state.error, 'Lua отклонил группу');
    reject = false;
    expect(await editor.save(), isTrue);
    expect(requests.last.single, {
      'id': 'gem-fireball',
      'level': 5,
      'quality': 20,
      'enabled': false,
    });
  });

  test('Повторный submit и изменение формы во время расчёта не меняют отправленный запрос', () async {
    final gate = Completer<({bool committed, String? error})>();
    final editor = ConditionEditorCubit(
      ConditionDefinition.fromJson(moving),
      false,
      (_, _) => gate.future,
    );
    addTearDown(editor.close);
    editor.select(true);
    final saving = editor.save();
    editor.select(false);
    expect(editor.state.selection, isTrue);
    expect(await editor.save(), isFalse);
    gate.complete((committed: true, error: null));
    expect(await saving, isTrue);
    expect(editor.state.saving, isFalse);
  });
}
