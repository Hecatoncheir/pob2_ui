import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../lib/data/installation_store.dart';
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
  return '${AppVersion.parse((await file.readAsString()).trim())}';
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
  final name = Platform.isWindows ? 'pob2_ui.exe' : 'pob2_ui';
  final executable = File.fromUri(root.uri.resolve('versions/$version/$name'));
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
  final active = await chooseActive(
    root,
    rollback: arguments.contains('--rollback'),
  );
  final pending = await readPending(root);
  final forwarded = arguments.where((value) => value != '--rollback').toList();
  if (pending == null || pending == active) {
    if (active == null) throw const FileSystemException('Нет активной версии');
    await startVersion(root, active, forwarded);
    return;
  }
  await tryCandidate(root, pending, active, forwarded);
  if (await readPending(root) == pending) await clearPending(root);
}

Future<void> clearPending(Directory root) async {
  final file = File.fromUri(root.uri.resolve('pending-version'));
  if (await file.exists()) await file.delete();
}

Future<String?> readPending(Directory root) async {
  try {
    return await readVersion(root, 'pending-version');
  } on FormatException {
    await clearPending(root);
    return null;
  }
}

Future<String?> chooseActive(Directory root, {required bool rollback}) async {
  final active = await readVersion(root, 'active-version');
  if (!rollback) return active;
  final previous = await readVersion(root, 'previous-version');
  if (previous == null)
    throw const FileSystemException('Нет предыдущей версии');
  if (active != null) await writeVersion(root, 'previous-version', active);
  await writeVersion(root, 'active-version', previous);
  await clearPending(root);
  return previous;
}

Future<void> tryCandidate(
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
  if (healthy) {
    if (active != null) await writeVersion(root, 'previous-version', active);
    await writeVersion(root, 'active-version', pending);
    await health.delete();
  } else {
    if (process != null) Process.killPid(process.pid);
    await recover(root, pending, active, arguments);
  }
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

Future<void> recover(
  Directory root,
  String pending,
  String? active,
  List<String> arguments,
) async {
  await File.fromUri(root.uri.resolve('update.log')).writeAsString(
    'Версия $pending не подтвердила запуск; восстановлена $active.\n',
    mode: FileMode.append,
  );
  if (active == null) {
    exitCode = 1;
    return;
  }
  await startVersion(root, active, arguments);
}

Future<bool> waitForHealth(File file) async {
  for (var attempt = 0; attempt < 150; attempt++) {
    if (await file.exists()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  return false;
}
