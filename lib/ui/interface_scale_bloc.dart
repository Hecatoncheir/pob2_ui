import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/interface_scale_repository.dart';
import '../domain/interface_scale.dart';
import 'core/preference_writes.dart';

sealed class InterfaceScaleEvent {
  const InterfaceScaleEvent();
}

final class InterfaceScaleSet extends InterfaceScaleEvent {
  const InterfaceScaleSet(this.percent);
  final int percent;
}

final class InterfaceScaleAdjusted extends InterfaceScaleEvent {
  const InterfaceScaleAdjusted(this.delta);
  final int delta;
}

class InterfaceScaleBloc
    extends Bloc<InterfaceScaleEvent, InterfaceScaleState> {
  InterfaceScaleBloc(
    InterfaceScaleRepository repository, {
    int initialPercent = 100,
  }) : _writes = PreferenceWrites(repository.save),
       super((percent: normalizeInterfaceScale(initialPercent), error: null)) {
    on<InterfaceScaleEvent>(_change);
  }

  final PreferenceWrites<int> _writes;

  Future<void> _change(
    InterfaceScaleEvent event,
    Emitter<InterfaceScaleState> emit,
  ) async {
    final percent = normalizeInterfaceScale(switch (event) {
      InterfaceScaleSet(:final percent) => percent,
      InterfaceScaleAdjusted(:final delta) => state.percent + delta,
    });
    if (percent == state.percent && state.error == null) return;
    emit((percent: percent, error: null));
    await _writes.enqueue(percent, (error) {
      if (!emit.isDone) emit((percent: state.percent, error: '$error'));
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    await _writes.pending;
  }
}
