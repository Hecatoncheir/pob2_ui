"""Остановка движка и удаление временного профиля после нативных проверок."""

from contextlib import contextmanager
from pathlib import Path
import subprocess
import sys
import tempfile
import time


def wait_for(read, message, timeout=45):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        value = read()
        if value:
            return value
        time.sleep(.1)
    raise RuntimeError(message)


def stop_profile_engine(binary, root, environment, engine=None):
    runtime = root / 'engine-run'
    record = runtime / 'pob2-engine' / 'pob2-ui' / 'connection.json'
    if not record.is_file():
        return
    engine = engine or binary.with_name('pob2-engine.exe' if sys.platform == 'win32' else 'pob2-engine')
    command = [
        str(engine), 'shutdown', '--profile', 'pob2-ui',
        '--runtime-dir', str(runtime), '--data-dir', str(root / 'engine-data'),
        '--timeout', '15s',
    ]
    result = subprocess.run(command, env=environment, capture_output=True, text=True, timeout=20)
    if result.returncode and record.is_file():
        raise RuntimeError('Не удалось остановить движок проверяемого профиля: ' + result.stderr.strip())
    wait_for(lambda: not record.exists(), 'Движок проверяемого профиля не завершился', timeout=30)


def stop_installation_profiles(binary, base, environment):
    for directory in base.iterdir():
        if directory.is_dir():
            stop_profile_engine(binary, directory, environment)


def remove_native_profile(temporary):
    def remove():
        try:
            temporary.cleanup()
        except PermissionError as error:
            # После снятия записи Windows может ещё держать файлы двигателя.
            if getattr(error, 'winerror', None) not in (32, 33):
                raise
            return False
        return True

    wait_for(remove, 'Файлы проверяемого профиля остались заблокированы', timeout=30)


@contextmanager
def temporary_profile(prefix):
    temporary = tempfile.TemporaryDirectory(prefix=prefix)
    try:
        yield Path(temporary.name).resolve()
    finally:
        remove_native_profile(temporary)
