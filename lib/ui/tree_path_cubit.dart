import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';
import '../domain/tree_geometry.dart';
import '../domain/tree_path_comparison.dart';
import 'workshop_cubit.dart';

typedef TreePathState = ({
  bool visible,
  int? first,
  int? second,
  bool busy,
  TreePathComparison? comparison,
  String? error,
});

const TreePathState _empty = (
  visible: false,
  first: null,
  second: null,
  busy: false,
  comparison: null,
  error: null,
);

class TreePathCubit extends Cubit<TreePathState> {
  TreePathCubit(this.model) : super(_empty);
  final WorkshopCubit model;
  int _generation = 0;

  void toggle() => _selection(visible: !state.visible);
  void reset() => _selection(visible: state.visible);

  void _selection({bool visible = true, int? first, int? second}) {
    _generation++;
    emit((
      visible: visible,
      first: first,
      second: second,
      busy: false,
      comparison: null,
      error: null,
    ));
  }

  void pick(TreeNode node) {
    if (!state.visible || state.busy || !model.canCompareTreePaths) return;
    if (node.allocated || _unavailable.contains(node.kind)) {
      _publish(error: 'Выберите неназначенный узел с доступным путём.');
      return;
    }
    final id = node.id;
    if (state.first == id) {
      _selection(first: state.second);
    } else if (state.second == id) {
      _selection(first: state.first);
    } else if (state.first == null) {
      _selection(first: id);
    } else {
      _selection(first: state.first, second: id);
    }
  }

  Future<void> calculate() async {
    final (:first, :second) = (first: state.first, second: state.second);
    if (first == null || second == null || state.busy) return;
    final generation = ++_generation;
    _publish(busy: true);
    try {
      final result = await model.compareTreePaths(first, second);
      if (_accept(generation)) _publish(comparison: result);
    } catch (error) {
      if (_accept(generation)) _publish(error: mcpErrorMessage(error));
    }
  }

  Future<void> apply({required bool first}) async {
    final comparison = state.comparison;
    if (state.busy || comparison == null) return;
    final generation = ++_generation;
    _publish(busy: true, comparison: comparison);
    final result = await model.applyTreePath(comparison, first: first);
    if (!_accept(generation)) return;
    if (result.committed) {
      _selection(visible: false);
    } else {
      _publish(comparison: comparison, error: result.error);
    }
  }

  bool _accept(int generation) => !isClosed && generation == _generation;

  void _publish({
    bool busy = false,
    TreePathComparison? comparison,
    String? error,
  }) {
    emit((
      visible: state.visible,
      first: state.first,
      second: state.second,
      busy: busy,
      comparison: comparison,
      error: error,
    ));
  }
}

const _unavailable = {'ClassStart', 'AscendClassStart', 'OnlyImage', 'Mastery'};
