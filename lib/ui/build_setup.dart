import 'package:material_ui/material_ui.dart';

import 'core/app_text.dart';
import 'pob_build_folder_actions.dart';
import 'workshop_cubit.dart';

enum BuildSetup {
  components,
  folder;

  static BuildSetup? pending(WorkshopCubit model) {
    if (!model.ready || !model.engine.connected) return components;
    if (!model.buildFolderReady) return folder;
    return null;
  }

  String get message => switch (this) {
    components => 'Установите компоненты, чтобы открыть сборку и получить настоящий расчёт.',
    folder =>
      'Выберите ту же папку сборок, которая указана в Path of Building.',
  };
}

class BuildSetupAction extends StatelessWidget {
  const BuildSetupAction(this.step, this.model, {super.key});
  final BuildSetup step;
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) {
    final (label, action) = switch (step) {
      BuildSetup.components => ('Подготовить PoB II', model.prepareComponents),
      BuildSetup.folder => (
        'Подключить папку сборок',
        () => showPobBuildFolder(context, model),
      ),
    };
    return FilledButton(
      onPressed: model.state.busy ? null : action,
      child: AppText(label),
    );
  }
}
