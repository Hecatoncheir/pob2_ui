import 'package:flutter/material.dart';

import '../data/game_catalog_repository.dart';

import '../domain/build_report.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'report_views.dart';
import 'skill_group_dialog.dart';
import 'gem_medallion.dart';
import 'workshop_cubit.dart';

class SkillsView extends StatelessWidget {
  const SkillsView({super.key, required this.model});
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) {
    final report = model.state.report!;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        SectionHeading(
          'Умения',
          subtitle: 'Группы камней из вашей сборки',
          action: FilledButton.icon(
            key: const Key('add-skill-group'),
            onPressed: model.state.busy || !model.engine.connected
                ? null
                : () => showSkillGroupEditor(context, model),
            icon: const Icon(Icons.add, size: 18),
            label: const AppText('Новая группа'),
          ),
        ),
        if (report.groups.isEmpty)
          const EmptyPanel(
            title: 'Умения ещё не добавлены',
            message: 'Добавьте группу камней, чтобы получить расчёт умения.',
            art: 'gem',
          ),
        if (report.groups.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SkillSelectors(model: model),
          ),
        const SizedBox(height: 22),
        ...report.groups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SkillGroup(group, model.catalogs),
          ),
        ),
      ],
    );
  }
}

class _SkillGroup extends StatelessWidget {
  const _SkillGroup(this.group, this.repository);
  final JsonMap group;
  final GameCatalogRepository repository;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SparkArt('icons/gem', width: 21),
            const SizedBox(width: 10),
            Expanded(
              child: AppText(
                '${group['label']}',
                game: true,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (group['enabled'] != true)
              AppText(
                'Отключена',
                style: TextStyle(color: Spark.of(context).muted),
              ),
          ],
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: jsonRows(group['gems'])
                .map((gem) => _GemRow(gem, repository))
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class _GemRow extends StatelessWidget {
  const _GemRow(this.gem, this.repository);
  final JsonMap gem;
  final GameCatalogRepository repository;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 122,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GemMedallion(
            size: gem['support'] == true ? 54 : 70,
            enabled: gem['enabled'] != false,
            id: gem['id'] as String?,
            repository: repository,
          ),
          const SizedBox(height: 10),
          AppText(
            '${gem['name']}',
            game: true,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          AppText(
            'Уровень ${gem['level']} · качество ${gem['quality']} %',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (gem['enabled'] == false)
            AppText(
              'Отключён',
              style: TextStyle(color: Spark.of(context).muted, fontSize: 12),
            ),
          if (gem['error'] case final String error when error.isNotEmpty)
            AppText(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Spark.of(context).danger, fontSize: 12),
            ),
        ],
      ),
    ),
  );
}
