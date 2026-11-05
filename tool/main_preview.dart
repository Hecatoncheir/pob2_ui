import 'package:pob2_ui/data/appearance_repository.dart';
import 'package:pob2_ui/ui/appearance_cubit.dart';
// Отладочный запуск с настоящим Lua; отдельный профиль задаётся через POB2_UI_HOME.
import 'package:flutter/material.dart';
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
  final appearance = AppearanceCubit(
    preferences,
    initialTheme: await preferences.load(),
  );
  runApp(PobApp(model: model, appearance: appearance));
  model.initialize();
}
