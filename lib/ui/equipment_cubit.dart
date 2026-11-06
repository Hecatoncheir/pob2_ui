import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/equipment_repository.dart';
import '../data/mcp_error_message.dart';
import '../domain/build_report.dart';
import '../domain/equipment_item.dart';
import 'equipment_presentation.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';

typedef EquipmentState = ({
  String? slot,
  ItemInspection? preview,
  bool loading,
  String? error,
});

class EquipmentCubit extends Cubit<EquipmentState> {
  EquipmentCubit(this.model)
    : repository = EquipmentRepository(model.engine),
      super((slot: null, preview: null, loading: false, error: null)) {
    _lastReport = model.state.report;
    _subscription = model.stream.listen(_changed);
  }
  final WorkshopCubit model;
  final EquipmentRepository repository;
  late final StreamSubscription<WorkshopState> _subscription;
  BuildReport? _lastReport;
  int _generation = 0;

  Future<void> select(String slot) async {
    final generation = ++_generation;
    final entry = model.state.report!.slots
        .where((entry) => entry['name'] == slot)
        .firstOrNull;
    final id = entry?['itemId'] as int? ?? 0;
    emit((slot: slot, preview: null, loading: id != 0, error: null));
    if (id == 0) return;
    try {
      final preview = await repository.inspect(slot, itemId: id);
      if (_current(generation))
        emit((slot: slot, preview: preview, loading: false, error: null));
    } catch (error) {
      if (_current(generation))
        emit((
          slot: slot,
          preview: null,
          loading: false,
          error: mcpErrorMessage(error),
        ));
    }
  }

  void _changed(WorkshopState value) {
    if (value.busy || value.report == _lastReport || isClosed) return;
    _lastReport = value.report;
    if (value.report == null) {
      _generation++;
      emit((slot: null, preview: null, loading: false, error: null));
      return;
    }
    final slots = equipmentSlots(value.report!);
    final current =
        slots.where((slot) => slot['name'] == state.slot).firstOrNull ??
        slots.firstOrNull;
    if (current != null) unawaited(select(current['name'] as String));
  }

  bool _current(int generation) => !isClosed && generation == _generation;
  @override
  Future<void> close() async {
    _generation++;
    await _subscription.cancel();
    await super.close();
  }
}
