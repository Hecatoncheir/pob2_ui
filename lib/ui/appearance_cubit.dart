import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/appearance_repository.dart';
import '../domain/appearance.dart';

class AppearanceCubit extends Cubit<AppearanceState> {
  AppearanceCubit(this.repository, {AppTheme initialTheme = AppTheme.light})
    : super((theme: initialTheme, error: null));
  final AppearanceRepository repository;
  Future<void> _pending = Future.value();
  int _generation = 0;

  Future<void> selectTheme(AppTheme theme) {
    final generation = ++_generation;
    emit((theme: theme, error: null));
    _pending = _pending.then((_) => _save(theme, generation));
    return _pending;
  }

  Future<void> _save(AppTheme theme, int generation) async {
    try {
      await repository.save(theme);
    } catch (error) {
      if (!isClosed && generation == _generation)
        emit((theme: state.theme, error: '$error'));
    }
  }

  @override
  Future<void> close() async {
    await _pending;
    return super.close();
  }
}
