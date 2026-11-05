import 'dart:io';

import 'installation_store.dart';

Future<void> markStartupHealthy(List<String> arguments) async {
  final index = arguments.indexOf('--pob-update-token');
  if (index < 0 || index + 1 >= arguments.length) return;
  final token = arguments[index + 1];
  if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(token)) return;
  final file = File.fromUri(
    InstallationStore.defaultRoot().uri.resolve('updates/health-$token.ready'),
  );
  await file.parent.create(recursive: true);
  await file.writeAsString('ready', flush: true);
}
