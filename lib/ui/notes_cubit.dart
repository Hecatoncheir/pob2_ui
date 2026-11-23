import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/session_repository.dart';

typedef NotesState = ({String text, bool loading, bool saving, String? error});

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this.repository, this.id, {this.write})
    : super((text: '', loading: true, saving: false, error: null));
  final BuildNotesStorage repository;
  final String id;
  final Future<void> Function(String text)? write;
  Future<void> _pending = Future.value();
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
    _pending = _pending.then((_) => _save(text, generation));
  }

  Future<void> _save(String text, int generation) async {
    if (isClosed || generation != _generation) return;
    try {
      final save = write;
      if (save == null) {
        await repository.saveNotes(id, text);
      } else {
        await save(text);
      }
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
      await _pending;
      if (write != null && state.error != null) return false;
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
