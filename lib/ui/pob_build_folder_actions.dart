import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'workshop_cubit.dart';

enum _FolderAction { detect, choose, refresh }

Future<void> showPobBuildFolder(
  BuildContext context,
  WorkshopCubit model,
) async {
  final action = await sparkDialog<_FolderAction>(
    context,
    _BuildFolderDialog(model),
  );
  if (!context.mounted || model.isClosed || model.state.busy) return;
  switch (action) {
    case _FolderAction.detect:
      await model.detectPobBuildFolder();
    case _FolderAction.choose:
      final directory = await getDirectoryPath(
        initialDirectory: model.sharedLibrary?.directory,
      );
      if (directory != null && context.mounted && !model.isClosed) {
        await model.selectPobBuildFolder(directory);
      }
    case _FolderAction.refresh:
      await model.refreshPobBuilds();
    case null:
      break;
  }
}

class _BuildFolderDialog extends StatelessWidget {
  const _BuildFolderDialog(this.model);
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const AppText('Папка сборок'),
    scrollable: true,
    content: switch (model.sharedLibrary?.directory) {
      final directory? => SelectableText(
        directory,
        key: const Key('build-folder-path'),
      ),
      null => const AppText(
        'Выберите ту же папку сборок, которая указана в Path of Building.',
      ),
    },
    actions: [
      const DialogCloseButton(label: 'Закрыть'),
      if (model.buildFolderReady)
        TextButton(
          onPressed: () => Navigator.pop(context, _FolderAction.refresh),
          child: const AppText('Обновить список сборок'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context, _FolderAction.choose),
        child: const AppText('Выбрать папку сборок PoB'),
      ),
      if (model.pobWindow.supported && model.ready)
        FilledButton(
          onPressed: () => Navigator.pop(context, _FolderAction.detect),
          child: const AppText('Найти папку PoB'),
        ),
    ],
  );
}
