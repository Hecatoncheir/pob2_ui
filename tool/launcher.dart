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
  var active = await readVersion(root, 'active-version');
  if (arguments.contains('--rollback')) {
    final previous = await readVersion(root, 'previous-version');
    if (previous == null)
      throw const FileSystemException('Нет предыдущей версии');
    await writeVersion(root, 'active-version', previous);
    active = previous;
  }
  String? pending;
  try {
    pending = await readVersion(root, 'pending-version');
  } on FormatException {
    await File.fromUri(root.uri.resolve('pending-version')).delete();
  }
  if (pending == null ||
      pending == active ||
      arguments.contains('--rollback')) {
    if (active == null) throw const FileSystemException('Нет активной версии');
    await startVersion(
      root,
      active,
      arguments.where((value) => value != '--rollback').toList(),
    );
    return;
  }
  final token = List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final health = File.fromUri(
    InstallationStore.defaultRoot().uri.resolve('updates/health-$token.ready'),
  );
  await health.parent.create(recursive: true);
  Process? child;
  var healthy = false;
  try {
    child = await startVersion(root, pending, [
      ...arguments,
      '--pob-update-token',
      token,
    ]);
    healthy = await waitForHealth(health);
  } on ProcessException {
    healthy = false;
  } on FileSystemException {
    healthy = false;
  }
  if (healthy) {
    if (active != null) await writeVersion(root, 'previous-version', active);
    await writeVersion(root, 'active-version', pending);
    await health.delete();
  } else {
    if (child != null) Process.killPid(child.pid);
    await File.fromUri(root.uri.resolve('update.log')).writeAsString(
      'Версия $pending не подтвердила запуск; восстановлена $active.\n',
      mode: FileMode.append,
    );
    if (active != null)
      await startVersion(root, active, arguments);
    else
      exitCode = 1;
  }
  if (await readVersion(root, 'pending-version') == pending)
    await File.fromUri(root.uri.resolve('pending-version')).delete();
}

Future<bool> waitForHealth(File file) async {
  for (var attempt = 0; attempt < 150; attempt++) {
    if (await file.exists()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  return false;
}
