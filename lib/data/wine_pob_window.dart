import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'process_service.dart';

class WinePobWindow {
  WinePobWindow._(this._process, this._control, this._name, this._token) {
    unawaited(_process.stdout.drain<void>());
    unawaited(_process.stderr.drain<void>());
    unawaited(_process.exitCode.then((_) => _exited = true));
  }

  final Process _process;
  final Future<int> Function(String, String, String) _control;
  final String _name;
  final String _token;
  bool _exited = false;

  static Future<WinePobWindow?> start(
    File executable,
    String prefix, {
    required String engineExecutable,
    required Future<void> Function() prepareBridge,
  }) async {
    final token = List.generate(
      24,
      (_) => _random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    final name = executable.uri.pathSegments.last;
    Future<int> control(String action, String name, String token) =>
        _engineControl(engineExecutable, action, name, token);
    final probe = await control('check', name, '');
    switch (probe) {
      case 0:
        break;
      case 2:
        await prepareBridge();
        return null;
      default:
        throw StateError(
          'Для управления окном PoB через Wine нужен X11 или XWayland.',
        );
    }
    await ProcessService().run('wine', [
      '--version',
    ], timeout: const Duration(seconds: 10));
    await prepareBridge();
    final process = await Process.start(
      'wine',
      ['start', '/min', '/wait', '/unix', executable.absolute.path],
      workingDirectory: executable.parent.path,
      environment: {
        'WINEPREFIX': prefix,
        'WAYLAND_DISPLAY': '',
        _ownerVariable: token,
      },
    );
    return WinePobWindow._(process, control, name, token);
  }

  static final _random = Random.secure();

  Future<void> minimize() async {
    if (!_exited) await _control('minimize', _name, _token);
  }

  Future<void> close() async {
    if (_exited) return;
    final result = await _control('close', _name, _token);
    if (result != 0 && !_exited) throw StateError(_closePending);
    if (await _wait(const Duration(seconds: 1))) return;
    await _control('restore', _name, _token);
    if (!await _wait(const Duration(seconds: 44))) {
      throw StateError(_closePending);
    }
  }

  Future<bool> _wait(Duration duration) async {
    try {
      await _process.exitCode.timeout(duration);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  static Future<int> _engineControl(
    String engine,
    String action,
    String name,
    String token,
  ) async {
    final process = await Process.run(
      engine,
      ['pob-window-control', '--executable', name, action],
      environment: {_ownerVariable: token},
    );
    if (process.exitCode != 0) return 1;
    final reply = jsonDecode(process.stdout as String);
    return switch ((action, reply)) {
      ('check', {'found': true}) => 2,
      ('close', {'found': false}) => 1,
      (_, {'found': bool()}) => 0,
      _ => 1,
    };
  }
}

const _ownerVariable = 'POB2_UI_WINE_OWNER';
const _closePending =
    'PoB ещё открыт. Сохраните сборку и завершите закрытие в PoB.';
