"""Проверить DLL после последовательной Release- и Debug-сборки Windows."""

import argparse
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).digest()


def check(sdk):
    for mode, suffix in [('Debug', ''), ('Release', '-release')]:
        actual = ROOT / 'build/windows/x64/runner' / mode / 'flutter_windows.dll'
        expected = sdk / ('bin/cache/artifacts/engine/windows-x64' + suffix) / 'flutter_windows.dll'
        if digest(actual) != digest(expected):
            raise ValueError(f'{mode}: DLL движка не соответствует конфигурации SDK')
    print('Debug и Release содержат соответствующие DLL движка Flutter')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--flutter-root', type=Path, required=True)
    check(parser.parse_args().flutter_root)
