"""Воспроизвести превышение времени и проверить диагностику запущенного этапа."""

import json
from pathlib import Path
import sys
import tempfile
import time
import unittest

from check_installer import run_with_progress


class InstallerProgressTest(unittest.TestCase):
    def test_timeout_reports_last_stage(self):
        with tempfile.TemporaryDirectory() as temporary:
            journal = Path(temporary) / 'progress.jsonl'
            journal.write_text(json.dumps({
                'step': 'open-build', 'timestampMs': int(time.time() * 1000) - 1000,
            }) + '\n', encoding='utf-8')
            with self.assertRaisesRegex(RuntimeError, 'Последний этап: open-build, выполнялся'):
                run_with_progress([sys.executable, '-c', 'import time; time.sleep(30)'], journal, 0.2)


if __name__ == '__main__':
    unittest.main()
