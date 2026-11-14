import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_info.dart';
import '../domain/component.dart';
import 'build_dialogs.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'pob_build_folder_actions.dart';
import 'pob_bridge_dialog.dart';
import 'pob_character_dialog.dart';
import 'shell_bloc.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';

Future<void> showSetupWizard(BuildContext context, WorkshopCubit model) async {
  final shell = context.read<ShellBloc>();
  final page = await sparkDialog<AppPage>(context, _SetupWizard(model));
  if (page != null && !shell.isClosed) shell.add(PageSelected(page));
}

enum _SetupStep {
  pob('Скачать Path of Building'),
  mcp('Скачать PoB MCP'),
  lua('Подключить Lua'),
  folder('Подключить папку сборок'),
  builds('Открыть или создать сборку');

  const _SetupStep(this.label);
  final String label;

  static _SetupStep current(WorkshopCubit model) {
    final installed = model.components.active;
    if (!installed.containsKey(Component.pob)) return pob;
    if (!installed.containsKey(Component.mcp)) return mcp;
    if (!model.luaReady) return lua;
    if (!model.buildFolderReady) return folder;
    return builds;
  }
}

class _SetupWizard extends StatefulWidget {
  const _SetupWizard(this.model);
  final WorkshopCubit model;

  @override
  State<_SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<_SetupWizard> {
  WorkshopCubit get model => widget.model;
  Future<void> Function()? _lastAction;

  Future<void> _run(Future<void> Function() action) async {
    if (model.state.busy) return;
    _lastAction = action;
    try {
      await action();
    } catch (error) {
      if (mounted && !model.isClosed) model.reportPersistenceError(error);
    }
    if (model.state.error == null) _lastAction = null;
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkshopCubit, WorkshopState>(
        bloc: model,
        builder: (context, state) {
          final step = _SetupStep.current(model);
          final phase = state.setupStage?.label;
          return AlertDialog(
            title: const AppText('Подготовка PoB II'),
            scrollable: true,
            content: SizedBox(
              width: 510,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in _SetupStep.values)
                    _StepRow(item, step, state.setupStage),
                  const SizedBox(height: 16),
                  _stepContent(context, step, state),
                  if (state.busy) _SetupProgress(phase ?? step.label),
                  if (!state.busy && state.error != null)
                    _failure(context, state, phase),
                ],
              ),
            ),
            actions: [
              if (step == _SetupStep.builds && !state.busy)
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    model.state.report == null
                        ? AppPage.library
                        : AppPage.workspace,
                  ),
                  child: const AppText('Готово'),
                )
              else
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const AppText('Позже'),
                ),
            ],
          );
        },
      );

  Widget _failure(BuildContext context, WorkshopState state, String? phase) =>
      _SetupError(
        phase: phase,
        error: state.error!,
        diagnostic: _diagnostic(context, state, phase),
        retry: _retry(state),
      );

  VoidCallback? _retry(WorkshopState state) {
    final action = state.setupStage == null
        ? _lastAction
        : model.prepareComponents;
    return action == null ? null : () => unawaited(_run(action));
  }

  String _diagnostic(BuildContext context, WorkshopState state, String? phase) {
    final lines = [
      '$appName $appVersion · ${Platform.operatingSystem}',
      if (phase != null) translateUi(context, phase),
      _diagnosticReason(translateUi(context, state.error!)),
      for (final component in Component.values)
        _componentDiagnostic(context, state, component),
    ];
    return lines.join('\n');
  }

  String _diagnosticReason(String reason) => reason
      .replaceAllMapped(
        RegExp(r'(https?://)[^\s/@]+@', caseSensitive: false),
        (match) => match[1]!,
      )
      .replaceAllMapped(
        RegExp(r'(https?://[^\s?#]+)\?[^\s]*', caseSensitive: false),
        (match) => match[1]!,
      );

  String _componentDiagnostic(
    BuildContext context,
    WorkshopState state,
    Component component,
  ) {
    final installed = model.components.active[component]?.tag ?? '—';
    final requested = state.releases[component]?.tag ?? '—';
    final active = translateUi(context, 'Установлена: $installed');
    final latest = translateUi(context, 'Последняя: $requested');
    return '${component.title} · $active · $latest';
  }

  Widget _stepContent(
    BuildContext context,
    _SetupStep step,
    WorkshopState state,
  ) => switch (step) {
    _SetupStep.pob || _SetupStep.mcp => _SetupActions(
      message: 'Для установки нужны Git и 64-битный Python 3.11+. После загрузки компонентов расчёты работают без сети.',
      actions: [
        FilledButton(
          onPressed: state.busy ? null : () => _run(model.prepareComponents),
          child: const AppText('Установить компоненты'),
        ),
      ],
    ),
    _SetupStep.lua => _SetupActions(
      actions: [
        FilledButton(
          onPressed: state.busy ? null : () => _run(model.prepareComponents),
          child: const AppText('Подключить Lua'),
        ),
      ],
    ),
    _SetupStep.folder => _folder(context, state),
    _SetupStep.builds => _builds(context, state.busy),
  };

  Widget _folder(BuildContext context, WorkshopState state) => _SetupActions(
    message: model.pobWindow.supported
        ? 'PoB II при необходимости запустит PoB свёрнутым и запросит путь к сборкам.'
        : 'Укажите папку PoB вручную или попробуйте найти её по стандартному пути.',
    actions: [
      FilledButton(
        onPressed: state.busy ? null : () => _run(model.detectPobBuildFolder),
        child: const AppText('Найти папку PoB'),
      ),
      OutlinedButton(
        onPressed: state.busy
            ? null
            : () => _run(() => choosePobBuildFolder(context, model)),
        child: const AppText('Выбрать папку сборок PoB'),
      ),
      if (state.error != null && model.pobWindow.supported)
        TextButton(
          onPressed: state.busy
              ? null
              : () => showPobBridgeSetup(
                  context,
                  model.pobWindow,
                  model.components.active[Component.mcp]!,
                ),
          child: const AppText('Настроить мост PoB'),
        ),
    ],
  );

  Widget _builds(BuildContext context, bool busy) => _SetupActions(
    message:
        'Сборки из подключённой папки уже доступны в разделе «Мои сборки».',
    directory: model.sharedLibrary?.directory,
    actions: [
      OutlinedButton(
        onPressed: busy ? null : () => showNewBuild(context, model),
        child: const AppText('Новая сборка'),
      ),
      OutlinedButton(
        onPressed: busy ? null : () => _run(model.openXmlFile),
        child: const AppText('Открыть XML'),
      ),
      if (model.pobWindow.supported) ...[
        OutlinedButton(
          onPressed: busy ? null : () => _run(model.importFromPob),
          child: const AppText('Импортировать из PoB'),
        ),
        PobCharacterImportButton(model),
      ],
    ],
  );
}

