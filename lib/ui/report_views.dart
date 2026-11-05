import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/build_report.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'shell_cubit.dart';
import 'workshop_cubit.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({super.key, required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellCubit shell;
  @override
  Widget build(BuildContext context) {
    final report = model.state.report!;
    return SurfacePanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _InspectorHeading(model: model, shell: shell),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              children: [
                SkillSelectors(model: model),
                const Divider(height: 22),
                _PrimaryStat(report),
                const SizedBox(height: 16),
                BlocBuilder<ShellCubit, ShellState>(
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
                  const Text(
                    'Предыдущий расчёт',
                    style: TextStyle(color: Spark.danger, fontSize: 11),
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
        ],
      ),
    );
  }
}

class _InspectorHeading extends StatelessWidget {
  const _InspectorHeading({required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellCubit shell;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 8, 4),
    child: Row(
      children: [
        const Expanded(
          child: Text(
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
  void _pins(BuildContext context, ShellCubit shell) => sparkDialog<void>(
    context,
    AlertDialog(
      title: const Text('Важные показатели'),
      content: SizedBox(
        width: 330,
        child: SingleChildScrollView(
          child: BlocBuilder<ShellCubit, ShellState>(
            bloc: shell,
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              children: statGroups.values
                  .expand((group) => group.entries)
                  .map(
                    (entry) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value),
                      value: state.pins.contains(entry.key),
                      onChanged: (_) => shell.pin(entry.key),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Готово'),
        ),
      ],
    ),
  );
}

class SkillSelectors extends StatelessWidget {
  const SkillSelectors({super.key, required this.model});
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Основное умение', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      _Selector(
        model: model,
        control: 'groups',
        data: model.state.report!.groupSelector,
      ),
      _Selector(
        model: model,
        control: 'skills',
        data: model.state.report!.skillSelector,
      ),
    ],
  );
}

class _Selector extends StatelessWidget {
  const _Selector({
    required this.model,
    required this.control,
    required this.data,
  });
  final WorkshopCubit model;
  final String control;
  final JsonMap data;
  @override
  Widget build(BuildContext context) {
    final entries = jsonRows(data['entries']);
    if (entries.isEmpty)
      return const Text(
        'Умение не выбрано',
        style: TextStyle(fontWeight: FontWeight.w700),
      );
    return DropdownButton<int>(
      value: data['selected'] as int?,
      isExpanded: true,
      isDense: true,
      underline: const SizedBox(),
      icon: const SparkArt('icons/chevron', width: 14),
      items: entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry['id'] as int,
              child: Text(
                '${entry['label']}',
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
          Text(statLabel(key), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          SoftSwitch(
            child: Text(
              formatStat(report.stats[key]),
              key: ValueKey(report.stats[key]),
              style: Spark.mono.copyWith(fontSize: 34, letterSpacing: -1.5),
            ),
          ),
          const Text(
            'урон в секунду',
            style: TextStyle(color: Spark.muted, fontSize: 10),
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
        Text(statLabel(stat), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
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
        title: Text(statLabel(key)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatStat(report.stats[key]),
              style: Spark.mono.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 16),
            const Text('Значение из текущего отчёта Lua PoB.'),
            const SizedBox(height: 8),
            Text(
              key,
              style: Spark.mono.copyWith(fontSize: 12, color: Spark.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );

class _StatGroup extends StatelessWidget {
  const _StatGroup(this.report, this.title, this.entries);
  final BuildReport report;
  final String title;
  final Map<String, String> entries;
  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: 12),
    visualDensity: VisualDensity.compact,
    title: Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
    shape: const Border(),
    collapsedShape: const Border(),
    children: entries.entries
        .map(
          (entry) =>
              StatRow(report: report, stat: entry.key, label: entry.value),
        )
        .toList(),
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
          child: Text(
            label,
            style: const TextStyle(color: Spark.muted, fontSize: 12),
          ),
        ),
        Text(
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
      foregroundColor: report.warnings.isEmpty ? Spark.green : Spark.danger,
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
    ),
    onPressed: () => showWarnings(context, report),
    icon: SparkArt(
      'icons/${report.warnings.isEmpty ? 'check' : 'info'}',
      width: 16,
      color: report.warnings.isEmpty ? Spark.green : Spark.danger,
    ),
    label: Text(
      'Предупреждения · ${report.warnings.length}',
      style: const TextStyle(fontSize: 11),
    ),
  );
}

void showWarnings(
  BuildContext context,
  BuildReport report,
) => sparkDialog<void>(
  context,
  AlertDialog(
    title: const Text('Предупреждения Lua'),
    content: SizedBox(
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: report.warnings.isEmpty
              ? [const Text('Lua не вернул предупреждений для этого расчёта.')]
              : report.warnings
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(line),
                      ),
                    )
                    .toList(),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Закрыть'),
      ),
    ],
  ),
);

class CalculationsView extends StatelessWidget {
  const CalculationsView({super.key, required this.report});
  final BuildReport report;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SectionHeading(
          'Расчёты',
          subtitle: 'Показатели текущего состояния сборки',
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
          title: const Text('Все показатели Lua'),
          children: report.stats.entries
              .map(
                (entry) => ListTile(
                  dense: true,
                  title: Text(
                    entry.key,
                    style: Spark.mono.copyWith(fontSize: 11),
                  ),
                  trailing: Text(
                    '${entry.value}',
                    style: Spark.mono.copyWith(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        ExpansionTile(
          title: const Text('Исходный отчёт'),
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
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        ...entries.entries.map(
          (entry) =>
              StatRow(report: report, stat: entry.key, label: entry.value),
        ),
      ],
    ),
  );
}
