import 'package:flutter/material.dart';

import 'data/startup_health.dart';
import 'ui/app_update_cubit.dart';

import 'data/component_repository.dart';
import 'data/installation_store.dart';
import 'data/mcp_client.dart';
import 'ui/app.dart';
import 'ui/workshop_cubit.dart';

void main(List<String> arguments) {
  WidgetsFlutterBinding.ensureInitialized();
  final model = WorkshopCubit(
    ComponentRepository(
      store: InstallationStore(InstallationStore.defaultRoot()),
    ),
    McpClient(),
  );
  final updates = AppUpdateCubit(root: model.components.store.root);
  runApp(PobApp(model: model, updates: updates));
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await markStartupHealthy(arguments);
    await updates.initialize();
  });
  model.initialize();
}
