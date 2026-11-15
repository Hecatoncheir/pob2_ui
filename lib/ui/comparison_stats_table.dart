import 'package:material_ui/material_ui.dart';

import '../domain/build_report.dart';
import '../domain/progression_comparison.dart';
import 'core/app_text.dart';

class ComparisonStatsTable extends StatelessWidget {
  const ComparisonStatsTable(
    this.before,
    this.after, {
    this.beforeLabel = 'Было',
    this.afterLabel = 'Стало',
    super.key,
  });

  final BuildReport before, after;
  final String beforeLabel, afterLabel;

  @override
  Widget build(BuildContext context) => Table(
    columnWidths: const {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(),
      2: FlexColumnWidth(),
      3: FlexColumnWidth(),
    },
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: [
      TableRow(
        children: [
          const AppText('Показатель'),
          AppText(beforeLabel, textAlign: TextAlign.end),
          AppText(afterLabel, textAlign: TextAlign.end),
          const AppText('Разница', textAlign: TextAlign.end),
        ],
      ),
      _row(context, 'Уровень', before.level, after.level),
      for (final metric in progressionMetrics)
        if (before.stats[metric] is num || after.stats[metric] is num)
          _row(
            context,
            statLabel(metric),
            before.stats[metric],
            after.stats[metric],
            percent: metric.endsWith('Resist') || metric == 'BlockChance',
          ),
    ],
  );

  TableRow _row(
    BuildContext context,
    String label,
    Object? before,
    Object? after, {
    bool percent = false,
  }) {
    final suffix = percent ? ' %' : '';
    final delta = before is num && after is num ? after - before : null;
    final scheme = Theme.of(context).colorScheme;
    final color = switch (delta) {
      final num value when value > 0 => scheme.secondary,
      final num value when value < 0 => scheme.error,
      _ => null,
    };
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AppText(label),
        ),
        Text(formatStat(before, suffix: suffix), textAlign: TextAlign.end),
        Text(formatStat(after, suffix: suffix), textAlign: TextAlign.end),
        Text(
          delta == null ? '—' : '${delta > 0 ? '+' : ''}${formatStat(delta)}',
          textAlign: TextAlign.end,
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
