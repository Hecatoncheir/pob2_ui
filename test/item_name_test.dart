import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/equipment_item.dart';
import 'package:pob2_ui/domain/item_name.dart';

void main() {
  test(
    'Повреждённое имя заменяется сохранившейся базой без изменения данных',
    () {
      final item = {
        'name': '???????? ??????',
        'base': 'Siphoning Wand',
        'raw': 'Rarity: RARE\n???????? ??????\nSiphoning Wand',
      };
      final original = Map.of(item);
      expect(itemDisplayName(item), 'Siphoning Wand');
      expect(EquipmentItem.fromJson(item).displayName, 'Siphoning Wand');
      expect(item, original);
    },
  );

  test('Имена всех редкостей, кириллица и неизвестный перевод сохраняются', () {
    for (final name in [
      'Siphoning Wand',
      'Flaming Siphoning Wand',
      'Doom Song',
      'Liminal Coil',
      'Песнь рока',
      '名前',
      'Unknown name?',
    ]) {
      expect(readableItemName(name, 'Wand'), name);
    }
    expect(readableItemName('^xFFFF77Песнь рока', 'Wand'), 'Песнь рока');
    expect(readableItemName('Sword\uFFFD', 'Wand'), 'Wand');
    expect(readableItemName('', 'Wand'), 'Wand');
    expect(readableItemName('?', 'Wand'), 'Wand');
    expect(readableItemName('????', '????'), '—');
  });

  test(
    'Описание Lua заменяет только повреждённый заголовок и сохраняет цвет',
    () {
      final source = {
        'source': 'original-lua',
        'item': {
          'name': '???? ????',
          'base': 'Lazuli Ring',
          'raw': 'Rarity: RARE\n???? ????\nLazuli Ring',
        },
        'lines': [
          {'text': '^xFFFF77???? ????'},
          {'text': '^x8888FF+50 to maximum Life'},
        ],
      };
      final inspection = ItemInspection.fromJson(source);
      expect(
        inspection.displayText('^xFFFF77???? ????'),
        '^xFFFF77Lazuli Ring',
      );
      expect(
        inspection.displayText('^x8888FF+50 to maximum Life'),
        '^x8888FF+50 to maximum Life',
      );
      expect(inspection.item.name, '???? ????');
      expect(inspection.lines.first['text'], '^xFFFF77???? ????');
    },
  );
}
