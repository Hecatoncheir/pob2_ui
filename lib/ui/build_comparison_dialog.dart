import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mcp_error_message.dart';
import '../domain/build_comparison.dart';
import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/library_entry.dart';
import 'comparison_stats_table.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'core/ui_translation.dart';
import 'workshop_cubit.dart';

class BuildComparisonButton extends StatelessWidget {
  const BuildComparisonButton(this.model, {super.key});
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const Key('compare-builds'),
    onPressed: model.state.busy
        ? null
        : () => sparkDialog<void>(
            context,
            BlocProvider(
              create: (_) => _BuildComparisonCubit(model),
              child: const _BuildComparisonDialog(),
            ),
            barrierDismissible: false,
          ),
    icon: const Icon(Icons.compare_arrows, size: 17),
    label: const AppText('Сравнить сборки'),
  );
}

typedef _SavedBuild = ({String title, Future<String> Function() read});
typedef _ComparisonState = ({
  List<_SavedBuild?> builds,
  BuildComparison? result,
  bool busy,
  String? error,
});

enum _Side {
  first('Первая сборка'),
  second('Вторая сборка');

  const _Side(this.label);
  final String label;
}

enum _FileChoice { xml }

class _BuildComparisonCubit extends Cubit<_ComparisonState> {
  _BuildComparisonCubit(this.model)
    : entries = model.state.library.entries,
      super((
        builds: [
          if (model.state.library.active case final active?)
            _fromLibrary(model, active)
          else
            null,
          null,
        ],
        result: null,
        busy: false,
        error: null,
      ));

  final WorkshopCubit model;
  final List<LibraryEntry> entries;

  static _SavedBuild _fromLibrary(WorkshopCubit model, LibraryEntry entry) =>
      (title: entry.title, read: () => model.library.read(entry.id));

  Future<void> pick(_Side side, Object source) => _run((start) async {
    final build = switch (source) {
      final LibraryEntry entry => _fromLibrary(model, entry),
      _ => await _openFile(),
    };
    if (build == null) return start;
    return (
      builds: List<_SavedBuild?>.unmodifiable(
        _Side.values.map(
          (item) => item == side ? build : start.builds[item.index],
        ),
      ),
      result: null,
      busy: false,
      error: null,
    );
  });

  Future<_SavedBuild?> _openFile() async {
    final file = await model.files.open();
    if (file == null) return null;
    return (title: file.title, read: () async => file.xml);
  }

  Future<void> compare() => _run((start) async {
    final [first, second] = start.builds;
    if (first == null || second == null) return start;
    return (
      builds: start.builds,
      result: await model.compareSavedBuilds(
        await first.read(),
        await second.read(),
      ),
      busy: false,
      error: null,
    );
  });

  Future<void> _run(
    Future<_ComparisonState> Function(_ComparisonState) action,
  ) async {
    final start = state;
    if (start.busy) return;
    emit((builds: start.builds, result: null, busy: true, error: null));
    try {
      final next = await action(start);
      if (!isClosed) emit(next);
    } catch (error) {
      if (!isClosed) {
        emit((
          builds: start.builds,
          result: null,
          busy: false,
          error: mcpErrorMessage(error),
        ));
      }
    }
  }
}

class _BuildComparisonDialog extends StatelessWidget {
  const _BuildComparisonDialog();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<_BuildComparisonCubit, _ComparisonState>(
        builder: (context, state) {
          final editor = context.read<_BuildComparisonCubit>();
          return PopScope(
            canPop: !state.busy,
            child: AlertDialog(
              title: const AppText('Сравнение сборок'),
              scrollable: true,
              content: SizedBox(
                width: 610,
                child: _content(context, editor, state),
              ),
              actions: _actions(context, editor, state),
            ),
          );
        },
      );

