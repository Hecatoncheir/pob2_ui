"""Проверка настоящих диалогов XML в отдельном профиле Windows и Linux."""

import argparse
import ctypes as C
from ctypes import wintypes as W
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import xml.etree.ElementTree as ET

from check_installer import FIXTURES, prepare_profile, run_build_check


def wait_for(read, message, timeout=45):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        value = read()
        if value:
            return value
        time.sleep(.1)
    raise RuntimeError(message)


class WindowsUi:
    def __init__(self, process):
        from check_window_state import USER, window_for
        self.user = USER
        self.process = process
        self.window = wait_for(lambda: window_for(process), 'Окно Windows не появилось')
        self.user.SetForegroundWindow.argtypes = [W.HWND]
        self.user.GetClassNameW.argtypes = [W.HWND, W.LPWSTR, C.c_int]
        self.user.GetForegroundWindow.restype = W.HWND
        self.user.MapVirtualKeyW.argtypes = [W.UINT, W.UINT]
        self.user.keybd_event.argtypes = [W.BYTE, W.BYTE, W.DWORD, C.c_size_t]
        self.user.AttachThreadInput.argtypes = [W.DWORD, W.DWORD, W.BOOL]

    def chord(self, modifier, key):
        codes = {'control': 0x11, 'alt': 0x12, 'escape': 0x1B, 'enter': 0x0D}
        if modifier:
            self._key(codes[modifier], False)
        code = codes.get(key, ord(key.upper()) if len(key) == 1 else 0)
        self._key(code, False)
        self._key(code, True)
        if modifier:
            self._key(codes[modifier], True)

    def _key(self, code, released):
        scan = self.user.MapVirtualKeyW(code, 0)
        self.user.keybd_event(code, scan, 2 if released else 0, 0)

    def focus(self, window):
        self.user.ShowWindow(window, 9)
        self.user.SetForegroundWindow(window)
        if self.user.GetForegroundWindow() != window:
            self._attach_focus(window)
        time.sleep(.2)
        if self.user.GetForegroundWindow() != window:
            raise RuntimeError('Windows не предоставила тесту фокус окна')

    def _attach_focus(self, window):
        current = C.WinDLL('kernel32').GetCurrentThreadId()
        threads = {
            self.user.GetWindowThreadProcessId(self.user.GetForegroundWindow(), None),
            self.user.GetWindowThreadProcessId(window, None),
        } - {0, current}
        for thread in threads:
            self.user.AttachThreadInput(current, thread, True)
        try:
            self.user.SetForegroundWindow(window)
        finally:
            for thread in threads:
                self.user.AttachThreadInput(current, thread, False)

    def dialog(self):
        from check_window_state import CALLBACK
        result = []

        @CALLBACK
        def visit(window, _):
            pid = W.DWORD()
            self.user.GetWindowThreadProcessId(window, C.byref(pid))
            if pid.value != self.process.pid or not self.user.IsWindowVisible(window):
                return True
            name = C.create_unicode_buffer(100)
            self.user.GetClassNameW(window, name, len(name))
            if name.value == '#32770' and window != self.window:
                result.append(window)
            return True

        self.user.EnumWindows(visit, 0)
        return result[0] if result else None

    def choose(self, window, file):
        self.focus(window)
        self.chord('alt', 'n')
        self.chord('control', 'a')
        self._text(str(file))
        self.chord(None, 'enter')

    def _text(self, text):
        class Key(C.Structure):
            _fields_ = [('vk', W.WORD), ('scan', W.WORD), ('flags', W.DWORD),
                        ('time', W.DWORD), ('extra', C.c_size_t)]

        class Payload(C.Union):
            _fields_ = [('key', Key), ('padding', C.c_uint64 * 4)]

        class Input(C.Structure):
            _fields_ = [('kind', W.DWORD), ('payload', Payload)]

        self.user.SendInput.argtypes = [W.UINT, C.POINTER(Input), C.c_int]
        for char in text:
            events = (Input * 2)(
                Input(1, Payload(key=Key(0, ord(char), 4, 0, 0))),
                Input(1, Payload(key=Key(0, ord(char), 6, 0, 0))),
            )
            if self.user.SendInput(2, events, C.sizeof(Input)) != 2:
                raise RuntimeError('Windows отклонила ввод пути XML')


