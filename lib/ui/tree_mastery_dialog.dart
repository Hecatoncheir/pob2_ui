import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mcp_error_message.dart';
import '../domain/build_edit_result.dart';
import '../domain/tree_geometry.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'workshop_cubit.dart';

Future<void> showTreeMastery(
  BuildContext context,
  WorkshopCubit model,
  TreeNode node,
) => sparkDialog<void>(
  context,
  BlocProvider(
    create: (_) => _MasteryCubit(model, node.id)..load(),
    child: _MasteryDialog(node),
  ),
  barrierDismissible: false,
);

typedef _MasteryState = ({
  TreeMastery? mastery,
  int? selected,
  bool saving,
  String? error,
});

class _MasteryCubit extends Cubit<_MasteryState> {
  _MasteryCubit(this.model, this.nodeId)
    : super((mastery: null, selected: null, saving: false, error: null));

  final WorkshopCubit model;
  final int nodeId;

  Future<void> load() async {
    try {
      final mastery = await model.readTreeMastery(nodeId);
      if (isClosed) return;
      emit((
        mastery: mastery,
        selected: mastery.activeEffect,
        saving: false,
        error: null,
      ));
    } catch (error) {
      if (!isClosed) {
        emit((
          mastery: null,
          selected: null,
          saving: false,
          error: mcpErrorMessage(error),
        ));
      }
    }
  }

  void select(int? id) => emit((
    mastery: state.mastery,
    selected: id,
    saving: state.saving,
    error: null,
  ));

  Future<bool> apply() =>
      _commit(() => model.selectMastery(nodeId, state.selected!));

  Future<bool> refund() => _commit(() => model.treeAction(nodeId, true));

  Future<bool> _commit(Future<BuildEditResult> Function() action) async {
    if (state.saving) return false;
    final current = state;
    emit((
      mastery: current.mastery,
      selected: current.selected,
      saving: true,
      error: null,
    ));
    final result = await action();
    if (isClosed) return false;
    emit((
      mastery: current.mastery,
      selected: current.selected,
      saving: false,
      error: result.error,
    ));
    return result.committed;
  }
}

class _MasteryDialog extends StatelessWidget {
  const _MasteryDialog(this.node);
  final TreeNode node;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<_MasteryCubit, _MasteryState>(
        builder: (context, state) {
          final editor = context.read<_MasteryCubit>();
          return PopScope(
            canPop: !state.saving,
            child: AlertDialog(
              title: AppText(node.name, game: true),
              scrollable: true,
              content: SizedBox(width: 470, child: _content(context, state)),
              actions: _actions(context, editor, state),
            ),
          );
        },
      );

  Widget _content(BuildContext context, _MasteryState state) {
    final mastery = state.mastery;
    if (mastery == null && state.error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mastery != null) _effects(context, state, mastery),
        if (state.error case final error?)
          AppText(error, style: TextStyle(color: Spark.of(context).danger)),
        if (state.saving) const LinearProgressIndicator(),
      ],
    );
  }

  Widget _effects(
    BuildContext context,
    _MasteryState state,
    TreeMastery mastery,
  ) {
    if (mastery.effects.isEmpty) {
      return const AppText('У узла нет доступных эффектов мастерства.');
    }
    return RadioGroup<int>(
      groupValue: state.selected,
      onChanged: context.read<_MasteryCubit>().select,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final effect in mastery.effects.entries)
            RadioListTile<int>(
              key: ValueKey('mastery-effect-${effect.key}'),
              value: effect.key,
              enabled: !state.saving,
              title: effect.value.isEmpty
                  ? AppText('Эффект мастерства ${effect.key}')
                  : AppText(effect.value.join('\n'), game: true),
            ),
        ],
      ),
    );
  }

  List<Widget> _actions(
    BuildContext context,
    _MasteryCubit editor,
    _MasteryState state,
  ) {
    final mastery = state.mastery;
    final canApply =
        !state.saving &&
        mastery?.effects.containsKey(state.selected) == true &&
        state.selected != mastery?.activeEffect;
    return [
      TextButton(
        onPressed: state.saving ? null : () => Navigator.pop(context),
        child: const AppText('Закрыть'),
      ),
      if (node.allocated)
        TextButton(
          onPressed: mastery == null || state.saving
              ? null
              : () => _finish(context, editor.refund()),
          child: const AppText('Вернуть очко'),
        ),
      FilledButton(
        key: const Key('mastery-apply'),
        onPressed: canApply ? () => _finish(context, editor.apply()) : null,
        child: const AppText('Применить и рассчитать'),
      ),
    ];
  }

  Future<void> _finish(BuildContext context, Future<bool> result) async {
    if (await result && context.mounted) Navigator.pop(context);
  }
}
