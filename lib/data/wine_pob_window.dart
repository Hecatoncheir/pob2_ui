import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'process_service.dart';

class WinePobWindow {
  WinePobWindow._(this._process, this._python, this._name, this._token) {
    unawaited(_process.stdout.drain<void>());
    unawaited(_process.stderr.drain<void>());
    unawaited(_process.exitCode.then((_) => _exited = true));
  }

  final Process _process;
  final String _python;
  final String _name;
  final String _token;
  bool _exited = false;

  static Future<WinePobWindow> start(
    File executable,
    String prefix, {
    required Future<void> Function() prepareBridge,
  }) async {
    final python = await ProcessService().python();
    final token = List.generate(
      24,
      (_) => _random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    final name = executable.uri.pathSegments.last;
    final probe = await _control(python, 'check', name);
    switch (probe.exitCode) {
      case 0:
        break;
      case 2:
        throw StateError(
          'PoB уже открыт без связи с мостом. Перезапустите его один раз.',
        );
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
    return WinePobWindow._(process, python, name, token);
  }

  static final _random = Random.secure();

  Future<void> minimize() async {
    if (!_exited) await _control(_python, 'minimize', _name, _token);
  }

  Future<void> close() async {
    if (_exited) return;
    final result = await _control(_python, 'close', _name, _token);
    if (result.exitCode != 0 && !_exited) throw StateError(_closePending);
    if (await _wait(const Duration(seconds: 1))) return;
    await _control(_python, 'restore', _name, _token);
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

  static Future<ProcessResult> _control(
    String python,
    String action,
    String name, [
    String token = '',
  ]) => Process.run(python, [
    '-X',
    'utf8',
    '-c',
    _windowControl,
    action,
    name,
    token,
  ]);
}

const _ownerVariable = 'POB2_UI_WINE_OWNER';
const _closePending =
    'PoB ещё открыт. Сохраните сборку и завершите закрытие в PoB.';

// В Wine свойство _NET_WM_PID содержит PID процесса Linux.
const _windowControl = r'''
import ctypes as c
from pathlib import Path
import sys

owner_variable = b"POB2_UI_WINE_OWNER="
action, executable_name, token = sys.argv[1:]
try:
    x11 = c.CDLL("libX11.so.6")
except OSError:
    sys.exit(1)

pointer, ulong, int32 = c.c_void_p, c.c_ulong, c.c_int


def bind(name, result, *arguments):
    function = getattr(x11, name)
    function.restype = result
    function.argtypes = arguments
    return function


open_display = bind("XOpenDisplay", pointer, c.c_char_p)
close_display = bind("XCloseDisplay", int32, pointer)
root_window = bind("XDefaultRootWindow", ulong, pointer)
default_screen = bind("XDefaultScreen", int32, pointer)
intern = bind("XInternAtom", ulong, pointer, c.c_char_p, int32)
free = bind("XFree", int32, pointer)
sync = bind("XSync", int32, pointer, int32)
iconify = bind("XIconifyWindow", int32, pointer, ulong, int32)
raise_window = bind("XMapRaised", int32, pointer, ulong)
send = bind("XSendEvent", int32, pointer, ulong, int32, c.c_long, pointer)
get_property = bind(
    "XGetWindowProperty", int32, pointer, ulong, ulong, c.c_long, c.c_long,
    int32, ulong, c.POINTER(ulong), c.POINTER(int32), c.POINTER(ulong),
    c.POINTER(ulong), c.POINTER(pointer),
)
error_handler_type = c.CFUNCTYPE(int32, pointer, pointer)
ignore_xerror = error_handler_type(lambda display, event: 0)
bind("XSetErrorHandler", pointer, error_handler_type)(ignore_xerror)


class ClientMessage(c.Structure):
    _fields_ = [
        ("type", int32), ("serial", ulong), ("send_event", int32),
        ("display", pointer), ("window", ulong), ("message_type", ulong),
        ("format", int32), ("data", c.c_long * 5),
    ]


class Event(c.Union):
    _fields_ = [("client", ClientMessage), ("padding", c.c_long * 24)]


display = open_display(None)
if not display:
    sys.exit(1)


def atom(name):
    return intern(display, name, 0)


def property_values(window, key, expected_type, limit):
    kind, form, count, trailing, data = ulong(), int32(), ulong(), ulong(), pointer()
    result = get_property(
        display, window, atom(key), 0, limit, 0, expected_type,
        c.byref(kind), c.byref(form), c.byref(count), c.byref(trailing), c.byref(data),
    )
    try:
        if result or not data or kind.value != expected_type or form.value != 32:
            return ()
        return tuple(c.cast(data, c.POINTER(ulong))[:count.value])
    finally:
        if data:
            free(data)


def matches(window):
    ids = property_values(window, b"_NET_WM_PID", 6, 1)
    if len(ids) != 1 or ids[0] <= 0:
        return False
    process = Path("/proc") / str(ids[0])
    try:
        command = (process / "cmdline").read_bytes().split(b"\0", 1)[0]
        name = command.replace(b"\\", b"/").rsplit(b"/", 1)[-1].lower()
        if name != executable_name.encode().lower():
            return False
        if action == "check":
            return True
        entries = (process / "environ").read_bytes().split(b"\0")
        return owner_variable + token.encode() in entries
    except OSError:
        return False


def close_window(window):
    delete = atom(b"WM_DELETE_WINDOW")
    if delete not in property_values(window, b"WM_PROTOCOLS", 4, 64):
        return False
    event = Event()
    event.client = ClientMessage(
        33, 0, 1, display, window, atom(b"WM_PROTOCOLS"), 32, (c.c_long * 5)(delete)
    )
    return bool(send(display, window, 0, 0, c.byref(event)))


try:
    root = root_window(display)
    if not property_values(root, b"_NET_SUPPORTING_WM_CHECK", 33, 1):
        sys.exit(1)
    windows = [window for window in property_values(root, b"_NET_CLIENT_LIST", 33, 4096) if matches(window)]
    if action == "check":
        sys.exit(2 if windows else 0)
    if action == "minimize":
        for window in windows:
            iconify(display, window, default_screen(display))
    elif action == "restore":
        for window in windows:
            raise_window(display, window)
    elif action == "close":
        if not any(close_window(window) for window in windows):
            sys.exit(1)
    else:
        sys.exit(1)
    sync(display, 0)
finally:
    close_display(display)
''';
