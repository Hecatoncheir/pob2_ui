import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../lib/data/installation_store.dart';
import '../lib/data/launcher_versions.dart';
import '../lib/domain/app_info.dart';
import '../lib/domain/app_release.dart';

Future<void> main(List<String> arguments) async {
  final root = File(Platform.resolvedExecutable).parent;
  try {
    final marker = jsonDecode(
      await File.fromUri(root.uri.resolve('pob2-install.json')).readAsString(),
    ) as Map<String, dynamic>;
    if (marker['id'] != appId)
      throw const FormatException('Неизвестная установка');
    final lock = await File.fromUri(root.uri.resolve('.launcher.lock'))
        .open(mode: FileMode.append);
    try {
      await lock.lock();
      await launch(root, arguments);
    } finally {
      await lock.close();
    }
  } catch (error) {
    await File.fromUri(root.uri.resolve('update.log'))
        .writeAsString('$error\n', mode: FileMode.append);
    exitCode = 1;
  }
}

Future<String?> readVersion(Directory root, String name) async {
  final file = File.fromUri(root.uri.resolve(name));
  if (!await file.exists()) return null;
  try {
    return '${AppVersion.parse((await file.readAsString()).trim())}';
  } on FormatException {
    return null;
  }
}

Future<void> writeVersion(Directory root, String name, String version) async {
  final file = File.fromUri(root.uri.resolve('$name.tmp'));
  await file.writeAsString(version, flush: true);
  await file.rename(File.fromUri(root.uri.resolve(name)).path);
}

Future<Process> startVersion(
  Directory root,
  String version,
  List<String> arguments,
) async {
  final executable = LauncherVersions(root).executable(version);
  if (!await executable.exists())
    throw const FileSystemException('Нет файлов выбранной версии');
  return Process.start(
    executable.path,
    arguments,
    workingDirectory: executable.parent.path,
    mode: ProcessStartMode.detached,
  );
}

Future<void> launch(Directory root, List<String> arguments) async {
  final active = await readVersion(root, 'active-version');
  final forwarded = arguments.where((value) => value != '--rollback').toList();
  if (arguments.contains('--rollback')) {
    await rollbackVersion(root, active, forwarded);
    return;
  }
  final pending = await readPending(root);
  final versions = LauncherVersions(root);
  for (final version in await versions.candidates(
    active: active,
    pending: pending,
  )) {
    if (await launchVersion(root, version, active, forwarded)) {
      if (await readPending(root) == pending) await clearPending(root);
      return;
    }
    await versions.reject(version);
    await recordFailure(root, version);
  }
  if (await readPending(root) == pending) await clearPending(root);
  throw const FileSystemException('Нет исправной установленной версии');
}

Future<void> clearPending(Directory root) async {
  final file = File.fromUri(root.uri.resolve('pending-version'));
  if (await file.exists()) await file.delete();
}

Future<String?> readPending(Directory root) =>
    readVersion(root, 'pending-version');

Future<bool> launchVersion(
  Directory root,
  String version,
  String? active,
  List<String> arguments,
) async {
  if (version != active) return tryCandidate(root, version, active, arguments);
  try {
    await startVersion(root, version, arguments);
    return true;
  } on ProcessException {
    return false;
  } on FileSystemException {
    return false;
  }
}

Future<void> rollbackVersion(
  Directory root,
  String? active,
  List<String> arguments,
) async {
  final previous = await readVersion(root, 'previous-version');
  if (previous == null)
    throw const FileSystemException('Нет предыдущей версии');
  final versions = LauncherVersions(root);
  if (await tryCandidate(root, previous, active, arguments)) {
    if (active != null && active != previous) await versions.reject(active);
  } else {
    await versions.reject(previous);
    await recordFailure(root, previous);
    if (active == null) throw const FileSystemException('Нет активной версии');
    await startVersion(root, active, arguments);
  }
  await clearPending(root);
}

Future<bool> tryCandidate(
  Directory root,
  String pending,
  String? active,
  List<String> arguments,
) async {
  final token = List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final health = File.fromUri(
    InstallationStore.defaultRoot().uri.resolve('updates/health-$token.ready'),
  );
  await health.parent.create(recursive: true);
  final (:process, :healthy) = await probeCandidate(root, pending, [
    ...arguments,
    '--pob-update-token',
    token,
  ], health);
  if (!healthy) {
    if (process != null) Process.killPid(process.pid);
    return false;
  }
  if (active != null && active != pending)
    await writeVersion(root, 'previous-version', active);
  await writeVersion(root, 'active-version', pending);
  await LauncherVersions(root).allow(pending);
  try {
    await health.delete();
  } on FileSystemException {
    // Подтверждение может быть ещё открыто завершившим запись Flutter-процессом.
  }
  return true;
}

Future<({Process? process, bool healthy})> probeCandidate(
  Directory root,
  String version,
  List<String> arguments,
  File health,
) async {
  Process? process;
  try {
    process = await startVersion(root, version, arguments);
    return (process: process, healthy: await waitForHealth(health));
  } on ProcessException {
    return (process: process, healthy: false);
  } on FileSystemException {
    return (process: process, healthy: false);
  }
}

Future<void> recordFailure(Directory root, String version) async {
  await File.fromUri(root.uri.resolve('update.log')).writeAsString(
    'Версия $version не подтвердила запуск; проверяется следующая установленная.\n',
    mode: FileMode.append,
  );
}

Future<bool> waitForHealth(File file) async {
  for (var attempt = 0; attempt < 150; attempt++) {
    if (await file.exists()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  return false;
}
