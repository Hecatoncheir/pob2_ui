import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';
import '../domain/skill_gem.dart';
import '../domain/support_comparison.dart';
import 'skill_group_cubit.dart';

class SupportComparisonState {
  const SupportComparisonState({
    this.selected = const {},
    this.query = '',
    this.loading = false,
    this.invalid = false,
    this.result,
    this.error,
  });
  final Set<String> selected;
  final String query;
  final bool loading, invalid;
  final SupportComparison? result;
  final String? error;

  SupportComparisonState copyWith({
    Set<String>? selected,
    String? query,
    bool? loading,
    bool? invalid,
    SupportComparison? result,
    bool clearResult = false,
    String? error,
  }) => SupportComparisonState(
    selected: selected == null ? this.selected : Set.unmodifiable(selected),
    query: query ?? this.query,
    loading: loading ?? this.loading,
    invalid: invalid ?? this.invalid,
    result: clearResult ? null : result ?? this.result,
    error: error,
  );
}

class SupportComparisonCubit extends Cubit<SupportComparisonState> {
  SupportComparisonCubit(this.editor)
    : candidates = List.unmodifiable(
        editor.state.catalog.where(editor.canPreviewSupport),
      ),
      _generation = editor.comparisonGeneration,
      super(const SupportComparisonState()) {
    _subscription = editor.stream.listen((_) {
      if (editor.comparisonGeneration != _generation) _invalidate();
    }, onDone: _invalidate);
  }
  final SkillGroupCubit editor;
  final List<SkillGem> candidates;
  final int _generation;
  StreamSubscription<SkillGroupState>? _subscription;

  void search(String query) => emit(state.copyWith(query: query));

  void toggle(String id) {
    if (state.loading ||
        state.invalid ||
        !candidates.any((gem) => gem.id == id))
      return;
    final selected = {...state.selected};
    if (!selected.remove(id)) selected.add(id);
    if (selected.length > 8) {
      emit(state.copyWith(error: 'Можно сравнить не более 8 поддержек'));
      return;
    }
    emit(state.copyWith(selected: selected, clearResult: true));
  }

  Future<void> calculate() async {
    if (state.loading || state.invalid || state.selected.isEmpty) return;
    emit(state.copyWith(loading: true, clearResult: true));
    try {
      final result = await editor.compareSupports(state.selected.toList());
      if (!isClosed && !state.invalid)
        emit(state.copyWith(loading: false, result: result));
    } catch (error) {
      if (!isClosed && !state.invalid) {
        emit(state.copyWith(loading: false, error: mcpErrorMessage(error)));
      }
    }
  }

  void _invalidate() {
    if (!isClosed)
      emit(
        state.copyWith(
          invalid: true,
          loading: false,
          clearResult: true,
          error: 'Сборка или группа изменились. Откройте сравнение заново.',
        ),
      );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
