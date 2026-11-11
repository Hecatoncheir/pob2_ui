import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'progression_apply_dialog.dart';
import 'progression_comparison_bloc.dart';
import 'progression_plan_actions.dart';
import 'tree_progression_bloc.dart';

class TreeProgressionPanel extends StatelessWidget {
  const TreeProgressionPanel({
    super.key,
    required this.nodes,
    required this.enabled,
    required this.onFocus,
    required this.onCapture,
    required this.onApply,
    required this.createComparison,
  });

  final Map<int, TreeNode> nodes;
  final bool enabled;
  final ValueChanged<int> onFocus;
  final Future<TreeProgressionStep?> Function() onCapture;
  final Future<void> Function(TreeProgressionStep, Set<ProgressionPart>)
  onApply;
  final ProgressionComparisonBloc Function(
    TreeProgressionStep, {
    TreeProgressionStep? baseline,
  })
  createComparison;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TreeProgressionBloc, TreeProgressionState>(
        buildWhen: (before, after) =>
            before.steps != after.steps ||
            before.selected != after.selected ||
            before.ready != after.ready ||
            before.error != after.error ||
            before.view.following != after.view.following,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, state),
            Expanded(child: _timeline(context, state)),
          ],
        ),
      );

  Widget _header(BuildContext context, TreeProgressionState state) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 6, 0),
    child: Row(
      children: [
        const Expanded(
          child: AppText(
            'План прокачки',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        if (state.selected case final index?) ...[
          IconButton(
            tooltip: translateUi(context, 'Изменить этап'),
            onPressed: () => _edit(context, state.steps[index]),
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          IconButton(
            tooltip: translateUi(context, 'Удалить этап'),
            onPressed: () => context.read<TreeProgressionBloc>().add(
              TreeProgressionRemoved(state.steps[index]),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
        IconButton(
          tooltip: translateUi(context, 'Сохранить этап'),
          onPressed: state.ready && enabled ? () => _record(context) : null,
          icon: const Icon(Icons.add, size: 20),
        ),
      ],
    ),
  );

  Widget _timeline(BuildContext context, TreeProgressionState state) {
    final next = state.steps.where((step) => !step.completed).firstOrNull;
    final nextKey = GlobalKey();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.steps.isNotEmpty) _following(context, state, next, nextKey),
          for (var index = 0; index < state.steps.length; index++)
            _step(
              context,
              state,
              index,
              identical(state.steps[index], next) ? nextKey : null,
            ),
          _status(context, state),
        ],
      ),
    );
  }

  Widget _following(
    BuildContext context,
    TreeProgressionState state,
    TreeProgressionStep? next,
    GlobalKey nextKey,
  ) {
    final plan = context.read<TreeProgressionBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const AppText('Режим прохождения'),
          value: state.view.following,
          onChanged: (value) =>
              plan.add(TreeProgressionFollowingChanged(value)),
        ),
        if (state.view.following)
          next == null
              ? const AppText('Все этапы завершены')
              : _nextStage(plan, next, nextKey),
      ],
    );
  }

  Widget _nextStage(
    TreeProgressionBloc plan,
    TreeProgressionStep step,
    GlobalKey nextKey,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.arrow_downward, size: 18),
    title: const AppText('Следующий этап'),
    subtitle: ProgressionStageName(step),
    onTap: () {
      plan.add(TreeProgressionSelected(step));
      final target = nextKey.currentContext;
      if (target != null) Scrollable.ensureVisible(target);
    },
  );

  Widget _status(BuildContext context, TreeProgressionState state) {
    if (state.error case final error?) {
      return AppText(
        error,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    if (state.ready && state.steps.isEmpty) {
      return const AppText('Выберите узлы и сохраните первый этап.');
    }
    return const SizedBox.shrink();
  }

  Widget _step(
    BuildContext context,
    TreeProgressionState state,
    int index,
    Key? nextKey,
  ) {
    final step = state.steps[index];
    final selected = state.selected == index;
    return _ProgressionMilestone(
      key: nextKey ?? ValueKey(step.identity),
      level: step.level,
      title: step.title,
      first: index == 0,
      last: index == state.steps.length - 1,
      selected: selected,
      completed: state.view.following && step.completed,
      onTap: () => context.read<TreeProgressionBloc>().add(
        TreeProgressionSelected(selected ? null : step),
      ),
      changes: selected ? _details(context, state, index) : null,
    );
  }

  Widget _details(BuildContext context, TreeProgressionState state, int index) {
    final step = state.steps[index];
    final note = step.note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 8),
            child: Text(note, style: Theme.of(context).textTheme.bodySmall),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _stepActions(context, state.steps, step),
        ),
        if (state.view.following) _checklist(context, step),
        _changes(context, state.steps, index),
      ],
    );
  }

  Widget _stepActions(
    BuildContext context,
    List<TreeProgressionStep> steps,
    TreeProgressionStep step,
  ) => Wrap(
    spacing: 2,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      FilledButton.tonalIcon(
        key: const Key('apply-progression-stage'),
        onPressed: enabled ? () => _apply(context, step) : null,
        icon: const Icon(Icons.check, size: 18),
        label: const AppText('Применить этап'),
      ),
      IconButton(
        tooltip: translateUi(context, 'Обновить этап из сборки'),
        onPressed: enabled ? () => _update(context, step) : null,
        icon: const Icon(Icons.sync, size: 18),
      ),
      if (steps.length > 1)
        IconButton(
          tooltip: translateUi(context, 'Сравнить с другим этапом'),
          onPressed: enabled ? () => _compare(context, step, steps) : null,
          icon: const Icon(Icons.compare_arrows, size: 18),
        ),
    ],
  );

  Widget _checklist(BuildContext context, TreeProgressionStep step) {
    final plan = context.read<TreeProgressionBloc>();
    return Column(
      children: [
        for (var index = 0; index < step.tasks.length; index++)
          _task(plan, step, index),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const AppText('Этап завершён'),
          value: step.completed,
          onChanged: (done) => plan.add(
            TreeProgressionUpdated(
              step,
              (saved) => saved.withProgress(completed: done),
            ),
          ),
        ),
      ],
    );
  }

  Widget _task(TreeProgressionBloc plan, TreeProgressionStep step, int index) {
    final task = step.tasks[index];
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(task.text),
      value: task.done,
      onChanged: (done) => plan.add(
        TreeProgressionUpdated(step, (saved) {
          if (index >= saved.tasks.length ||
              saved.tasks[index].text != task.text) {
            return saved;
          }
          final tasks = [...saved.tasks];
          tasks[index] = (text: task.text, done: done == true);
          return saved.withProgress(tasks: tasks);
        }),
      ),
    );
  }

  Widget _changes(
    BuildContext context,
    List<TreeProgressionStep> steps,
    int index,
  ) {
    final (:added, :removed) = treeProgressionChange(steps, index);
    if (added.isEmpty && removed.isEmpty) {
      return const AppText('Узлы без изменений');
    }
    final colors = Theme.of(context).colorScheme;
    final plan = context.read<TreeProgressionBloc>();
    return Wrap(
      spacing: 6,
      children: [
        for (final id in added)
          _nodeChip(plan, id, Icons.add, colors.secondary),
        for (final id in removed)
          _nodeChip(plan, id, Icons.remove, colors.error),
      ],
    );
  }

  Widget _nodeChip(
    TreeProgressionBloc plan,
    int id,
    IconData icon,
    Color color,
  ) {
    final node = nodes[id];
    return MouseRegion(
      onEnter: node == null
          ? null
          : (_) => plan.add(TreeProgressionNodeHovered(id)),
      onExit: node == null
          ? null
          : (_) => plan.add(const TreeProgressionNodeHovered(null)),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: color),
        label: AppText(
          node?.name ?? '$id',
          game: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: node == null ? null : () => onFocus(id),
      ),
    );
  }

  Future<void> _record(BuildContext context) async {
    final captured = await onCapture();
    if (captured == null || !context.mounted) return;
    final result = await sparkDialog<_EditedStage>(
      context,
      _ProgressionStepDialog(captured),
    );
    if (result == null || !context.mounted) return;
    context.read<TreeProgressionBloc>().add(
      TreeProgressionRecorded(
        captured.withProgress(
          details: result.details,
          tasks: [for (final text in result.tasks) (text: text, done: false)],
        ),
      ),
    );
  }

  Future<void> _apply(BuildContext context, TreeProgressionStep step) async {
    final parts = await sparkDialog<Set<ProgressionPart>>(
      context,
      BlocProvider(
        create: (_) => createComparison(step),
        child: ProgressionApplyDialog(step.parts, nodes),
      ),
    );
    if (parts != null && context.mounted) await onApply(step, parts);
  }

  Future<void> _edit(BuildContext context, TreeProgressionStep step) async {
    final result = await sparkDialog<_EditedStage>(
      context,
      _ProgressionStepDialog(step, heading: 'Изменить этап'),
    );
    if (result == null || !context.mounted) return;
    context.read<TreeProgressionBloc>().add(
      TreeProgressionEdited(step, result.details, tasks: result.tasks),
    );
  }

  Future<void> _compare(
    BuildContext context,
    TreeProgressionStep step,
    List<TreeProgressionStep> steps,
  ) async {
    final baseline = await chooseProgressionBaseline(context, step, steps);
    if (baseline == null || !context.mounted) return;
    await sparkDialog<void>(
      context,
      BlocProvider(
        create: (_) => createComparison(step, baseline: baseline),
        child: ProgressionApplyDialog(
          step.parts,
          nodes,
          stages: (before: baseline, after: step),
        ),
      ),
    );
  }

  Future<void> _update(BuildContext context, TreeProgressionStep step) async {
    final current = await onCapture();
    if (current == null || !context.mounted) return;
    final parts = await sparkDialog<Set<ProgressionPart>>(
      context,
      UpdateProgressionPartsDialog(current.parts),
    );
    if (parts == null || !context.mounted) return;
    context.read<TreeProgressionBloc>().add(
      TreeProgressionUpdated(
        step,
        (saved) => saved.withPartsFrom(current, parts),
      ),
    );
  }
}

