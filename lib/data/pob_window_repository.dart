import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'mcp_client.dart';
import 'process_service.dart';

class PobWindowRepository {
  const PobWindowRepository();

  bool get supported => Platform.isWindows;

  Future<List<String>> findInstallations(Installation mcp) async {
    final output = await _run(mcp, ['-c', _discovery]);
    final paths = (jsonDecode(output) as List).cast<String>();
    return List.unmodifiable(paths);
  }

  Future<void> installBridge(Installation mcp, String directory) async {
    final executable = await _executable(directory);
    await _run(mcp, [
      'run.py',
      'install-bridge',
      '--pob-dir',
      executable.parent.path,
    ]);
  }

  Future<void> restartAndCheckBridge(Installation mcp, String directory) async {
    final executable = await _executable(directory);
    await _closeWindow(await executable.resolveSymbolicLinks());
    await Process.start(
      executable.path,
      const [],
      workingDirectory: executable.parent.path,
      mode: ProcessStartMode.detached,
    );
    final status = await _run(mcp, [
      '-c',
      _waitForBridge,
      executable.parent.path,
    ], timeout: const Duration(seconds: 60));
    if (status != 'ready') {
      throw StateError(
        'PoB запущен, но мост пока не отвечает. Проверьте связь ещё раз.',
      );
    }
  }

  Future<File> _executable(String directory) async {
    final executable = File.fromUri(
      Directory(directory).absolute.uri
          .resolve(Uri.encodeComponent('Path of Building-PoE2.exe')),
    );
    if (!await executable.exists()) {
      throw const FormatException('Выберите папку с приложением PoB для PoE 2');
    }
    return executable;
  }

  Future<void> _closeWindow(String executable) async {
    final result = await Process.run(
      'powershell.exe',
      ['-NoProfile', '-NonInteractive', '-Command', _closePobWindow],
      environment: {'POB2_RESTART_EXE': executable},
    );
    switch (result.exitCode) {
      case 0:
        return;
      case 2:
        throw StateError(
          'PoB ещё открыт. Сохраните сборку и завершите закрытие в PoB.',
        );
      default:
        throw StateError('Закройте выбранный PoB вручную и повторите запуск.');
    }
  }

  Future<void> checkBridge(Installation mcp, String directory) async {
    await _exportXml(mcp, directory: directory);
  }

  Future<String> readXml(Installations components) async {
    final mcp = components[Component.mcp];
    if (mcp == null) throw StateError('Подключите Lua');
    return _exportXml(mcp);
  }

  Future<String> _exportXml(Installation mcp, {String? directory}) async {
    final client = McpClient();
    try {
      await client.connectToPobWindow(mcp, directory: directory);
      return await client.exportBuildXml();
    } finally {
      await client.close();
    }
  }

  Future<String> _run(
    Installation mcp,
    List<String> arguments, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final process = ProcessService();
    final python = await process.python();
    try {
      return await process.run(
        python,
        ['-X', 'utf8', ...arguments],
        directory: mcp.directory,
        timeout: timeout,
      );
    } on ProcessException catch (error) {
      throw StateError(error.message.trim());
    }
  }
}

const _discovery = '''
import json
from pathlib import Path

from pob_poe2_mcp.bridge import load_config
from pob_poe2_mcp.engine import engine_layout, installed_engine_dirs
from pob_poe2_mcp.transport import bridge_state_dir

paths = installed_engine_dirs()
saved = load_config(bridge_state_dir()).get("installDir")
if isinstance(saved, str):
    path = Path(saved).resolve()
    if engine_layout(path) and path not in paths:
        paths.append(path)

print(json.dumps([
    str(path) for path in paths if (path / "Path of Building-PoE2.exe").is_file()
]))
''';

const _closePobWindow = r'''
$ErrorActionPreference = 'Stop'
$target = $env:POB2_RESTART_EXE
$name = [IO.Path]::GetFileNameWithoutExtension($target)
$session = [Diagnostics.Process]::GetCurrentProcess().SessionId
$windows = @()
foreach ($process in [Diagnostics.Process]::GetProcessesByName($name)) {
    try {
        if ($process.HasExited -or $process.SessionId -ne $session) { continue }
        $path = $process.MainModule.FileName
        if (!$path) { exit 3 }
        if ([string]::Equals($path, $target, [StringComparison]::OrdinalIgnoreCase)) {
            $windows += $process
        }
    } catch {
        if (!$process.HasExited) { exit 3 }
    }
}
if ($windows.Count -gt 1) { exit 3 }
if ($windows.Count -eq 0) { exit 0 }
$window = $windows[0]
try {
    if (!$window.HasExited -and $window.CloseMainWindow()) {
        [void]$window.WaitForExit(45000)
    }
} catch {
    if (!$window.HasExited) { exit 2 }
}
if (!$window.HasExited) { exit 2 }
exit 0
''';

const _waitForBridge = '''
import sys
import time

from pob_poe2_mcp.api import BuildAPI
from pob_poe2_mcp.errors import EngineError

deadline = time.monotonic() + 45
while time.monotonic() < deadline:
    try:
        with BuildAPI(mode="app", pob_dir=sys.argv[1], timeout=4):
            print("ready")
            break
    except (EngineError, OSError):
        time.sleep(0.4)
''';
