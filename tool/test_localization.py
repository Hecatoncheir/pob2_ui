"""Полнота каталогов и неизменность параметров переводов без обращения к сети."""
import json
from pathlib import Path
import re
import unittest

import localize_ui

ROOT = Path(__file__).resolve().parents[1]


class LocalizationTests(unittest.TestCase):
    def test_reviewed_terms_are_reproducible_and_complete(self):
        reviewed = json.loads((ROOT / 'lib/l10n/ui_reviewed.json').read_text('utf-8'))
        cache = json.loads((ROOT / 'lib/l10n/ui_translations.json').read_text('utf-8'))
        messages = localize_ui.collect()
        for source, values in reviewed['terms'].items():
            with self.subTest(source=source):
                self.assertTrue(source in messages.values(), source)
                self.assertEqual(len(values), len(reviewed['locales']))
                key = next(key for key, text in messages.items() if text == source)
                for locale, value in zip(reviewed['locales'], values):
                    self.assertEqual(cache[locale][key], value)
        for source, value in reviewed['english'].items():
            key = next(key for key, text in messages.items() if text == source)
            self.assertEqual(cache['en'][key], value)

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
