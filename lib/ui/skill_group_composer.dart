import 'package:material_ui/material_ui.dart';

import '../domain/build_report.dart';
import '../domain/skill_gem.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'gem_medallion.dart';
import 'skill_gem_editor.dart';
import 'skill_group_cubit.dart';
import 'skill_group_sockets.dart';
import 'skill_support_target_picker.dart';

class SkillGroupComposer extends StatelessWidget {
  const SkillGroupComposer({
    super.key,
    required this.editor,
    required this.state,
  });
  final SkillGroupCubit editor;
  final SkillGroupState state;

  @override
  Widget build(BuildContext context) {
    final primary = state.supportTarget;
    if (primary == null) return SkillGroupSockets(editor: editor, state: state);
    return ListView(
      key: const Key('chosen-gems'),
      children: [
        SurfacePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              if (state.activeGems.length > 1) ...[
                SkillSupportTargetPicker(
                  editor,
                  state,
                  key: const Key('composer-support-target'),
                ),
                const SizedBox(height: 12),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final active = _primary(primary);
                  if (editor.supportScope == 'none') return active;
                  final supports = _supports();
                  if (constraints.maxWidth >= 620)
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: active),
                        const SizedBox(width: 20),
                        Expanded(flex: 4, child: supports),
                      ],
                    );
                  return Column(
                    children: [active, const SizedBox(height: 18), supports],
                  );
                },
              ),
              if (state.selected case final selected?
                  when selected.gem.support) ...[
                const Divider(height: 30),
                SkillGemEditor(
                  key: ValueKey(selected.key),
                  draft: selected,
                  editor: editor,
                  index: state.gems.indexOf(selected),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _primary(GemDraft primary) {
    if (editor.locksPrimary) {
      final gem = jsonRows(editor.group!['gems']).first;
      return Row(
        children: [
          GemMedallion(
            size: 70,
            id: gem['id'] as String?,
            repository: editor.repository,
            groupId: editor.groupId,
            sourceIndex: 1,
          ),
          const SizedBox(width: 12),
          Expanded(child: AppText(primary.gem.name, game: true)),
        ],
      );
    }
    final index = state.gems.indexOf(primary);
    final image = GemSocketTarget(
      editor: editor,
      index: index,
      builder: (hovered) => InkWell(
        onTap: () => editor.selectGem(primary.key),
        borderRadius: BorderRadius.circular(40),
        child: GemMedallion(
          key: ValueKey('gem-socket-${primary.key}'),
          size: 70,
          highlighted: hovered,
          enabled: primary.enabled,
          id: primary.gem.id,
          repository: editor.repository,
          level: int.tryParse(primary.level) ?? 1,
          quality: int.tryParse(primary.quality) ?? 0,
        ),
      ),
    );
    final fields = SkillGemEditor(
      key: ValueKey(primary.key),
      draft: primary,
      editor: editor,
      index: index,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [image, const SizedBox(height: 6), fields],
          );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            const SizedBox(width: 12),
            Expanded(child: fields),
          ],
        );
      },
    );
  }

  Widget _supports() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppText('Камни поддержки', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 10),
      SkillGroupSockets(editor: editor, state: state, supportsOnly: true),
      const SizedBox(height: 8),
      const AppText(
        'Перетащите камень сюда или нажмите на иконку для настройки',
        style: TextStyle(fontSize: 11),
      ),
    ],
  );
}
