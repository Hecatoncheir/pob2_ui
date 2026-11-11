import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/tree_progression_repository.dart';
import '../domain/tree_progression.dart';

typedef TreeProgressionState = ({
  List<TreeProgressionStep> steps,
  int? selected,
  bool ready,
  String? error,
  TreeProgressionView view,
});

typedef TreeProgressionView = ({
  bool visible,
  TreeProgressionFocusRequested? focus,
  int? hoveredNode,
});

sealed class TreeProgressionEvent {
  const TreeProgressionEvent();
}

final class TreeProgressionOpened extends TreeProgressionEvent {
  const TreeProgressionOpened();
}

final class TreeProgressionVisibilityChanged extends TreeProgressionEvent {
  const TreeProgressionVisibilityChanged(this.visible);
  final bool visible;
}

final class TreeProgressionFocusRequested extends TreeProgressionEvent {
  TreeProgressionFocusRequested(this.id);
  final int id;
}

final class TreeProgressionNodeHovered extends TreeProgressionEvent {
  const TreeProgressionNodeHovered(this.id);
  final int? id;
}

final class TreeProgressionRecorded extends TreeProgressionEvent {
  const TreeProgressionRecorded(this.step);
  final TreeProgressionStep step;
}

final class TreeProgressionEdited extends TreeProgressionEvent {
  const TreeProgressionEdited(this.step, this.details);
  final TreeProgressionStep step;
  final TreeProgressionDetails details;
}

final class TreeProgressionSelected extends TreeProgressionEvent {
  const TreeProgressionSelected(this.step);
  final TreeProgressionStep? step;
}

final class TreeProgressionRemoved extends TreeProgressionEvent {
  const TreeProgressionRemoved(this.step);
  final TreeProgressionStep step;
}

class TreeProgressionBloc
    extends Bloc<TreeProgressionEvent, TreeProgressionState> {
  TreeProgressionBloc(this.repository)
    : super((
        steps: const [],
        selected: null,
        ready: false,
        error: null,
        view: (visible: false, focus: null, hoveredNode: null),
      )) {
    on<TreeProgressionEvent>(
      _apply,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  final TreeProgressionRepository repository;

  Future<void> _apply(
    TreeProgressionEvent event,
    Emitter<TreeProgressionState> emit,
  ) async {
    switch (event) {
      case TreeProgressionOpened():
        await _open(emit);
      case TreeProgressionVisibilityChanged(:final visible):
        _setView(emit, (visible: visible, focus: null, hoveredNode: null));
      case TreeProgressionFocusRequested():
        _setView(emit, (
          visible: state.view.visible,
          focus: event,
          hoveredNode: null,
        ));
      case TreeProgressionNodeHovered(:final id):
        _setView(emit, (
          visible: state.view.visible,
          focus: state.view.focus,
          hoveredNode: id,
        ));
      case TreeProgressionRecorded(:final step) when state.ready:
        await _insert(emit, [...state.steps], step);
      case TreeProgressionEdited(:final step, :final details) when state.ready:
        await _edit(emit, step, details);
      case TreeProgressionSelected(:final step) when state.ready:
        _select(emit, step);
      case TreeProgressionRemoved(:final step) when state.ready:
        final steps = [...state.steps]..remove(step);
        await _save(emit, steps, null);
      default:
        break;
    }
  }

  Future<void> _edit(
    Emitter<TreeProgressionState> emit,
    TreeProgressionStep step,
    TreeProgressionDetails details,
  ) async {
    final (:level, :title, :note) = details;
    if (details == step.details || level < 1 || level > 100) return;
    final steps = [...state.steps];
    final index = steps.indexOf(step);
    if (index < 0) return;
    final edited = TreeProgressionStep(
      level,
      step.nodes,
      title: title,
      note: note,
      allocation: step.allocation,
    );
    if (level != step.level) {
      steps.removeAt(index);
      await _insert(emit, steps, edited);
      return;
    }
    steps[index] = edited;
    await _save(emit, steps, index);
  }

  Future<void> _insert(
    Emitter<TreeProgressionState> emit,
    List<TreeProgressionStep> steps,
    TreeProgressionStep step,
  ) async {
    final next = steps.indexWhere((entry) => entry.level > step.level);
    final index = next < 0 ? steps.length : next;
    steps.insert(index, step);
    await _save(emit, steps, index);
  }

  Future<void> _open(Emitter<TreeProgressionState> emit) async {
    try {
      _emit(emit, await repository.load(), null);
    } catch (_) {
      emit((
        steps: const [],
        selected: null,
        ready: false,
        error: 'Не удалось открыть план прокачки',
        view: state.view,
      ));
    }
  }

  void _setView(Emitter<TreeProgressionState> emit, TreeProgressionView view) =>
      emit((
        steps: state.steps,
        selected: state.selected,
        ready: state.ready,
        error: state.error,
        view: view,
      ));

  void _select(Emitter<TreeProgressionState> emit, TreeProgressionStep? step) {
    final index = step == null ? -1 : state.steps.indexOf(step);
    _emit(emit, state.steps, index < 0 ? null : index);
  }

  void _emit(
    Emitter<TreeProgressionState> emit,
    List<TreeProgressionStep> steps,
    int? index,
  ) => emit((
    steps: List.unmodifiable(steps),
    selected: index,
    ready: true,
    error: null,
    view: (visible: state.view.visible, focus: null, hoveredNode: null),
  ));

  Future<void> _save(
    Emitter<TreeProgressionState> emit,
    List<TreeProgressionStep> steps,
    int? index,
  ) async {
    try {
      await repository.save(steps);
      _emit(emit, steps, index);
    } catch (_) {
      emit((
        steps: state.steps,
        selected: state.selected,
        ready: true,
        error: 'Не удалось сохранить план прокачки',
        view: state.view,
      ));
    }
  }
}
