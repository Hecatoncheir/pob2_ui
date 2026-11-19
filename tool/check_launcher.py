"""Проверить собранный загрузчик без окон и без пользовательского профиля."""
import argparse
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import time

from release import ROOT, dart_executable


def hide_console(binary):
    if os.name != 'nt':
        return
    data = bytearray(binary.read_bytes())
    offset = struct.unpack_from('<I', data, 0x3c)[0]
    assert data[offset:offset + 4] == b'PE\0\0'
    struct.pack_into('<H', data, offset + 24 + 68, 2)
    binary.write_bytes(data)


def wait_launches(profile, count):
    for _ in range(200):
        file = profile / 'launches.jsonl'
        entries = [json.loads(line) for line in file.read_text(encoding='utf-8').splitlines()] if file.exists() else []
        if len(entries) >= count:
            return entries
        time.sleep(.05)
    raise TimeoutError('Кандидат не записал факт запуска')


def check(target):
    windows = target == 'windows-x64'
    binary = 'pob2_ui.exe' if windows else 'pob2_ui'
    launcher = 'pob2_ui.exe' if windows else 'pob2-ui'
    compiled = ROOT / ('build/launcher.exe' if windows else 'build/pob2-ui')
    with tempfile.TemporaryDirectory(prefix='pob2-launcher-check-') as temporary:
        root = Path(temporary).resolve()
        profile = root / 'profile'
        profile.mkdir()
        environment = dict(os.environ, POB2_UI_HOME=str(profile))
        (root / 'pob2-install.json').write_text('{"id":"dev.hecatoncheir.pob2Ui"}')
        shutil.copy2(compiled, root / launcher)
        fixture = root / ('candidate.exe' if windows else 'candidate')
        subprocess.run([str(dart_executable()), 'compile', 'exe',
                        str(ROOT / 'tool/fixtures/healthy_candidate.dart'), '-o', str(fixture)],
                       cwd=ROOT, check=True)
        hide_console(fixture)

        def install(version):
            destination = root / 'versions' / version
            destination.mkdir(parents=True, exist_ok=True)
            shutil.copy2(fixture, destination / binary)

        def launch(expected, *arguments):
            previous = len((profile / 'launches.jsonl').read_text(encoding='utf-8').splitlines()) if (profile / 'launches.jsonl').exists() else 0
            subprocess.run([str(root / launcher), *arguments], env=environment,
                           check=True, timeout=45,
                           creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
            entries = wait_launches(profile, previous + 1)
            actual = Path(entries[-1]['executable']).parent.name
            assert actual == expected, (actual, expected)
            assert (root / 'active-version').read_text().strip() == expected
            return entries[-1]

        install('0.9.9')
        install('0.10.3')
        (root / 'active-version').write_text('0.9.9')
        entry = launch('0.10.3', '--проверка', 'аргумент с пробелом')
        assert entry['arguments'][:2] == ['--проверка', 'аргумент с пробелом']
        assert (root / 'previous-version').read_text().strip() == '0.9.9'
        (root / 'pending-version').write_text('0.9.9')
        launch('0.10.3')
        assert not (root / 'pending-version').exists()
        launch('0.9.9', '--rollback')
        launch('0.9.9')
        (root / 'pending-version').write_text('999.0.0')
        launch('0.9.9')
        rejected = json.loads((root / 'rejected-versions.json').read_text())['versions']
        assert '999.0.0' in rejected and '0.10.3' in rejected
        (root / 'pending-version').write_text('0.10.3')
        launch('0.10.3')
        assert '0.10.3' not in json.loads((root / 'rejected-versions.json').read_text())['versions']
        (root / 'active-version').write_text('../повреждённый маркер')
        launch('0.10.3')
        time.sleep(.2)
    print(json.dumps({'target': target, 'latestWithoutPending': True,
                      'stalePendingIgnored': True, 'rollbackPreserved': True,
                      'missingCandidateRejected': True, 'explicitRetryAllowed': True,
                      'invalidMarkerRecovered': True, 'argumentsPreserved': True}, ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--target', choices=['windows-x64', 'linux-x64'], required=True)
    check(parser.parse_args().target)
