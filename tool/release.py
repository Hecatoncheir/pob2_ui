"""Проверка версии, сборка установщиков и подготовка неизменяемого релиза."""

import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]
TARGETS = ('windows-x64', 'macos-arm64', 'linux-x64')


def version(root=ROOT):
    source = (root / 'pubspec.yaml').read_text(encoding='utf-8')
    match = re.search(r'^version: (\d+\.\d+\.\d+)\+(\d+)\s*$', source, re.M)
    if not match:
        raise ValueError('Нужна версия x.y.z+build в pubspec.yaml')
    info = (root / 'lib/domain/app_info.dart').read_text(encoding='utf-8')
    if f"const appVersion = '{match[1]}';" not in info or f'const appBuild = {match[2]};' not in info:
        raise ValueError('Версия pubspec.yaml расходится с app_info.dart')
    return match[1]


def entry(text, number):
    match = re.search(r'^## \[' + re.escape(number) + r'\] - \d{4}-\d{2}-\d{2}\s*$', text, re.M)
    if not match:
        raise ValueError('Нет раздела changelog с версией и датой')
    body = re.split(r'^## ', text[match.end():], maxsplit=1, flags=re.M)[0].strip()
    if not body:
        raise ValueError('Пустой раздел changelog')
    return body + '\n'


def validate(tag, root=ROOT):
    if not re.fullmatch(r'v(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)', tag):
        raise ValueError('Нужен стабильный тег vX.Y.Z')
    if tag[1:] != version(root):
        raise ValueError('Тег расходится с версией приложения')
    return entry((root / 'CHANGELOG.md').read_text(encoding='utf-8'), tag[1:])


def filename(number, target):
    suffix = {'windows-x64': 'windows-x64-setup.exe', 'macos-arm64': 'macos-arm64.dmg', 'linux-x64': 'linux-x64.run'}
    return f'pob2-ui-{number}-{suffix[target]}'


def prepare(tag, directory):
    notes = validate(tag)
    packages = [directory / filename(tag[1:], target) for target in TARGETS]
    for package in packages:
        if not package.is_file() or package.stat().st_size == 0:
            raise ValueError(f'Нет установщика: {package.name}')
    lines = []
    for package in packages:
        with package.open('rb') as stream:
            lines.append(hashlib.file_digest(stream, 'sha256').hexdigest() + '  ' + package.name)
    (directory / 'SHA256SUMS').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    (directory / 'RELEASE_NOTES.md').write_text(notes, encoding='utf-8')


def run(*arguments):
    subprocess.run([str(value) for value in arguments], check=True, cwd=ROOT)


def launcher(destination):
    run('dart', 'compile', 'exe', 'tool/launcher.dart', '-o', destination)
    if sys.platform == 'win32':
        # Стабильный запускатель не открывает консольное окно.
        data = bytearray(destination.read_bytes())
        offset = struct.unpack_from('<I', data, 0x3c)[0]
        if data[offset:offset + 4] != b'PE\0\0':
            raise ValueError('Запускатель не является PE-файлом')
        struct.pack_into('<H', data, offset + 24 + 68, 2)
        destination.write_bytes(data)


def windows(number, output):
    compiled = ROOT / 'build/launcher.exe'
    launcher(compiled)
    compiler = shutil.which('iscc') or str(Path(os.environ.get('ProgramFiles(x86)', 'C:/Program Files (x86)')) / 'Inno Setup 6/ISCC.exe')
    run(compiler, f'/DAppVersion={number}', f'/DBundleDir={ROOT / "build/windows/x64/runner/Release"}',
        f'/DLauncherFile={compiled}', f'/DOutputDir={output}', 'installer/pob2_ui.iss')


def linux(number, output):
    compiled = ROOT / 'build/pob2-ui'
    launcher(compiled)
    payload = io.BytesIO()
    with tarfile.open(fileobj=payload, mode='w:gz') as archive:
        archive.add(ROOT / 'build/linux/x64/release/bundle', arcname='bundle')
        archive.add(compiled, arcname='pob2-ui')
    header = (ROOT / 'installer/linux-header.sh').read_text(encoding='utf-8').replace('@VERSION@', number)
    package = output / filename(number, 'linux-x64')
    package.write_bytes(header.encode('utf-8') + payload.getvalue())
    package.chmod(0o755)


def macos(number, output):
    bundle = ROOT / 'build/macos/Build/Products/Release/PoB II.app'
    resources = bundle / 'Contents/Resources'
    (resources / 'pob2-install.json').write_text(json.dumps({'schema': 1, 'id': 'dev.hecatoncheir.pob2Ui', 'kind': 'macos-dmg'}), encoding='utf-8')
    shutil.copy2(ROOT / 'installer/update-macos.sh', resources)
    identity = os.environ.get('MACOS_SIGN_IDENTITY', '-')
    run('/usr/bin/codesign', '--force', '--deep', '--sign', identity, bundle)
    run('/usr/bin/codesign', '--verify', '--deep', '--strict', bundle)
    with tempfile.TemporaryDirectory(prefix='pob2-dmg-') as temporary:
        staging = Path(temporary)
        run('/usr/bin/ditto', bundle, staging / bundle.name)
        (staging / 'Applications').symlink_to('/Applications')
        run('/usr/bin/hdiutil', 'create', '-volname', 'PoB II', '-srcfolder', staging, '-format', 'UDZO', output / filename(number, 'macos-arm64'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tag')
    parser.add_argument('--check-only', action='store_true')
    parser.add_argument('--package', choices=TARGETS)
    parser.add_argument('--artifacts', type=Path, default=ROOT / 'build/packages')
    args = parser.parse_args()
    if args.check_only:
        validate(args.tag or 'v' + version())
    elif args.package:
        args.artifacts.mkdir(parents=True, exist_ok=True)
        {'windows-x64': windows, 'linux-x64': linux, 'macos-arm64': macos}[args.package](version(), args.artifacts.resolve())
    else:
        prepare(args.tag, args.artifacts)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as failure:
        raise SystemExit(f'Ошибка выпуска: {failure}')
