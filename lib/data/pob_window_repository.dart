import 'dart:convert';
import 'dart:io';

import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/pob_character.dart';
import 'mcp_client.dart';
import 'process_service.dart';

typedef _LaunchedPob = ({String path, int pid, int started});

class PobWindowRepository {
  final _launched = <String, _LaunchedPob>{};
  bool _windowBusy = false;

  bool get supported => Platform.isWindows || Platform.isLinux;
  bool get canRestart => Platform.isWindows;

  Future<List<String>> findInstallations(Installation mcp) async {
    final output = await _run(mcp, ['-c', _discovery]);
    final paths = (jsonDecode(output) as List).cast<String>();
    return List.unmodifiable(paths);
  }

  Future<void> installBridge(Installation mcp, String directory) async {
    if (Platform.isLinux) {
      await _run(mcp, ['-c', _installLinuxBridge, directory]);
      return;
    }
    await _executable(directory);
    await _run(mcp, ['run.py', 'install-bridge', '--pob-dir', directory]);
  }

  Future<void> restartAndCheckBridge(Installation mcp, String directory) =>
      _windowOperation(() => _restartAndCheck(mcp, directory));

  Future<void> _restartAndCheck(Installation mcp, String directory) async {
    final executable = await _executable(directory);
    final path = await executable.resolveSymbolicLinks();
    final window = await _restartWindow(executable, path);
    _launched[path.toLowerCase()] = window;
    final status = await _run(mcp, [
      '-c',
      _waitForBridge,
      directory,
    ], timeout: const Duration(seconds: 60));
    if (status != 'ready') {
      throw StateError(
        'PoB запущен, но мост пока не отвечает. Проверьте связь ещё раз.',
      );
    }
    await _runForWindow(_minimizePobWindow, window);
  }

  Future<void> closeLaunchedWindows() => _windowOperation(() async {
    for (final key in _launched.keys.toList()) {
      final result = await _runForWindow(_closeLaunchedPob, _launched[key]!);
      switch (result.exitCode) {
        case 0:
          _launched.remove(key);
        case 2:
          throw StateError(_closePending);
        default:
          throw StateError('Не удалось закрыть PoB.');
      }
    }
  });

  Future<void> _windowOperation(Future<void> Function() action) async {
    if (_windowBusy) throw StateError('Дождитесь завершения текущей операции');
    _windowBusy = true;
    try {
      await action();
    } finally {
      _windowBusy = false;
    }
  }

  Future<File> _executable(String directory) async {
    final root = Directory(directory).absolute.uri;
    final name = Uri.encodeComponent('Path of Building-PoE2.exe');
    final executable = File.fromUri(root.resolve(name));
    if (await executable.exists()) return executable;
    final runtime = File.fromUri(root.resolve('runtime/$name'));
    if (await runtime.exists()) return runtime;
    throw const FormatException('Выберите папку с приложением PoB для PoE 2');
  }

  Future<_LaunchedPob> _restartWindow(File executable, String path) async {
    final result = await _windowScript(_restartPobWindow, {
      'POB2_WINDOW_EXE': path,
      'POB2_LAUNCH_EXE': executable.path,
    });
    switch (result.exitCode) {
      case 0:
        if (jsonDecode(result.stdout as String) case {
          'pid': final int pid,
          'started': final int started,
        }) {
          return (path: path, pid: pid, started: started);
        }
        throw StateError('Не удалось запустить PoB.');
      case 2:
        throw StateError(_closePending);
      case 4:
        throw StateError('Не удалось запустить PoB.');
      default:
        throw StateError('Закройте выбранный PoB вручную и повторите запуск.');
    }
  }

  Future<ProcessResult> _runForWindow(String script, _LaunchedPob window) =>
      _windowScript(_findLaunchedPob + script, {
        'POB2_WINDOW_EXE': window.path,
        'POB2_WINDOW_PID': '${window.pid}',
        'POB2_WINDOW_STARTED': '${window.started}',
      });

  Future<ProcessResult> _windowScript(
    String script,
    Map<String, String> environment,
  ) => Process.run('powershell.exe', [
    '-NoProfile',
    '-NonInteractive',
    '-Command',
    script,
  ], environment: environment);

  Future<String?> checkBridge(Installation mcp, String directory) async {
    final result = await _run(mcp, ['-c', _checkBridge, directory]);
    return jsonDecode(result) as String?;
  }

  Future<String> readXml(Installations components) async {
    final mcp = components[Component.mcp];
    if (mcp == null) throw StateError('Подключите Lua');
    return _exportXml(mcp);
  }

  Future<List<PobCharacter>> listCharacters(Installations components) async {
    final response = await _windowTool(components, 'pob_list_characters');
    if (response case {'characters': final List<Object?> characters}) {
      return List.unmodifiable(
        characters.map(readPobCharacter).toList()..sort(
          (first, second) =>
              first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        ),
      );
    }
    throw const FormatException('PoB вернул неверный список персонажей.');
  }

  Future<JsonMap> readCharacter(Installations components, String name) async {
    final response = await _windowTool(components, 'pob_get_character', {
      'name': name,
    });
    return switch (response) {
      {'character': final JsonMap character} => character,
      _ => throw const FormatException('PoB вернул неверные данные персонажа.'),
    };
  }

  Future<JsonMap> _windowTool(
    Installations components,
    String tool, [
    JsonMap arguments = const {},
  ]) async {
    final mcp = components[Component.mcp];
    if (mcp == null) throw StateError('Подключите Lua');
    return _withWindow(mcp, (client) async {
      if (!client.tools.contains(tool)) {
        throw StateError('Обновите MCP в разделе «Компоненты».');
      }
      try {
        return await client.call(tool, arguments);
      } on StateError catch (error) {
        if ('${error.message}'.contains('"UNKNOWN_METHOD"')) {
          throw StateError('Подключите мост заново и перезапустите PoB.');
        }
        rethrow;
      }
    });
  }

