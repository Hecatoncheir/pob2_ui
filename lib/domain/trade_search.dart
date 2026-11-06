import 'build_report.dart';

typedef TradeChoice = ({String id, String label});

class TradeStat {
  TradeStat.fromJson(JsonMap json)
    : id = json['id'] as String,
      label = json['label'] as String,
      type = json['type'] as String,
      numeric = json['numeric'] == true,
      options = List.unmodifiable(
        jsonRows(json['options'])
            .map((row) => (id: '${row['id']}', label: row['text'] as String)),
      );
  final String id, label, type;
  final bool numeric;
  final List<TradeChoice> options;
}

class TradeCatalog {
  TradeCatalog.fromJson(JsonMap json)
    : stats = List.unmodifiable(
        jsonRows(json['stats']).map(TradeStat.fromJson),
      ),
      bases = List.unmodifiable(jsonStrings(json['bases'])),
      currencies = List.unmodifiable(
        jsonRows(json['currencies']).map(
          (row) => (id: row['id'] as String, label: row['label'] as String),
        ),
      ) {
    if (json['source'] != 'original-lua')
      throw const FormatException('Ожидался торговый каталог PoB');
  }
  final List<TradeStat> stats;
  final List<String> bases;
  final List<TradeChoice> currencies;
}

class TradeFilterDraft {
  const TradeFilterDraft(
    this.stat, {
    this.min = '',
    this.max = '',
    this.option,
  });
  final TradeStat stat;
  final String min, max;
  final String? option;

  TradeFilterDraft copyWith({String? min, String? max, String? option}) =>
      TradeFilterDraft(
        stat,
        min: min ?? this.min,
        max: max ?? this.max,
        option: option ?? this.option,
      );

  JsonMap toJson() => {
    'id': stat.id,
    if (min.trim().isNotEmpty) 'min': _number(min),
    if (max.trim().isNotEmpty) 'max': _number(max),
    if (option != null) 'option': option,
  };

  static num _number(String text) {
    final value = num.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite)
      throw const FormatException('Введите корректное число');
    return value;
  }
}
