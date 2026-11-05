"""Регрессии правил выпуска и упаковки."""

from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from release import TARGETS, entry, filename, prepare, validate, version


class ReleaseTests(unittest.TestCase):
    def test_versions_and_changelog_agree(self):
        self.assertTrue(validate('v' + version()))
        for invalid in ['main', 'v01.2.3', 'v9.9.9', 'v1.2.3-beta']:
            with self.subTest(tag=invalid), self.assertRaises(ValueError):
                validate(invalid)

    def test_changelog_contains_only_requested_section(self):
        text = '## [Не выпущено]\n- Потом\n\n## [1.2.3] - 2026-11-05\n- Нужно\n\n## [1.2.2] - 2026-10-05\n- Раньше\n'
        self.assertEqual(entry(text, '1.2.3'), '- Нужно\n')
        with self.assertRaises(ValueError):
            entry('## [1.2.3] - 2026-11-05\n', '1.2.3')

    def test_all_three_installers_are_required(self):
        with tempfile.TemporaryDirectory() as temporary, patch('release.validate', return_value='Описание\n'):
            directory = Path(temporary)
            with self.assertRaises(ValueError):
                prepare('v1.2.3', directory)
            for target in TARGETS:
                (directory / filename('1.2.3', target)).write_bytes(target.encode())
            (directory / 'private.txt').write_text('secret')
            prepare('v1.2.3', directory)
            lines = (directory / 'SHA256SUMS').read_text().splitlines()
            self.assertEqual(len(lines), 3)
            self.assertNotIn('private', '\n'.join(lines))
            self.assertEqual((directory / 'RELEASE_NOTES.md').read_text(encoding='utf-8'), 'Описание\n')


if __name__ == '__main__':
    unittest.main()
