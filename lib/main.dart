import 'package:flutter/material.dart';

import 'data/component_repository.dart';
import 'data/installation_store.dart';
import 'data/mcp_client.dart';
import 'ui/app.dart';
import 'ui/workshop_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final model = WorkshopModel(
    ComponentRepository(
      store: InstallationStore(InstallationStore.defaultRoot()),
    ),
    McpClient(),
  );
  runApp(PobApp(model: model));
  model.initialize();
}
