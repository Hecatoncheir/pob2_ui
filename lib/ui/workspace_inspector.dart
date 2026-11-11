import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'progression_comparison_bloc.dart';
import 'report_views.dart';
import 'shell_bloc.dart';
import 'tree_progression_bloc.dart';
import 'tree_progression_panel.dart';
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
      onCapture: () async => key == null ? null : model.captureProgression(key),
      createComparison: (step) {
        final session = model.progressionComparison(key!);
        return ProgressionComparisonBloc(
          (parts) => session.compare(step, parts),
          session.close,
        );
      },
      onApply: (step, parts) async {
        if (key != null) await model.applyProgression(key, step, parts: parts);
      },
      onFocus: (id) {
        plan.add(TreeProgressionFocusRequested(id));
        if (inDialog) Navigator.pop(context);
      },
    );
  }
}
