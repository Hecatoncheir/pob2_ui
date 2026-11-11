import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/equipment_item.dart';
import '../domain/progression_comparison.dart';
import '../domain/tree_progression.dart';
import 'equipment_repository.dart';
import 'game_catalog_repository.dart';
import 'mcp_client.dart';
import 'pob_build_document.dart';

typedef ProgressionComparisonSource = ({
  Installations components,
  BuildReport report,
  String xml,
  Set<int> starts,
});

class ProgressionComparisonSession {
  ProgressionComparisonSession(this.readSource);

  final Future<ProgressionComparisonSource> Function() readSource;
  final _engine = McpClient();
  late final _catalog = GameCatalogRepository(_engine);
  late final _equipment = EquipmentRepository(_engine);

  Future<ProgressionComparison> compare(
    TreeProgressionStep step,
    Set<ProgressionPart> parts, {
    TreeProgressionStep? baseline,
  }) async {
    final source = await readSource();
    if (!_engine.connected) await _engine.connect(source.components);
    final before = baseline == null
        ? (
            report: source.report,
            nodes: PobBuildDocument(source.xml).allocatedNodes
                .difference(source.starts),
          )
        : await _calculate(source, baseline, baseline.parts);
    final after = await _calculate(source, step, parts);
    return (
      before: before.report,
      after: after.report,
      nodes: (
        added: after.nodes.difference(before.nodes),
        removed: before.nodes.difference(after.nodes),
      ),
    );
  }

  Future<({BuildReport current, List<BuildReport> stages})> reports(
    List<TreeProgressionStep> steps,
  ) async {
    final source = await readSource();
    await _engine.connect(source.components);
    return (
      current: source.report,
      stages: [
        for (final step in steps)
          (await _calculate(source, step, step.parts)).report,
      ],
    );
  }

  Future<({BuildReport report, Set<int> nodes})> _calculate(
    ProgressionComparisonSource source,
    TreeProgressionStep step,
    Set<ProgressionPart> parts,
  ) async {
    final candidate = PobBuildDocument(source.xml)
        .withProgression(step, parts: parts);
    await _engine.call('pob_import_xml', {'xml': candidate});
    final result = await _engine.call('pob_check_build');
    final report = parseBuildReport(result);
    final after = PobBuildDocument(await _engine.exportBuildXml())
        .allocatedNodes
        .difference(source.starts);
    if (parts.contains(ProgressionPart.tree)) {
      verifyProgressionTree(step, report.level, after);
    }
    return (report: report, nodes: after);
  }

  Future<List<JsonMap>> describeGem(String id, int level, int quality) =>
      _catalog.gemTooltip(id: id, level: level, quality: quality);

  Future<ItemInspection> describeItem(String raw) =>
      _equipment.inspect(raw: raw);

  Future<void> close() => _engine.close();
}
