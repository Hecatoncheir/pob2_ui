class GameDictionary {
  GameDictionary(
    this.language,
    Map<String, String> english,
    Map<String, String> localized,
  ) {
    final ambiguous = <String>{};
    for (final entry in english.entries) {
      final value = localized[entry.key];
      if (entry.value.isEmpty || value == null || value.isEmpty) continue;
      if (entry.value.contains('#')) {
        _addTemplate(entry.key, entry.value, value);
      } else {
        _addExact(entry.value, value, ambiguous);
      }
    }
  }
  GameDictionary.english() : language = 'en';
  final String language;
  final _exact = <String, String>{};
  final _templates = <String, List<_Template>>{};
  final _passiveKeys = <String>{};
  static final _number = RegExp(r'[+-]?[0-9]+(?:[.,][0-9]+)?');

  void _addExact(String source, String value, Set<String> ambiguous) {
    if (ambiguous.contains(source)) return;
    final previous = _exact[source];
    if (previous != null && previous != value) {
      ambiguous.add(source);
      _exact.remove(source);
      return;
    }
    _exact[source] = value;
  }

  void _addTemplate(String id, String source, String value) {
    // Выгрузка нормализует позиции до #. Для нескольких чисел порядок
    // аргументов не доказан: такие строки оставляем в исходном виде.
    if ('#'.allMatches(source).length != 1 || '#'.allMatches(value).length != 1)
      return;
    final key = _key(source);
    // В описаниях дерева предпочитаем профильный каталог: другие категории
    // иногда переводят ту же английскую фразу с иным предлогом или регистром.
    final passive = id.startsWith('stat_translations/passive_skill.');
    if (!passive && _passiveKeys.contains(key)) return;
    if (passive && _passiveKeys.add(key)) _templates.remove(key);
    _templates.putIfAbsent(key, () => []).add(_Template(source, value));
  }

  String translate(String source) {
    final text = source.trim();
    final exact = _exact[text];
    if (exact != null) return _keepSpace(source, text, exact);
    final key = _key(text);
    final candidates = _templates[key] ?? const [];
    final matches = candidates
        .map((template) => template.apply(text))
        .nonNulls
        .toSet();
    if (matches.length != 1) return source;
    return _keepSpace(source, text, matches.single);
  }

  String _keepSpace(String source, String text, String translated) {
    final start = source.indexOf(text);
    return source.substring(0, start) +
        translated +
        source.substring(start + text.length);
  }

  static String _key(String text) =>
      text.replaceAll(_number, '#').replaceAll('+#', '#').replaceAll('-#', '#');
}

class _Template {
  _Template(String source, this.localized)
    : pattern = RegExp(
        '^${RegExp.escape(source).replaceAll('#', r'([+-]?[0-9]+(?:[.,][0-9]+)?)')}'
        r'$',
      );
  final RegExp pattern;
  final String localized;
  String? apply(String source) {
    final match = pattern.firstMatch(source);
    return match == null ? null : localized.replaceFirst('#', match[1]!);
  }
}
