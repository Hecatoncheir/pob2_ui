import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/tree_geometry.dart';
import '../domain/tree_path_comparison.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'tree_canvas.dart';
import 'tree_path_cubit.dart';

class TreePathPanel extends StatelessWidget {
  const TreePathPanel({super.key, required this.cubit, required this.nodes});
  final TreePathCubit cubit;
  final Map<int, TreeNode> nodes;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TreePathCubit, TreePathState>(
        bloc: cubit,
        builder: (context, state) => SurfacePanel(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: _content(context, state),
          ),
        ),
      );

  Widget _content(BuildContext context, TreePathState state) {
    final comparison = state.comparison;
    final current =
        comparison != null && cubit.model.isTreePathCurrent(comparison);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppText('Сравнение путей'),
        if (state.second == null)
          const AppText('Выберите два целевых узла на дереве.'),
        if (state.busy) const LinearProgressIndicator(),
        if (state.error case final error?) AppText(error),
        if (comparison != null && !current && state.error != staleTreePaths)
          const AppText(staleTreePaths),
        _actions(state),
        const SizedBox(height: 8),
        _paths(context, state, current),
      ],
    );
  }

  Widget _paths(BuildContext context, TreePathState state, bool current) {
    final reports = state.comparison?.reports;
    final enabled = current && !state.busy && cubit.model.canCompareTreePaths;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 390;
        final width = stacked
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            SizedBox(
              width: width,
              child: _PathDetails(
                id: state.first,
                node: nodes[state.first],
                first: true,
                option: reports?.first,
                baseline: reports?.baseline,
                apply: enabled ? () => cubit.apply(first: true) : null,
              ),
            ),
            SizedBox(
              width: width,
              child: _PathDetails(
                id: state.second,
                node: nodes[state.second],
                first: false,
                option: reports?.second,
                baseline: reports?.baseline,
                apply: enabled ? () => cubit.apply(first: false) : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _actions(TreePathState state) => Wrap(
    spacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      if (state.second != null)
        OutlinedButton(
          key: const Key('calculate-tree-paths'),
          onPressed: state.busy || !cubit.model.canCompareTreePaths
              ? null
              : cubit.calculate,
          child: const AppText('Рассчитать пути'),
        ),
      if (state.first != null)
        TextButton(
          onPressed: state.busy ? null : cubit.reset,
          child: const AppText('Очистить выбор'),
        ),
    ],
  );
}

class _PathDetails extends StatelessWidget {
  const _PathDetails({
    required this.id,
    required this.node,
    required this.first,
    required this.option,
    required this.baseline,
    required this.apply,
  });

  final int? id;
  final TreeNode? node;
  final bool first;
  final TreePathOption? option;
  final TreePathStats? baseline;
  final VoidCallback? apply;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: first ? firstTreePathColor : secondTreePathColor,
          ),
          const SizedBox(width: 6),
          AppText(first ? 'Путь A' : 'Путь B'),
          if (node case final node?) ...[
            const SizedBox(width: 6),
            Expanded(
              child: AppText(
                node.name,
                game: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else if (id case final id?)
            Text('  #$id'),
        ],
      ),
      if ((option, baseline) case (final path?, final before?))
        _metrics(context, path, before),
    ],
  );

  Widget _metrics(
    BuildContext context,
    TreePathOption path,
    TreePathStats before,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = NumberFormat('0.######', locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Очки пути · ${path.points}'),
        _stat('DPS', path.stats.dps, before.dps, format),
        _stat('Здоровье', path.stats.life, before.life, format),
        TextButton(
          key: ValueKey(first ? 'apply-tree-path-a' : 'apply-tree-path-b'),
          onPressed: apply,
          child: AppText(first ? 'Применить путь A' : 'Применить путь B'),
        ),
      ],
    );
  }

  Widget _stat(String label, num? value, num? baseline, NumberFormat format) {
    final delta = value == null || baseline == null ? null : value - baseline;
    final current = value == null ? '—' : format.format(value);
    final change = delta == null
        ? ''
        : ' (${delta > 0 ? '+' : ''}${format.format(delta)})';
    return Wrap(
      spacing: 6,
      children: [AppText(label), Text('$current$change')],
    );
  }
}
