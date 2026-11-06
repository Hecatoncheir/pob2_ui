import '../domain/equipment_item.dart';
import 'mcp_client.dart';

class EquipmentRepository {
  EquipmentRepository(this.engine);
  final McpClient engine;
  bool get available => engine.tools.containsAll({
    'pob_inspect_item',
    'pob_equip_item',
    'pob_select_weapon_set',
  });
  Future<ItemInspection> inspect(
    String slot, {
    String? raw,
    int? itemId,
  }) async {
    if (!available)
      throw const FormatException('Обновите MCP для редактора экипировки');
    return ItemInspection.fromJson(
      await engine.call('pob_inspect_item', {
        'slot': slot,
        if (raw != null) 'raw': raw,
        if (itemId != null) 'itemId': itemId,
      }),
    );
  }
}
