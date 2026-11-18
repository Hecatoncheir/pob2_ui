import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/tree_path_comparison.dart';
import 'mcp_client.dart';
import 'pob_build_document.dart';

Future<TreePathReports> compareTreePaths(
  McpClient session,
  Installations components,
  String source,
  int first,
  int second,
) async {
  if (first == second) {
    throw const FormatException('Выберите два разных узла.');
  }
  try {
    await session.connect(components);
    await _import(session, source);
    final baseline = await _readReport(session);
    final allocated = PobBuildDocument(source).allocatedNodes;
    final left = await _preview(session, baseline, allocated, first);
    await _import(session, source);
    final right = await _preview(session, baseline, allocated, second);
    return (baseline: _stats(baseline), first: left, second: right);
  } finally {
    await session.close();
  }
}

Future<void> _import(McpClient session, String source) async {
  await session.call('pob_import_xml', {'xml': source});
}

Future<TreePathOption> _preview(
  McpClient session,
  BuildReport baseline,
  Set<int> allocated,
  int target,
) async {
  final tip = await session.call('pob_node_tooltip', {
    'id': target,
    'compare': false,
  });
  final path = _path(tip, target, allocated);
  await session.call('pob_tree_action', {'id': target, 'action': 'allocate'});
  final after = await _readReport(session);
  _checkConditions(baseline, after);
  final xml = await session.exportBuildXml();
  final next = PobBuildDocument(xml).allocatedNodes;
  final added = next.difference(allocated);
  if (!next.containsAll(allocated) ||
      added.length != path.nodes.length ||
      !added.containsAll(path.nodes)) {
    throw const FormatException('Lua назначил другой путь.');
  }
  return (
    target: target,
    points: path.points,
    nodes: path.nodes,
    stats: _stats(after),
    xml: xml,
  );
}

({int points, List<int> nodes}) _path(
  JsonMap tip,
  int target,
  Set<int> allocated,
) {
  if (tip case {'points': final int points, 'path': final List<Object?> path}
      when points > 0 &&
          path.firstOrNull == target &&
          !allocated.contains(target)) {
    final nodes = List<int>.unmodifiable(path.reversed.cast<int>());
    return (points: points, nodes: nodes);
  }
  throw const FormatException('К выбранному узлу нет пути.');
}

void _checkConditions(BuildReport before, BuildReport after) {
  if (before.level != after.level ||
      before.mainSkill != after.mainSkill ||
      before.config.length != after.config.length ||
      !before.config.entries.every(
        (entry) => after.config[entry.key] == entry.value,
      )) {
    throw const FormatException('Lua применил разные условия расчёта');
  }
}

Future<BuildReport> _readReport(McpClient session) async =>
    parseBuildReport(await session.call('pob_check_build'));

TreePathStats _stats(BuildReport report) =>
    (dps: report.stats['TotalDPS'] as num?, life: report.stats['Life'] as num?);

void checkAppliedTreePath(String xml, TreePathOption option) {
  final applied = PobBuildDocument(xml);
  final expected = PobBuildDocument(option.xml);
  final nodes = applied.allocatedNodes;
  final previewNodes = expected.allocatedNodes;
  if (nodes.length != previewNodes.length ||
      !nodes.containsAll(previewNodes) ||
      !applied.hasSameTreeAllocation(expected)) {
    throw const FormatException('Lua назначил другой путь.');
  }
}
