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
  runApp(PobApp(model: model, updates: updates, appearance: appearance));
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await markStartupHealthy(arguments);
    await updates.initialize();
  });
  model.initialize();
}
