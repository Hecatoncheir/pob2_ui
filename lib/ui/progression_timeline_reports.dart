import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/build_report.dart';
import '../domain/progression_comparison.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/ui_translation.dart';

typedef ProgressionReportsLoader =
    Future<({BuildReport current, List<BuildReport> stages})> Function(
      List<TreeProgressionStep>,
    );

class ProgressionTimelineReports extends StatefulWidget {
  const ProgressionTimelineReports({
    super.key,
    required this.steps,
    required this.load,
    required this.source,
    required this.enabled,
    required this.builder,
  });

  final List<TreeProgressionStep> steps;
  final ProgressionReportsLoader? load;
  final BuildReport? source;
  final bool enabled;
  final Widget Function(
    Map<Object, List<ProgressionHighlight>> summaries,
    Widget? status,
  )
  builder;

  @override
  State<ProgressionTimelineReports> createState() =>
      _ProgressionTimelineReportsState();
}

class _ProgressionTimelineReportsState
    extends State<ProgressionTimelineReports> {
  Future<Map<Object, List<ProgressionHighlight>>>? _result;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(ProgressionTimelineReports oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_changed(oldWidget)) _result = null;
    if (_result == null) _refresh();
  }

  bool _changed(ProgressionTimelineReports old) =>
      old.source != widget.source ||
      !listEquals(
        old.steps.map(_snapshot).toList(),
        widget.steps.map(_snapshot).toList(),
      );

  Object _snapshot(TreeProgressionStep step) => (
    step.identity,
    step.level,
    step.allocation,
    step.skills,
    step.equipment,
    Object.hashAllUnordered(step.nodes),
  );

  void _refresh() {
    final load = widget.load;
    final steps = widget.steps;
    if (!widget.enabled || load == null || steps.length < 2) return;
    _result = load(steps).then(
      (result) => {
        for (var index = 1; index < steps.length; index++)
          steps[index].identity: progressionHighlights(
            result.stages[index - 1],
            result.stages[index],
          ),
      },
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _result,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return widget.builder(const {}, null);
      }
      if (snapshot.hasError) {
        return widget.builder(
          const {},
          TextButton.icon(
            onPressed: widget.enabled ? () => setState(_refresh) : null,
            icon: const Icon(Icons.refresh, size: 16),
            label: const AppText('Повторить расчёт этапов'),
          ),
        );
      }
      return widget.builder(snapshot.data ?? const {}, null);
    },
  );
}

class ProgressionTimelineHighlights extends StatelessWidget {
  const ProgressionTimelineHighlights(this.values, {super.key});

  final List<ProgressionHighlight> values;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 2,
    children: [for (final value in values) _highlight(context, value)],
  );

  Widget _highlight(BuildContext context, ProgressionHighlight value) {
    final (:metric, :delta) = value;
    final colors = Theme.of(context).colorScheme;
    final label = translateUi(context, statLabel(metric));
    final suffix = metric.endsWith('Resist') || metric == 'BlockChance'
        ? ' %'
        : '';
    return Text(
      '$label ${delta > 0 ? '+' : ''}${formatStat(delta, suffix: suffix)}',
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: delta > 0 ? colors.secondary : colors.error),
    );
  }
}
