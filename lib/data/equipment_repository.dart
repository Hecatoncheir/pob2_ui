import '../domain/equipment_item.dart';
import 'workbench_client.dart';

typedef SharedEquipmentReader = Future<ItemInspection?> Function({
  String? slot,
  String? raw,
  int? itemId,
  required bool compare,
});

class EquipmentRepository {
  EquipmentRepository(this.engine, {this.readShared});
  final WorkbenchClient engine;
  final SharedEquipmentReader? readShared;
  bool get canCompare => engine.tools.contains('pob_compare_item');
  bool get canInspect => engine.tools.contains('pob_inspect_item');
  bool get available => engine.tools.containsAll({
    'pob_inspect_item',
    'pob_equip_item',
    'pob_select_weapon_set',
  });
  Future<ItemInspection> inspect({
    String? slot,
    String? raw,
    int? itemId,
    bool compare = false,
  }) async {
    final shared = await readShared?.call(
      slot: slot,
      raw: raw,
      itemId: itemId,
      compare: compare,
    );
    if (shared != null) return shared;
    if (!canInspect)
      throw const FormatException('Обновите MCP для редактора экипировки');
    return ItemInspection.fromJson(
      await engine.call(
        compare && canCompare ? 'pob_compare_item' : 'pob_inspect_item',
        {
          if (slot != null) 'slot': slot,
          if (raw != null) 'raw': raw,
          if (itemId != null) 'itemId': itemId,
        },
      ),
    );
  }
}
