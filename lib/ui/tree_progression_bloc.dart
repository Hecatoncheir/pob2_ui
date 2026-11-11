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
  bool following,
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
  const TreeProgressionEdited(this.step, this.details, {this.tasks});
  final TreeProgressionStep step;
  final TreeProgressionDetails details;
  final List<String>? tasks;
}

final class TreeProgressionUpdated extends TreeProgressionEvent {
  const TreeProgressionUpdated(this.step, this.update);
  final TreeProgressionStep step;
  final TreeProgressionStep Function(TreeProgressionStep) update;
}

final class TreeProgressionFollowingChanged extends TreeProgressionEvent {
  const TreeProgressionFollowingChanged(this.following);
  final bool following;
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
        view: (
          visible: false,
          following: false,
          focus: null,
          hoveredNode: null,
        ),
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
        _setView(emit, (
          visible: visible,
          following: state.view.following,
          focus: null,
          hoveredNode: null,
        ));
      case TreeProgressionFollowingChanged(:final following):
        _setView(emit, (
          visible: state.view.visible,
          following: following,
          focus: state.view.focus,
          hoveredNode: state.view.hoveredNode,
        ));
      case TreeProgressionFocusRequested():
        _setView(emit, (
          visible: state.view.visible,
          following: state.view.following,
          focus: event,
          hoveredNode: null,
        ));
      case TreeProgressionNodeHovered(:final id):
        _setView(emit, (
          visible: state.view.visible,
          following: state.view.following,
          focus: state.view.focus,
          hoveredNode: id,
        ));
      case TreeProgressionRecorded(:final step) when state.ready:
        await _insert(emit, [...state.steps], step);
      case TreeProgressionEdited() when state.ready:
        await _edit(emit, event);
      case TreeProgressionUpdated(:final step, :final update) when state.ready:
        await _replace(emit, step, update);
      case TreeProgressionSelected(:final step) when state.ready:
        _select(emit, step);
      case TreeProgressionRemoved(:final step) when state.ready:
        await _save(emit, [
          for (final entry in state.steps)
            if (entry.identity != step.identity) entry,
        ], null);
      default:
        break;
    }
  }

  Future<void> _edit(
    Emitter<TreeProgressionState> emit,
    TreeProgressionEdited event,
  ) async {
    final details = event.details;
    if (details.level < 1 || details.level > 100) return;
    await _replace(
      emit,
      event.step,
      (step) => step.withProgress(
        details: details,
        tasks: _editTasks(step, event.tasks),
      ),
    );
  }

  List<ProgressionTask>? _editTasks(
    TreeProgressionStep step,
    List<String>? labels,
  ) {
    if (labels == null) return null;
    final completed = {for (final task in step.tasks) task.text: task.done};
    return [
      for (final text in labels) (text: text, done: completed[text] ?? false),
    ];
  }

  Future<void> _replace(
    Emitter<TreeProgressionState> emit,
    TreeProgressionStep step,
    TreeProgressionStep Function(TreeProgressionStep) update,
  ) async {
    final steps = [...state.steps];
    final index = _indexOf(step);
    if (index < 0) return;
    final previous = steps[index];
    final edited = update(previous);
    if (identical(previous, edited)) return;
    if (edited.level != previous.level) {
      steps.removeAt(index);
      await _insert(emit, steps, edited);
      return;
    }
    steps[index] = edited;
    await _save(emit, steps, index);
  }

  int _indexOf(TreeProgressionStep step) =>
      state.steps.indexWhere((entry) => entry.identity == step.identity);

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
    final index = step == null ? -1 : _indexOf(step);
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
    view: (
      visible: state.view.visible,
      following: state.view.following,
      focus: null,
      hoveredNode: null,
    ),
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
