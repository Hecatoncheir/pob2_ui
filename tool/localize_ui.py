"""Каталог строк интерфейса и воспроизводимая генерация ARB/таблицы поиска."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import time
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'lib/l10n'
LANGUAGES = {'en': 'en', 'ru': 'ru', 'fr': 'fr', 'de': 'de', 'es': 'es',
             'pt_BR': 'pt', 'ja': 'ja', 'ko': 'ko', 'th': 'th', 'zh_Hant': 'zh-TW'}
SEEDS = {
    'Язык': 'Language', 'Игровые переводы загружаются…': 'Loading game translations…',
    'Нет перевода — показываем оригинал': 'Original text is shown when a translation is unavailable',
    'Сила': 'Strength', 'Ловкость': 'Dexterity', 'Интеллект': 'Intelligence',
    'Уклонение': 'Evasion', 'Броня': 'Armour', 'Энергощит': 'Energy Shield',
    'Урон': 'Damage', 'Условия': 'Configuration', 'Умения': 'Skills',
    'До узла: {p0} очков': '{p0} points to node',
    'Этот узел даст:': 'Allocating this node will give you:',
    'Возврат узла изменит показатели:': 'Unallocating this node will give you:',
    'Этот узел и путь к нему дадут:': 'Allocating this node and all nodes leading to it will give you:',
    'Выбор этого узла не изменит показатели.': 'No changes from allocating this node.',
    'Характеристика': 'Attribute', 'Восхождение': 'Ascendancy', 'Оформление': 'Appearance',
}
SEEDS.update({'Полный DPS': 'Full DPS', 'Суммарный DPS': 'Combined DPS', 'DPS ударов': 'Hit DPS', 'DPS пронзания и ударов': 'Impale + Hit DPS', 'Средний удар': 'Average Hit', 'Скорость атак и чар': 'Attack/Cast Speed', 'Постепенный DPS': 'DoT DPS', 'DPS кровотечения': 'Bleed DPS', 'DPS поджога': 'Ignite DPS', 'DPS отравления': 'Poison DPS', 'Здоровье': 'Life', 'Восстановление здоровья': 'Life regen', 'Похищение здоровья': 'Life leech', 'Восстанавливаемый энергощит': 'Recoverable ES', 'Восстановление энергощита': 'Energy Shield regen', 'Похищение энергощита': 'Energy Shield leech', 'Мана': 'Mana', 'Восстановление маны': 'Mana regen', 'Похищение маны': 'Mana leech', 'Руническая защита': 'Runic Ward', 'Дух': 'Spirit', 'Все характеристики': 'Total Attributes', 'Избежание атак вблизи': 'Melee avoid chance', 'Избежание чар': 'Spell avoid chance', 'Избежание снарядов': 'Projectile avoid chance', 'Эффективное здоровье': 'Effective Hit Pool', 'Максимальный выдерживаемый удар': 'Eff. Maximum Hit Taken', 'Получаемый физический урон': 'Taken Phys dmg', 'Получаемый урон молнией': 'Taken Lightning dmg', 'Получаемый урон холодом': 'Taken Cold dmg', 'Получаемый урон огнём': 'Taken Fire dmg', 'Получаемый урон хаосом': 'Taken Chaos dmg', 'Шанс критического удара': 'Crit Chance', 'Множитель критического удара': 'Crit Multiplier', 'Шанс кровотечения': 'Bleed Chance', 'Шанс заморозки': 'Freeze Chance', 'Шанс поджога': 'Ignite Chance', 'Шанс шока': 'Shock Chance', 'Скорость передвижения': 'Move speed', 'Радиус освещения': 'Light Radius', 'Шанс блока': 'Block Chance', 'Шанс блока чар': 'Spell Block Chance', 'Подавление урона чар': 'Spell Suppression Chance', 'Редкость найденных предметов': 'Rarity of Items found', 'Приспешник · {p0}': 'Minion {p0}', 'Всего маны': 'Total Mana', 'Всего здоровья': 'Total Life', 'Урон / защита': 'Offence/Defence', 'Узел не изменит показатели.': 'No changes.'})


SEEDS.update({
    'Новая группа умений': 'New skill group', 'Новая группа': 'New group',
    'Название группы': 'Group name', 'Найти камень': 'Search gems',
    'Добавить и рассчитать': 'Add and calculate', 'Заданные': 'Configured',
    'Выберите камни для группы': 'Choose gems for the group',
    'Качество, %': 'Quality, %', 'Камень включён': 'Gem enabled',
    'Убрать камень': 'Remove gem',
})

def quoted(text, start, found):
    quote = text[start]
    delimiter = quote * (3 if text.startswith(quote * 3, start) else 1)
    index = start + len(delimiter)
    literal, count = [], 0
    raw = start > 0 and text[start - 1] == 'r'
    while index < len(text):
        if text.startswith(delimiter, index):
            found.append(''.join(literal))
            return index + len(delimiter)
        char = text[index]
        if char == '\\' and not raw:
            value = text[index + 1:index + 2]
            literal.append({'n': '\n', 't': '\t', 'r': '\r'}.get(value, value))
            index += 2
        elif char == '$' and not raw:
            if text[index + 1:index + 2] == '{':
                index = expression_end(text, index + 2, found)
                literal.append('{p%d}' % count)
                count += 1
            else:
                match = re.match(r'\$[A-Za-z_]\w*', text[index:])
                if match:
                    literal.append('{p%d}' % count)
                    count += 1
                    index += len(match[0])
                else:
                    literal.append(char)
                    index += 1
        else:
            literal.append(char)
            index += 1
    return index


def expression_end(text, index, found):
    depth = 1
    while index < len(text):
        char = text[index]
        if char in "'\"":
            index = quoted(text, index, found)
            continue
        if char == '{': depth += 1
        if char == '}':
            depth -= 1
            if depth == 0: return index + 1
        index += 1
    raise ValueError('Незакрытая интерполяция Dart')


def strings(text):
    found, index = [], 0
    while index < len(text):
        if text.startswith('//', index):
            end = text.find('\n', index)
            index = len(text) if end < 0 else end + 1
        elif text.startswith('/*', index):
            end = text.find('*/', index + 2)
            index = len(text) if end < 0 else end + 2
        elif text[index] in "'\"":
            index = quoted(text, index, found)
        else:
            index += 1
    return found


def collect():
    messages = set(SEEDS)
    for path in (ROOT / 'lib').rglob('*.dart'):
        if 'l10n' in path.parts or path.name.endswith('.g.dart') or path.name in ('vector_drawings.dart', 'app_language.dart'):
            continue
        messages.update(s for s in strings(path.read_text('utf-8')) if len(s) < 1000 and re.search('[А-Яа-яЁё]', s))
    return {'m' + hashlib.sha256(s.encode()).hexdigest()[:10]: s for s in sorted(messages)}


def request_translation(text, source, target):
    query = urllib.parse.urlencode({'client': 'gtx', 'sl': source, 'tl': target, 'dt': 't', 'q': text})
    url = 'https://translate.googleapis.com/translate_a/single?' + query
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=30) as response:
                data = json.load(response)
            return ''.join(row[0] for row in data[0] if row[0])
        except Exception:
            if attempt == 2: raise
            time.sleep(attempt + 1)


def protect(text):
    text = re.sub(r'\{p(\d+)\}', lambda m: '{' + m[1] + '}', text)
    terms = []
    def replace(match):
        terms.append(match[0])
        return '{%d}' % (100 + len(terms) - 1)
    text = re.sub(r'\b(?:PoB II|Lua|MCP|XML|DPS|SHA-256|GitHub|Flutter|Windows|Linux|macOS|HTTP)\b', replace, text)
    return text, terms


def restore(text, original, terms):
    for index, term in enumerate(terms): text = text.replace('{%d}' % (100 + index), term)
    text = re.sub(r'\{(\d+)\}', lambda m: '{p' + m[1] + '}', text)
    if sorted(re.findall(r'\{p\d+\}', text)) != sorted(re.findall(r'\{p\d+\}', original)):
        raise ValueError('Перевод изменил параметры: ' + original)
    return text


def translate(messages, source, target):
    result = {}
    items = list(messages.items())
    for offset in range(0, len(items), 12):
        batch = items[offset:offset + 12]
        protected = {key: protect(value) for key, value in batch}
        text = '\n'.join(f'[{key}] {protected[key][0]}' for key, _ in batch)
        translated = request_translation(text, source, target)
        markers = list(re.finditer(r'\[(m[a-f0-9]{10})\]', translated, re.I))
        rows = {m[1].lower(): translated[m.end():markers[i+1].start() if i+1 < len(markers) else len(translated)].strip()
                for i, m in enumerate(markers)}
        for key, original in batch:
            value = rows.get(key)
            if value is None: value = request_translation(protected[key][0], source, target)
            result[key] = restore(value, original, protected[key][1])
        print(f'{target}: {min(offset + 12, len(items))}/{len(items)}', flush=True)
    return result


def icu(value):
    chunks = re.split(r'(\{p\d+\})', value)
    return ''.join(s if re.fullmatch(r'\{p\d+\}', s) else s.replace("'", "''").replace('{', "'{'").replace('}', "'}'") for s in chunks)


def generate_lookup(messages, english):
    exact, patterns, seen = [], [], set()
    def quote(value): return json.dumps(value, ensure_ascii=False).replace('$', r'\$')
    for key, source in messages.items():
        for alias in (source, english[key]):
            if alias in seen: continue
            seen.add(alias)
            parameters = sorted(set(re.findall(r'\{p(\d+)\}', alias)), key=int)
            if parameters:
                arguments = ', '.join(f'args[{index}]' for index in parameters)
                patterns.append((len(re.sub(r'\{p\d+\}', '', alias)),
                    f'  UiRule({quote(alias)}, (l, args) => l.{key}({arguments})),\n'))
            else:
                exact.append(f'  {quote(alias)}: (l) => l.{key},\n')
    output = ['// Сгенерировано tool/localize_ui.py из ARB; не редактировать вручную.\n',
      "import '../../l10n/generated/app_localizations.dart';\nimport 'ui_rule.dart';\n\n",
      'final uiExactTranslations = <String, String Function(AppLocalizations)>{\n',
      *exact, '};\n\nfinal uiPatternTranslations = <UiRule>[\n',
      *(value for _, value in sorted(patterns, reverse=True)), '];\n']
    (ROOT / 'lib/ui/core/ui_messages.g.dart').write_text(''.join(output), encoding='utf-8')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--translate', action='store_true')
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    cache_file = OUTPUT / 'ui_translations.json'
    cache = json.loads(cache_file.read_text('utf-8')) if cache_file.exists() else {}
    messages = collect()
    cache = {locale: {key: value for key, value in rows.items() if key in messages}
             for locale, rows in cache.items()}
    cache['ru'] = messages
    english = cache.setdefault('en', {})
    english.update({key: SEEDS[value] for key, value in messages.items() if value in SEEDS})
    missing = {key: value for key, value in messages.items() if key not in english}
    if missing and args.translate: english.update(translate(missing, 'ru', 'en'))
    if any(key not in english for key in messages): raise ValueError('Не переведён базовый каталог')
    for locale, target in LANGUAGES.items():
        current = cache.setdefault(locale, {})
        missing = {key: english[key] for key in messages if key not in current}
        if missing and args.translate: current.update(translate(missing, 'en', target))
        if any(key not in current for key in messages): raise ValueError('Нет строк языка ' + locale)
        catalog = {'@@locale': locale}
        for key, source in messages.items():
            catalog[key] = icu(current[key])
            if locale == 'en':
                parameters = sorted(set(re.findall(r'\{(p\d+)\}', source)))
                catalog['@' + key] = {'description': source,
                    'placeholders': {name: {'type': 'String'} for name in parameters}}
        folder = OUTPUT / 'arb'
        folder.mkdir(exist_ok=True)
        (folder / f'app_{locale}.arb').write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        if locale in ('pt_BR', 'zh_Hant'):
            base = locale.split('_')[0]
            fallback = dict(catalog, **{'@@locale': base})
            (folder / f'app_{base}.arb').write_text(json.dumps(fallback, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        cache_file.write_text(json.dumps(cache, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    (OUTPUT / 'ui_sources.json').write_text(json.dumps(messages, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    generate_lookup(messages, english)
    print('Строк:', len(messages))


if __name__ == '__main__': main()
