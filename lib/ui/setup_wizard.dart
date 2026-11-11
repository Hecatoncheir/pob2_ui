import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/component.dart';
import 'build_dialogs.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
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

class _SetupWizard extends StatelessWidget {
  const _SetupWizard(this.model);
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkshopCubit, WorkshopState>(
        bloc: model,
        builder: (context, state) {
          final step = _SetupStep.current(model);
          return AlertDialog(
            title: const AppText('Подготовка PoB II'),
            scrollable: true,
            content: SizedBox(
              width: 510,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in _SetupStep.values) _StepRow(item, step),
                  const SizedBox(height: 16),
                  _stepContent(context, step, state),
                  if (state.busy) const _SetupProgress(),
                  if (state.error case final error?) _SetupError(error),
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

  Widget _stepContent(
    BuildContext context,
    _SetupStep step,
    WorkshopState state,
  ) => switch (step) {
    _SetupStep.pob || _SetupStep.mcp => _SetupActions(
      message: 'Для установки нужны Git и 64-битный Python 3.11+. После загрузки компонентов расчёты работают без сети.',
      actions: [
        FilledButton(
          onPressed: state.busy ? null : model.prepareComponents,
          child: const AppText('Установить компоненты'),
        ),
      ],
    ),
    _SetupStep.lua => _SetupActions(
      actions: [
        FilledButton(
          onPressed: state.busy ? null : model.prepareComponents,
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
        onPressed: state.busy ? null : model.detectPobBuildFolder,
        child: const AppText('Найти папку PoB'),
      ),
      OutlinedButton(
        onPressed: state.busy
            ? null
            : () => choosePobBuildFolder(context, model),
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
        onPressed: busy ? null : model.openXmlFile,
        child: const AppText('Открыть XML'),
      ),
      if (model.pobWindow.supported) ...[
        OutlinedButton(
          onPressed: busy ? null : model.importFromPob,
          child: const AppText('Импортировать из PoB'),
        ),
        PobCharacterImportButton(model),
      ],
    ],
  );
}

class _StepRow extends StatelessWidget {
  const _StepRow(this.step, this.current);
  final _SetupStep step, current;

  @override
  Widget build(BuildContext context) {
    final done = step.index < current.index;
    final active = step == current;
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
  const _SetupProgress();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 16),
    child: LinearProgressIndicator(),
  );
}

class _SetupError extends StatelessWidget {
  const _SetupError(this.error);
  final String error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: AppText(
      error,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}
