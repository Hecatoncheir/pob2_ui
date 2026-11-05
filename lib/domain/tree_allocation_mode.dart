enum TreeAllocationMode {
  common(0),
  weaponOne(1),
  weaponTwo(2);

  const TreeAllocationMode(this.luaValue);
  final int luaValue;
}
