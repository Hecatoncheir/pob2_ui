import 'package:flutter/material.dart';

import 'core/app_text.dart';
import 'core/spark_theme.dart';
import 'gem_drag.dart';
import 'gem_medallion.dart';
import 'skill_group_cubit.dart';

class SkillGroupSockets extends StatelessWidget {
  const SkillGroupSockets({
    super.key,
    required this.editor,
    required this.state,
    this.supportsOnly = false,
  });
  final SkillGroupCubit editor;
  final SkillGroupState state;
  final bool supportsOnly;

  @override
  Widget build(BuildContext context) {
    if (state.gems.isEmpty) {
      return _target(
        0,
        (hovered) => Container(
          key: const Key('empty-gem-socket'),
          height: 150,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hovered
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .1)
                : null,
            border: Border.all(color: Spark.of(context).line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GemMedallion(empty: true, highlighted: hovered),
              const SizedBox(height: 12),
              const AppText('Выберите камень умения'),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      key: const Key('gem-socket-strip'),
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (
            var index = supportsOnly ? 1 : 0;
            index < state.gems.length;
            index++
          )
            _socket(index),
          _target(
            state.gems.length,
            (hovered) => Padding(
              key: const Key('append-gem-socket'),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GemMedallion(empty: true, highlighted: hovered),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socket(int index) {
    final draft = state.gems[index];
    return _target(
      index,
      (hovered) => DraggableGem(
        data: (
          gem: draft.gem,
          draftKey: draft.key,
          groupId: editor.groupId,
          sourceIndex: draft.sourceIndex,
        ),
        saving: state.saving || !draft.gem.support,
        repository: editor.repository,
        child: SizedBox(
          key: ValueKey('gem-socket-${draft.key}'),
          width: 88,
          child: Column(
            children: [
              InkWell(
                onTap: () => editor.selectGem(draft.key),
                borderRadius: BorderRadius.circular(40),
                child: GemMedallion(
                  size: index == 0 ? 70 : 54,
                  highlighted: hovered || state.selectedKey == draft.key,
                  enabled: draft.enabled,
                  id: draft.gem.id,
                  repository: editor.repository,
                ),
              ),
              const SizedBox(height: 7),
              AppText(
                draft.gem.name,
                game: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _target(int index, Widget Function(bool hovered) child) =>
      GemSocketTarget(editor: editor, index: index, builder: child);
}

class GemSocketTarget extends StatelessWidget {
  const GemSocketTarget({
    super.key,
    required this.editor,
    required this.index,
    required this.builder,
  });
  final SkillGroupCubit editor;
  final int index;
  final Widget Function(bool hovered) builder;
  @override
  Widget build(BuildContext context) => DragTarget<GemDrag>(
    onWillAcceptWithDetails: (details) =>
        editor.accepts(details.data.gem, index),
    onAcceptWithDetails: (details) {
      final data = details.data;
      if (data.draftKey case final int key) {
        editor.move(key, index);
      } else {
        editor.insert(data.gem, index);
      }
    },
    builder: (_, candidates, _) => builder(candidates.isNotEmpty),
  );
}
