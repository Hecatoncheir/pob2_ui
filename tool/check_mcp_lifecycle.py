"""Проверить настоящий код завершения готового PoB II после команды MCP."""

import argparse
import json
import os
from pathlib import Path
import queue
import shutil
import subprocess
import tempfile
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
BINARIES = {
    'windows-x64': 'build/windows/x64/runner/Release/pob2_ui.exe',
    'linux-x64': 'build/linux/x64/release/bundle/pob2_ui',
    'macos-arm64': 'build/macos/Build/Products/Release/PoB II.app/Contents/MacOS/PoB II',
}


class Editor:
    def __init__(self, profile, component):
        binary = 'python/python.exe' if os.name == 'nt' else 'python/bin/python3'
        self.process = subprocess.Popen(
            [str(component / binary), '-X', 'utf8', str(component / 'run.py'),
             'serve', '--mode', 'editor', '--editor-endpoint',
             str(profile / 'mcp-editor/endpoint.json')],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, encoding='utf-8',
        )
        self.lines = queue.Queue()
        self.counter = 0
        threading.Thread(target=self._read, daemon=True).start()
        threading.Thread(target=lambda: self.process.stderr.read(), daemon=True).start()
        self.rpc('initialize', {'protocolVersion': '2025-11-25', 'capabilities': {},
                                'clientInfo': {'name': 'release-lifecycle-check', 'version': '1'}})

    def _read(self):
        for line in self.process.stdout:
            self.lines.put(line)

    def rpc(self, method, params):
        self.counter += 1
        self.process.stdin.write(json.dumps({
            'jsonrpc': '2.0', 'id': self.counter, 'method': method, 'params': params,
        }) + '\n')
        self.process.stdin.flush()
        response = json.loads(self.lines.get(timeout=210))
        if 'error' in response:
            raise RuntimeError(response['error'])
        return response['result']

    def call(self, name, arguments=None):
        response = self.rpc('tools/call', {'name': name, 'arguments': arguments or {}})
        if response.get('isError'):
            raise RuntimeError(response)
        return response['structuredContent']['result']

    def close(self):
        self.process.stdin.close()
        try:
            self.process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            self.process.kill()
            self.process.wait()


def wait_for_editor(process, profile):
    for _ in range(600):
        if process.poll() is not None:
            raise RuntimeError(f'Приложение завершилось до включения MCP: {process.returncode}')
        if (profile / 'mcp-editor/endpoint.json').is_file():
            return
        time.sleep(.2)
    raise TimeoutError('Приложение не включило MCP')


def check(binary, components):
    with tempfile.TemporaryDirectory(prefix='pob2-mcp-exit-') as temporary:
        profile = Path(temporary)
        builds = profile / 'builds'
        builds.mkdir()
        shutil.copyfile(components, profile / 'components.json')
        (profile / 'pob-builds.json').write_text(json.dumps({
            'directory': str(builds), 'migrated': True,
        }), encoding='utf-8')
        manifest = json.loads(components.read_text(encoding='utf-8-sig'))
        component = Path(manifest['active']['mcp']['directory'])
        environment = dict(os.environ, POB2_UI_HOME=str(profile))
        process = subprocess.Popen([str(binary), '--mcp-editor'], env=environment)
        editor = None
        try:
            wait_for_editor(process, profile)
            editor = Editor(profile, component)
            tools = editor.rpc('tools/list', {})['tools']
            assert len(tools) == 42, len(tools)
            status = editor.call('pob_editor_status')
            assert status['processId'] == process.pid, status
            classes = editor.call('pob_catalog', {'kind': 'classes'})['entries']
            witch = next(entry for entry in classes if entry['name'] == 'Witch')
            editor.call('pob_create_build', {'classId': witch['id'], 'level': 90,
                                            'name': 'MCP lifecycle check'})
            editor.call('pob_editor_status')
            editor.call('pob_editor_app', {'action': 'save'})
            editor.call('pob_editor_app', {'action': 'close'})
            code = process.wait(timeout=30)
            assert code == 0, f'После ответа MCP процесс завершился с кодом {code}'
            assert list(builds.glob('*.xml')), 'Не сохранён XML'
            return {'appVersion': status['appVersion'], 'appBuild': status['appBuild'],
                    'tools': len(tools), 'exitCode': code, 'xmlSaved': True}
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
            if editor is not None:
                editor.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', required=True, choices=BINARIES)
    parser.add_argument('--components', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    arguments = parser.parse_args()
    result = check(ROOT / BINARIES[arguments.target], arguments.components)
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(json.dumps(result, indent=2), encoding='utf-8')
    print(json.dumps(result), flush=True)


if __name__ == '__main__':
    main()
