import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/session_repository.dart';

typedef NotesState = ({String text, bool loading, bool saving, String? error});

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this.repository, this.id)
    : super((text: '', loading: true, saving: false, error: null));
  final SessionRepository repository;
  final String id;
  int _generation = 0;
  bool _loaded = false;
  bool get canEdit => _loaded;

  Future<void> load() async {
    try {
      final text = await repository.readNotes(id);
      _loaded = true;
      if (!isClosed)
        emit((text: text, loading: false, saving: false, error: null));
    } catch (error) {
      if (!isClosed)
        emit((
          text: state.text,
          loading: false,
          saving: false,
          error: '$error',
        ));
    }
  }

  void edit(String text) {
    if (!canEdit) return;
    final generation = ++_generation;
    emit((text: text, loading: false, saving: true, error: null));
    _save(text, generation);
  }

  Future<void> _save(String text, int generation) async {
    try {
      await repository.saveNotes(id, text);
      if (!isClosed && generation == _generation) {
        emit((text: state.text, loading: false, saving: false, error: null));
      }
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit((
          text: state.text,
          loading: false,
          saving: false,
          error: '$error',
        ));
      }
    }
  }

  Future<bool> flush() async {
    try {
      await repository.flushText();
      if (!isClosed)
        emit((text: state.text, loading: false, saving: false, error: null));
      return true;
    } catch (error) {
      if (!isClosed)
        emit((
          text: state.text,
          loading: false,
          saving: false,
          error: '$error',
        ));
      return false;
    }
  }
}
