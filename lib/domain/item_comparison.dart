import 'build_report.dart';

class ItemComparison {
  ItemComparison.fromJson(JsonMap json)
    : revision = json['revision'] as int,
      reason = json['reason'] as String?,
      rows = List.unmodifiable(
        jsonRows(json['rows']).map(ItemComparisonRow.fromJson),
      );
  final int revision;
  final String? reason;
  final List<ItemComparisonRow> rows;
}

class ItemComparisonRow {
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
