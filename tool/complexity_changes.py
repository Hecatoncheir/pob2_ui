"""Сравнение результатов анализатора Dart между ревизиями."""

from collections import Counter, defaultdict
from difflib import SequenceMatcher
from html import escape
import os
from pathlib import Path


def _index(entries, root):
    files = defaultdict(lambda: defaultdict(list))
    for entry in entries:
        name = Path(entry['file']).relative_to(root).as_posix()
        files[name][entry['name']].append(entry)
    return files


def _matching_lines(before, after):
    matcher = SequenceMatcher(None, before.splitlines(), after.splitlines(), autojunk=False)
    return {
        b + offset + 1: a + offset + 1
        for a, b, size in matcher.get_matching_blocks()
        for offset in range(size)
    }


def _pair(before, after, lines):
    if len(before) == len(after) == 1:
        return [(before[0], after[0])], [], 0
    old_by_line = defaultdict(list)
    for entry in before:
        old_by_line[entry['line']].append(entry)
    counts = Counter(entry['line'] for entry in after)
    pairs = []
    remaining = []
    for entry in after:
        old_line = lines.get(entry['line'])
        candidates = old_by_line.get(old_line, [])
        if len(candidates) != 1 or counts[entry['line']] != 1:
            remaining.append(entry)
        else:
            pairs.append((old_by_line.pop(old_line)[0], entry))
    old = [entry for entries in old_by_line.values() for entry in entries]
    if len(old) == len(remaining) == 1:
        pairs.append((old[0], remaining.pop()))
    return pairs, [] if old else remaining, len(remaining) if old else 0


def compare(before, after, base_root, root, renames):
    old_files = _index(before, base_root)
    new_files = _index(after, root)
    changes = {'increased': [], 'decreased': [], 'added': [], 'ambiguous': 0}
    for path, current in new_files.items():
        old_path = renames.get(path, path)
        previous = old_files.get(old_path, {})
        source = (root / path).read_text(encoding='utf-8')
        original = (base_root / old_path).read_text(encoding='utf-8') if previous else ''
        if source == original:
            continue
        duplicates = any(
            name in previous and (len(entries) > 1 or len(previous[name]) > 1)
            for name, entries in current.items()
        )
        lines = _matching_lines(original, source) if duplicates else {}
        for name, entries in current.items():
            pairs, added, ambiguous = _pair(previous.get(name, []), entries, lines)
            changes['ambiguous'] += ambiguous
            for old, new in pairs:
                delta = new['cognitive'] - old['cognitive']
                if delta:
                    kind = 'increased' if delta > 0 else 'decreased'
                    changes[kind].append(_change(path, new, old['cognitive']))
            changes['added'].extend(
                _change(path, new, None) for new in added if new['cognitive'] > 0)
    for kind in ('increased', 'decreased', 'added'):
        changes[kind].sort(
            key=lambda row: (-abs(row['after'] - (row['before'] or 0)),
                             row['file'], row['line']))
    return changes


def _change(path, current, before):
    return dict(file=path, line=current['line'], name=current['name'],
                before=before, after=current['cognitive'])


def _command_text(value, *, property_value=False):
    value = value.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')
    return value.replace(':', '%3A').replace(',', '%2C') if property_value else value


def annotate(path, line, message, *, kind='warning'):
    if os.getenv('GITHUB_ACTIONS') == 'true':
        file = _command_text(path, property_value=True)
        print(f'::{kind} file={file},line={line}::{_command_text(message)}')


def _markdown_text(value):
    return escape(value).replace('|', '&#124;').replace('\n', ' ')


def publish(changes, functions, limit, violations):
    lines = [
        '## Когнитивная сложность Dart',
        f'Проверено функций: {functions}. Предел COG: {limit}. Превышений: {violations}.',
    ]
    if changes is not None:
        increased = changes['increased']
        decreased = changes['decreased']
        added = changes['added']
        message = (f'Рост COG: {len(increased)}. Снижение: {len(decreased)}. '
                   f'Новых функций с COG выше 0: {len(added)}.')
        print(message)
        lines.extend(['', f"Базовая ревизия: `{changes['base'][:12]}`.", '', message])
        if changes['ambiguous']:
            lines.append(f"Не удалось однозначно сопоставить одноимённые функции: {changes['ambiguous']}.")
        for row in increased[:10]:
            message = f"{row['name']}: COG {row['before']} → {row['after']}"
            print(f"{row['file']}:{row['line']}  {message}")
            annotate(row['file'], row['line'], message)
        rows = increased + added + decreased
        if rows:
            lines.extend(['', '| Функция | Файл и строка | Было | Стало |',
                          '| --- | --- | ---: | ---: |'])
            for row in rows[:30]:
                name = _markdown_text(row['name'])
                location = _markdown_text(f"{row['file']}:{row['line']}")
                before = '—' if row['before'] is None else row['before']
                lines.append(f"| {name} | {location} | {before} | {row['after']} |")
            if len(rows) > 30:
                lines.append('\nПолный список доступен в changes.json в артефакте complexity-report.')
    if summary := os.getenv('GITHUB_STEP_SUMMARY'):
        with Path(summary).open('a', encoding='utf-8') as output:
            output.write('\n'.join(lines) + '\n')
