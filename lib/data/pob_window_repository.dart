import 'dart:convert';
import 'dart:io';

import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/pob_character.dart';
import 'bundled_engine.dart';
import 'process_service.dart';
import 'wine_pob_window.dart';

typedef _LaunchedPob = ({String path, int pid, int started});

class PobWindowRepository {
  PobWindowRepository({String? engineExecutable})
    : engineExecutable = engineExecutable ?? defaultEngineExecutable();

  final String engineExecutable;
  final _launched = <String, _LaunchedPob>{};
  WinePobWindow? _wineWindow;
  bool _windowBusy = false;

  bool get supported => Platform.isWindows || Platform.isLinux;
  bool get canRestart => Platform.isWindows;

  Future<List<String>> findInstallations(Installation pob) async {
    final result = await _discover();
    return List.unmodifiable((result['paths'] as List).cast<String>());
  }

  Future<JsonMap> _discover() => _native('discover').then(_decode);

  Future<String> _launchDirectory(Installations components) async {
    final result = await _discover();
    if (result['preferred'] case final String preferred) return preferred;
    final paths = (result['paths'] as List).cast<String>();
    if (paths.length == 1) return paths.single;
    final pob = components[Component.pob];
    if (Platform.isWindows && paths.isEmpty && pob != null)
      return pob.directory;
    throw StateError('Выберите установку в разделе «Настроить мост PoB».');
  }

  Future<void> installBridge(Installation pob, String directory) async {
    await _native('install', directory: directory);
  }

  Future<void> restartAndCheckBridge(Installation pob, String directory) =>
      _windowOperation(() => _restartAndCheck(directory));

  Future<void> _restartAndCheck(String directory) async {
    final executable = await _executable(directory);
    final path = await executable.resolveSymbolicLinks();
    await _startAndCheck(directory, executable, path, restart: true);
  }

  Future<void> _startAndCheck(
    String directory,
    File executable,
    String path, {
    required bool restart,
  }) async {
    final key = path.toLowerCase();
    final window = await _startWindow(executable, path, restart: restart);
    if (window != null) _launched[key] = window;
    await _waitUntilReady(directory, alreadyOpen: window == null);
    if (window != null) await _runForWindow(_minimizePobWindow, window);
  }

  Future<void> _waitUntilReady(
    String directory, {
    required bool alreadyOpen,
  }) async {
    if (!await _bridgeReady(directory, alreadyOpen)) {
      throw StateError(
        alreadyOpen
            ? 'PoB уже открыт без связи с мостом. Перезапустите его один раз.'
            : 'PoB запущен, но мост пока не отвечает. Проверьте связь ещё раз.',
      );
    }
  }

  Future<bool> _bridgeReady(String directory, bool alreadyOpen) async {
    final seconds = alreadyOpen ? '5' : '45';
    try {
      await _native(
        'status',
        directory: directory,
        arguments: ['--wait', '${seconds}s'],
      );
      return true;
    } on StateError catch (error) {
      if (!_bridgeUnavailable(error)) rethrow;
      return false;
    }
  }

  Future<void> _ensureBridge(String directory) async {
    await _native('install', directory: directory, arguments: ['--ensure']);
  }

  Future<void> _startWine(String directory, File executable) async {
    final prefix =
        _decode(await _native('wine-prefix', directory: directory))['prefix']
            as String;
    final window = await WinePobWindow.start(
      executable,
      prefix,
      engineExecutable: engineExecutable,
      prepareBridge: () => _ensureBridge(directory),
    );
    if (window != null) _wineWindow = window;
    await _waitUntilReady(directory, alreadyOpen: window == null);
    await window?.minimize();
  }

  Future<void> _closeWine() async {
    await _wineWindow?.close();
    _wineWindow = null;
  }

  Future<void> closeLaunchedWindows() => _windowOperation(() async {
    await _closeWine();
    for (final key in _launched.keys.toList()) {
      await _closeOwned(key);
    }
  });

  Future<void> _closeOwned(String key) async {
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

  Future<T> _windowOperation<T>(Future<T> Function() action) async {
    if (_windowBusy) throw StateError('Дождитесь завершения текущей операции');
    _windowBusy = true;
    try {
      return await action();
    } finally {
      _windowBusy = false;
    }
  }

  Future<File> _executable(String directory) async {
    final root = Directory(directory).absolute.uri;
    const name = 'Path of Building-PoE2.exe';
    const devName = 'Path{space}of{space}Building-PoE2.exe';
    for (final candidate in [
      Uri.encodeComponent(name),
      'runtime/${Uri.encodeComponent(name)}',
      'runtime/${Uri.encodeComponent(devName)}',
    ]) {
      final executable = File.fromUri(root.resolve(candidate));
      if (await executable.exists()) return executable;
    }
    throw const FormatException('Выберите папку с приложением PoB для PoE 2');
  }

  Future<_LaunchedPob?> _startWindow(
    File executable,
    String path, {
    required bool restart,
  }) async {
    final result = await _windowScript(
      _restartPobWindow,
      _launchEnvironment(executable, path, restart: restart),
    );
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
      case 5:
        return null;
      case 6:
        throw StateError(_anotherWindow);
      default:
        throw StateError('Закройте выбранный PoB вручную и повторите запуск.');
    }
  }

