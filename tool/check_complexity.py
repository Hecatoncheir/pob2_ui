"""Воспроизводимая проверка когнитивной сложности собственного кода Dart."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LOCK = json.loads((ROOT / 'tool/complexity-lock.json').read_text(encoding='utf-8'))
WORK = ROOT / 'build/complexity'


def run(*args, capture=False):
    return subprocess.run([str(value) for value in args], check=True, capture_output=capture, text=True, encoding='utf-8')


def checkout(name):
    item = LOCK[name]
    target = WORK / (name + '-' + item['revision'][:12])
    if target.exists():
        actual = run('git', '-C', target, 'rev-parse', 'HEAD', capture=True).stdout.strip()
        if actual != item['revision']:
            raise ValueError('Ревизия инструмента сложности не совпадает')
        if run('git', '-C', target, 'status', '--porcelain', '--untracked-files=no', capture=True).stdout.strip():
            raise ValueError('Исходники инструмента сложности изменены')
        return target
    target.mkdir(parents=True)
    run('git', '-C', target, 'init', '--quiet')
    run('git', '-C', target, 'fetch', '--depth=1', item['repository'], item['revision'])
    run('git', '-C', target, 'checkout', '--detach', 'FETCH_HEAD')
    return target


def cmake_executable():
    command = shutil.which('cmake')
    if command:
        return command
    if os.name != 'nt':
        raise ValueError('Для сборки грамматики нужен CMake')
    locator = Path(os.environ['ProgramFiles(x86)']) / 'Microsoft Visual Studio/Installer/vswhere.exe'
    installation = run(locator, '-latest', '-products', '*', '-property', 'installationPath', capture=True).stdout.strip()
    return Path(installation) / 'Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/cmake.exe'


def build_parser(grammar):
    output = WORK / ('parser-' + LOCK['dart']['revision'][:12])
    output.mkdir(exist_ok=True)
    extension = 'dll' if os.name == 'nt' else 'so'
    library = output / ('dart.' + extension)
    if library.exists():
        return library
    source = WORK / 'cmake'
    source.mkdir(exist_ok=True)
    configuration = '\n'.join([
        'cmake_minimum_required(VERSION 3.15)',
        'project(dart_parser C)',
        f'add_library(dart SHARED "{grammar.as_posix()}/src/parser.c" "{grammar.as_posix()}/src/scanner.c")',
        f'target_include_directories(dart PRIVATE "{grammar.as_posix()}/src")',
        'set_target_properties(dart PROPERTIES PREFIX "" WINDOWS_EXPORT_ALL_SYMBOLS ON)',
        f'set_target_properties(dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY "{output.as_posix()}" RUNTIME_OUTPUT_DIRECTORY_RELEASE "{output.as_posix()}")',
        'target_compile_definitions(dart PRIVATE _CRT_SECURE_NO_WARNINGS)',
    ])
    (source / 'CMakeLists.txt').write_text(configuration, encoding='utf-8')
    cmake = cmake_executable()
    run(cmake, '-S', source, '-B', source / 'out')
    run(cmake, '--build', source / 'out', '--config', 'Release')
    if not library.exists():
        raise ValueError('Не собрана грамматика Dart')
    return library


def check(report_only):
    analyzer = checkout('analyzer')
    grammar = checkout('dart')
    library = build_parser(grammar)
    files = sorted((ROOT / 'lib').rglob('*.dart')) + [ROOT / 'tool/launcher.dart']
    listing = WORK / 'dart-files.txt'
    listing.write_text('\n'.join(path.as_posix() for path in files), encoding='utf-8')
    result = run('nvim', '--headless', '-u', 'NONE', '-l', ROOT / 'tool/complexity.lua', analyzer, library, listing, capture=True)
    entries = json.loads(result.stdout)
    if not entries:
        raise ValueError('Анализатор не нашёл функций; проверка не выполнена')
    entries.sort(key=lambda item: item['cognitive'], reverse=True)
    (WORK / 'report.json').write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding='utf-8')
    limit = LOCK['maxCognitive']
    for item in entries[:15]:
        relative = Path(item['file']).relative_to(ROOT)
        print(f"COG {item['cognitive']:2} / CC {item['cyclomatic']:2}  {relative}:{item['line']}  {item['name']}")
    violations = [entry for entry in entries if entry['cognitive'] > limit]
    print(f'Функций: {len(entries)}; предел COG: {limit}; превышений: {len(violations)}')
    if violations and not report_only:
        raise ValueError('Снизьте сложность функций выше установленного предела')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report-only', action='store_true')
    try:
        check(parser.parse_args().report_only)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        if isinstance(error, subprocess.CalledProcessError) and error.stderr:
            print(error.stderr, file=sys.stderr)
        raise SystemExit(f'Проверка сложности не пройдена: {error}')
