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
import xml.etree.ElementTree as ET

from release import ROOT, dart_executable, filename, version

PREVIOUS_VERSION = '0.11.0'
FIXTURES = ROOT / 'integration_test/fixtures'


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
        processes = subprocess.check_output(['ps', '-ww', '-eo', 'pid=,args='], text=True)
        expected = str(install / 'versions') + '/'
        for line in processes.splitlines():
            pieces = line.strip().split(None, 1)
            if len(pieces) == 2 and pieces[1].startswith(expected):
                os.kill(int(pieces[0]), 15)
    time.sleep(1)


def stop_macos(bundle):
    expected = str(bundle / 'Contents/MacOS/PoB II')
    processes = subprocess.check_output(['ps', '-ww', '-eo', 'pid=,args='], text=True)
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
    return executable


def progress_summary(journal):
    if not journal.is_file():
        return 'Приложение не записало начало запуска'
    for line in reversed(journal.read_text(encoding='utf-8').splitlines()):
        try:
            last = json.loads(line)
        except json.JSONDecodeError:
            continue
        elapsed = max(0, time.time() - last['timestampMs'] / 1000)
        return f"Последний этап: {last['step']}, выполнялся {elapsed:.1f} с"
    return 'Журнал запуска пуст'


def run_with_progress(command, journal, timeout, **kwargs):
    try:
        return subprocess.run(command, timeout=timeout, **kwargs)
    except subprocess.TimeoutExpired as error:
        raise RuntimeError(f'Тайм-аут после {timeout} с. {progress_summary(journal)}') from error


def run_build_check(executable, data, environment, stage):
    journal = data / f'installer-progress-{stage}.jsonl'
    try:
        result = run_with_progress(
            [str(executable)], journal, 600,
            cwd=executable.parent, env=dict(environment, POB2_UI_INSTALLER_CHECK=stage),
        )
    finally:
        if journal.is_file():
            review = ROOT / 'build/review'
            review.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(journal, review / f'{data.name}-{journal.name}')
            print(journal.read_text(encoding='utf-8'), end='', flush=True)
    output = data / f'installer-check-{stage}.json'
    if not output.is_file():
        raise RuntimeError(f'Установленное приложение не записало результат {stage}')
    report = json.loads(output.read_text(encoding='utf-8'))
    if result.returncode or 'error' in report:
        raise RuntimeError(f'Проверка {stage} завершилась ошибкой: {report}')
    return report


def prepare_profile(data, components, archives=None):
    builds = data / 'builds'
    builds.mkdir(parents=True)
    if components is not None:
        shutil.copyfile(components, data / 'components.json')
    if archives is not None:
        shutil.copytree(archives, data / 'component-downloads')
    (data / 'pob-builds.json').write_text(
        json.dumps({'directory': str(builds), 'migrated': True}), encoding='utf-8',
    )
    return builds


def verify_reopened(executable, data, builds, environment, saved):
    files = list(builds.glob('*.xml'))
    assert len(files) == 1 and files[0].name == saved['id']
    original = files[0].read_bytes()
    restored = run_build_check(executable, data, environment, 'restore')
    assert restored == saved, (saved, restored)
    assert files[0].read_bytes() == original, 'Повторный запуск изменил XML'


def check_build(executable, base, environment, target, *, components, archives, previous, verify_link, package):
    data = base / 'build-profile'
    builds = prepare_profile(data, components, archives)
    env = dict(environment, POB2_UI_HOME=str(data), PYTHONDONTWRITEBYTECODE='1')
    if components is None:
        env = archive_check_environment(env)
    saved = run_build_check(executable, data, env, 'save')
    assert saved['source'] == 'original-lua' and saved['level'] == 90 and saved['life'] > 0
    manifest = data / 'components.json'
    if components is None:
        active = json.loads(manifest.read_text(encoding='utf-8'))['active']
        assert all(component.get('archiveSha256') for component in active.values())
    if archives is not None:
        verify_archive_reuse(data, target)
    verify_reopened(executable, data, builds, env, saved)
    print('Установленный PoB II: расчёт Lua, XML и заметки восстановлены без HTTP после перезапуска')
    if previous is not None:
        check_previous(target, previous, executable, base, env, manifest, verify_link, package)


def verify_archive_reuse(data, target):
    journal = data / 'installer-progress-save.jsonl'
    steps = [json.loads(line)['step'] for line in journal.read_text(encoding='utf-8').splitlines()]
    for archive in ('pob.zip', f'mcp-{target}.zip'):
        assert f'Используется проверенный архив {archive}' in steps, steps