  Map<String, String> _launchEnvironment(
    File executable,
    String path, {
    required bool restart,
  }) => {
    'POB2_WINDOW_EXE': path,
    'POB2_LAUNCH_EXE': executable.path,
    'POB2_WINDOW_RESTART': restart ? '1' : '0',
    'POB2_WINDOW_PROBE': '0',
  };

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

  Future<String?> checkBridge(Installation pob, String directory) async {
    try {
      await _native('check', directory: directory);
      return null;
    } on StateError catch (error) {
      final details = _decode(error.message.toString());
      return details['message'] as String;
    }
  }

  Future<String> readXml(Installations components) async =>
      switch (await _windowTool(components, 'pob_export_xml')) {
        {'xml': final String xml} when xml.trim().isNotEmpty => xml,
        _ => throw const FormatException('Lua не вернул XML сборки'),
      };

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

  Future<String> buildDirectory(Installations components) async {
    final response = await _windowTool(components, 'pob_get_build_directory');
    return switch (response) {
      {'directory': final String directory} when directory.isNotEmpty =>
        directory,
      _ => throw const FormatException('PoB не сообщил путь к папке сборок.'),
    };
  }

  Future<JsonMap> _windowTool(
    Installations components,
    String tool, [
    JsonMap arguments = const {},
  ]) => _windowOperation(() async {
    try {
      return await _readNativeWindow(tool, arguments);
    } on StateError catch (error) {
      if (!_bridgeUnavailable(error) || !supported) rethrow;
    }
    final directory = await _launchDirectory(components);
    final executable = await _executable(directory);
    await _startAutomatically(directory, executable);
    return _readNativeWindow(tool, arguments, directory: directory);
  });

  Future<JsonMap> _readNativeWindow(
    String tool,
    JsonMap arguments, {
    String? directory,
  }) {
    final command = switch (tool) {
      'pob_export_xml' => 'export',
      'pob_get_build_directory' => 'build-directory',
      'pob_list_characters' => 'characters',
      'pob_get_character' => 'character',
      _ => throw ArgumentError.value(tool),
    };
    return _native(
      command,
      directory: directory,
      arguments: [
        if (arguments['name'] case final String name) ...['--name', name],
      ],
    ).then(_decode);
  }

  JsonMap _decode(String value) => jsonDecode(value) as JsonMap;

  Future<String> _native(
    String command, {
    String? directory,
    List<String> arguments = const [],
  }) async {
    try {
      return await ProcessService().run(engineExecutable, [
        'pob-window',
        if (directory != null) ...['--pob-dir', directory],
        ...arguments,
        command,
      ], timeout: const Duration(seconds: 65));
    } on ProcessException catch (error) {
      final match = RegExp(
        r'^([A-Z][A-Z_]+): (.*)',
        multiLine: true,
      ).firstMatch(error.message);
      throw StateError(
        jsonEncode({
          'code': match?.group(1) ?? 'BRIDGE_ERROR',
          'message': match?.group(2) ?? error.message.trim(),
        }),
      );
    }
  }

  Future<void> _startAutomatically(String directory, File executable) async {
    if (Platform.isLinux) {
      await _startWine(directory, executable);
      return;
    }
    final path = await executable.resolveSymbolicLinks();
    final probe = await _windowScript(_restartPobWindow, {
      ..._launchEnvironment(executable, path, restart: false),
      'POB2_WINDOW_PROBE': '1',
    });
    if (probe.exitCode == 6) throw StateError(_anotherWindow);
    if (probe.exitCode != 0 && probe.exitCode != 5) {
      throw StateError('Закройте выбранный PoB вручную и повторите запуск.');
    }
    await _ensureBridge(directory);
    await _startAndCheck(directory, executable, path, restart: false);
  }

  bool _bridgeUnavailable(StateError error) {
    try {
      return switch (jsonDecode(error.message.toString())) {
        {
          'code':
              'BRIDGE_NOT_RUNNING' ||
              'BRIDGE_RESTART_REQUIRED' ||
              'ENGINE_STOPPED',
        } =>
          true,
        _ => false,
      };
    } on FormatException {
      return false;
    }
  }
}

const _closePending =
    'PoB ещё открыт. Сохраните сборку и завершите закрытие в PoB.';
const _anotherWindow =
    'Уже открыта другая установка PoB. Подключите её в разделе «Компоненты».';

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
$restart = $env:POB2_WINDOW_RESTART -eq '1'
$names = if ($restart) { @($name) } else { @($name, 'Path of Building-PoE2', 'Path{space}of{space}Building-PoE2') | Select-Object -Unique }
$processes = $names | ForEach-Object { [Diagnostics.Process]::GetProcessesByName($_) }
foreach ($process in $processes) {
    try {
        if ($process.HasExited -or $process.SessionId -ne $session) { continue }
        $path = $process.MainModule.FileName
        if (!$path) { exit 3 }
        if ([string]::Equals($path, $target, [StringComparison]::OrdinalIgnoreCase)) {
            $windows += $process
        } elseif (!$restart) {
            exit 6
        }
    } catch {
        if (!$process.HasExited) { exit 3 }
    }
}
if ($windows.Count -gt 0 -and !$restart) { exit 5 }
if ($env:POB2_WINDOW_PROBE -eq '1') { exit 0 }
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
