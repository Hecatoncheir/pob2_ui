import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'core/app_text.dart';
import 'core/ui_translation.dart';
import 'workshop_cubit.dart';

class PobBuildFolderActions extends StatelessWidget {
  const PobBuildFolderActions(this.model, {super.key});
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) {
    final busy = model.state.busy;
    final ready = model.buildFolderReady;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: busy ? null : () => _choose(context),
          icon: const Icon(Icons.folder_open_outlined, size: 18),
          label: const AppText('Выбрать папку сборок PoB'),
        ),
        if (model.pobWindow.supported && model.ready)
          OutlinedButton(
            onPressed: busy ? null : model.detectPobBuildFolder,
            child: const AppText('Найти папку через мост'),
          ),
        if (ready)
          IconButton(
            tooltip: translateUi(context, 'Обновить список сборок'),
            onPressed: busy ? null : model.refreshPobBuilds,
            icon: const Icon(Icons.refresh_rounded),
          ),
      ],
    );
  }

  Future<void> _choose(BuildContext context) async {
    final directory = await getDirectoryPath(
      initialDirectory: model.sharedLibrary?.directory,
    );
    if (directory != null && context.mounted)
      await model.selectPobBuildFolder(directory);
  }
}