  Widget _content(
    BuildContext context,
    _BuildComparisonCubit editor,
    _ComparisonState state,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final side in _Side.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPicker(context, editor, state, side),
        ),
      const AppText(
        'Условия расчёта и настройки группы берутся из первой сборки.',
      ),
      if (state.busy)
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: LinearProgressIndicator(),
        ),
      if (state.error case final error?)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: AppText(
            error,
            style: TextStyle(color: Spark.of(context).danger),
          ),
        ),
      if (state.result case final result?) _ComparisonResult(result),
    ],
  );

  Widget _buildPicker(
    BuildContext context,
    _BuildComparisonCubit editor,
    _ComparisonState state,
    _Side side,
  ) {
    final title = state.builds[side.index]?.title;
    return PopupMenuButton<Object>(
      key: ValueKey('build-comparison-${side.name}'),
      tooltip: translateUi(context, side.label),
      enabled: !state.busy,
      onSelected: (source) => editor.pick(side, source),
      itemBuilder: (_) => [
        PopupMenuItem(
          key: ValueKey('build-comparison-file-${side.name}'),
          value: _FileChoice.xml,
          child: const AppText('Выбрать XML-файл'),
        ),
        if (editor.entries.isNotEmpty) const PopupMenuDivider(),
        for (final entry in editor.entries)
          PopupMenuItem(
            key: ValueKey('build-comparison-library-${side.name}-${entry.id}'),
            value: entry,
            child: Text(
              entry.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      child: InputDecorator(
        decoration: InputDecoration(
          label: AppText(side.label),
          enabled: !state.busy,
        ),
        child: Row(
          children: [
            Expanded(
              child: title == null
                  ? const AppText('Выберите сборку')
                  : Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(
    BuildContext context,
    _BuildComparisonCubit editor,
    _ComparisonState state,
  ) => [
    TextButton(
      onPressed: state.busy ? null : () => Navigator.of(context).pop(),
      child: const AppText('Закрыть'),
    ),
    FilledButton(
      key: const Key('build-comparison-run'),
      onPressed: state.busy || state.builds.contains(null)
          ? null
          : editor.compare,
      child: const AppText('Сравнить сборки'),
    ),
  ];
}

class _ComparisonResult extends StatelessWidget {
  const _ComparisonResult(this.comparison);
  final BuildComparison comparison;

  @override
  Widget build(BuildContext context) {
    final (:before, :after, :components) = comparison;
    return Padding(
      key: const Key('build-comparison-result'),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _conditions(before, components),
          const SizedBox(height: 12),
          const AppText('Основное умение'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _skill(_Side.first, before)),
              const SizedBox(width: 12),
              Expanded(child: _skill(_Side.second, after)),
            ],
          ),
          const SizedBox(height: 12),
          ComparisonStatsTable(
            before,
            after,
            beforeLabel: _Side.first.label,
            afterLabel: _Side.second.label,
          ),
        ],
      ),
    );
  }

  Widget _conditions(BuildReport before, Installations components) {
    final pob = components[Component.pob]!;
    final mcp = components[Component.mcp];
    final enemyLevel = before.config['enemyLevel'];
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Tooltip(
          message: mcp == null
              ? 'PoB ${pob.commit}'
              : 'PoB ${pob.commit} · MCP ${mcp.commit}',
          child: Text(
            mcp == null ? 'PoB ${pob.tag}' : 'PoB ${pob.tag} · MCP ${mcp.tag}',
          ),
        ),
        if (enemyLevel is num)
          Wrap(
            spacing: 4,
            children: [
              const AppText('Уровень противника'),
              Text(formatStat(enemyLevel)),
            ],
          ),
      ],
    );
  }

  Widget _skill(_Side side, BuildReport report) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(side.label),
      AppText(report.mainSkill, game: true),
      for (final selector in [
        report.skillPartSelector,
        report.skillStatSetSelector,
      ])
        if (_selectedLabel(selector) case final label?)
          AppText(label, game: true),
    ],
  );

  String? _selectedLabel(JsonMap selector) =>
      jsonRows(selector['entries'])
              .where((entry) => entry['id'] == selector['selected'])
              .firstOrNull?['label']
          as String?;
}
