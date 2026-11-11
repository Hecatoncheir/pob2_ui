import 'dart:convert';

import 'build_report.dart';
import 'progression_comparison.dart';

typedef ProgressionGem = ({
  String? id,
  String name,
  String group,
  int level,
  int quality,
  bool enabled,
  bool main,
});
typedef ProgressionItem = ({String name, String raw});
typedef ProgressionItemChange = ({
  String slot,
  int? nodeId,
  ProgressionItem? before,
  ProgressionItem? after,
});
typedef ProgressionGemChange = ({
  ProgressionGem? before,
  ProgressionGem? after,
});

extension ProgressionLoadoutChange on ProgressionComparison {
  List<ProgressionGemChange> get gems {
    final old = _gems(before);
    final next = _gems(after);
    return [
      for (final key in {...old.keys, ...next.keys})
        if (_gemValues(old[key]) != _gemValues(next[key]))
          (before: old[key], after: next[key]),
    ];
  }

  List<ProgressionItemChange> get equipment {
    final old = _equipped(before);
    final next = _equipped(after);
    return [
      for (final key in {...old.keys, ...next.keys})
        if (old[key] != next[key])
          (
            slot: key.slot,
            nodeId: key.nodeId,
            before: old[key],
            after: next[key],
          ),
    ];
  }
}

Map<({String slot, int? nodeId}), ProgressionItem> _equipped(
  BuildReport report,
) {
  final items = {for (final item in report.items) item['id']: item};
  return {
    for (final slot in report.slots)
      if (slot case {'name': final String name, 'itemId': final int id})
        if (items[id] case {'name': final String item, 'raw': final String raw})
          (slot: name, nodeId: slot['nodeId'] as int?): (name: item, raw: raw),
  };
}

Object? _gemValues(ProgressionGem? gem) => gem == null
    ? null
    : (gem.name, gem.level, gem.quality, gem.enabled, gem.main);

typedef _GemKey = (String, int, String, int);

Map<_GemKey, ProgressionGem> _gems(BuildReport report) {
  final occurrences = <String, int>{};
  final selected = report.groupSelector['selected'];
  return {
    for (final group in report.groups)
      ..._groupGems(group, occurrences, selected == group['id']),
  };
}

Map<_GemKey, ProgressionGem> _groupGems(
  JsonMap group,
  Map<String, int> occurrences,
  bool main,
) {
  final gems = jsonRows(group['gems']);
  if (gems.isEmpty) return {};
  final base = jsonEncode([
    group['source'],
    group['supportScope'],
    group['slotSupports'] == true ? null : _gemId(gems.first),
  ]);
  final index = _next(occurrences, base);
  final gemOccurrences = <String, int>{};
  return {
    for (final gem in gems)
      (base, index, _gemId(gem), _next(gemOccurrences, _gemId(gem))): _gem(
        gem,
        group,
        main && identical(gem, gems.first),
      ),
  };
}

int _next(Map<String, int> occurrences, String key) =>
    occurrences.update(key, (value) => value + 1, ifAbsent: () => 0);

String _gemId(JsonMap gem) => '${gem['id'] ?? gem['skillId'] ?? gem['name']}';

ProgressionGem _gem(JsonMap gem, JsonMap group, bool main) => (
  id: gem['id'] as String?,
  name: cleanPoB('${gem['name'] ?? _gemId(gem)}'),
  group: cleanPoB('${group['label'] ?? ''}'),
  level: gem['level'] as int? ?? 1,
  quality: gem['quality'] as int? ?? 0,
  enabled: group['enabled'] != false && gem['enabled'] != false,
  main: main,
);
