import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/trade_search_repository.dart';
import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'progression_comparison_bloc.dart';
import 'report_views.dart';
import 'shell_bloc.dart';
import 'tree_progression_bloc.dart';
import 'tree_progression_panel.dart';
import 'trade_search_dialog.dart';
import 'workshop_cubit.dart';

class WorkspaceInspector extends StatelessWidget {
  const WorkspaceInspector({
    super.key,
    required this.model,
    required this.shell,
    this.inDialog = false,
  });

  final WorkshopCubit model;
  final ShellBloc shell;
  final bool inDialog;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<ShellBloc, ShellState, WorkshopTab>(
        bloc: shell,
        selector: (state) => state.tab,
        builder: (context, tab) {
          final plan = context.read<TreeProgressionBloc?>();
          final tree = model.state.document?.tree;
          final key = model.progressionKey;
          final statistics = StatisticsPanel(model: model, shell: shell);
          if (tab != WorkshopTab.tree ||
              tree == null ||
              plan == null ||
              plan.isClosed) {
            return statistics;
          }
          return BlocSelector<TreeProgressionBloc, TreeProgressionState, bool>(
            bloc: plan,
            selector: (state) => state.view.visible,
            builder: (context, visible) => SurfacePanel(
              padding: EdgeInsets.zero,
              showBorder: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _switcher(plan, visible),
                  Expanded(
                    child: IndexedStack(
                      index: visible ? 1 : 0,
                      sizing: StackFit.expand,
                      children: [statistics, _plan(context, plan, tree, key)],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _switcher(TreeProgressionBloc plan, bool visible) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
    child: SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: false,
          label: AppText('Параметры', key: Key('inspector-parameters')),
        ),
        ButtonSegment(
          value: true,
          label: AppText('План', key: Key('inspector-plan')),
        ),
      ],
      selected: {visible},
      onSelectionChanged: (selection) =>
          plan.add(TreeProgressionVisibilityChanged(selection.single)),
    ),
  );

  Widget _plan(
    BuildContext context,
    TreeProgressionBloc plan,
    TreeGeometry tree,
    TreeProgressionKey? key,
  ) {
    final document = model.state.document!;
    return TreeProgressionPanel(
      nodes: {for (final node in tree.nodes) node.id: node},
      enabled: key != null && !model.state.busy && !document.stale,
      report: document.report,
      onCapture: () async => key == null ? null : model.captureProgression(key),
      createComparison: (step, {baseline}) =>
          _comparison(key!, step, baseline: baseline),
      createRemaining: (step) => _comparison(key!, step, allParts: true),
      loadReports: key == null
          ? null
          : (steps) async {
              final session = model.progressionComparison(key);
              try {
                return await session.reports(steps);
              } finally {
                await session.close();
              }
            },
      findPath: model.progressionPath,
      onPath: (id, path) => _focus(context, plan, id, path: path),
      search: TradeSearchRepository(model.engine).available
          ? (context, slot, base) =>
                showProgressionTrade(context, model, slot, base)
          : null,
      onApply: (step, parts) async {
        if (key != null) await model.applyProgression(key, step, parts: parts);
      },
      onFocus: (id) => _focus(context, plan, id),
    );
  }

  void _focus(
    BuildContext context,
    TreeProgressionBloc plan,
    int id, {
    List<int> path = const [],
  }) {
    plan.add(TreeProgressionFocusRequested(id, path: path));
    if (inDialog) Navigator.pop(context);
  }

  ProgressionComparisonBloc _comparison(
    TreeProgressionKey key,
    TreeProgressionStep step, {
    TreeProgressionStep? baseline,
    bool allParts = false,
  }) {
    final session = model.progressionComparison(key);
    return ProgressionComparisonBloc(
      (parts) => session.compare(step, parts, baseline: baseline),
      session.close,
      initial: allParts || baseline != null
          ? step.parts
          : const {ProgressionPart.tree},
      describeGem: session.describeGem,
      describeItem: session.describeItem,
    );
  }
}
