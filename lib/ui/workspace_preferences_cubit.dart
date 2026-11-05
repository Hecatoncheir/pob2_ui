import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/workspace_preferences_repository.dart';
import '../domain/workspace_preferences.dart';
import 'keyboard_bindings.dart';

typedef WorkspacePreferencesState = ({
  WorkspacePreferences preferences,
  String? error,
});

class WorkspacePreferencesCubit extends Cubit<WorkspacePreferencesState> {
  WorkspacePreferencesCubit(this.repository, {WorkspacePreferences? initial})
    : super((preferences: initial ?? WorkspacePreferences(), error: null));
  final WorkspacePreferencesRepository repository;
  Future<void> _pending = Future.value();
  int _generation = 0;

  void resizeSidebar(double width) => emit((
    preferences: state.preferences.copyWith(sidebarWidth: width.clamp(78, 300)),
    error: null,
  ));

  Future<void> settleSidebar() {
    final width = settledSidebarWidth(state.preferences.sidebarWidth);
    return _change(
      state.preferences.copyWith(
        sidebarWidth: width,
        expandedWidth: width >= 160 ? width : state.preferences.expandedWidth,
      ),
    );
  }

  Future<void> toggleSidebar() => _change(
    state.preferences.copyWith(
      sidebarWidth: state.preferences.sidebarWidth < 160
          ? state.preferences.expandedWidth
          : 78,
    ),
  );

  Future<void> setBinding(AppCommand command, KeyBinding? binding) {
    final conflict = AppCommand.values
        .where(
          (other) =>
              other != command &&
              binding != null &&
              commandBindings(state.preferences, other).contains(binding),
        )
        .firstOrNull;
    if (conflict != null) {
      emit((
        preferences: state.preferences,
        error: 'Сочетание уже используется: ${commandLabels[conflict]}',
      ));
      return Future.value();
    }
    return _change(
      state.preferences.copyWith(
        shortcuts: {...state.preferences.shortcuts, command: binding},
      ),
    );
  }

  Future<void> resetBindings() =>
      _change(state.preferences.copyWith(shortcuts: {}));

  Future<void> _change(WorkspacePreferences preferences) {
    final generation = ++_generation;
    emit((preferences: preferences, error: null));
    _pending = _pending.then((_) => _save(preferences, generation));
    return _pending;
  }

  Future<void> _save(WorkspacePreferences preferences, int generation) async {
    try {
      await repository.save(preferences);
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit((preferences: state.preferences, error: '$error'));
      }
    }
  }

  @override
  Future<void> close() async {
    await _pending;
    return super.close();
  }
}
