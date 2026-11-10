"""Настоящее окно Windows: геометрия и сохранение данных перед закрытием."""

import ctypes as C
import argparse
from ctypes import wintypes as W
import os
from pathlib import Path
import subprocess
import stat
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
USER = C.WinDLL('user32', use_last_error=True)
CALLBACK = C.WINFUNCTYPE(W.BOOL, W.HWND, W.LPARAM)
USER.EnumWindows.argtypes = [CALLBACK, W.LPARAM]
USER.GetWindowThreadProcessId.argtypes = [W.HWND, C.POINTER(W.DWORD)]
USER.IsWindowVisible.argtypes = [W.HWND]
USER.IsZoomed.argtypes = [W.HWND]
USER.SetWindowPos.argtypes = [W.HWND, W.HWND, C.c_int, C.c_int, C.c_int, C.c_int, W.UINT]
USER.GetWindowRect.argtypes = [W.HWND, C.POINTER(W.RECT)]
USER.PostMessageW.argtypes = [W.HWND, W.UINT, W.WPARAM, W.LPARAM]
USER.ShowWindow.argtypes = [W.HWND, C.c_int]


def window_for(process):
    result = []
    @CALLBACK
    def visit(window, _):
        pid = W.DWORD()
        USER.GetWindowThreadProcessId(window, C.byref(pid))
        if pid.value == process.pid and USER.IsWindowVisible(window):
            result.append(window)
        return True
    USER.EnumWindows(visit, 0)
    return result[0] if result else None


def start(binary, root):
    # Проверка окна использует локальный английский интерфейс без загрузки игровых переводов.
    (root / 'language.json').write_text('{"schema":1,"language":"en"}', encoding='utf-8')
    process = subprocess.Popen([str(binary)], env={**os.environ, 'POB2_UI_HOME': str(root)}, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(200):
        window = window_for(process)
        if window: return process, window
        if process.poll() is not None: raise ValueError('Приложение завершилось до первого кадра')
        time.sleep(.1)
    process.kill()
    raise ValueError('Окно приложения не появилось')


def close(process, window):
    USER.PostMessageW(window, 0x10, 0, 0)
    process.wait(timeout=15)


def rectangle(window):
    rect = W.RECT()
    USER.GetWindowRect(window, C.byref(rect))
    return rect.left, rect.top, rect.right, rect.bottom


def check(binary, root):
    process, window = start(binary, root)
    try:
        USER.SetWindowPos(window, None, 73, 85, 1000, 740, 0x14)
        time.sleep(.4)
        expected = rectangle(window)
        close(process, window)
        assert (root / 'window-state.bin').is_file(), 'Положение не сохранено'
        assert (root / 'draft.xml').is_file(), 'Закрытие обошло сохранение Flutter'
        process, window = start(binary, root)
        assert rectangle(window) == expected, (rectangle(window), expected)
        USER.ShowWindow(window, 3)
        time.sleep(.4)
        close(process, window)
        process, window = start(binary, root)
        assert USER.IsZoomed(window), 'Развёрнутое состояние не восстановлено'
        USER.ShowWindow(window, 9)
        time.sleep(.4)
        assert rectangle(window) == expected, 'Размер обычного окна потерян после разворачивания'
        USER.SetWindowPos(window, None, -30000, -30000, 1000, 740, 0x14)
        close(process, window)
        process, window = start(binary, root)
        x, y, right, bottom = rectangle(window)
        assert right > 0 and bottom > 0 and x < 10000 and y < 10000, 'Окно осталось за пределами экранов'
        close(process, window)
        print('Окно: положение, размер, разворачивание и возврат на доступный экран проверены')
    finally:
        if process.poll() is None:
            process.kill()
            process.wait(timeout=10)


def check_close_guard(binary, root):
    root.mkdir()
    draft = root / 'draft.xml'
    backup = root / 'draft.xml.bak'
    text = '<draft>Проверка сохранения</draft>'
    draft.write_text(text, encoding='utf-8')
    draft.chmod(stat.S_IREAD)
    process, window = start(binary, root)
    try:
        deadline = time.monotonic() + 10
        while not backup.exists():
            USER.PostMessageW(window, 0x10, 0, 0)
            time.sleep(.2)
            assert process.poll() is None, 'Ошибка записи не остановила закрытие'
            if time.monotonic() > deadline:
                raise RuntimeError('Обработчик закрытия не попытался сохранить черновик')
        assert draft.read_text(encoding='utf-8') == text, 'Черновик изменён при отказе записи'
        draft.chmod(stat.S_IREAD | stat.S_IWRITE)
        backup.chmod(stat.S_IREAD | stat.S_IWRITE)
        close(process, window)
        assert draft.read_text(encoding='utf-8') == text, 'Повторное закрытие потеряло текст'
        print('Закрытие: ошибка записи удерживает окно; повтор сохраняет текст и завершает приложение')
    finally:
        for file in (draft, backup):
            if file.exists():
                file.chmod(stat.S_IREAD | stat.S_IWRITE)
        if process.poll() is None:
            process.kill()
            process.wait(timeout=10)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, default=ROOT / 'build/windows/x64/runner/Release/pob2_ui.exe')
    arguments = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='pob2-window-test-') as temporary:
        check(arguments.binary, Path(temporary))
        check_close_guard(arguments.binary, Path(temporary) / 'close-guard')