def previous_executable(target, package, base, environment):
    if target == 'macos-arm64':
        base.mkdir()
        return mount_macos(package, base) / 'Contents/MacOS/PoB II'
    if target == 'windows-x64':
        run(package, '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-', '/DIR=' + str(base), env=environment)
        return base / 'versions' / PREVIOUS_VERSION / 'pob2_ui.exe'
    run('/bin/sh', package, '--prefix', base, '--wait-pid', '2147483647', env=environment)
    return base / 'versions' / PREVIOUS_VERSION / 'pob2_ui'


def verify_launcher_upgrade(target, old, executable, package, environment):
    if target == 'macos-arm64':
        return
    install = old.parents[2]
    if target == 'windows-x64':
        run(package, '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-',
            '/DIR=' + str(install), env=environment)
        name = 'pob2_ui.exe'
    else:
        run('/bin/sh', package, '--prefix', install, env=environment)
        name = 'pob2-ui'
    expected = executable.parents[2] / name
    assert (install / name).read_bytes() == expected.read_bytes(), 'Установщик оставил старый загрузчик'
    print('Установщик обновил прежний корневой загрузчик')


def check_previous(target, package, executable, base, environment, components, verify_link, current_package):
    data = base / f'v{PREVIOUS_VERSION}-profile'
    builds = prepare_profile(data, components)
    env = dict(environment, POB2_UI_HOME=str(data),
               POB2_UI_CHECK_FIXTURE=str(FIXTURES / 'witch_fireball.xml'))
    env.pop('POB2_UI_CHECK_CODE', None)
    setup_env = dict(env, PATH=os.environ.get('PATH', ''))
    old = previous_executable(target, package, base / f'v{PREVIOUS_VERSION}-installation', setup_env)
    saved = run_build_check(old, data, env, 'save')
    verify_launcher_upgrade(target, old, executable, current_package, setup_env)
    prepare_cleanup_profile(data)
    before = {file.name: file.read_bytes() for file in builds.glob('*.xml')}
    assert run_build_check(executable, data, env, 'cleanup') == saved
    assert {file.name: file.read_bytes() for file in builds.glob('*.xml')} == before
    verify_reopened(executable, data, builds, env, saved)
    assert any((data / 'tree-cache').rglob('*.png')), 'Кеш дерева не восстановлен из Lua'
    print(f'После обновления с v{PREVIOUS_VERSION}, очистки и отката совпали XML, заметки и отчёт Lua')
    check_previous_weapons(old, executable, data, env)
    if verify_link:
        link_env = dict(env, POB2_UI_CHECK_LINK=str(FIXTURES / 'witch_fireball.poblink'))
        imported = run_build_check(executable, data, link_env, 'link')
        assert imported['id'] != saved['id'] and imported['source'] == 'original-lua', imported
        assert abs(imported['dps'] - 12.817708) < 0.00001, imported
        print(f"После обновления Ведьма с pobb.in рассчитана на Lua, TotalDPS {imported['dps']}")


def check_previous_weapons(old, executable, source_data, environment):
    for weapon, expected in ((1, 15.38125), (2, 19.482916666667)):
        data = source_data.parent / f'v{PREVIOUS_VERSION}-weapon-{weapon}-profile'
        builds = prepare_profile(data, source_data / 'components.json')
        file = builds / 'Ведьма оружие.xml'
        root = ET.parse(FIXTURES / 'witch_weapon_paths.xml').getroot()
        root.find('Notes').text = 'Installer check notes'
        items = root.find('Items')
        for section in (items, items.find('ItemSet')):
            section.set('useSecondWeaponSet', 'true' if weapon == 2 else 'false')
        file.write_bytes(ET.tostring(root, encoding='utf-8', xml_declaration=True))
        settings = data / 'pob-builds.json'
        selected = json.loads(settings.read_text(encoding='utf-8'))
        selected['active'] = file.name
        settings.write_text(json.dumps(selected), encoding='utf-8')
        env = dict(environment, POB2_UI_HOME=str(data))
        saved = run_build_check(old, data, env, 'restore')
        assert saved['id'] == file.name and abs(saved['dps'] - expected) < 0.00001, saved
        verify_reopened(executable, data, builds, env, saved)
        print(f'Профиль v{PREVIOUS_VERSION}: оружие {weapon}, DPS {expected}, XML и заметки сохранены без HTTP', flush=True)


def _link_or_copy(source, target):
    try:
        return os.link(source, target)
    except OSError:
        return shutil.copy2(source, target)


def prepare_cleanup_profile(data):
    manifest = data / 'components.json'
    state = json.loads(manifest.read_text(encoding='utf-8'))
    versions = data / 'versions'
    state['previous'] = {}
    for name, install in state['active'].items():
        directory = versions / f'{name}-rollback'
        shutil.copytree(install['directory'], directory, symlinks=True, copy_function=_link_or_copy)
        state['previous'][name] = dict(install, directory=str(directory))
    manifest.write_text(json.dumps(state), encoding='utf-8')
    obsolete = versions / 'pob-obsolete'
    obsolete.mkdir()
    (obsolete / '.pob2-component.json').write_text(json.dumps({
        'schema': 1, 'component': 'pob',
        'tag': state['active']['pob']['tag'], 'commit': state['active']['pob']['commit'],
    }), encoding='utf-8')
    (obsolete / 'stale.bin').write_bytes(b'old installation')


