import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/app_info.dart';
import 'app_update_model.dart';
import 'workshop_model.dart';

Future<void> showAppUpdates(
  BuildContext context,
  AppUpdateModel updates,
  WorkshopModel workshop,
) => showDialog<void>(
  context: context,
  builder: (context) => ListenableBuilder(
    listenable: Listenable.merge([updates, workshop]),
    builder: (context, _) => AlertDialog(
      title: const Text('Обновление PoB II'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Установлена версия $appVersion'),
              const SizedBox(height: 12),
              Text(updates.message),
              if (updates.release != null) ...[
                const SizedBox(height: 12),
                Text(
                  updates.release!.notes.isEmpty
                      ? 'Описание выпуска отсутствует'
                      : updates.release!.notes,
                ),
              ],
              if (updates.phase == UpdatePhase.downloading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: updates.progress),
                Text('${(updates.progress * 100).round()} %'),
              ],
              if (updates.phase == UpdatePhase.ready)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Обновление загружено и проверено. Перед перезапуском сборка и XML будут сохранены.',
                  ),
                ),
              if (updates.installation == null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Эта копия запущена без установщика или из каталога без права записи. Установите новую версию со страницы выпусков.',
                  ),
                ),
              if (updates.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SelectableText(
                    updates.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Загружать обновления автоматически'),
                subtitle: const Text('Перезапуск — только по вашей команде'),
                value: updates.autoDownload,
                onChanged: updates.busy || updates.installation == null
                    ? null
                    : updates.setAutoDownload,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: updates.phase == UpdatePhase.installing
              ? null
              : () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
        if (updates.phase == UpdatePhase.downloading)
          TextButton(
            onPressed: updates.cancel,
            child: const Text('Приостановить'),
          )
        else if (updates.installation == null ||
            (updates.available && updates.release?.installer == null))
          FilledButton(
            onPressed: updates.openReleases,
            child: const Text('Страница выпусков'),
          )
        else if (updates.phase == UpdatePhase.ready)
          FilledButton(
            onPressed: workshop.busy || updates.busy
                ? null
                : () async {
                    if (await updates.install(workshop.checkpoint)) {
                      await workshop.engine.close();
                      exit(0);
                    }
                  },
            child: const Text('Перезапустить и обновить'),
          )
        else if (updates.available)
          FilledButton(
            onPressed: updates.busy ? null : updates.download,
            child: const Text('Скачать обновление'),
          )
        else
          FilledButton(
            onPressed: updates.busy ? null : updates.check,
            child: Text(updates.busy ? 'Проверяем…' : 'Проверить'),
          ),
      ],
    ),
  ),
);
