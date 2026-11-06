import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/mcp_error_message.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/equipment_item.dart';
import 'package:pob2_ui/ui/equipment_view.dart';
import 'package:pob2_ui/ui/equipment_board.dart';
import 'package:pob2_ui/ui/item_editor_cubit.dart';

import 'editor_widget_test.dart' show application;
import 'support/editor_fakes.dart';
import 'support/workshop_fixture.dart' show fixture;

ItemInspection inspection({
  bool compatible = true,
  String name = 'Tide Loop',
}) => ItemInspection.fromJson({
  'source': 'original-lua',
  'compatible': compatible,
  'slots': ['Ring 1', 'Ring 2'],
  'item': {
    'name': name,
    'base': 'Lazuli Ring',
    'rarity': 'RARE',
    'raw': 'Rarity: Rare\n$name\nLazuli Ring',
    'unsupported': [
      {'line': 'unrecognized modifier'},
    ],
  },
  'lines': [
    {'size': 22, 'text': '^xFFFF77$name'},
    {'separator': true},
    {'text': '^x8888FF+50 to maximum Life'},
    {'separator': true},
    {'text': '^xDD0022Requires Level 99'},
  ],
});

class EquipmentEngine extends EditorCatalogEngine {
  EquipmentEngine() {
    tools = {
      ...tools,
      'pob_inspect_item',
      'pob_equip_item',
      'pob_select_weapon_set',
    };
  }
  bool incompatible = false;
  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    if (name != 'pob_inspect_item') return super.call(name, arguments);
    final value = inspection(compatible: !incompatible);
    return {
      'source': 'original-lua',
      'compatible': value.compatible,
      'slots': value.slots,
      'item': {
        'name': value.item.name,
        'raw': value.item.raw,
        'rarity': value.item.rarity,
        'unsupported': value.item.unsupported,
      },
      'lines': value.lines,
    };
  }
}

class EquipmentWorkshop extends EditorWorkshop {
  EquipmentWorkshop(EquipmentEngine super.engine);
  ({String slot, String? raw, int? id})? equipped;
  @override
  Future<({bool committed, String? error})> equipItem(
    String slot, {
    String? raw,
    int? itemId,
  }) async {
    equipped = (slot: slot, raw: raw, id: itemId);
    return result;
  }
}

void main() {
  testWidgets('Название оберега видно только при наведении', (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final report = BuildReport.fromJson({
      ...fixture.raw,
      'items': [],
      'slots': [
        {'name': 'Charm 1', 'itemId': 0, 'visible': true},
      ],
    });
    await tester.pumpWidget(
      application(
        EquipmentBoard(
          report: report,
          selected: null,
          select: (_) {},
          busy: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Оберег I'), findsNothing);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    addTearDown(mouse.removePointer);
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('equipment-slot-Charm 1'))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Оберег I'), findsOneWidget);
  });
  test('Сообщение Lua показывается без служебного JSON', () {
    expect(
      mcpErrorMessage(
        StateError(
          '{"code":"INVALID_REQUEST","message":"Lua не распознал базу предмета"}',
        ),
      ),
      'Lua не распознал базу предмета',
    );
    expect(mcpErrorMessage(StateError('Нет соединения')), 'Нет соединения');
  });
  test(
    'Устаревшее описание игнорируется, отказ сохраняет текст и совместимость',
    () async {
      final first = Completer<ItemInspection>();
      var calls = 0;
      final editor = ItemEditorCubit(
        ({raw, itemId}) async =>
            ++calls == 1 ? first.future : inspection(compatible: false),
        ({raw, itemId}) async => (committed: false, error: 'Сбой записи'),
      );
      addTearDown(editor.close);
      editor.text('first');
      final pending = editor.preview();
      editor.text('second');
      await editor.preview();
      first.complete(inspection());
      await pending;
      expect(editor.state.raw, 'second');
      expect(editor.state.preview!.compatible, isFalse);
      expect(editor.canSave, isFalse);
      expect(editor.mayExit(), isFalse);
    },
  );

  for (final width in [360.0, 1280.0]) {
    testWidgets('Экипировка и ввод предмета: $width, отказ и повтор', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = EquipmentWorkshop(EquipmentEngine());
      addTearDown(model.close);
      await tester.pumpWidget(application(ItemsView(model: model)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('equipment-slot-Weapon 1')));
      await tester.pumpAndSettle();
      final edit = find.byKey(const Key('equipment-edit'));
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('item-raw')),
        'Rarity: Rare\nTide Loop\nLazuli Ring',
      );
      await tester.tap(find.byKey(const Key('item-preview')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Не распознано Lua'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      model.result = (committed: false, error: 'Ошибка сохранения');
      await tester.tap(find.byKey(const Key('item-editor-save')));
      await tester.pumpAndSettle();
      expect(find.text('Ошибка сохранения'), findsOneWidget);
      expect(find.byKey(const Key('item-raw')), findsOneWidget);
      model.result = (committed: true, error: null);
      await tester.tap(find.byKey(const Key('item-editor-save')));
      await tester.pumpAndSettle();
      expect(model.equipped?.slot, 'Weapon 1');
      expect(find.byKey(const Key('item-editor-save')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
