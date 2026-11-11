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

typedef ProgressionHighlight = ({String metric, num delta});

List<ProgressionHighlight> progressionHighlights(
  BuildReport before,
  BuildReport after,
) {
  final changes = <({ProgressionHighlight value, double relative})>[];
  final dps = _timelineDps(before, after);
  for (final metric in progressionMetrics.where(
    (key) => !key.endsWith('DPS') || key == dps,
  )) {
    final old = before.stats[metric];
    final next = after.stats[metric];
    if (old is! num || next is! num || !old.isFinite || !next.isFinite) {
      continue;
    }
    final delta = next - old;
    if (delta == 0) continue;
    changes.add((
      value: (metric: metric, delta: delta),
      relative: (delta.abs() / old.abs().clamp(1, double.infinity)).toDouble(),
    ));
  }
  changes.sort((a, b) => b.relative.compareTo(a.relative));
  return changes.take(2).map((entry) => entry.value).toList();
}

String _timelineDps(BuildReport before, BuildReport after) {
  final old = before.stats['FullDPS'];
  final next = after.stats['FullDPS'];
  return old is num && next is num && (old > 0 || next > 0)
      ? 'FullDPS'
      : 'TotalDPS';
}
