import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'tree_progression_bloc.dart';

class TreeProgressionPanel extends StatelessWidget {
  const TreeProgressionPanel({
    super.key,
    required this.nodes,
    required this.level,
    required this.enabled,
    required this.onFocus,
  });

  final Map<int, TreeNode> nodes;
  final int level;
  final bool enabled;
  final ValueChanged<int> onFocus;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TreeProgressionBloc, TreeProgressionState>(
        buildWhen: (before, after) =>
            before.steps != after.steps ||
            before.selected != after.selected ||
            before.ready != after.ready ||
            before.error != after.error,
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
            tooltip: translateUi(context, 'Изменить уровень этапа'),
            onPressed: () => _editLevel(context, state.steps[index]),
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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.steps.length + 1,
      itemBuilder: (context, index) {
        if (index == state.steps.length) return _status(context, state);
        return _step(context, state, index);
      },
    );
  }

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

  Widget _step(BuildContext context, TreeProgressionState state, int index) {
    final step = state.steps[index];
    final selected = state.selected == index;
    return _ProgressionMilestone(
      level: step.level,
      first: index == 0,
      last: index == state.steps.length - 1,
      selected: selected,
      onTap: () => context.read<TreeProgressionBloc>().add(
        TreeProgressionSelected(selected ? null : step),
      ),
      changes: selected ? _changes(context, state.steps, index) : null,
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
    final selected = nodes.values.where(
      (node) => node.allocated && _canRecord(node),
    );
    final ids = selected.map((node) => node.id).toSet();
    final result = await sparkDialog<int>(
      context,
      _ProgressionLevelDialog(level),
    );
    if (result == null || !context.mounted) return;
    context.read<TreeProgressionBloc>().add(
      TreeProgressionRecorded(TreeProgressionStep(result, ids)),
    );
  }

  Future<void> _editLevel(
    BuildContext context,
    TreeProgressionStep step,
  ) async {
    final result = await sparkDialog<int>(
      context,
      _ProgressionLevelDialog(step.level, title: 'Изменить уровень этапа'),
    );
    if (result == null || !context.mounted) return;
    context.read<TreeProgressionBloc>().add(
      TreeProgressionLevelChanged(step, result),
    );
  }

  bool _canRecord(TreeNode node) =>
      node.kind != 'ClassStart' && node.kind != 'AscendClassStart';
}

class _ProgressionMilestone extends StatelessWidget {
  const _ProgressionMilestone({
    required this.level,
    required this.first,
    required this.last,
    required this.selected,
    required this.onTap,
    this.changes,
  });

  static const _axisCenter = 9.0;
  static const _rowCenter = 22.0;
  static const _inset = 28.0;

  final int level;
  final bool first, last, selected;
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
    child: Container(
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
                child: AppText(
                  'Уровень $level',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? accent : colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressionLevelDialog extends StatefulWidget {
  const _ProgressionLevelDialog(this.level, {this.title = 'Сохранить этап'});
  final int level;
  final String title;

  @override
  State<_ProgressionLevelDialog> createState() =>
      _ProgressionLevelDialogState();
}

class _ProgressionLevelDialogState extends State<_ProgressionLevelDialog> {
  late final controller = TextEditingController(
    text: '${widget.level.clamp(1, 100)}',
  );
  final form = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: AppText(widget.title),
    content: Form(
      key: form,
      child: TextFormField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(label: AppText('Уровень')),
        validator: _validateLevel,
        onFieldSubmitted: (_) => _submit(),
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
    Navigator.pop(context, int.parse(controller.text));
  }
}
