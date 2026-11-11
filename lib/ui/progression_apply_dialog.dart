import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/build_report.dart';
import '../domain/progression_comparison.dart';
import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/ui_translation.dart';
import 'progression_comparison_bloc.dart';

class ProgressionApplyDialog extends StatelessWidget {
  const ProgressionApplyDialog(this.available, this.nodes, {super.key});
  final Set<ProgressionPart> available;
  final Map<int, TreeNode> nodes;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProgressionComparisonBloc, ProgressionComparisonState>(
        builder: (context, state) => AlertDialog(
          title: const AppText('Что применить из этапа?'),
          scrollable: true,
          content: SizedBox(
            width: 540,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (available.length > 1)
                  for (final part in available) _checkbox(context, state, part),
                _comparison(context, state),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText('Отмена'),
            ),
            FilledButton(
              onPressed: state.comparison != null
                  ? () => Navigator.pop(context, state.parts)
                  : null,
              child: const AppText('Применить этап'),
            ),
          ],
        ),
      );

  Widget _checkbox(
    BuildContext context,
    ProgressionComparisonState state,
    ProgressionPart part,
  ) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    value: state.parts.contains(part),
    title: AppText(switch (part) {
      ProgressionPart.tree => 'Уровень и дерево',
      ProgressionPart.skills => 'Умения',
      ProgressionPart.equipment => 'Экипировка',
    }),
    onChanged: (checked) {
      final next = {...state.parts};
      if (checked == true) {
        next.add(part);
      } else {
        next.remove(part);
      }
      context.read<ProgressionComparisonBloc>().add(
        ProgressionPartsSelected(next),
      );
    },
  );

  Widget _comparison(BuildContext context, ProgressionComparisonState state) {
    if (state.parts.isEmpty) return const SizedBox.shrink();
    if (state.comparison case final comparison?) {
      return _ComparisonDetails(
        comparison,
        nodes,
        key: const Key('progression-comparison'),
      );
    }
    if (state.failed) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const AppText('Не удалось сравнить этап'),
          TextButton(
            onPressed: () => context.read<ProgressionComparisonBloc>().add(
              ProgressionPartsSelected(state.parts),
            ),
            child: const AppText('Повторить'),
          ),
        ],
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          AppText('Расчёт сравнения…'),
        ],
      ),
    );
  }
}

class _ComparisonDetails extends StatelessWidget {
  const _ComparisonDetails(this.comparison, this.nodes, {super.key});
  final ProgressionComparison comparison;
  final Map<int, TreeNode> nodes;

  @override
  Widget build(BuildContext context) {
    final (:before, :after, nodes: change) = comparison;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        if (change.added.isEmpty && change.removed.isEmpty)
          const AppText('Узлы без изменений'),
        if (change.added.isNotEmpty)
          _nodeList(
            context,
            'Добавятся',
            Icons.add,
            colors.secondary,
            change.added,
          ),
        if (change.removed.isNotEmpty)
          _nodeList(
            context,
            'Снимутся',
            Icons.remove,
            colors.error,
            change.removed,
          ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
              children: [
                AppText('Показатель'),
                AppText('Было', textAlign: TextAlign.end),
                AppText('Стало', textAlign: TextAlign.end),
                AppText('Разница', textAlign: TextAlign.end),
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
        ),
      ],
    );
  }

  Widget _nodeList(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Set<int> ids,
  ) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    initiallyExpanded: ids.length <= 5,
    leading: Icon(icon, color: color),
    title: Text('${translateUi(context, label)} · ${ids.length}'),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final id in ids.toList()..sort())
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 4),
          child: Tooltip(
            message: '$id',
            child: AppText(nodes[id]?.name ?? '$id', game: true),
          ),
        ),
    ],
  );

  TableRow _row(
    BuildContext context,
    String label,
    dynamic before,
    dynamic after, {
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
