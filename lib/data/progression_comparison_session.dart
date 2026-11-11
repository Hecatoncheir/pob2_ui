import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/progression_comparison.dart';
import '../domain/tree_progression.dart';
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

  Future<ProgressionComparison> compare(
    TreeProgressionStep step,
    Set<ProgressionPart> parts,
  ) async {
    final source = await readSource();
    final original = PobBuildDocument(source.xml);
    final before = original.allocatedNodes.difference(source.starts);
    final candidate = original.withProgression(step, parts: parts);
    if (!_engine.connected) await _engine.connect(source.components);
    await _engine.call('pob_import_xml', {'xml': candidate});
    final result = await _engine.call('pob_check_build');
    final report = parseBuildReport(result);
    final after = PobBuildDocument(await _engine.exportBuildXml())
        .allocatedNodes
        .difference(source.starts);
    if (parts.contains(ProgressionPart.tree)) {
      verifyProgressionTree(step, report.level, after);
    }
    return (
      before: source.report,
      after: report,
      nodes: (
        added: after.difference(before),
        removed: before.difference(after),
      ),
    );
  }

  Future<void> close() => _engine.close();
}
