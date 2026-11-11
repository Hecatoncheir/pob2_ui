import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/workspace_preferences_repository.dart';
import '../domain/workspace_preferences.dart';
import 'core/preference_writes.dart';
import 'keyboard_bindings.dart';

typedef WorkspacePreferencesState = ({
  WorkspacePreferences preferences,
  String? error,
});

sealed class WorkspacePreferencesEvent {
  const WorkspacePreferencesEvent();
}

final class SidebarDragged extends WorkspacePreferencesEvent {
  const SidebarDragged(this.delta);
  final double delta;
}

final class SidebarDragEnded extends WorkspacePreferencesEvent {
  const SidebarDragEnded();
}

final class SidebarToggled extends WorkspacePreferencesEvent {
  const SidebarToggled();
}

final class ShortcutChanged extends WorkspacePreferencesEvent {
  const ShortcutChanged(this.command, this.binding);
  final AppCommand command;
  final KeyBinding? binding;
}

final class ShortcutsReset extends WorkspacePreferencesEvent {
  const ShortcutsReset();
}

class WorkspacePreferencesBloc
    extends Bloc<WorkspacePreferencesEvent, WorkspacePreferencesState> {
  WorkspacePreferencesBloc(
    WorkspacePreferencesRepository repository, {
    WorkspacePreferences? initial,
  }) : _writes = PreferenceWrites(repository.save),
       super((preferences: initial ?? WorkspacePreferences(), error: null)) {
    on<WorkspacePreferencesEvent>(_apply);
  }

  final PreferenceWrites<WorkspacePreferences> _writes;

  FutureOr<void> _apply(
    WorkspacePreferencesEvent event,
    Emitter<WorkspacePreferencesState> emit,
  ) {
    final preferences = state.preferences;
    switch (event) {
      case SidebarDragged(:final delta):
        final width = (preferences.sidebarWidth + delta).clamp(78.0, 300.0);
        emit((
          preferences: preferences.copyWith(sidebarWidth: width),
          error: null,
        ));
      case SidebarDragEnded():
        final width = settledSidebarWidth(preferences.sidebarWidth);
        return _save(
          preferences.copyWith(
            sidebarWidth: width,
            expandedWidth: width >= 160 ? width : preferences.expandedWidth,
          ),
          emit,
        );
      case SidebarToggled():
        final width = preferences.sidebarWidth < 160
            ? preferences.expandedWidth
            : 78.0;
        return _save(preferences.copyWith(sidebarWidth: width), emit);
      case ShortcutChanged():
        return _changeShortcut(event, emit);
      case ShortcutsReset():
        return _save(preferences.copyWith(shortcuts: {}), emit);
    }
  }

  Future<void> _changeShortcut(
    ShortcutChanged event,
    Emitter<WorkspacePreferencesState> emit,
  ) async {
    final preferences = state.preferences;
    final conflict = _shortcutConflict(preferences, event);
    if (conflict != null) {
      emit((
        preferences: preferences,
        error: 'Сочетание уже используется: ${commandLabels[conflict]}',
      ));
      return;
    }
    await _save(
      preferences.copyWith(
        shortcuts: {...preferences.shortcuts, event.command: event.binding},
      ),
      emit,
    );
  }

  AppCommand? _shortcutConflict(
    WorkspacePreferences preferences,
    ShortcutChanged event,
  ) {
    final binding = event.binding;
    if (binding == null) return null;
    return AppCommand.values
        .where(
          (other) =>
              other != event.command &&
              commandBindings(preferences, other).contains(binding),
        )
        .firstOrNull;
  }

  Future<void> _save(
    WorkspacePreferences preferences,
    Emitter<WorkspacePreferencesState> emit,
  ) {
    emit((preferences: preferences, error: null));
    return _writes.enqueue(preferences, (error) {
      if (!emit.isDone) emit((preferences: state.preferences, error: '$error'));
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    await _writes.pending;
  }
}
