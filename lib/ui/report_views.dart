import 'core/dialog_close_button.dart';
import 'core/app_text.dart';

import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/build_report.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'shell_bloc.dart';
import 'workshop_cubit.dart';
import 'core/frosted_surface.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({super.key, required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellBloc shell;
  @override
  Widget build(BuildContext context) {
    final report = model.state.report!;
    return SurfacePanel(
      padding: EdgeInsets.zero,
      showBorder: false,
      child: Stack(
        children: [
          Positioned.fill(
            top: 8,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: ListView(
                key: const Key('statistics-scroll'),
                padding: const EdgeInsets.fromLTRB(18, 60, 18, 18),
                children: [
                  SkillSelectors(model: model),
                  const Divider(height: 22),
                  _PrimaryStat(report),
                  const SizedBox(height: 16),
                  BlocBuilder<ShellBloc, ShellState>(
                    bloc: shell,
                    builder: (context, state) => Wrap(
                      spacing: 12,
                      runSpacing: 18,
                      children: state.pins
                          .map(
                            (key) =>
                                SizedBox(width: 112, child: _Stat(report, key)),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (model.state.document!.stale)
                    AppText(
                      'Предыдущий расчёт',
                      style: TextStyle(
                        color: Spark.of(context).danger,
                        fontSize: 11,
                      ),
                    ),
                  WarningButton(report: report),
                  const SizedBox(height: 12),
                  ...statGroups.entries.map(
                    (group) => _StatGroup(report, group.key, group.value),
                  ),
                  const SizedBox(height: 16),
                  const DotLabel('Рассчитано в Lua PoB'),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FrostedSurface(
              key: const Key('statistics-header'),
              showShadow: false,
              backgroundOpacity: .65,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: const Border(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InspectorHeading(model: model, shell: shell),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Spark.of(context).line,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectorHeading extends StatelessWidget {
  const _InspectorHeading({required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellBloc shell;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 8, 4),
    child: Row(
      children: [
        const Expanded(
          child: AppText(
            'Показатели',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        ArtIconButton(
          'settings',
          label: 'Закрепить показатели',
          onPressed: () => _pins(context, shell),
        ),
        ArtIconButton(
          'refresh',
          label: 'Пересчитать в Lua',
          onPressed: model.state.busy ? null : model.refreshReport,
        ),
      ],
    ),
  );
  void _pins(BuildContext context, ShellBloc shell) => sparkDialog<void>(
    context,
    AlertDialog(
      title: const AppText('Важные показатели'),
      content: SizedBox(
        width: 330,
        child: SingleChildScrollView(
          child: BlocBuilder<ShellBloc, ShellState>(
            bloc: shell,
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              children: statGroups.values
                  .expand((group) => group.entries)
                  .map(
                    (entry) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: AppText(entry.value),
                      value: state.pins.contains(entry.key),
                      onChanged: (_) =>
                          shell.add(StatisticPinToggled(entry.key)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      actions: [const DialogCloseButton(label: 'Готово')],
    ),
  );
}

class SkillSelectors extends StatelessWidget {
  const SkillSelectors({super.key, required this.model});
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) => _Selector(
    model: model,
    control: 'skills',
    data: model.state.report!.skillSelector,
    label: 'Основное умение',
  );
}

class _Selector extends StatelessWidget {
  const _Selector({
    required this.model,
    required this.control,
    required this.data,
    required this.label,
  });
  final WorkshopCubit model;
  final String control;
  final JsonMap data;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      _options(),
    ],
  );

  Widget _options() {
    final entries = jsonRows(data['entries']);
    if (entries.isEmpty)
      return const AppText(
        'Умение не выбрано',
        style: TextStyle(fontWeight: FontWeight.w700),
      );
    if (entries.length == 1)
      return AppText(
        '${entries.single['label']}',
        game: true,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      );
    return DropdownButton<int>(
      key: ValueKey('main-skill-$control'),
      value: data['selected'] as int?,
      isExpanded: true,
      isDense: true,
      underline: const SizedBox(),
      icon: const SparkArt('icons/chevron', width: 14),
      items: entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry['id'] as int,
              child: AppText(
                '${entry['label']}',
                game: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: model.state.busy || data['enabled'] != true
          ? null
          : (id) => model.selectMain(control, id!),
    );
  }
}

class _PrimaryStat extends StatelessWidget {
  const _PrimaryStat(this.report);
  final BuildReport report;
  @override
  Widget build(BuildContext context) {
    final key = report.stats.containsKey('FullDPS') ? 'FullDPS' : 'TotalDPS';
    return InkWell(
      onTap: () => statDetails(context, report, key),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(statLabel(key), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          SoftSwitch(
            child: AppText(
              formatStat(report.stats[key]),
              key: ValueKey(report.stats[key]),
              style: Spark.mono.copyWith(fontSize: 34, letterSpacing: -1.5),
            ),
          ),
          AppText(
            'урон в секунду',
            style: TextStyle(color: Spark.of(context).muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.report, this.stat);
  final BuildReport report;
  final String stat;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => statDetails(context, report, stat),
    borderRadius: BorderRadius.circular(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(statLabel(stat), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        AppText(
          formatStat(report.stats[stat]),
          style: Spark.mono.copyWith(fontSize: 18),
        ),
      ],
    ),
  );
}

void statDetails(BuildContext context, BuildReport report, String key) =>
    sparkDialog<void>(
      context,
      AlertDialog(
        title: AppText(statLabel(key)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              formatStat(report.stats[key]),
              style: Spark.mono.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 16),
            const AppText('Значение из текущего отчёта Lua PoB.'),
            const SizedBox(height: 8),
            AppText(
              key,
              style: Spark.mono.copyWith(
                fontSize: 12,
                color: Spark.of(context).muted,
              ),
            ),
          ],
        ),
        actions: [const DialogCloseButton(label: 'Закрыть')],
      ),
    );

class _StatGroup extends StatelessWidget {
  const _StatGroup(this.report, this.title, this.entries);
  final BuildReport report;
  final String title;
  final Map<String, String> entries;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: ExpansionTile(
      key: PageStorageKey('stat-group-$title'),
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      visualDensity: VisualDensity.compact,
      clipBehavior: Clip.antiAlias,
      collapsedBackgroundColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHigh,
      backgroundColor: Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withValues(alpha: .06),
        Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      title: AppText(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Spark.of(context).line),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Spark.of(context).line),
      ),
      children: entries.entries
          .map(
            (entry) =>
                StatRow(report: report, stat: entry.key, label: entry.value),
          )
          .toList(),
    ),
  );
}

class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.report,
    required this.stat,
    required this.label,
  });
  final BuildReport report;
  final String stat, label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: AppText(
            label,
            style: TextStyle(color: Spark.of(context).muted, fontSize: 12),
          ),
        ),
        AppText(
          formatStat(
            report.stats[stat],
            suffix: stat.endsWith('Resist') ? ' %' : '',
          ),
          style: Spark.mono.copyWith(fontSize: 12),
        ),
      ],
    ),
  );
}

class WarningButton extends StatelessWidget {
  const WarningButton({super.key, required this.report});
  final BuildReport report;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    style: TextButton.styleFrom(
      foregroundColor: report.warnings.isEmpty
          ? Spark.of(context).green
          : Spark.of(context).danger,
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
    ),
    onPressed: () => showWarnings(context, report),
    icon: SparkArt(
      'icons/${report.warnings.isEmpty ? 'check' : 'info'}',
      width: 16,
      color: report.warnings.isEmpty
          ? Spark.of(context).green
          : Spark.of(context).danger,
    ),
    label: AppText(
      'Предупреждения · ${report.warnings.length}',
      style: const TextStyle(fontSize: 11),
    ),
  );
}

void showWarnings(BuildContext context, BuildReport report) =>
    sparkDialog<void>(
      context,
      AlertDialog(
        title: const AppText('Предупреждения Lua'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: report.warnings.isEmpty
                  ? [
                      const AppText(
                        'Lua не вернул предупреждений для этого расчёта.',
                      ),
                    ]
                  : report.warnings
                        .map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: AppText(line),
                          ),
                        )
                        .toList(),
            ),
          ),
        ),
        actions: [const DialogCloseButton(label: 'Закрыть')],
      ),
    );

class CalculationsView extends StatelessWidget {
  const CalculationsView({
    super.key,
    required this.report,
    required this.model,
  });
  final BuildReport report;
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SectionHeading(
          'Расчёты',
          subtitle: 'Показатели текущего состояния сборки',
        ),
        if (report.skillPartSelector.isNotEmpty)
          _skillOption('parts', 'Часть умения', report.skillPartSelector),
        if (report.skillStatSetSelector.isNotEmpty)
          _skillOption(
            'statSets',
            'Вариант умения',
            report.skillStatSetSelector,
          ),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: statGroups.entries
              .map(
                (group) => SizedBox(
                  width: constraints.maxWidth < 360
                      ? constraints.maxWidth - 44
                      : 300,
                  child: _CalculationGroup(
                    report: report,
                    title: group.key,
                    entries: group.value,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        WarningButton(report: report),
        ExpansionTile(
          title: const AppText('Все показатели Lua'),
          children: report.stats.entries
              .map(
                (entry) => ListTile(
                  dense: true,
                  title: AppText(
                    entry.key,
                    style: Spark.mono.copyWith(fontSize: 11),
                  ),
                  trailing: AppText(
                    '${entry.value}',
                    style: Spark.mono.copyWith(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        ExpansionTile(
          title: const AppText('Исходный отчёт'),
          children: [
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(report.raw),
              style: Spark.mono.copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _skillOption(String control, String label, JsonMap data) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 300,
        child: _Selector(
          model: model,
          control: control,
          data: data,
          label: label,
        ),
      ),
    ),
  );
}

class _CalculationGroup extends StatelessWidget {
  const _CalculationGroup({
    required this.report,
    required this.title,
    required this.entries,
  });
  final BuildReport report;
  final String title;
  final Map<String, String> entries;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        ...entries.entries.map(
          (entry) =>
              StatRow(report: report, stat: entry.key, label: entry.value),
        ),
      ],
    ),
  );
}
