import 'build_report.dart';
import 'engine_session.dart';
import 'tree_allocation_mode.dart';

typedef TreePathStats = ({num? dps, num? life});
typedef TreePathOption = ({
  int target,
  int points,
  List<int> nodes,
  TreePathStats stats,
  String? xml,
});
typedef TreePathReports = ({
  TreePathStats baseline,
  TreePathOption first,
  TreePathOption second,
});

typedef EngineTreePaths = ({
  EngineTreePreviewOffer first,
  EngineTreePreviewOffer second,
  int inputRevision,
  int bindingEpoch,
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
    this.enginePaths,
  });

  final BuildReport source;
  final String sourceRevision;
  final String? buildId;
  final TreePathReports reports;
  final TreeAllocationMode mode;
  final int weaponSet;
  final String componentSource;
  final EngineTreePaths? enginePaths;
}

const staleTreePaths = 'Сборка изменилась. Пересчитайте пути.';
