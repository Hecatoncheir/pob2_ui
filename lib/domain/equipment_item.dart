import 'build_report.dart';

class EquipmentItem {
  EquipmentItem.fromJson(JsonMap json)
    : id = json['id'] as int?,
      name = json['name'] as String,
      base = json['base'] as String? ?? '',
      raw = json['raw'] as String,
      rarity = json['rarity'] as String? ?? 'NORMAL',
      unsupported = List.unmodifiable(jsonRows(json['unsupported']));
  final int? id;
  final String name, base, raw, rarity;
  final List<JsonMap> unsupported;
}

class ItemInspection {
  ItemInspection.fromJson(JsonMap json)
    : item = EquipmentItem.fromJson(jsonMap(json['item'])),
      slots = List.unmodifiable(jsonStrings(json['slots'])),
      compatible = json['compatible'] == true,
      lines = List.unmodifiable(jsonRows(json['lines'])) {
    if (json['source'] != 'original-lua')
      throw const FormatException('Ожидалось описание предмета из Lua');
  }
  final EquipmentItem item;
  final List<String> slots;
  final List<JsonMap> lines;
  final bool compatible;
}
