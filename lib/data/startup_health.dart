import 'dart:io';

import 'bundled_engine.dart';
import 'installation_store.dart';

String? _startupToken(List<String> arguments) {
  final index = arguments.indexOf('--pob-update-token');
  if (index < 0 || index + 1 >= arguments.length) return null;
  final token = arguments[index + 1];
  return RegExp(r'^[a-f0-9]{32}$').hasMatch(token) ? token : null;
}

Future<bool> checkUpdateEngine(List<String> arguments) async {
  if (_startupToken(arguments) == null) return true;
  return verifyBundledEngine();
}

Future<void> markStartupHealthy(List<String> arguments) async {
  final token = _startupToken(arguments);
  if (token == null) return;
  final file = File.fromUri(
    InstallationStore.defaultRoot().uri.resolve('updates/health-$token.ready'),
  );
  await file.parent.create(recursive: true);
  await file.writeAsString('ready', flush: true);
}
