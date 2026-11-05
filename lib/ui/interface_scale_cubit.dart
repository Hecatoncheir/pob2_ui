import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/interface_scale_repository.dart';
import '../domain/interface_scale.dart';

class InterfaceScaleCubit extends Cubit<InterfaceScaleState> {
  InterfaceScaleCubit(this.repository, {int initialPercent = 100})
    : super((percent: normalizeInterfaceScale(initialPercent), error: null));
  final InterfaceScaleRepository repository;
  Future<void> _pending = Future.value();
  int _generation = 0;

  Future<void> changeBy(int delta) => setPercent(state.percent + delta);

  Future<void> setPercent(int value) {
    final percent = normalizeInterfaceScale(value);
    if (percent == state.percent && state.error == null) return _pending;
    final generation = ++_generation;
    emit((percent: percent, error: null));
    _pending = _pending.then((_) => _save(percent, generation));
    return _pending;
  }

  Future<void> _save(int percent, int generation) async {
    try {
      await repository.save(percent);
    } catch (error) {
      if (!isClosed && generation == _generation)
        emit((percent: state.percent, error: '$error'));
    }
  }

  @override
  Future<void> close() async {
    await _pending;
    return super.close();
  }
}
