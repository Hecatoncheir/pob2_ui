import 'data/appearance_repository.dart';
import 'ui/appearance_cubit.dart';

import 'package:flutter/material.dart';

import 'data/startup_health.dart';
import 'ui/app_update_cubit.dart';

import 'data/component_repository.dart';
import 'data/installation_store.dart';
import 'data/mcp_client.dart';
import 'ui/app.dart';
import 'ui/workshop_cubit.dart';
import 'data/language_preferences.dart';
import 'data/game_dictionary_repository.dart';
import 'ui/language_cubit.dart';
import 'data/interface_scale_repository.dart';
import 'ui/interface_scale_cubit.dart';
import 'data/workspace_preferences_repository.dart';
import 'ui/workspace_preferences_cubit.dart';
import 'ui/exit_protection.dart';

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  final model = WorkshopCubit(
    ComponentRepository(
      store: InstallationStore(InstallationStore.defaultRoot()),
    ),
    McpClient(),
  );
  final updates = AppUpdateCubit(root: model.components.store.root);
  final preferences = AppearanceRepository(model.components.store.root);
  final appearance = AppearanceCubit(
    preferences,
    initialTheme: await preferences.load(),
  );
  final languagePreferences = LanguagePreferences(model.components.store.root);
  final language = LanguageCubit(
    languagePreferences,
    GameDictionaryRepository(model.components.store.root),
    initialLanguage: await languagePreferences.load(),
  );
  final scalePreferences = InterfaceScaleRepository(
    model.components.store.root,
  );
  final interfaceScale = InterfaceScaleCubit(
    scalePreferences,
    initialPercent: await scalePreferences.load(),
  );
  final workspaceRepository = WorkspacePreferencesRepository(
    model.components.store.root,
  );
  final workspacePreferences = WorkspacePreferencesCubit(
    workspaceRepository,
    initial: await workspaceRepository.load(),
  );
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
      ),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await markStartupHealthy(arguments);
    await updates.initialize();
  });
  model.initialize();
  language.load();
}
