import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/tree_allocation_mode.dart';
import '../domain/tree_path_comparison.dart';
import 'mcp_client.dart';
import 'pob_build_document.dart';

Future<TreePathReports> compareTreePaths(
  McpClient session,
  Installations components,
  String source,
  int first,
  int second, {
  TreeAllocationMode mode = TreeAllocationMode.common,
}) async {
  if (first == second) {
    throw const FormatException('Выберите два разных узла.');
  }
  try {
    await session.connect(components);
    await _import(session, source, mode);
    final baseline = await _readReport(session);
    final before = PobBuildDocument(source);
    final left = await _preview(session, baseline, before, first, mode);
    await _import(session, source, mode);
    final right = await _preview(session, baseline, before, second, mode);
    return (baseline: _stats(baseline), first: left, second: right);
  } finally {
    await session.close();
  }
}

Future<void> _import(
  McpClient session,
  String source,
  TreeAllocationMode mode,
) async {
  await session.call('pob_import_xml', {'xml': source});
  await session.call('pob_tree_options', {'mode': mode.luaValue});
}

Future<TreePathOption> _preview(
  McpClient session,
  BuildReport baseline,
  PobBuildDocument before,
  int target,
  TreeAllocationMode mode,
) async {
  final tip = await session.call('pob_node_tooltip', {
    'id': target,
    'compare': false,
  });
  _checkTarget(tip, target, before.allocatedNodes);
  await session.call('pob_tree_action', {'id': target, 'action': 'allocate'});
  final after = await _readReport(session);
  _checkConditions(baseline, after);
  final xml = await session.exportBuildXml();
  final next = PobBuildDocument(xml);
  final allocation = before.allocationModes;
  final changed =
      next.allocationModes.entries
          .where((entry) => allocation[entry.key] != entry.value)
          .map((entry) => entry.key)
          .toList()
        ..sort();
  if (!next.allocatedNodes.containsAll(before.allocatedNodes) ||
      !changed.contains(target)) {
    throw const FormatException('Lua назначил другой путь.');
  }
  return (
    target: target,
    points: _usedPoints(after, mode) - _usedPoints(baseline, mode),
    nodes: List<int>.unmodifiable(changed),
    stats: _stats(after),
    xml: xml,
  );
}

void _checkTarget(JsonMap tip, int target, Set<int> allocated) {
  if (tip case {'path': final List<Object?> path}
      when path.firstOrNull == target && !allocated.contains(target)) {
    return;
  }
  throw const FormatException('К выбранному узлу нет пути.');
}

int _usedPoints(BuildReport report, TreeAllocationMode mode) {
  final pairs = RegExp(r'(\d+)\s*/\s*(\d+)').allMatches(report.points).toList();
  if (pairs.length != 4) {
    throw const FormatException('Lua не вернул счётчики очков дерева.');
  }
  return int.parse(pairs[mode.luaValue][1]!);
}

void _checkConditions(BuildReport before, BuildReport after) {
  if (before.level != after.level ||
      before.weaponSet != after.weaponSet ||
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
  final expected = PobBuildDocument(option.xml!);
  final nodes = applied.allocatedNodes;
  final previewNodes = expected.allocatedNodes;
  if (nodes.length != previewNodes.length ||
      !nodes.containsAll(previewNodes) ||
      !applied.hasSameTreeAllocation(expected)) {
    throw const FormatException('Lua назначил другой путь.');
  }
}
