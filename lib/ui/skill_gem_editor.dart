import 'package:material_ui/material_ui.dart';

import '../domain/skill_gem.dart';
import 'core/app_text.dart';
import 'core/spark_theme.dart';
import 'skill_group_cubit.dart';

class SkillGemEditor extends StatelessWidget {
  const SkillGemEditor({
    super.key,
    required this.draft,
    required this.editor,
    required this.index,
  });
  final GemDraft draft;
  final SkillGroupCubit editor;
  final int index;

  bool get saving => editor.state.saving;
  bool get removable => editor.canRemove(draft.key);
  bool get incompatible =>
      draft.gem.support &&
      !editor.state.support.loading &&
      editor.state.support.error == null &&
      !editor.state.support.ids.contains(draft.gem.id);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: AppText(
              draft.gem.name,
              game: true,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: saving || removable
                ? 'Убрать камень'
                : 'Сначала уберите камни поддержки',
            onPressed: saving || !removable
                ? null
                : () => editor.remove(draft.key),
            icon: const Icon(Icons.close, size: 17),
          ),
        ],
      ),
      if (incompatible)
        AppText(
          'Эта поддержка не подходит выбранному умению',
          style: TextStyle(color: Spark.of(context).danger, fontSize: 12),
        ),
      _fields(),
      if (draft.gem.support) _reorder(),
    ],
  );

  Widget _fields() => Row(
    children: [
      Expanded(
        child: TextFormField(
          key: ValueKey('gem-level-${draft.key}'),
          initialValue: draft.level,
          enabled: !saving,
          onChanged: (value) => editor.change(draft.key, level: value),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(label: AppText('Уровень')),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          key: ValueKey('gem-quality-${draft.key}'),
          initialValue: draft.quality,
          enabled: !saving,
          onChanged: (value) => editor.change(draft.key, quality: value),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(label: AppText('Качество, %')),
        ),
      ),
      const SizedBox(width: 6),
      Tooltip(
        message: 'Камень включён',
        child: Switch(
          key: ValueKey('gem-enabled-${draft.key}'),
          value: draft.enabled,
          onChanged: saving
              ? null
              : (value) => editor.change(draft.key, enabled: value),
        ),
      ),
    ],
  );

  Widget _reorder() {
    final supports = editor.state.gems.indexed.where(
      (entry) => entry.$2.gem.support,
    );
    final left = supports.where((entry) => entry.$1 < index).lastOrNull;
    final right = supports.where((entry) => entry.$1 > index).firstOrNull;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _moveButton('Сдвинуть влево', Icons.chevron_left, left?.$1),
        _moveButton('Сдвинуть вправо', Icons.chevron_right, right?.$1),
      ],
    );
  }

  Widget _moveButton(String tooltip, IconData icon, int? destination) =>
      IconButton(
        tooltip: tooltip,
        onPressed:
            destination != null && editor.canMoveSupport(draft.key, destination)
            ? () => editor.move(draft.key, destination)
            : null,
        icon: Icon(icon, size: 18),
      );
}
