import 'build_report.dart';

class ConditionDefinition {
  ConditionDefinition({
    required this.id,
    required this.name,
    required this.type,
    List<JsonMap> choices = const [],
  }) : choices = List.unmodifiable(_uniqueChoices(choices));
  factory ConditionDefinition.fromJson(JsonMap json) => switch (json) {
    {
      'id': final String id,
      'name': final String name,
      'type': final String type,
    } =>
      ConditionDefinition(
        id: id,
        name: name,
        type: type,
        choices: jsonRows(json['choices']),
      ),
    _ => throw const FormatException('Lua не вернул описание условия'),
  };
  final String id, name, type;
  final List<JsonMap> choices;

  bool get editable => const {
    'check',
    'list',
    'text',
    'count',
    'countAllowZero',
    'integer',
    'float',
  }.contains(type);

  String get label =>
      const {
        'enemyIsBoss': 'Тип противника',
        'resistancePenalty': 'Штраф сопротивлений',
        'enemySizePreset': 'Размер противника',
        'enemyLevel': 'Уровень противника',
        'customMods': 'Пользовательские модификаторы',
      }[id] ??
      (name.isEmpty ? id : cleanPoB(name));

  Object? selection(Object? current) {
    if (type == 'check') return current == true;
    return choices.any((choice) => choice['value'] == current) ? current : null;
  }

  Object parse(String text, Object? selection) => switch (type) {
    'text' => text,
    'check' => switch (selection) {
      final bool value => value,
      _ => throw const FormatException('Выберите значение'),
    },
    'list' => _listValue(selection),
    _ => _number(text),
  };

  num _number(String text) {
    if (!editable)
      throw const FormatException('Тип условия пока не поддерживается');
    final value = type == 'float'
        ? double.tryParse(text.trim().replaceAll(',', '.'))
        : int.tryParse(text.trim());
    if (value == null || !value.isFinite) {
      throw FormatException(
        type == 'float' ? 'Введите число' : 'Введите целое число',
      );
    }
    return value;
  }

  Object _listValue(Object? value) {
    if (value == null || !choices.any((choice) => choice['value'] == value)) {
      throw const FormatException('Выберите значение из каталога');
    }
    return value;
  }
}

Iterable<JsonMap> _uniqueChoices(List<JsonMap> choices) {
  final values = <Object>{};
  return choices.where((choice) {
    final Object? value = choice['value'] as Object?;
    return value != null && values.add(value);
  });
}
