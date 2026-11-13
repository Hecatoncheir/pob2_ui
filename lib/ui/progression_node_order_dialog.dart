import 'package:material_ui/material_ui.dart';

import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/ui_translation.dart';

class ProgressionNodeOrderDialog extends StatefulWidget {
  const ProgressionNodeOrderDialog(this.step, this.nodes, {super.key});

  final TreeProgressionStep step;
  final Map<int, TreeNode> nodes;

  @override
  State<ProgressionNodeOrderDialog> createState() =>
      _ProgressionNodeOrderDialogState();
}

class _ProgressionNodeOrderDialogState
    extends State<ProgressionNodeOrderDialog> {
  late final _order = [...widget.step.keyNodes];
  int _revision = 0;

  String _name(int id) => widget.nodes[id]?.name ?? '#$id';

  void _add(int? id) {
    if (id == null || _order.contains(id)) return;
    setState(() {
      _order.add(id);
      _revision++;
    });
  }

  void _move(int from, int to) =>
      setState(() => _order.insert(to, _order.removeAt(from)));

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const AppText('Порядок ключевых узлов'),
    content: SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _picker(context),
          for (var index = 0; index < _order.length; index++)
            _entry(context, index),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const AppText('Отмена'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, List<int>.of(_order)),
        child: const AppText('Сохранить'),
      ),
    ],
  );

  Widget _picker(BuildContext context) {
    final options = widget.step.nodes.where((id) => !_order.contains(id));
    if (options.isEmpty) return const SizedBox.shrink();
    return DropdownMenu<int>(
      key: ValueKey(_revision),
      expandedInsets: EdgeInsets.zero,
      menuHeight: 260,
      enableFilter: true,
      requestFocusOnTap: true,
      label: const AppText('Добавить ключевой узел'),
      onSelected: _add,
      dropdownMenuEntries: [
        for (final id in options)
          DropdownMenuEntry(
            value: id,
            label: '${translateGame(context, _name(id))} · #$id',
          ),
      ],
    );
  }

  Widget _entry(BuildContext context, int index) {
    final id = _order[index];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text('${index + 1}'),
      title: AppText(_name(id), game: true),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: translateUi(context, 'Выше'),
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: index > 0 ? () => _move(index, index - 1) : null,
          ),
          IconButton(
            tooltip: translateUi(context, 'Ниже'),
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: index + 1 < _order.length
                ? () => _move(index, index + 1)
                : null,
          ),
          IconButton(
            tooltip: translateUi(context, 'Удалить'),
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _order.removeAt(index)),
          ),
        ],
      ),
    );
  }
}
