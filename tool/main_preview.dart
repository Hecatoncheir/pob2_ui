// Отладочный запуск с настоящим Lua; отдельный профиль задаётся через POB2_UI_HOME.
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

void main() {
  enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();
  final model = WorkshopCubit(
    ComponentRepository(
      store: InstallationStore(InstallationStore.defaultRoot()),
    ),
    McpClient(),
  );
  runApp(PobApp(model: model));
  model.initialize();
}
