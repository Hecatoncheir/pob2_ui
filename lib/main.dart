import 'package:flutter/material.dart';

import 'data/startup_health.dart';
import 'ui/app_update_model.dart';

import 'data/component_repository.dart';
import 'data/installation_store.dart';
import 'data/mcp_client.dart';
import 'ui/app.dart';
import 'ui/workshop_model.dart';

void main(List<String> arguments) {
  WidgetsFlutterBinding.ensureInitialized();
  final model = WorkshopModel(
    ComponentRepository(
      store: InstallationStore(InstallationStore.defaultRoot()),
    ),
    McpClient(),
  );
  final updates = AppUpdateModel(root: model.components.store.root);
  runApp(PobApp(model: model, updates: updates));
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await markStartupHealthy(arguments);
    await updates.initialize();
  });
  model.initialize();
}
