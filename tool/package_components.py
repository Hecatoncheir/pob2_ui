"""Подготовить архивы PoB/MCP из закреплённых исходников и пакетов."""

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
LOCK = json.loads((ROOT / 'tool/components-lock.json').read_text())
MCP_REPO = 'Hecatoncheir/pob-poe2-mcp'
MCP_TAG = LOCK['mcp']['tag']
PYTHON_REPO = 'astral-sh/python-build-standalone'
PYTHON_TAG = '20261110'
PYTHON_PREFIX = f'cpython-3.14.10+{PYTHON_TAG}-'
PYTHON_ASSETS = {
    'macos-arm64': ('aarch64-apple-darwin', 'f15ec3d15460dd66c2eb88639b152cd9040e7d1ece11e38bf89e8f53f0171e02'),
    'linux-x64': ('x86_64-unknown-linux-gnu', 'c2ff2e97422f5d3896a16e0317fd212ba977bbf2688d93a6f7a03d817506bd30'),
}
MCP_WHEEL = (f'pob_poe2_mcp-{MCP_TAG[1:]}-py3-none-any.whl',
             '7f4d0de2c28422213a11010b86a44967a1cb76ba0ba7f687bbf5fe71897abdb1')
MCP_NATIVE = {
    'macos-arm64': '3f0cc6de7ee59f9f6151e22993395222b4c4cbcf846a75a46850f7bd97f97fae',
    'linux-x64': '3e4805621702776ba8728fd716b2b7f2405adc53f7d368e09f551372af3c21d0',
}
MCP_WINDOWS = ('pob-poe2-mcp-windows-x64.zip',
               '8693f052323acb48e6922851156212f806c4b58a701c895591d7d2d6735ac0e5')


def digest(path):
    with path.open('rb') as source:
        return hashlib.file_digest(source, 'sha256').hexdigest()


def download(cache, repo, tag, name, sha256):
    file = cache / name
    if not file.is_file():
        subprocess.run(['gh', 'release', 'download', tag, '--repo', repo,
                        '--dir', str(cache), '--pattern', name], check=True)
    if digest(file) != sha256:
        raise ValueError(f'SHA-256 не совпал для {name}')
    return file


def zip_member(archive, relative, source, mode):
    entry = zipfile.ZipInfo(relative)
    entry.compress_type = zipfile.ZIP_DEFLATED
    entry.external_attr = ((mode & 0o755) | 0o100000) << 16
    with archive.open(entry, 'w') as output:
        shutil.copyfileobj(source, output)


def pack_pob(target, checkout, staging):
    commit = LOCK['pob']['commit']
    revision = subprocess.check_output(['git', '-C', checkout, 'rev-parse', 'HEAD'], text=True).strip()
    if revision != commit:
        raise ValueError(f'Ожидалась ревизия PoB {commit}, получена {revision}')
    source = staging / 'pob.tar'
    subprocess.run(['git', '-C', checkout, 'archive', '--format=tar', '-o', source,
                    commit, 'src', 'runtime', 'LICENSE.md'], check=True)
    with tarfile.open(source) as contents, zipfile.ZipFile(target, 'w') as archive:
        for entry in contents:
            if entry.isfile():
                with contents.extractfile(entry) as stream:
                    zip_member(archive, entry.name, stream, entry.mode)
            elif not entry.isdir():
                raise ValueError(f'Необычный тип файла PoB {entry.name}')


def unpack_mcp(cache, target, staging):
    if target == 'windows-x64':
        portable = download(cache, MCP_REPO, MCP_TAG, *MCP_WINDOWS)
        with zipfile.ZipFile(portable) as contents:
            contents.extractall(staging)
        return staging / 'pob-poe2-mcp'

    python_arch, python_digest = PYTHON_ASSETS[target]
    name = f'{PYTHON_PREFIX}{python_arch}-install_only_stripped.tar.gz'
    portable = download(cache, PYTHON_REPO, PYTHON_TAG, name, python_digest)
    with tarfile.open(portable) as contents:
        members = (entry for entry in contents
                   if entry.name != 'python/share/terminfo'
                   and not entry.name.startswith('python/share/terminfo/'))
        contents.extractall(staging, members=members, filter='data')
    wheel = download(cache, MCP_REPO, MCP_TAG, *MCP_WHEEL)
    with zipfile.ZipFile(wheel) as contents:
        contents.extractall(staging)
    native = download(cache, MCP_REPO, MCP_TAG, f'pob-poe2-mcp-native-{target}.zip',
                      MCP_NATIVE[target])
    with zipfile.ZipFile(native) as contents:
        contents.extractall(staging / 'pob_poe2_mcp')
    return staging


def pack_mcp(output, cache, target, staging):
    source = unpack_mcp(cache, target, staging)
    (source / 'run.py').write_text('from pob_poe2_mcp.cli import main\n\n'
                                 'if __name__ == "__main__":\n    main()\n', encoding='utf-8')
    with zipfile.ZipFile(output, 'w') as archive:
        for file in sorted(source.rglob('*')):
            if file.is_symlink() and not file.resolve(strict=True).is_relative_to(source):
                raise ValueError(f'Ссылка выходит за пределы пакета {file}')
            if file.is_file():
                with file.open('rb') as stream:
                    zip_member(archive, file.relative_to(source).as_posix(), stream, file.stat().st_mode)


def fetch_pob(destination):
    subprocess.run(['git', 'init', '--quiet', destination], check=True)
    git = ['git', '-C', destination]
    subprocess.run([*git, 'fetch', '--depth=1',
                    'https://github.com/PathOfBuildingCommunity/PathOfBuilding-PoE2.git',
                    f'refs/tags/{LOCK["pob"]["tag"]}'], check=True)
    subprocess.run([*git, 'switch', '--detach', 'FETCH_HEAD'], check=True)
    return destination


def package(output, cache, checkout):
    output.mkdir(parents=True, exist_ok=True)
    cache.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='pob2-components-') as path:
        staging = Path(path).resolve()
        source = checkout or fetch_pob(staging / 'checkout')
        pack_pob(output / 'pob.zip', source, staging)
        for target in ('windows-x64', *PYTHON_ASSETS):
            folder = staging / target
            folder.mkdir()
            pack_mcp(output / f'mcp-{target}.zip', cache, target, folder)
    packages = {file.name: {'size': file.stat().st_size, 'sha256': digest(file)}
                for file in sorted(output.glob('*.zip'))}
    print(json.dumps(packages, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--cache', required=True, type=Path)
    parser.add_argument('--pob-checkout', type=Path)
    args = parser.parse_args()
    package(args.output, args.cache, args.pob_checkout)


if __name__ == '__main__':
    main()
