import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/game_dictionary_repository.dart';
import '../data/language_preferences.dart';
import '../domain/app_language.dart';
import '../domain/game_dictionary.dart';
import 'core/preference_writes.dart';

typedef LanguageState = ({
  AppLanguage language,
  GameDictionary? dictionary,
  bool loading,
  String? error,
});

sealed class LanguageEvent {
  const LanguageEvent();
}

final class LanguageSelected extends LanguageEvent {
  const LanguageSelected(this.language);
  final AppLanguage language;
}

final class LanguageLoadRequested extends LanguageEvent {
  const LanguageLoadRequested();
}

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc(
    LanguagePreferences preferences,
    this.dictionaries, {
    AppLanguage initialLanguage = AppLanguage.russian,
  }) : _writes = PreferenceWrites(preferences.save),
       super((
         language: initialLanguage,
         dictionary: null,
         loading: false,
         error: null,
       )) {
    on<LanguageEvent>(_change);
  }

  final GameDictionaryRepository dictionaries;
  final PreferenceWrites<AppLanguage> _writes;
  int _generation = 0;

  Future<void> get pendingSave => _writes.pending;

  Future<void> _change(LanguageEvent event, Emitter<LanguageState> emit) async {
    final generation = ++_generation;
    final language = switch (event) {
      LanguageSelected(:final language) => language,
      LanguageLoadRequested() => state.language,
    };
    emit((language: language, dictionary: null, loading: true, error: null));
    final read = _read(language, generation, emit);
    if (event is LanguageSelected) {
      await Future.wait([
        _writes.enqueue(language, (error) {
          if (_current(generation, emit)) {
            emit((
              language: state.language,
              dictionary: state.dictionary,
              loading: state.loading,
              error: '$error',
            ));
          }
        }),
        read,
      ]);
    } else {
      await read;
    }
  }

  Future<void> _read(
    AppLanguage language,
    int generation,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final dictionary = await dictionaries.load(language);
      if (_current(generation, emit)) {
        emit((
          language: language,
          dictionary: dictionary,
          loading: false,
          error: state.error,
        ));
      }
    } catch (error) {
      if (_current(generation, emit)) {
        emit((
          language: language,
          dictionary: null,
          loading: false,
          error: '$error',
        ));
      }
    }
  }

  bool _current(int generation, Emitter<LanguageState> emit) =>
      !emit.isDone && generation == _generation;

  @override
  Future<void> close() async {
    await super.close();
    await pendingSave;
  }
}
