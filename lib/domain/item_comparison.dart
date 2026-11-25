import 'build_report.dart';

class ItemComparison {
  ItemComparison({
    required this.revision,
    required List<ItemComparisonRow> rows,
  }) : reason = null,
       warnings = const [],
       rows = List.unmodifiable(rows);

  ItemComparison.fromJson(JsonMap json)
    : revision = json['revision'] as int,
      reason = json['reason'] as String?,
      warnings = List.unmodifiable(jsonStrings(json['warnings'])),
      rows = List.unmodifiable(
        jsonRows(json['rows']).map(ItemComparisonRow.fromJson),
      );
  final int revision;
  final String? reason;
  final List<String> warnings;
  final List<ItemComparisonRow> rows;
}

class ItemComparisonRow {
  const ItemComparisonRow({
    required this.id,
    required this.label,
    this.actor = 'player',
    this.before,
    this.after,
    this.change,
  });

  ItemComparisonRow.fromJson(JsonMap json)
    : id = json['id'] as String,
      label = json['label'] as String,
      actor = json['actor'] as String? ?? 'player',
      before = json['beforeText'] as String?,
      after = json['afterText'] as String?,
      change = json['changeText'] as String?;
  final String id, label, actor;
  final String? before, after, change;
}
