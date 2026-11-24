import 'dart:io';

import 'data/appearance_repository.dart';
import 'data/bundled_engine.dart';
import 'domain/engine_session.dart';
import 'installer_check.dart';
import 'ui/appearance_bloc.dart';

import 'package:material_ui/material_ui.dart';

import 'data/startup_health.dart';
import 'ui/app_update_cubit.dart';

import 'data/engine_components.dart';
import 'data/installation_store.dart';
import 'data/workbench_client.dart';
import 'data/pob_build_library.dart';
import 'data/pob_window_repository.dart';
import 'data/profile_use.dart';
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
  final check = _installerCheckStage();
  final root = InstallationStore.defaultRoot();
  final progress = check == null ? null : InstallerCheckProgress(root, check);
  progress?.record('startup');
  WidgetsFlutterBinding.ensureInitialized();
  if (!await checkUpdateEngine(arguments)) exit(1);
  if (check == 'restore' || check == 'cleanup') {
    HttpOverrides.global = OfflineInstallerCheck();
  }
  final model = await _openWorkshop(root, check);
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
      progress!.record('first-frame');
      exit(await checkInstalledBuild(model, initialization, check, progress));
    }
    if (arguments.contains('--mcp-editor')) {
      await initialization;
      await model.waitForPrimarySession();
      await model.mcpEditor.enable();
    }
    await updates.initialize();
  });
  if (check == null) language.add(const LanguageLoadRequested());
}

Future<WorkshopCubit> _openWorkshop(Directory root, String? check) async {
  final executable = defaultEngineExecutable();
  final components = EngineComponents(
    store: InstallationStore(root),
    profileUse: await ProfileUse.open(root),
    executable: executable,
  );
  WorkbenchClient createWorkbench() => WorkbenchClient(executable);
  return WorkshopCubit(
    components,
    createWorkbench(),
    createEngine: createWorkbench,
    pobWindow: PobWindowRepository(engineExecutable: executable),
    library: PobBuildLibrary(root),
    primaryEngine: _primaryEngineOptions(root, check, executable),
  );
}

EngineOptions? _primaryEngineOptions(
  Directory root,
  String? installerCheck,
  String executable,
) {
  if (installerCheck == 'cleanup' || installerCheck == 'link') return null;
  return EngineOptions(
    executable: executable,
    profile: 'pob2-ui',
    runtimeDirectory: Directory.fromUri(root.uri.resolve('engine-run/')).path,
    dataDirectory: Directory.fromUri(root.uri.resolve('engine-data/')).path,
  );
}

String? _installerCheckStage() {
  final environment = Platform.environment;
  if (environment['POB2_UI_HOME']?.isNotEmpty != true) return null;
  return switch (environment['POB2_UI_INSTALLER_CHECK']) {
    final stage?
        when const {'save', 'restore', 'link', 'cleanup'}.contains(stage) =>
      stage,
    _ => null,
  };
}
