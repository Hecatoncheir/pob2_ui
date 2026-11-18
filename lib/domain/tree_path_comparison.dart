import 'build_report.dart';
import 'tree_allocation_mode.dart';

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
    required this.mode,
    required this.weaponSet,
    required this.componentSource,
  });

  final BuildReport source;
  final String sourceRevision;
  final String? buildId;
  final TreePathReports reports;
  final TreeAllocationMode mode;
  final int weaponSet;
  final String componentSource;
}

const staleTreePaths = 'Сборка изменилась. Пересчитайте пути.';
