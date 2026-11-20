import 'build_report.dart';
import 'skill_gem.dart';

typedef SupportCompatibility = ({
  Set<String> ids,
  SupportSockets? sockets,
  List<String> warnings,
});

class SupportSockets {
  const SupportSockets(this.count, this.enabled, this.scope, this.allowed);
  factory SupportSockets.fromJson(JsonMap json) => switch (json) {
    {
      'supportCount': final int count,
      'enabledSupportCount': final int enabled,
      'scope': final String scope,
      'supportsAllowed': final bool allowed,
      'capacity': null,
      'capacityStatus': 'unavailable',
    }
        when count >= 0 && enabled >= 0 && enabled <= count =>
      SupportSockets(count, enabled, scope, allowed),
    _ => throw const FormatException('Lua не вернул сведения о ячейках'),
  };
  final int count, enabled;
  final String scope;
  final bool allowed;
}

class SupportComparisonEntry {
  const SupportComparisonEntry({
    required this.id,
    this.dps,
    this.error,
    this.warnings = const [],
  });
  factory SupportComparisonEntry.fromJson(JsonMap json) {
    final id = json['supportId'];
    if (id is! String) throw const FormatException('Нет ID поддержки');
    if (json['error'] case {
      'code': final String _,
      'message': final String error,
    }) {
      return SupportComparisonEntry(id: id, error: error);
    }
    if (json case {
      'source': 'original-lua',
      'before': final num? before,
      'after': final num? after,
      'delta': final num? delta,
    }) {
      if ([
        before,
        after,
        delta,
      ].whereType<num>().every((value) => value.isFinite)) {
        return SupportComparisonEntry(
          id: id,
          dps: (before: before, after: after, delta: delta),
          warnings: List.unmodifiable(jsonStrings(json['warnings'])),
        );
      }
    }
    throw const FormatException('Lua не вернул сравнение поддержек');
  }
  final String id;
  final SupportDps? dps;
  final String? error;
  final List<String> warnings;
}

class SupportComparison {
  SupportComparison(
    this.xmlHash,
    this.revision,
    List<SupportComparisonEntry> entries,
  ) : entries = List.unmodifiable(entries);
  final String xmlHash;
  final int revision;
  final List<SupportComparisonEntry> entries;

  List<SupportComparisonEntry> get ranked => [...entries]..sort(_compare);

  static int _compare(SupportComparisonEntry a, SupportComparisonEntry b) {
    final first = a.dps?.delta;
    final second = b.dps?.delta;
    if (first != null && second != null) return second.compareTo(first);
    if (first != null) return -1;
    if (second != null) return 1;
    if (a.error == null && b.error != null) return -1;
    if (a.error != null && b.error == null) return 1;
    return a.id.compareTo(b.id);
  }
}