class _ProgressionMilestone extends StatelessWidget {
  const _ProgressionMilestone({
    super.key,
    required this.level,
    required this.title,
    required this.first,
    required this.last,
    required this.selected,
    required this.completed,
    required this.onTap,
    this.changes,
  });

  static const _axisCenter = 9.0;
  static const _rowCenter = 22.0;
  static const _inset = 28.0;

  final int level;
  final String title;
  final bool first, last, selected, completed;
  final VoidCallback onTap;
  final Widget? changes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = colors.brightness == Brightness.dark
        ? colors.primary
        : colors.secondary;
    final rail = Color.lerp(colors.outline, colors.secondary, .45)!;
    final branch = selected ? accent : rail;
    return Stack(
      children: [
        if (!first) _rail(rail, top: 0, height: _rowCenter),
        if (!last) _rail(rail, top: _rowCenter, bottom: 0),
        PositionedDirectional(
          start: _axisCenter,
          top: _rowCenter - 1,
          width: _inset - _axisCenter,
          height: 2,
          child: ColoredBox(color: branch),
        ),
        PositionedDirectional(
          start: 0,
          top: 0,
          width: _inset,
          height: _rowCenter * 2,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: onTap,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: _marker(colors, branch),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: _inset, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _label(colors, accent),
              if (changes case final details?)
                Padding(padding: const EdgeInsets.only(top: 5), child: details),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rail(
    Color color, {
    required double top,
    double? height,
    double? bottom,
  }) => PositionedDirectional(
    start: _axisCenter - 1,
    top: top,
    height: height,
    bottom: bottom,
    width: 2,
    child: ColoredBox(color: color),
  );

  Widget _marker(ColorScheme colors, Color border) => Container(
    width: _axisCenter * 2,
    height: _axisCenter * 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: colors.surface,
      border: Border.all(color: border, width: 2),
    ),
    alignment: Alignment.center,
    child: completed
        ? Icon(Icons.check, size: 13, color: colors.secondary)
        : Container(
            width: selected ? 8 : 5,
            height: selected ? 8 : 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: border),
          ),
  );

  Widget _label(ColorScheme colors, Color accent) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: selected ? accent : colors.outline),
    );
    return Semantics(
      selected: selected,
      child: Material(
        color: selected
            ? Color.alphaBlend(accent.withValues(alpha: .12), colors.surface)
            : colors.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _rowCenter * 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: _caption(colors, accent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _caption(ColorScheme colors, Color accent) {
    final heading = TextStyle(
      fontWeight: FontWeight.w700,
      color: selected ? accent : colors.onSurface,
    );
    if (title.isEmpty) return AppText('Уровень $level', style: heading);
    return Wrap(
      spacing: 8,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: heading,
        ),
        AppText(
          'Уровень $level',
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

typedef _EditedStage = ({TreeProgressionDetails details, List<String> tasks});

class _ProgressionStepDialog extends StatefulWidget {
  const _ProgressionStepDialog(this.step, {this.heading = 'Сохранить этап'});
  final TreeProgressionStep step;
  final String heading;

  @override
  State<_ProgressionStepDialog> createState() => _ProgressionStepDialogState();
}

class _ProgressionStepDialogState extends State<_ProgressionStepDialog> {
  late final level = TextEditingController(
    text: '${widget.step.level.clamp(1, 100)}',
  );
  late final title = TextEditingController(text: widget.step.title);
  late final note = TextEditingController(text: widget.step.note);
  late final tasks = TextEditingController(
    text: widget.step.tasks.map((task) => task.text).join('\n'),
  );
  final form = GlobalKey<FormState>();

  @override
  void dispose() {
    level.dispose();
    title.dispose();
    note.dispose();
    tasks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: AppText(widget.heading),
    scrollable: true,
    content: Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const Key('progression-level'),
            controller: level,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(label: AppText('Уровень')),
            validator: _validateLevel,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('progression-title'),
            controller: title,
            decoration: const InputDecoration(label: AppText('Название этапа')),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('progression-note'),
            controller: note,
            minLines: 2,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              label: AppText('Заметка к этапу'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('progression-tasks'),
            controller: tasks,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              label: AppText('Задачи этапа'),
              helper: AppText('Одна задача на строку'),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const AppText('Отмена'),
      ),
      FilledButton(onPressed: _submit, child: const AppText('Сохранить')),
    ],
  );

  String? _validateLevel(String? value) {
    final level = int.tryParse(value ?? '');
    if (level != null && level >= 1 && level <= 100) return null;
    return translateUi(context, 'Введите уровень от 1 до 100');
  }

  void _submit() {
    if (form.currentState?.validate() != true) return;
    Navigator.pop<_EditedStage>(context, (
      details: (
        level: int.parse(level.text),
        title: title.text.trim(),
        note: note.text.trim(),
      ),
      tasks: [
        ...tasks.text
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toSet(),
      ],
    ));
  }
}
