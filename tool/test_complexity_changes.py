"""Проверки сравнения ревизий по когнитивной сложности."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from complexity_changes import compare


def _entry(path, line, name, cognitive):
    return dict(file=str(path), line=line, name=name, cognitive=cognitive)


class ComplexityChangesTests(unittest.TestCase):
    def test_renamed_file_keeps_baseline_and_distinguishes_same_named_methods(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            base = root / 'base'
            base.mkdir()
            before = base / 'old.dart'
            after = root / 'new.dart'
            before.write_text(
                'class A {\n  int run() => 1;\n}\n'
                'class B {\n  int run() {\n    return 2;\n  }\n}\n',
                encoding='utf-8',
            )
            after.write_text(
                '// Сдвиг строк\nclass A {\n  int run() => 1;\n}\n'
                'class B {\n  int run() {\n    if (ready) return 2;\n    return 3;\n  }\n}\n'
                'int extra() => ready ? 1 : 0;\n',
                encoding='utf-8',
            )
            changes = compare(
                [_entry(before, 2, 'run', 0), _entry(before, 5, 'run', 0)],
                [_entry(after, 3, 'run', 0), _entry(after, 6, 'run', 1),
                 _entry(after, 11, 'extra', 1)],
                base, root, {'new.dart': 'old.dart'},
            )
            self.assertEqual(changes['increased'], [
                dict(file='new.dart', line=6, name='run', before=0, after=1),
            ])
            self.assertEqual(changes['added'], [
                dict(file='new.dart', line=11, name='extra', before=None, after=1),
            ])
            self.assertEqual(changes['decreased'], [])
            self.assertEqual(changes['ambiguous'], 0)