def archive_check_environment(environment):
    system_path = str(Path(os.environ['SystemRoot']) / 'System32') if os.name == 'nt' else ''
    environment = dict(
        environment,
        PATH=system_path,
        POB2_UI_CHECK_CODE=str(FIXTURES / 'witch_fireball.pobcode'),
    )
    for key in ('POB2_UI_PYTHON', 'PYTHONHOME', 'PYTHONPATH'):
        environment.pop(key, None)
    for executable in ('git', 'python', 'python3'):
        assert shutil.which(executable, path=system_path) is None, executable
    return environment


def check(target, *, build_check=False, components=None, archives=None, package=None, previous=None, verify_link=False):
    number = version()
    if previous is not None and not previous.is_file():
        raise FileNotFoundError(previous)
    package = package or ROOT / 'build/packages' / filename(number, target)
    options = dict(components=components, archives=archives, previous=previous,
                   verify_link=verify_link, package=package)
    with tempfile.TemporaryDirectory(prefix='pob2-install-check-') as temporary:
        base = Path(temporary).resolve()
        install = base / 'PoB II'
        data = base / 'data'
        environment = dict(os.environ, POB2_UI_HOME=str(data))
        environment.pop('POB2_UI_INSTALLER_CHECK', None)
        if target == 'linux-x64':
            environment['XDG_DATA_HOME'] = str(base / 'xdg-data')
            environment['HOME'] = str(base / 'home')
        if target == 'macos-arm64':
            executable = check_macos(package, base, data, environment)
            if build_check:
                check_build(executable, base, environment, target, **options)
            return
        if target == 'windows-x64':
            run(package, '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-', '/RELAUNCH', '/DIR=' + str(install), env=environment)
            binary = 'pob2_ui.exe'
        else:
            run('/bin/sh', package, '--prefix', install, '--wait-pid', '2147483647', '--relaunch', env=environment)
            binary = 'pob2-ui'
        marker = json.loads((install / 'pob2-install.json').read_text())
        assert marker['id'] == 'dev.hecatoncheir.pob2Ui'
        wait_file(install / 'active-version', number)
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
        # Загрузчик должен найти новую версию без pending-version.
        candidate = '999.0.1'
        shutil.copytree(install / 'versions' / number, install / 'versions' / candidate, symlinks=True)
        run(install / binary, env=environment)
        assert (install / 'active-version').read_text().strip() == candidate
        assert (install / 'previous-version').read_text().strip() == number
        stop_versions(install, environment)
        # Устаревший маркер не должен понизить уже работающую новую версию.
        (install / 'pending-version').write_text(number)
        run(install / binary, env=environment)
        assert (install / 'active-version').read_text().strip() == candidate
        assert not (install / 'pending-version').exists()
        stop_versions(install, environment)
        run(install / binary, '--rollback', env=environment)
        assert (install / 'active-version').read_text().strip() == number
        stop_versions(install, environment)
        run(install / binary, env=environment)
        assert (install / 'active-version').read_text().strip() == number
        stop_versions(install, environment)
        if build_check:
            executable = install / 'versions' / number / ('pob2_ui.exe' if os.name == 'nt' else 'pob2_ui')
            check_build(executable, base, environment, target, **options)
    print(f'{target}: установщик и настоящий запуск проверены')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', required=True)
    parser.add_argument('--build-check', action='store_true', help='Проверить сохранение и восстановление сборки')
    inputs = parser.add_mutually_exclusive_group()
    inputs.add_argument('--components', type=Path, help='Манифест уже скачанной пары для проверки сборки')
    inputs.add_argument('--archives', type=Path, help='Каталог архивов из smoke.dart --keep-archives')
    parser.add_argument('--package', type=Path, help='Путь к готовому установщику')
    parser.add_argument('--previous', type=Path, help=f'Каталог с установщиком v{PREVIOUS_VERSION} для проверки обновления')
    parser.add_argument('--verify-link', action='store_true', help='Импортировать Ведьму с pobb.in после обновления')
    args = parser.parse_args()
    if args.verify_link and not args.previous:
        parser.error('--verify-link требует --previous')
    check(
        args.target,
        build_check=args.build_check or args.components is not None or args.archives is not None or args.previous is not None,
        components=args.components,
        archives=args.archives,
        package=args.package.resolve() if args.package else None,
        previous=(args.previous / filename(PREVIOUS_VERSION, args.target)).resolve() if args.previous else None,
        verify_link=args.verify_link,
    )
