import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/progression_comparison.dart';
import '../domain/tree_progression.dart';

typedef ProgressionComparisonState = ({
  Set<ProgressionPart> parts,
  ProgressionComparison? comparison,
  bool failed,
});

class ProgressionPartsSelected {
  ProgressionPartsSelected(Iterable<ProgressionPart> parts)
    : parts = Set.unmodifiable(parts);

  final Set<ProgressionPart> parts;
}

class ProgressionComparisonBloc
    extends Bloc<ProgressionPartsSelected, ProgressionComparisonState> {
  ProgressionComparisonBloc(this._compare, this._dispose)
    : super((parts: const {}, comparison: null, failed: false)) {
    on<ProgressionPartsSelected>(_choose);
    add(ProgressionPartsSelected(const {ProgressionPart.tree}));
  }

  final Future<ProgressionComparison> Function(Set<ProgressionPart>) _compare;
  final Future<void> Function() _dispose;
  Future<void> _worker = Future.value();

  Future<void> _choose(
    ProgressionPartsSelected event,
    Emitter<ProgressionComparisonState> emit,
  ) async {
    final parts = event.parts;
    emit((parts: parts, comparison: null, failed: false));
    if (parts.isEmpty) return;
    final next = _worker.then((_) => _load(parts, emit));
    _worker = next;
    await next;
  }

  Future<void> _load(
    Set<ProgressionPart> parts,
    Emitter<ProgressionComparisonState> emit,
  ) async {
    if (emit.isDone || !_current(parts)) return;
    try {
      final comparison = await _compare(parts);
      if (!emit.isDone && _current(parts)) {
        emit((parts: parts, comparison: comparison, failed: false));
      }
    } catch (_) {
      if (!emit.isDone && _current(parts)) {
        emit((parts: parts, comparison: null, failed: true));
      }
    }
  }

  bool _current(Set<ProgressionPart> parts) =>
      !isClosed && identical(state.parts, parts);

  @override
  Future<void> close() async {
    await super.close();
    await _worker;
    await _dispose();
  }
}
