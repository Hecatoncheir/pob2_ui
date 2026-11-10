import 'core/app_text.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_info.dart';
import 'app_update_cubit.dart';
import 'app_update_state.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';

Future<void> showAppUpdates(
  BuildContext context,
  AppUpdateCubit updates,
  WorkshopCubit workshop,
) => showDialog<void>(
  context: context,
  builder: (_) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: updates),
      BlocProvider.value(value: workshop),
    ],
    child: const _UpdateDialog(),
  ),
);

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppUpdateCubit, AppUpdateState>(
        builder: (context, state) => AlertDialog(
          title: const AppText('Обновление PoB II'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(child: _UpdateContent(state)),
          ),
          actions: [
            TextButton(
              onPressed: state.phase == UpdatePhase.installing
                  ? null
                  : () => Navigator.pop(context),
              child: const AppText('Закрыть'),
            ),
            _PrimaryAction(state),
          ],
        ),
      );
}

class _UpdateContent extends StatelessWidget {
  const _UpdateContent(this.state);
  final AppUpdateState state;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppText('Установлена версия $appVersion'),
      const SizedBox(height: 12),
      AppText(state.message),
      if (state.release case final release?) ...[
        const SizedBox(height: 12),
        AppText(
          release.notes.isEmpty
              ? 'Описание выпуска отсутствует'
              : release.notes,
        ),
      ],
      if (state.phase == UpdatePhase.downloading) ...[
        const SizedBox(height: 16),
        LinearProgressIndicator(value: state.progress),
        AppText('${(state.progress * 100).round()} %'),
      ],
      if (state.phase == UpdatePhase.ready)
        const _Notice(
          'Обновление загружено и проверено. Перед перезапуском сборка и XML будут сохранены.',
        ),
      if (state.installation == null)
        const _Notice(
          'Эта копия запущена без установщика или из каталога без права записи. Установите новую версию со страницы выпусков.',
        ),
      if (state.error case final error?)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SelectableText(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const AppText('Загружать обновления автоматически'),
        subtitle: const AppText('Перезапуск — только по вашей команде'),
        value: state.autoDownload,
        onChanged: state.busy || state.installation == null
            ? null
            : context.read<AppUpdateCubit>().setAutoDownload,
      ),
    ],
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(top: 12), child: AppText(text));
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction(this.state);
  final AppUpdateState state;
  @override
  Widget build(BuildContext context) {
    final updates = context.read<AppUpdateCubit>();
    if (state.phase == UpdatePhase.downloading)
      return TextButton(
        onPressed: updates.cancel,
        child: const AppText('Приостановить'),
      );
    if (state.installation == null ||
        (state.available && state.release?.installer == null))
      return FilledButton(
        onPressed: updates.openReleases,
        child: const AppText('Страница выпусков'),
      );
    return switch (state.phase) {
      UpdatePhase.ready => const _RestartButton(),
      UpdatePhase.available => FilledButton(
        onPressed: updates.download,
        child: const AppText('Скачать обновление'),
      ),
      _ => FilledButton(
        onPressed: state.busy ? null : updates.check,
        child: AppText(state.busy ? 'Проверяем…' : 'Проверить'),
      ),
    };
  }
}

class _RestartButton extends StatelessWidget {
  const _RestartButton();
  @override
  Widget build(BuildContext context) =>
      BlocSelector<WorkshopCubit, WorkshopState, bool>(
        selector: (state) => state.busy,
        builder: (context, busy) => FilledButton(
          onPressed: busy ? null : () => _restart(context),
          child: const AppText('Перезапустить и обновить'),
        ),
      );

  Future<void> _restart(BuildContext context) async {
    final updates = context.read<AppUpdateCubit>();
    final workshop = context.read<WorkshopCubit>();
    if (!await updates.install(() => workshop.checkpoint(closePob: true)))
      return;
    await workshop.close();
    exit(0);
  }
}
