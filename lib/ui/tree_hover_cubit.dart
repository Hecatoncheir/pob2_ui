import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/node_preview.dart';

typedef TreeHoverState = ({
  int? id,
  NodePreview? preview,
  String? error,
  bool loading,
});

class TreeHoverCubit extends Cubit<TreeHoverState> {
  TreeHoverCubit(this.load, {this.delay = const Duration(milliseconds: 140)})
    : super((id: null, preview: null, error: null, loading: false));
  final Future<NodePreview> Function(int) load;
  final Duration delay;
  Timer? _timer;
  int _generation = 0;

  void hover(int? id) {
    if (state.id == id) return;
    _timer?.cancel();
    final generation = ++_generation;
    emit((id: id, preview: null, error: null, loading: id != null));
    if (id != null) _timer = Timer(delay, () => _read(id, generation));
  }

  Future<void> _read(int id, int generation) async {
    try {
      final preview = await load(id);
      if (!_current(generation)) return;
      emit((id: id, preview: preview, error: null, loading: false));
    } catch (error) {
      if (!_current(generation)) return;
      emit((id: id, preview: null, error: '$error', loading: false));
    }
  }

  bool _current(int generation) => !isClosed && generation == _generation;
  void clear() => hover(null);
  @override
  Future<void> close() {
    _generation++;
    _timer?.cancel();
    return super.close();
  }
}
