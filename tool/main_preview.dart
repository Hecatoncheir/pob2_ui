import 'package:pob2_ui/data/interface_scale_repository.dart';
import 'package:pob2_ui/ui/interface_scale_bloc.dart';
import 'package:pob2_ui/data/language_preferences.dart';
import 'package:pob2_ui/data/game_dictionary_repository.dart';
import 'package:pob2_ui/ui/language_bloc.dart';
import 'package:pob2_ui/data/appearance_repository.dart';
import 'package:pob2_ui/ui/appearance_bloc.dart';
// Отладочный запуск с настоящим Lua; отдельный профиль задаётся через POB2_UI_HOME.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

Future<void> main() async {
  enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();
  final model = WorkshopCubit(
    ComponentRepository(
      store: InstallationStore(InstallationStore.defaultRoot()),
    ),
    McpClient(),
  );
  final preferences = AppearanceRepository(model.components.store.root);
  final appearance = AppearanceBloc(
    preferences,
    initialTheme: await preferences.load(),
  );
  final languages = LanguagePreferences(model.components.store.root);
  final language = LanguageBloc(
    languages,
    GameDictionaryRepository(model.components.store.root),
    initialLanguage: await languages.load(),
  );
  final scalePreferences = InterfaceScaleRepository(
    model.components.store.root,
  );
  final interfaceScale = InterfaceScaleBloc(
    scalePreferences,
    initialPercent: await scalePreferences.load(),
  );
  runApp(
    PobApp(
      model: model,
      appearance: appearance,
      language: language,
      interfaceScale: interfaceScale,
    ),
  );
  language.add(const LanguageLoadRequested());
  model.initialize();
}
