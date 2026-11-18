import 'build_report.dart';

typedef TreePathStats = ({num? dps, num? life});
typedef TreePathOption = ({
  int target,
  int points,
  List<int> nodes,
  TreePathStats stats,
  String xml,
});
typedef TreePathReports = ({
  TreePathStats baseline,
  TreePathOption first,
  TreePathOption second,
});

class TreePathComparison {
  const TreePathComparison({
    required this.source,
    required this.sourceRevision,
    required this.buildId,
    required this.reports,
  });

  final BuildReport source;
  final String sourceRevision;
  final String? buildId;
  final TreePathReports reports;
}

const staleTreePaths = 'Сборка изменилась. Пересчитайте пути.';
