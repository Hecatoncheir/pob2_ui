enum TreeAllocationMode {
  common(0, 'common'),
  weaponOne(1, 'weapon_set_1'),
  weaponTwo(2, 'weapon_set_2');

  const TreeAllocationMode(this.luaValue, this.wireName);

  final int luaValue;
  final String wireName;

  static TreeAllocationMode? fromWire(String name) =>
      values.where((mode) => mode.wireName == name).firstOrNull;
}
