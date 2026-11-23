import 'build_report.dart';
import 'item_comparison.dart';
import 'item_name.dart';

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
  String get displayName => readableItemName(name, base);
}

class ItemInspection {
  ItemInspection.fromJson(JsonMap json)
    : item = EquipmentItem.fromJson(jsonMap(json['item'])),
      slots = List.unmodifiable(jsonStrings(json['slots'])),
      compatible = json['compatible'] == true,
      lines = List.unmodifiable(jsonRows(json['lines'])),
      buildRevision = null,
      comparison = json['comparison'] is JsonMap
          ? ItemComparison.fromJson(json['comparison'] as JsonMap)
          : null {
    if (json['source'] != 'original-lua')
      throw const FormatException('Ожидалось описание предмета из Lua');
  }
  ItemInspection.withBuildRevision(ItemInspection source, this.buildRevision)
    : item = source.item,
      slots = source.slots,
      compatible = source.compatible,
      lines = source.lines,
      comparison = source.comparison;

  final int? buildRevision;
  final EquipmentItem item;
  final List<String> slots;
  final List<JsonMap> lines;
  final bool compatible;
  final ItemComparison? comparison;

  String displayText(String text) {
    final clean = cleanPoB(text);
    if (clean.isEmpty || clean != cleanPoB(item.name)) return text;
    return text.replaceFirst(clean, item.displayName);
  }
}
