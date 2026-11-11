import 'build_report.dart';
import 'tree_progression.dart';

typedef ProgressionComparison = ({
  BuildReport before,
  BuildReport after,
  TreeProgressionChange nodes,
});

const progressionMetrics = [
  'FullDPS',
  'TotalDPS',
  'Life',
  'Mana',
  'EnergyShield',
  'Armour',
  'Evasion',
  'EffectiveHitPool',
  'BlockChance',
  'FireResist',
  'ColdResist',
  'LightningResist',
  'ChaosResist',
];