class XWindowAttributes(C.Structure):
    _fields_ = [
        ('x', C.c_int), ('y', C.c_int), ('width', C.c_int), ('height', C.c_int),
        ('border', C.c_int), ('depth', C.c_int), ('visual', C.c_void_p), ('root', C.c_ulong),
        ('kind', C.c_int), ('bit_gravity', C.c_int), ('win_gravity', C.c_int),
        ('backing_store', C.c_int), ('backing_planes', C.c_ulong), ('backing_pixel', C.c_ulong),
        ('save_under', C.c_int), ('colormap', C.c_ulong), ('map_installed', C.c_int),
        ('map_state', C.c_int), ('all_events', C.c_long), ('your_events', C.c_long),
        ('propagate', C.c_long), ('override_redirect', C.c_int), ('screen', C.c_void_p),
    ]


class LinuxUi:
    def __init__(self, process):
        self.x = C.CDLL('libX11.so.6')
        self.xt = C.CDLL('libXtst.so.6')
        self.x.XOpenDisplay.restype = C.c_void_p
        self.display = self.x.XOpenDisplay(None)
        if not self.display:
            raise RuntimeError('Не найден DISPLAY для окна GTK')
        self.x.XDefaultRootWindow.argtypes = [C.c_void_p]
        self.x.XDefaultRootWindow.restype = C.c_ulong
        self.root = self.x.XDefaultRootWindow(self.display)
        self.x.XQueryTree.argtypes = [C.c_void_p, C.c_ulong, C.POINTER(C.c_ulong),
                                     C.POINTER(C.c_ulong), C.POINTER(C.POINTER(C.c_ulong)), C.POINTER(C.c_uint)]
        self.x.XFetchName.argtypes = [C.c_void_p, C.c_ulong, C.POINTER(C.c_void_p)]
        self.x.XInternAtom.argtypes = [C.c_void_p, C.c_char_p, C.c_int]
        self.x.XInternAtom.restype = C.c_ulong
        self.x.XGetWindowProperty.argtypes = [C.c_void_p, C.c_ulong, C.c_ulong, C.c_long,
                                             C.c_long, C.c_int, C.c_ulong, C.POINTER(C.c_ulong),
                                             C.POINTER(C.c_int), C.POINTER(C.c_ulong),
                                             C.POINTER(C.c_ulong), C.POINTER(C.c_void_p)]
        self.x.XGetWindowAttributes.argtypes = [C.c_void_p, C.c_ulong, C.POINTER(XWindowAttributes)]
        self.x.XSetInputFocus.argtypes = [C.c_void_p, C.c_ulong, C.c_int, C.c_ulong]
        self.x.XKeysymToKeycode.argtypes = [C.c_void_p, C.c_ulong]
        self.x.XChangeKeyboardMapping.argtypes = [C.c_void_p, C.c_int, C.c_int, C.POINTER(C.c_ulong), C.c_int]
        self.x.XSync.argtypes = [C.c_void_p, C.c_int]
        self.x.XFree.argtypes = [C.c_void_p]
        self.xt.XTestFakeKeyEvent.argtypes = [C.c_void_p, C.c_uint, C.c_int, C.c_ulong]
        self.process = process
        self.window = wait_for(self._process_window, 'Окно GTK не появилось')

    def _windows(self):
        root, parent = C.c_ulong(), C.c_ulong()
        children, count = C.POINTER(C.c_ulong)(), C.c_uint()
        self.x.XQueryTree(self.display, self.root, C.byref(root), C.byref(parent), C.byref(children), C.byref(count))
        rows = []
        for window in list(children[:count.value]):
            if not self._shown(window):
                continue
            name = C.c_void_p()
            self.x.XFetchName(self.display, window, C.byref(name))
            title = C.string_at(name).decode('utf-8', errors='replace') if name.value else ''
            rows.append((window, title))
            if name.value:
                self.x.XFree(name)
        if children:
            self.x.XFree(children)
        return rows

    def _process_window(self):
        atom = self.x.XInternAtom(self.display, b'_NET_WM_PID', False)
        for window, _ in self._windows():
            actual, count, remaining = C.c_ulong(), C.c_ulong(), C.c_ulong()
            format_ = C.c_int()
            data = C.c_void_p()
            self.x.XGetWindowProperty(self.display, window, atom, 0, 1, False, 6,
                                      C.byref(actual), C.byref(format_), C.byref(count),
                                      C.byref(remaining), C.byref(data))
            pid = C.cast(data, C.POINTER(C.c_ulong))[0] if count.value else None
            if data.value:
                self.x.XFree(data)
            if pid == self.process.pid:
                return window
        return None

    def _shown(self, window):
        attributes = XWindowAttributes()
        self.x.XGetWindowAttributes(self.display, window, C.byref(attributes))
        return attributes.map_state == 2 and attributes.width > 100 and attributes.height > 100

    def _find(self, title):
        return next((window for window, name in self._windows() if title.lower() in name.lower()), None)

    def focus(self, window):
        self.x.XSetInputFocus(self.display, window, 1, 0)
        self.x.XSync(self.display, False)
        time.sleep(.2)

    def _key(self, code, down):
        self.xt.XTestFakeKeyEvent(self.display, code, down, 0)
        self.x.XSync(self.display, False)

    def chord(self, modifier, key):
        symbols = {'control': 0xFFE3, 'escape': 0xFF1B, 'enter': 0xFF0D}
        code = self.x.XKeysymToKeycode(self.display, symbols.get(key, ord(key) if len(key) == 1 else 0))
        control = self.x.XKeysymToKeycode(self.display, symbols['control'])
        if modifier:
            self._key(control, True)
        self._key(code, True)
        self._key(code, False)
        if modifier:
            self._key(control, False)

    def dialog(self):
        return self._find('Open') or self._find('Save')

    def choose(self, window, file):
        self.focus(window)
        self.chord('control', 'l')
        time.sleep(.3)
        self.chord('control', 'a')
        for char in str(file):
            value = ord(char)
            symbol = value if value < 256 else value | 0x1000000
            symbols = (C.c_ulong * 2)(symbol, symbol)
            # Два явных символа сохраняют регистр имени без автоматической смены регистра Xlib.
            self.x.XChangeKeyboardMapping(self.display, 255, 2, symbols, 1)
            self.x.XSync(self.display, False)
            time.sleep(.02)
            self._key(255, True)
            self._key(255, False)
        self.chord(None, 'enter')


