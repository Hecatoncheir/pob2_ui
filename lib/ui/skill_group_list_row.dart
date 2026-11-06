import 'package:flutter/material.dart';

import '../data/game_catalog_repository.dart';
import '../domain/build_report.dart';
import '../domain/skill_gem.dart';
import 'core/app_text.dart';
import 'core/spark_theme.dart';
import 'gem_drag.dart';
import 'gem_medallion.dart';

class SkillGroupListRow extends StatelessWidget {
  const SkillGroupListRow({
    super.key,
    required this.group,
    required this.repository,
    required this.selected,
    required this.main,
    required this.busy,
    required this.select,
    required this.edit,
    required this.chooseMain,
    required this.add,
    required this.remove,
  });
  final JsonMap group;
  final GameCatalogRepository repository;
  final bool selected, main, busy;
  final VoidCallback select, edit, chooseMain, remove;
  final void Function(GemDrag data) add;

  @override
  Widget build(BuildContext context) => DragTarget<GemDrag>(
    key: ValueKey('skill-group-drop-${group['id']}'),
    onWillAcceptWithDetails: (details) =>
        !busy && details.data.gem.support && details.data.groupId == null,
    onAcceptWithDetails: (details) => add(details.data),
    builder: (context, candidates, _) => Material(
      color: candidates.isEmpty
          ? Spark.of(context).surface
          : Theme.of(context).colorScheme.primary.withValues(alpha: .12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected || candidates.isNotEmpty
              ? Theme.of(context).colorScheme.primary
              : Spark.of(context).line,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : select,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 14,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _ordered()
                      .map((gem) => _gem(context, gem))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _header() => Row(
    children: [
      Tooltip(
        message: 'Основное умение',
        child: Checkbox(
          key: ValueKey('main-skill-group-${group['id']}'),
          value: main,
          onChanged: busy
              ? null
              : (value) {
                  if (value == true) chooseMain();
                },
        ),
      ),
      Expanded(
        child: InkWell(
          onTap: busy ? null : edit,
          child: AppText(
            '${group['label']}',
            game: true,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      IconButton(
        tooltip: 'Редактировать группу',
        onPressed: busy ? null : edit,
        icon: const Icon(Icons.tune, size: 18),
      ),
      IconButton(
        key: ValueKey('delete-skill-group-${group['id']}'),
        tooltip: 'Удалить умение',
        onPressed: busy ? null : remove,
        icon: const Icon(Icons.delete_outline, size: 18),
      ),
    ],
  );

  List<JsonMap> _ordered() {
    final gems = jsonRows(group['gems']);
    return [
      ...gems.where((gem) => gem['support'] != true),
      ...gems.where((gem) => gem['support'] == true),
    ];
  }

  Widget _gem(BuildContext context, JsonMap gem) {
    final body = SizedBox(
      width: 98,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: busy ? null : edit,
            borderRadius: BorderRadius.circular(40),
            child: GemMedallion(
              size: gem['support'] == true ? 52 : 68,
              enabled: gem['enabled'] != false,
              id: gem['id'] as String?,
              repository: repository,
            ),
          ),
          const SizedBox(height: 7),
          AppText(
            '${gem['name']}',
            game: true,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          AppText(
            'Уровень ${gem['level']} · качество ${gem['quality']} %',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Spark.of(context).muted),
          ),
          if (gem['error'] case final String error when error.isNotEmpty)
            AppText(
              error,
              style: TextStyle(fontSize: 10, color: Spark.of(context).danger),
            ),
        ],
      ),
    );
    if (gem['support'] != true || gem['id'] is! String) return body;
    return DraggableGem(
      key: ValueKey('group-gem-${group['id']}-${gem['sourceIndex']}'),
      data: (
        gem: SkillGem.fromJson(gem),
        draftKey: null,
        groupId: group['id'] as int,
        sourceIndex: gem['sourceIndex'] as int?,
      ),
      saving: busy,
      repository: repository,
      child: body,
    );
  }
}
