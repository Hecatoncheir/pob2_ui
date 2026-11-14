import 'dart:io';

import 'data/appearance_repository.dart';
import 'installer_check.dart';
import 'ui/appearance_bloc.dart';

import 'package:material_ui/material_ui.dart';

import 'data/startup_health.dart';
import 'ui/app_update_cubit.dart';

import 'data/component_repository.dart';
import 'data/installation_store.dart';
import 'data/mcp_client.dart';
import 'data/pob_build_library.dart';
import 'ui/app.dart';
import 'ui/workshop_cubit.dart';
import 'data/language_preferences.dart';
import 'data/game_dictionary_repository.dart';
import 'ui/language_bloc.dart';
import 'data/interface_scale_repository.dart';
import 'ui/interface_scale_bloc.dart';
import 'data/workspace_preferences_repository.dart';
import 'ui/workspace_preferences_bloc.dart';
import 'ui/exit_protection.dart';

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  final check = _installerCheckStage();
  final root = InstallationStore.defaultRoot();
  final model = WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    McpClient(),
    library: PobBuildLibrary(root),
  );
  final updates = AppUpdateCubit(root: model.components.store.root);
  final preferences = AppearanceRepository(model.components.store.root);
  final appearance = AppearanceBloc(
    preferences,
    initialTheme: await preferences.load(),
  );
  final languagePreferences = LanguagePreferences(model.components.store.root);
  final language = LanguageBloc(
    languagePreferences,
    GameDictionaryRepository(model.components.store.root),
    initialLanguage: await languagePreferences.load(),
  );
  final scalePreferences = InterfaceScaleRepository(
    model.components.store.root,
  );
  final interfaceScale = InterfaceScaleBloc(
    scalePreferences,
    initialPercent: await scalePreferences.load(),
  );
  final workspaceRepository = WorkspacePreferencesRepository(
    model.components.store.root,
  );
  final workspacePreferences = WorkspacePreferencesBloc(
    workspaceRepository,
    initial: await workspaceRepository.load(),
  );
  final initialization = model.initialize();
  runApp(
    ExitProtection(
      model: model,
      child: PobApp(
        model: model,
        updates: updates,
        appearance: appearance,
        language: language,
        interfaceScale: interfaceScale,
        workspacePreferences: workspacePreferences,
        initialization: check == null ? initialization : null,
      ),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await markStartupHealthy(arguments);
    if (check != null) {
      exit(await checkInstalledBuild(model, initialization, check));
    }
    await updates.initialize();
  });
  if (check == null) language.add(const LanguageLoadRequested());
}

String? _installerCheckStage() {
  final environment = Platform.environment;
  if (environment['POB2_UI_HOME']?.isNotEmpty != true) return null;
  return switch (environment['POB2_UI_INSTALLER_CHECK']) {
    final stage? when stage == 'save' || stage == 'restore' => stage,
    _ => null,
  };
}
