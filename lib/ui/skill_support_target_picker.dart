import 'package:material_ui/material_ui.dart';

import 'core/app_text.dart';
import 'skill_group_cubit.dart';

class SkillSupportTargetPicker extends StatelessWidget {
  const SkillSupportTargetPicker(this.editor, this.state, {super.key});

  final SkillGroupCubit editor;
  final SkillGroupState state;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: const InputDecoration(
      label: AppText('Умение для подбора поддержек'),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: state.supportTarget?.key,
        isExpanded: true,
        isDense: true,
        items: [
          for (final (index, draft) in state.activeGems.indexed)
            DropdownMenuItem(
              key: ValueKey('support-target-${draft.key}'),
              value: draft.key,
              child: _label(draft.gem.name, index),
            ),
        ],
        onChanged: state.saving
            ? null
            : (key) => editor.selectSupportTarget(key!),
      ),
    ),
  );

  Widget _label(String name, int index) {
    final title = AppText(
      name,
      game: true,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (state.activeGems.where((draft) => draft.gem.name == name).length == 1) {
      return title;
    }
    return Row(
      children: [
        Text('${index + 1} · '),
        Expanded(child: title),
      ],
    );
  }
}
