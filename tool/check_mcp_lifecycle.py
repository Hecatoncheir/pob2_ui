"""Проверить настоящий код завершения готового PoB II после команды MCP."""

import argparse
from contextlib import ExitStack
import json
import os
from pathlib import Path
import queue
import shutil
import subprocess
import threading
import time
from urllib.request import Request, urlopen

from check_profile import stop_profile_engine, temporary_profile, wait_for

ROOT = Path(__file__).resolve().parents[1]
BINARIES = {
    'windows-x64': 'build/windows/x64/runner/Release/pob2_ui.exe',
    'linux-x64': 'build/linux/x64/release/bundle/pob2_ui',
    'macos-arm64': 'build/macos/Build/Products/Release/PoB II.app/Contents/MacOS/PoB II',
}


def failure_status(profile):
    try:
        endpoint = json.loads((profile / 'mcp-editor/endpoint.json').read_text())
        payload = json.dumps({'tool': 'pob_editor_status', 'arguments': {},
                              'revision': None}).encode()
        request = Request(f"http://127.0.0.1:{endpoint['port']}/edit", data=payload,
                          headers={'Authorization': 'Bearer ' + endpoint['token'],
                                   'Content-Type': 'application/json'})
        with urlopen(request, timeout=5) as response:
            status = json.load(response)['result']
        return {key: status.get(key) for key in
                ('busy', 'dialogOpen', 'status', 'error', 'log')}
    except (OSError, ValueError, KeyError) as error:
        return {'diagnosticError': str(error)}


class Editor:
    def __init__(self, profile, component, engine, environment):
        endpoint = str(profile / 'mcp-editor/endpoint.json')
        if engine:
            command = [engine, 'editor', '--endpoint', endpoint]
        else:
            binary = 'python/python.exe' if os.name == 'nt' else 'python/bin/python3'
            command = [str(component / binary), '-X', 'utf8', str(component / 'run.py'),
                       'serve', '--mode', 'editor', '--editor-endpoint', endpoint]
        self.process = subprocess.Popen(
            command, env=environment, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, encoding='utf-8',
        )
        self.lines = queue.Queue()
        self.counter = 0
        threading.Thread(target=self._read, daemon=True).start()
        threading.Thread(target=lambda: self.process.stderr.read(), daemon=True).start()
        self.rpc('initialize', {'protocolVersion': '2025-11-25', 'capabilities': {},
                                'clientInfo': {'name': 'release-lifecycle-check', 'version': '1'}})
        self.process.stdin.write(json.dumps({'jsonrpc': '2.0', 'method': 'notifications/initialized'}) + '\n')
        self.process.stdin.flush()

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
    with temporary_profile('pob2-mcp-exit-') as profile, ExitStack() as cleanup:
        builds = profile / 'builds'
        builds.mkdir()
        engine = os.environ.get('POB2_PACKAGED_ENGINE')
        environment = dict(os.environ, POB2_UI_HOME=str(profile))
        component = prepare_runtime(profile, components, engine, environment)
        if engine:
            cleanup.callback(stop_profile_engine, binary, profile, environment, Path(engine))
        (profile / 'pob-builds.json').write_text(json.dumps({
            'directory': str(builds), 'migrated': True,
        }), encoding='utf-8')
        process = subprocess.Popen([str(binary), '--mcp-editor'], env=environment)
        editor = None
        try:
            wait_for_editor(process, profile)
            editor = Editor(profile, component, engine, environment)
            tools = editor.rpc('tools/list', {})['tools']
            assert len(tools) == 42, len(tools)
            status = editor.call('pob_editor_status')
            assert not status['dialogOpen'], status
            assert status['processId'] == process.pid, status
            classes = editor.call('pob_catalog', {'kind': 'classes'})['entries']
            witch = next(entry for entry in classes if entry['name'] == 'Witch')
            editor.call('pob_create_build', {'classId': witch['id'], 'level': 90,
                                            'name': 'MCP lifecycle check'})
            editor.call('pob_editor_status')
            if engine:
                assert_window_image(editor)
                assert not (profile / 'components.json').exists()
            editor_action_when_idle(editor, 'save')
            editor_action_when_idle(editor, 'close')
            code = process.wait(timeout=30)
            assert code == 0, f'После ответа MCP процесс завершился с кодом {code}'
            assert list(builds.glob('*.xml')), 'Не сохранён XML'
            return {'appVersion': status['appVersion'], 'appBuild': status['appBuild'],
                    'tools': len(tools), 'exitCode': code, 'xmlSaved': True, 'nativeEditor': bool(engine)}
        except Exception:
            print(json.dumps({'failureStatus': failure_status(profile)},
                             ensure_ascii=False), flush=True)
            raise
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
            if editor is not None:
                editor.close()


def prepare_runtime(profile, components, engine, environment):
    if not engine:
        shutil.copyfile(components, profile / 'components.json')
        manifest = json.loads(components.read_text(encoding='utf-8-sig'))
        return Path(manifest['active']['mcp']['directory'])
    environment['POB2_ENGINE_EXECUTABLE'] = engine
    environment['POB2_UI_PYTHON'] = str(profile / 'python-not-installed')
    subprocess.run([engine, 'pob-data', 'ensure'], env=environment, check=True, timeout=310)
    return None


def editor_action_when_idle(editor, action):
    def apply():
        status = editor.call('pob_editor_status')
        if status['busy'] or status['dialogOpen']:
            return False
        try:
            editor.call('pob_editor_app', {'action': action})
        except RuntimeError as error:
            result = error.args[0]
            if isinstance(result, dict) and any('"APP_BUSY"' in item.get('text', '')
                                                for item in result.get('content', [])):
                return False
            raise
        return True
    wait_for(apply, 'Редактор PoB II остался занят перед ' + action, timeout=30)


def assert_window_image(editor):
    result = editor.rpc('tools/call', {
        'name': 'pob_editor_ui', 'arguments': {'action': 'screenshot'},
    })
    assert not result.get('isError'), result
    assert any(item.get('mimeType') == 'image/png' and item.get('data', '').startswith('iVBORw0KGgo')
               for item in result['content']), 'Go MCP не вернул PNG окна'


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