class _StepRow extends StatelessWidget {
  const _StepRow(this.step, this.current, this.phase);
  final _SetupStep step, current;
  final WorkshopSetupStage? phase;

  @override
  Widget build(BuildContext context) {
    final highlighted = switch (phase) {
      WorkshopSetupStage.pob => _SetupStep.pob,
      WorkshopSetupStage.mcp => _SetupStep.mcp,
      WorkshopSetupStage.compatibility => _SetupStep.lua,
      _ => current,
    };
    final done = step != highlighted && step.index < current.index;
    final active = step == highlighted;
    final colors = Theme.of(context).colorScheme;
    final color = active || done ? colors.primary : colors.onSurfaceVariant;
    return Semantics(
      selected: active,
      checked: done,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: done
                  ? Icon(Icons.check, size: 17, color: color)
                  : Text('${step.index + 1}', style: TextStyle(color: color)),
            ),
            Expanded(
              child: AppText(
                step.label,
                style: TextStyle(
                  color: active ? colors.onSurface : colors.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupActions extends StatelessWidget {
  const _SetupActions({this.message, this.directory, required this.actions});
  final String? message, directory;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (message case final text?) ...[
        AppText(text),
        const SizedBox(height: 10),
      ],
      if (directory case final path?) ...[
        SelectableText(path, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
      ],
      Wrap(spacing: 8, runSpacing: 8, children: actions),
    ],
  );
}

class _SetupProgress extends StatelessWidget {
  const _SetupProgress(this.phase);
  final String phase;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(liveRegion: true, child: AppText(phase)),
        const SizedBox(height: 8),
        const LinearProgressIndicator(),
      ],
    ),
  );
}

class _SetupError extends StatefulWidget {
  const _SetupError({
    this.phase,
    required this.error,
    required this.diagnostic,
    this.retry,
  });
  final String? phase;
  final String diagnostic;
  final String error;
  final VoidCallback? retry;

  @override
  State<_SetupError> createState() => _SetupErrorState();
}

class _SetupErrorState extends State<_SetupError> {
  String? _feedback;

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.diagnostic));
      if (mounted) setState(() => _feedback = 'Диагностика скопирована');
    } catch (_) {
      if (mounted)
        setState(() => _feedback = 'Не удалось скопировать диагностику');
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.phase case final phase?)
          AppText(phase, style: Theme.of(context).textTheme.titleSmall),
        AppText(
          widget.error,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.retry case final retry?)
              FilledButton(onPressed: retry, child: const AppText('Повторить')),
            OutlinedButton.icon(
              onPressed: _copy,
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const AppText('Скопировать диагностику'),
            ),
          ],
        ),
        if (_feedback case final feedback?)
          Semantics(liveRegion: true, child: AppText(feedback)),
      ],
    ),
  );
}
