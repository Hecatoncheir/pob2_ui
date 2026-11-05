"""Полнота каталогов и неизменность параметров переводов без обращения к сети."""
import json
from pathlib import Path
import re
import unittest

import localize_ui

ROOT = Path(__file__).resolve().parents[1]


class LocalizationTests(unittest.TestCase):
    def test_all_catalogs_match_sources_and_parameters(self):
        messages = localize_ui.collect()
        saved = json.loads((ROOT / 'lib/l10n/ui_sources.json').read_text('utf-8'))
        self.assertEqual(messages, saved, 'Сгенерируйте новые строки интерфейса')
        cache = json.loads((ROOT / 'lib/l10n/ui_translations.json').read_text('utf-8'))
        for locale in localize_ui.LANGUAGES:
            with self.subTest(locale=locale):
                rows = cache[locale]
                self.assertEqual(set(rows), set(messages))
                for key, value in rows.items():
                    self.assertTrue(value.strip(), key)
                    self.assertEqual(sorted(re.findall(r'\{p\d+\}', value)),
                                     sorted(re.findall(r'\{p\d+\}', messages[key])), key)

    def test_icu_preserves_literal_braces_and_apostrophes(self):
        self.assertEqual(localize_ui.icu("Don't replace {p0} or {Lua}"),
                         "Don''t replace {p0} or '{'Lua'}'")


if __name__ == '__main__':
    unittest.main()
