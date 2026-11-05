"""Проверить готовый установщик и подтверждение первого запуска Flutter."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

from release import ROOT, dart_executable, filename, version


def run(*args, **kwargs):
    subprocess.run([str(value) for value in args], check=True, **kwargs)


def wait_file(path, expected, timeout=45):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if path.is_file() and path.read_text().strip() == expected:
            return
        time.sleep(.2)
    raise RuntimeError(f'Не подтверждён запуск: {path}')


def stop_versions(install, environment):
    if os.name == 'nt':
        script = "Get-Process pob2_ui -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($env:POB2_CHECK_ROOT) } | Stop-Process -Force"
        run(shutil.which('pwsh') or 'powershell', '-NoProfile', '-Command', script, env=dict(environment, POB2_CHECK_ROOT=str(install)))
    else:
        processes = subprocess.check_output(['ps', '-eo', 'pid=,args='], text=True)
        expected = str(install / 'versions') + '/'
        for line in processes.splitlines():
            pieces = line.strip().split(None, 1)
            if len(pieces) == 2 and pieces[1].startswith(expected):
                os.kill(int(pieces[0]), 15)
    time.sleep(1)


def stop_macos(bundle):
    expected = str(bundle / 'Contents/MacOS/PoB II')
    processes = subprocess.check_output(['ps', '-eo', 'pid=,args='], text=True)
    for line in processes.splitlines():
        pieces = line.strip().split(None, 1)
        if len(pieces) == 2 and pieces[1].startswith(expected):
            os.kill(int(pieces[0]), 15)
    time.sleep(1)


def mount_macos(package, base):
    mount = base / 'mount'
    mount.mkdir()
    run('hdiutil', 'attach', package, '-readonly', '-nobrowse', '-mountpoint', mount)
    bundle = base / 'PoB II.app'
    try:
        run('ditto', mount / bundle.name, bundle)
    finally:
        run('hdiutil', 'detach', mount)
    run('codesign', '--verify', '--deep', '--strict', bundle)
    return bundle


def failed_macos_package(bundle, base):
    staging = base / 'failed-dmg'
    staging.mkdir()
    candidate = staging / bundle.name
    run('ditto', bundle, candidate)
    source = base / 'failed.c'
    source.write_text('#include <unistd.h>\nint main(void) { sleep(60); return 0; }\n')
    run('clang', source, '-o', candidate / 'Contents/MacOS/PoB II')
    run('codesign', '--force', '--deep', '--sign', '-', candidate)
    package = base / 'failed.dmg'
    run('hdiutil', 'create', '-volname', 'PoB II', '-srcfolder', staging, '-format', 'UDZO', package)
    return package


def check_macos(package, base, data, environment):
    bundle = mount_macos(package, base)
    executable = bundle / 'Contents/MacOS/PoB II'
    process = subprocess.Popen([str(executable), '--pob-update-token', '1' * 32], env=environment)
    try:
        wait_file(data / 'updates' / ('health-' + '1' * 32 + '.ready'), 'ready')
    finally:
        process.terminate()
        process.wait(timeout=15)
    helper = bundle / 'Contents/Resources/update-macos.sh'
    arguments = ['/bin/sh', helper, package, bundle, str(process.pid), version()]
    run(*arguments, env=environment, timeout=90)
    assert Path(str(bundle) + '.previous').is_dir()
    stop_macos(bundle)
    original_digest = hashlib.sha256(executable.read_bytes()).digest()
    arguments[2] = failed_macos_package(bundle, base)
    failed = subprocess.run([str(value) for value in arguments], env=environment, timeout=90)
    assert failed.returncode != 0
    assert hashlib.sha256(executable.read_bytes()).digest() == original_digest
    stop_macos(bundle)
    print('macos-arm64: DMG, запуск, замена приложения и откат проверены')


def check(target):
    number = version()
    package = ROOT / 'build/packages' / filename(number, target)
    with tempfile.TemporaryDirectory(prefix='pob2-install-check-') as temporary:
        base = Path(temporary).resolve()
        install = base / 'PoB II'
        data = base / 'data'
        environment = dict(os.environ, POB2_UI_HOME=str(data))
        if target == 'macos-arm64':
            check_macos(package, base, data, environment)
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
        stop_versions(install, environment)
        # Отсутствующий кандидат должен вернуть рабочую версию.
        (install / 'pending-version').write_text('999.0.0')
        run(install / binary, env=environment)
        assert (install / 'active-version').read_text().strip() == number
        assert not (install / 'pending-version').exists()
        assert '999.0.0' in (install / 'update.log').read_text(encoding='utf-8')
        stop_versions(install, environment)
        failed = install / 'versions/999.0.2'
        failed.mkdir()
        run(dart_executable(), 'compile', 'exe', ROOT / 'tool/fixtures/failed_candidate.dart', '-o', failed / ('pob2_ui.exe' if os.name == 'nt' else 'pob2_ui'))
        (install / 'pending-version').write_text('999.0.2')
        run(install / binary, env=environment, timeout=45)
        assert (install / 'active-version').read_text().strip() == number
        assert not (install / 'pending-version').exists()
        assert '999.0.2' in (install / 'update.log').read_text(encoding='utf-8')
        stop_versions(install, environment)
        # Проверяем протокол переключения на том же настоящем Flutter-бандле.
        candidate = '999.0.1'
        shutil.copytree(install / 'versions' / number, install / 'versions' / candidate, symlinks=True)
        (install / 'pending-version').write_text(candidate)
        run(install / binary, env=environment)
        assert (install / 'active-version').read_text().strip() == candidate
        assert (install / 'previous-version').read_text().strip() == number
        stop_versions(install, environment)
        run(install / binary, '--rollback', env=environment)
        assert (install / 'active-version').read_text().strip() == number
        stop_versions(install, environment)
    print(f'{target}: установщик и настоящий запуск проверены')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', required=True)
    check(parser.parse_args().target)
