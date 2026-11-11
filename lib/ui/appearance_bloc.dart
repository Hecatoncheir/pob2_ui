import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/appearance_repository.dart';
import '../domain/appearance.dart';
import 'core/preference_writes.dart';

final class ThemeSelected {
  const ThemeSelected(this.theme);
  final AppTheme theme;
}

class AppearanceBloc extends Bloc<ThemeSelected, AppearanceState> {
  AppearanceBloc(
    AppearanceRepository repository, {
    AppTheme initialTheme = AppTheme.light,
  }) : _writes = PreferenceWrites(repository.save),
       super((theme: initialTheme, error: null)) {
    on<ThemeSelected>(_select);
  }

  final PreferenceWrites<AppTheme> _writes;

  Future<void> _select(ThemeSelected event, Emitter<AppearanceState> emit) {
    emit((theme: event.theme, error: null));
    return _writes.enqueue(event.theme, (error) {
      if (!emit.isDone) emit((theme: state.theme, error: '$error'));
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    await _writes.pending;
  }
}
