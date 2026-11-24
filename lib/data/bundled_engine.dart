import 'dart:async';
import 'dart:convert';
import 'dart:io';

File bundledEngineFile() {
  final executable = File(Platform.resolvedExecutable);
  final name = Platform.isWindows ? 'pob2-engine.exe' : 'pob2-engine';
  return File.fromUri(executable.parent.uri.resolve(name));
}

String defaultEngineExecutable() {
  final explicit = Platform.environment['POB2_ENGINE_EXECUTABLE'];
  if (explicit != null && explicit.isNotEmpty) return explicit;
  final bundled = bundledEngineFile();
  return bundled.existsSync() ? bundled.path : bundled.uri.pathSegments.last;
}

File _bundledVersionFile() {
  final executable = bundledEngineFile();
  final directory = Platform.isMacOS
      ? executable.parent.uri.resolve('../Resources/')
      : executable.parent.uri;
  return File.fromUri(directory.resolve('pob2-engine.version'));
}

Future<bool> verifyBundledEngine() async {
  try {
    final manifest = _bundledVersionFile();
    if (!await manifest.exists()) return true;
    final expected = (await manifest.readAsString()).trim();
    return expected.isNotEmpty && await _bundledEngineVersion() == expected;
  } on FileSystemException {
    return false;
  } on ProcessException {
    return false;
  } on FormatException {
    return false;
  } on TimeoutException {
    return false;
  }
}

Future<String?> _bundledEngineVersion() async {
  final process = await Process.start(bundledEngineFile().path, ['--version']);
  try {
    final values = await Future.wait<Object>([
      process.exitCode,
      process.stdout.transform(utf8.decoder).join(),
      process.stderr.transform(utf8.decoder).join(),
    ]).timeout(const Duration(seconds: 5));
    if (values[0] != 0) return null;
    return switch (jsonDecode(values[1] as String)) {
      {'version': final String version} => version,
      _ => null,
    };
  } finally {
    process.kill();
  }
}