def open_dialog(ui, key):
    def trigger():
        dialog = ui.dialog()
        if dialog:
            return dialog
        ui.focus(ui.window)
        ui.chord('control', key)
        time.sleep(1)
        return ui.dialog()
    dialog = wait_for(trigger, f'Нативный диалог Ctrl+{key.upper()} не появился', timeout=180)
    print(f'Открыт нативный диалог Ctrl+{key.upper()}', flush=True)
    return dialog


def allocation(file):
    root = ET.parse(file).getroot()
    specs = root.find('Tree').findall('Spec')
    spec = specs[int(root.find('Tree').get('activeSpec', '1')) - 1]
    return {name: set((spec if name == 'nodes' else spec.find(name)).get('nodes', '').split(','))
            for name in ('nodes', 'WeaponSet1', 'WeaponSet2')}


def check(binary, components):
    with tempfile.TemporaryDirectory(prefix='pob2-native-') as temporary:
        root = Path(temporary).resolve()
        prepare_profile(root, components)
        environment = dict(os.environ, POB2_UI_HOME=str(root), POB2_UI_CHECK_FIXTURE=str(FIXTURES / 'witch_fireball.xml'))
        environment.pop('POB2_UI_CHECK_CODE', None)
        run_build_check(binary, root, environment, 'save')
        (root / 'language.json').write_text('{"schema":1,"language":"en"}', encoding='utf-8')
        source = root / 'Ведьма оружие.xml'
        source.write_bytes((FIXTURES / 'witch_weapon_paths.xml').read_bytes())
        target = root / 'Ведьма сохранена.xml'
        process = subprocess.Popen([str(binary)], env=environment, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            ui = WindowsUi(process) if sys.platform == 'win32' else LinuxUi(process)
            dialog = open_dialog(ui, 'o')
            ui.focus(dialog)
            ui.chord(None, 'escape')
            wait_for(lambda: not ui.dialog(), 'Отмена диалога не завершилась')
            ui.choose(open_dialog(ui, 'o'), source)
            wait_for(lambda: not ui.dialog(), 'XML не открылся через нативный диалог')
            time.sleep(8)
            ui.choose(open_dialog(ui, 's'), target)
            wait_for(lambda: target.is_file(), 'XML не сохранён через нативный диалог')
            assert allocation(source) == allocation(target), 'Диалоги изменили распределение I/II'
            ui.choose(open_dialog(ui, 'o'), target)
            wait_for(lambda: not ui.dialog(), 'Сохранённый XML не открылся')
            print('Нативные Ctrl+O/Ctrl+S, отмена, кириллица и пробелы в пути, XML I/II проверены.', flush=True)
        finally:
            process.terminate()
            process.wait(timeout=20)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--components', type=Path, required=True)
    options = parser.parse_args()
    check(options.binary.resolve(), options.components.resolve())
