import 'data/appearance_repository.dart';
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
        initialization: initialization,
      ),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await markStartupHealthy(arguments);
    await updates.initialize();
  });
  language.add(const LanguageLoadRequested());
}
