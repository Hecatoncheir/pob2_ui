import 'package:flutter/material.dart';

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
  bool get removable => index != 0 || editor.state.gems.length == 1;
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
            tooltip: removable
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

  Widget _reorder() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      IconButton(
        tooltip: 'Сдвинуть влево',
        onPressed: saving || index <= 1
            ? null
            : () => editor.move(draft.key, index - 1),
        icon: const Icon(Icons.chevron_left, size: 18),
      ),
      IconButton(
        tooltip: 'Сдвинуть вправо',
        onPressed: saving || index == editor.state.gems.length - 1
            ? null
            : () => editor.move(draft.key, index + 1),
        icon: const Icon(Icons.chevron_right, size: 18),
      ),
    ],
  );
}
