typedef JsonMap = Map<String, dynamic>;

JsonMap jsonMap(dynamic value) => value is JsonMap ? value : const {};
List<JsonMap> jsonRows(dynamic value) => value is List
    ? value
          .map((row) => Map<String, dynamic>.unmodifiable(row as JsonMap))
          .toList(growable: false)
    : const [];
List<String> jsonStrings(dynamic value) => value is List
    ? value.map((row) => '$row').toList(growable: false)
    : const [];
String cleanPoB(String value) =>
    value.replaceAll(RegExp(r'\^x[0-9a-fA-F]{6}|\^\d'), '').trim();

class BuildReport {
  BuildReport.fromJson(JsonMap json) : raw = Map.unmodifiable(json) {
    if (json['source'] != 'original-lua')
      throw const FormatException('Ожидался отчёт исходного Lua');
  }
  final JsonMap raw;
  JsonMap get stats => jsonMap(raw['stats']);
  JsonMap get snapshot => jsonMap(raw['snapshot']);
  JsonMap get character => jsonMap(snapshot['buildInfo']);
  JsonMap get config => jsonMap(raw['config']);
  List<JsonMap> get groups => jsonRows(raw['groups']);
  List<JsonMap> get items => jsonRows(raw['items']);
  List<JsonMap> get slots => jsonRows(raw['slots']);
  String get name => character['name'] as String? ?? 'Сборка';
  String get characterClass => character['class'] as String? ?? '—';
  int get level => character['level'] as int? ?? 0;
  String get points => cleanPoB(raw['pointDisplay'] as String? ?? '');
  String get treeVersion => snapshot['treeVersion'] as String? ?? '—';
  JsonMap get groupSelector => jsonMap(character['groups']);
  JsonMap get skillSelector => jsonMap(character['skills']);
  String get mainSkill {
    final selected = skillSelector['selected'];
    return jsonRows(skillSelector['entries'])
            .where((entry) => entry['id'] == selected)
            .map((entry) => '${entry['label']}')
            .firstOrNull ??
        'Умение не выбрано';
  }

  List<String> get warnings =>
      [
            ...jsonStrings(raw['warnings']),
            ..._gemWarnings(),
            ..._itemWarnings(),
            ..._modifierWarnings(),
          ]
          .map(cleanPoB)
          .where((line) => line.isNotEmpty)
          .toSet()
          .toList(growable: false);

  Iterable<String> _gemWarnings() sync* {
    for (final group in groups) {
      for (final gem in jsonRows(group['gems'])) {
        if (gem['error'] case final String error when error.isNotEmpty)
          yield '${gem['name']}: $error';
      }
    }
  }

  Iterable<String> _itemWarnings() sync* {
    for (final item in items) {
      for (final line in jsonRows(item['unsupported'])) {
        yield '${item['name']}: ${line['line']}';
      }
    }
  }

  Iterable<String> _modifierWarnings() sync* {
    for (final block in jsonRows(raw['customMods'])) {
      for (final line in jsonRows(block['unparsed'])) {
        yield '${block['title']}: ${line['line']}';
      }
    }
  }
}

String formatStat(dynamic value, {String suffix = ''}) {
  if (value is! num || !value.isFinite) return '—';
  final digits = value.abs() < 10 && value != value.roundToDouble() ? 2 : 0;
  final parts = value.toStringAsFixed(digits).split('.');
  final integer = parts.first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}\u2009',
  );
  return '$integer${parts.length == 2 ? ',${parts[1]}' : ''}$suffix';
}

const statGroups = <String, Map<String, String>>{
  'Урон': {
    'TotalDPS': 'DPS',
    'FullDPS': 'Полный DPS',
    'AverageDamage': 'Средний урон',
    'Speed': 'Скорость',
    'CritChance': 'Крит. шанс',
    'HitChance': 'Шанс попадания',
  },
  'Ресурсы': {
    'Life': 'Здоровье',
    'EnergyShield': 'Энергощит',
    'Mana': 'Мана',
    'Spirit': 'Дух',
    'LifeRegen': 'Регенерация здоровья',
    'ManaRegen': 'Регенерация маны',
  },
  'Защита': {
    'Armour': 'Броня',
    'Evasion': 'Уклонение',
    'EffectiveHitPool': 'Эффективное здоровье',
    'BlockChance': 'Блок',
  },
  'Сопротивления': {
    'FireResist': 'Огонь',
    'ColdResist': 'Холод',
    'LightningResist': 'Молния',
    'ChaosResist': 'Хаос',
  },
  'Характеристики': {
    'Str': 'Сила',
    'Dex': 'Ловкость',
    'Int': 'Интеллект',
    'MovementSpeedMod': 'Передвижение',
  },
};

String statLabel(String key) =>
    statGroups.values
        .expand((group) => group.entries)
        .where((entry) => entry.key == key)
        .map((entry) => entry.value)
        .firstOrNull ??
    key;
