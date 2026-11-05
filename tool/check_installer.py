"""Проверить готовый установщик и подтверждение первого запуска Flutter."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time

from release import ROOT, filename, version


def run(*args, **kwargs):
    subprocess.run([str(value) for value in args], check=True, **kwargs)


def wait_file(path, expected, timeout=45):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if path.is_file() and path.read_text().strip() == expected:
            return
        time.sleep(.2)
    raise RuntimeError(f'Не подтверждён запуск: {path}')


def check(target):
    number = version()
    package = ROOT / 'build/packages' / filename(number, target)
    with tempfile.TemporaryDirectory(prefix='pob2-install-check-') as temporary:
        base = Path(temporary)
        install = base / 'PoB II'
        data = base / 'data'
        environment = dict(os.environ, POB2_UI_HOME=str(data))
        if target == 'macos-arm64':
            mount = base / 'mount'
            mount.mkdir()
            run('hdiutil', 'attach', package, '-readonly', '-nobrowse', '-mountpoint', mount)
            try:
                bundle = base / 'PoB II.app'
                run('ditto', mount / bundle.name, bundle)
            finally:
                run('hdiutil', 'detach', mount)
            run('codesign', '--verify', '--deep', '--strict', bundle)
            process = subprocess.Popen([str(bundle / 'Contents/MacOS/PoB II'), '--pob-update-token', '1' * 32], env=environment)
            try:
                wait_file(data / 'updates' / ('health-' + '1' * 32 + '.ready'), 'ready')
            finally:
                process.terminate()
                process.wait(timeout=15)
            return
        if target == 'windows-x64':
            run(package, '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-', '/DIR=' + str(install), env=environment)
            binary = 'pob2_ui.exe'
        else:
            run('/bin/sh', package, '--prefix', install, env=environment)
            binary = 'pob2-ui'
        marker = json.loads((install / 'pob2-install.json').read_text())
        assert marker['id'] == 'dev.hecatoncheir.pob2Ui'
        process = subprocess.Popen([str(install / binary)], env=environment)
        wait_file(install / 'active-version', number)
        process.wait(timeout=45)
        # Сам Flutter работает отдельно от короткоживущего запускателя.
        # Завершаем только процессы этого временного каталога.
        if target == 'windows-x64':
            script = "Get-Process pob2_ui -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($env:POB2_CHECK_ROOT) } | Stop-Process -Force"
            run('powershell', '-NoProfile', '-Command', script, env=dict(environment, POB2_CHECK_ROOT=str(install)))
        else:
            processes = subprocess.check_output(['ps', '-eo', 'pid=,args='], text=True)
            expected = str(install / 'versions' / number / 'pob2_ui')
            for line in processes.splitlines():
                pieces = line.strip().split(None, 1)
                if len(pieces) == 2 and pieces[1].startswith(expected + ' '):
                    os.kill(int(pieces[0]), 15)
        time.sleep(1)
    print(f'{target}: установщик и настоящий запуск проверены')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', required=True)
    check(parser.parse_args().target)
