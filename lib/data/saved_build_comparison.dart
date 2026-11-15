import '../domain/build_comparison.dart';
import '../domain/build_report.dart';
import '../domain/component.dart';
import 'mcp_client.dart';
import 'pob_build_document.dart';
import 'tree_progression_exchange.dart';

Future<BuildComparison> compareSavedXml(
  McpClient session,
  Installations components,
  String baselineXml,
  String candidateXml,
) async {
  try {
    await session.connect(components);
    await session.call('pob_import_xml', {
      'xml': splitTreeProgression(baselineXml).xml,
    });
    final original = await _readReport(session);
    final enemyLevel =
        _positiveLevel(original.config['enemyLevel']) ??
        _positiveLevel(original.configPlaceholders['enemyLevel']) ??
        original.level;
    final canonicalXml = await session.exportBuildXml();
    final conditions = PobBuildDocument(canonicalXml);
    await session.call('pob_import_xml', {'xml': canonicalXml});
    final before = await _readWithEnemyLevel(session, enemyLevel);
    final candidate = PobBuildDocument(splitTreeProgression(candidateXml).xml);
    await session.call('pob_import_xml', {
      'xml': candidate.withCalculationConditions(conditions),
    });
    final after = await _readWithEnemyLevel(session, enemyLevel);
    if (before.config['enemyLevel'] != enemyLevel ||
        !_sameConfig(before.config, after.config)) {
      throw const FormatException('Lua применил разные условия расчёта');
    }
    return (before: before, after: after, components: components);
  } finally {
    await session.close();
  }
}

Future<BuildReport> _readWithEnemyLevel(
  McpClient session,
  int enemyLevel,
) async {
  final report = await _readReport(session);
  if (report.config['enemyLevel'] == enemyLevel) return report;
  // PoB может опустить уровень врага при экспорте, если он равен умолчанию.
  await session.call('pob_set_config', {
    'values': {'enemyLevel': enemyLevel},
  });
  return _readReport(session);
}

Future<BuildReport> _readReport(McpClient session) async =>
    parseBuildReport(await session.call('pob_check_build'));

int? _positiveLevel(Object? value) => value is int && value > 0 ? value : null;

bool _sameConfig(JsonMap first, JsonMap second) =>
    first.length == second.length &&
    first.entries.every((entry) => second[entry.key] == entry.value);
