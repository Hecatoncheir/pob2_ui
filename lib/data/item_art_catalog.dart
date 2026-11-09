import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/build_report.dart';
import '../domain/equipment_item.dart';

class ItemArtCatalog {
  const ItemArtCatalog._(this._bases, this._uniques);

  static final shared = _load();
  final Map<String, String> _bases, _uniques;

  static Future<ItemArtCatalog> _load() async {
    final data = jsonDecode(
      await rootBundle.loadString('assets/item_art.json'),
    ) as Map<String, dynamic>;
    return ItemArtCatalog._(
      Map<String, String>.from(data['bases'] as Map),
      Map<String, String>.from(data['uniques'] as Map),
    );
  }

  String? imageFor(EquipmentItem item) =>
      _image(item.name, item.base, item.rarity);

  String? imageForReport(JsonMap item) => _image(
    item['name'] as String? ?? '',
    item['base'] as String? ?? '',
    item['rarity'] as String? ?? '',
  );

  String? _image(String name, String base, String rarity) {
    final nameKey = name.trim().toLowerCase();
    final baseKey = base.trim().toLowerCase();
    final unique = rarity == 'UNIQUE' || rarity == 'RELIC'
        ? _uniques[nameKey] ?? _uniques['$nameKey, $baseKey']
        : null;
    final path = unique ?? _bases[baseKey];
    return path == null
        ? null
        : 'https://cdn.poe2db.tw/image/Art/2DItems/$path';
  }
}