  Future<String> _exportXml(Installation mcp) =>
      _withWindow(mcp, (client) => client.exportBuildXml());

  Future<T> _withWindow<T>(
    Installation mcp,
    Future<T> Function(McpClient) action,
  ) async {
    final client = McpClient();
    try {
      await client.connectToPobWindow(mcp);
      return await action(client);
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
      if (error.message.trim() == 'POB_WINE_UNSUPPORTED') {
        throw StateError('Обновите MCP в разделе «Компоненты».');
      }
      throw StateError(error.message.trim());
    }
  }
}

const _closePending =
    'PoB ещё открыт. Сохраните сборку и завершите закрытие в PoB.';

const _discovery = '''
import json
import sys
from pathlib import Path

from pob_poe2_mcp import bridge

if hasattr(bridge, "installed_bridge_dirs"):
    paths = bridge.installed_bridge_dirs()
elif sys.platform == "win32":
    from pob_poe2_mcp.engine import engine_layout, installed_engine_dirs
    from pob_poe2_mcp.transport import bridge_state_dir
    paths = installed_engine_dirs()
    saved = bridge.load_config(bridge_state_dir()).get("installDir")
    if isinstance(saved, str):
        path = Path(saved).resolve()
        if engine_layout(path) and path not in paths:
            paths.append(path)
    paths = [path for path in paths if (path / "Path of Building-PoE2.exe").is_file()]
else:
    sys.exit("POB_WINE_UNSUPPORTED")
print(json.dumps([str(path) for path in paths]))
''';

const _installLinuxBridge = '''
import sys
from pob_poe2_mcp import bridge
from pob_poe2_mcp.errors import EngineError

if not hasattr(bridge, "installed_bridge_dirs"):
    sys.exit("POB_WINE_UNSUPPORTED")
try:
    bridge.install_bridge(sys.argv[1])
except (EngineError, OSError) as error:
    sys.exit(str(error))
''';

const _checkBridge = '''
import json
import sys
from pob_poe2_mcp.api import BuildAPI
from pob_poe2_mcp.errors import EngineError

try:
    with BuildAPI(mode="app", pob_dir=sys.argv[1], timeout=5) as api:
        path = None
        if "getBuildDirectory" in api.capabilities.get("methods", []):
            path = api.call("getBuildDirectory")["directory"]
        print(json.dumps(path))
except (EngineError, OSError) as error:
    sys.exit(str(error))
''';

const _windowApi = r'''
function Show-PobWindow($handle, $command) {
    Add-Type -Name PobWindow -Namespace Pob -MemberDefinition @'
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(System.IntPtr window, int command);
'@
    [void][Pob.PobWindow]::ShowWindowAsync($handle, $command)
}
''';

// Если PoB ждёт ответа на запрос сохранения, окно нужно развернуть.
const _closeWindow =
    _windowApi +
    r'''
function Close-PobWindow($window) {
    try {
        if (!$window.HasExited -and $window.CloseMainWindow()) {
            if ($window.WaitForExit(1000)) { return }
            try {
                $window.Refresh()
                $restore = 9
                Show-PobWindow $window.MainWindowHandle $restore
            } catch {}
            [void]$window.WaitForExit(44000)
        }
    } catch {
        if (!$window.HasExited) { exit 2 }
    }
    if (!$window.HasExited) { exit 2 }
}
''';

const _restartPobWindow =
    _closeWindow +
    r'''
$ErrorActionPreference = 'Stop'
$target = $env:POB2_WINDOW_EXE
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
if ($windows.Count -eq 1) { Close-PobWindow $windows[0] }
try {
    $launch = $env:POB2_LAUNCH_EXE
    $started = Start-Process -FilePath $launch -WorkingDirectory ([IO.Path]::GetDirectoryName($launch)) -WindowStyle Minimized -PassThru
    @{pid = $started.Id; started = $started.StartTime.ToUniversalTime().Ticks} | ConvertTo-Json -Compress
} catch {
    exit 4
}
exit 0
''';

const _findLaunchedPob = r'''
$ErrorActionPreference = 'Stop'
try {
    $window = [Diagnostics.Process]::GetProcessById([int]$env:POB2_WINDOW_PID)
} catch [ArgumentException] {
    exit 0
}
try {
    if ($window.HasExited -or $window.StartTime.ToUniversalTime().Ticks -ne [long]$env:POB2_WINDOW_STARTED) { exit 0 }
    if (![string]::Equals($window.MainModule.FileName, $env:POB2_WINDOW_EXE, [StringComparison]::OrdinalIgnoreCase)) { exit 0 }
} catch {
    if ($window.HasExited) { exit 0 }
    exit 3
}
''';

const _closeLaunchedPob =
    _closeWindow +
    r'''
Close-PobWindow $window
exit 0
''';

// PoB может закрыться между проверкой моста и сворачиванием.
const _minimizePobWindow =
    _windowApi +
    r'''
try {
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $minimizeWithoutActivation = 7
    while (!$window.HasExited -and $timer.ElapsedMilliseconds -lt 5000) {
        $window.Refresh()
        if ($window.MainWindowHandle -ne [IntPtr]::Zero) {
            Show-PobWindow $window.MainWindowHandle $minimizeWithoutActivation
            break
        }
        Start-Sleep -Milliseconds 50
    }
} catch {}
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
