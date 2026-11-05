import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/game_dictionary_repository.dart';
import '../data/language_preferences.dart';
import '../domain/app_language.dart';
import '../domain/game_dictionary.dart';

typedef LanguageState = ({
  AppLanguage language,
  GameDictionary? dictionary,
  bool loading,
  String? error,
});

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(
    this.preferences,
    this.dictionaries, {
    AppLanguage initialLanguage = AppLanguage.russian,
  }) : super((
         language: initialLanguage,
         dictionary: null,
         loading: false,
         error: null,
       ));
  final LanguagePreferences preferences;
  final GameDictionaryRepository dictionaries;
  Future<void> _pendingSave = Future.value();
  int _generation = 0;

  Future<void> selectLanguage(AppLanguage language) async {
    final generation = ++_generation;
    emit((language: language, dictionary: null, loading: true, error: null));
    _pendingSave = _pendingSave.then((_) => _save(language, generation));
    await Future.wait([_pendingSave, _read(language, generation)]);
  }

  Future<void> load() {
    final generation = ++_generation;
    emit((
      language: state.language,
      dictionary: null,
      loading: true,
      error: null,
    ));
    return _read(state.language, generation);
  }

  Future<void> _save(AppLanguage language, int generation) async {
    try {
      await preferences.save(language);
    } catch (error) {
      if (_current(generation))
        emit((
          language: state.language,
          dictionary: state.dictionary,
          loading: state.loading,
          error: '$error',
        ));
    }
  }

  Future<void> _read(AppLanguage language, int generation) async {
    try {
      final dictionary = await dictionaries.load(language);
      if (_current(generation))
        emit((
          language: language,
          dictionary: dictionary,
          loading: false,
          error: state.error,
        ));
    } catch (error) {
      if (_current(generation))
        emit((
          language: language,
          dictionary: null,
          loading: false,
          error: '$error',
        ));
    }
  }

  bool _current(int generation) => !isClosed && generation == _generation;

  @override
  Future<void> close() async {
    _generation++;
    await _pendingSave;
    return super.close();
  }
}
