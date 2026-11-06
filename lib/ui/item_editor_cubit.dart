import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';

import '../domain/build_edit_result.dart';
import '../domain/equipment_item.dart';

typedef InspectItem = Future<ItemInspection> Function({
  String? raw,
  int? itemId,
});
typedef EquipItem = Future<BuildEditResult> Function({
  String? raw,
  int? itemId,
});
typedef ItemEditorState = ({
  String raw,
  int? itemId,
  ItemInspection? preview,
  bool loading,
  bool saving,
  String? error,
});

class ItemEditorCubit extends Cubit<ItemEditorState> {
  ItemEditorCubit(this.inspect, this.equip, {String initial = ''})
    : original = initial,
      super((
        raw: initial,
        itemId: null,
        preview: null,
        loading: false,
        saving: false,
        error: null,
      ));
  final InspectItem inspect;
  final EquipItem equip;
  final String original;
  int _generation = 0;
  bool get canSave =>
      state.preview?.compatible == true && !state.loading && !state.saving;

  void text(String raw) {
    if (state.saving) return;
    _generation++;
    emit((
      raw: raw,
      itemId: null,
      preview: null,
      loading: false,
      saving: false,
      error: null,
    ));
  }

  Future<void> preview({int? itemId}) async {
    if (state.saving) return;
    final generation = ++_generation;
    emit((
      raw: state.raw,
      itemId: itemId,
      preview: null,
      loading: true,
      saving: false,
      error: null,
    ));
    try {
      final result = await inspect(
        raw: itemId == null ? state.raw : null,
        itemId: itemId,
      );
      if (!_current(generation)) return;
      emit((
        raw: state.raw,
        itemId: itemId,
        preview: result,
        loading: false,
        saving: false,
        error: result.compatible ? null : 'Предмет не подходит для этого слота',
      ));
    } catch (error) {
      if (_current(generation))
        emit((
          raw: state.raw,
          itemId: itemId,
          preview: null,
          loading: false,
          saving: false,
          error: mcpErrorMessage(error),
        ));
    }
  }

  Future<bool> save() async {
    if (!canSave) return false;
    emit((
      raw: state.raw,
      itemId: state.itemId,
      preview: state.preview,
      loading: false,
      saving: true,
      error: null,
    ));
    try {
      final result = await equip(
        raw: state.itemId == null ? state.raw : null,
        itemId: state.itemId,
      );
      if (!isClosed)
        emit((
          raw: state.raw,
          itemId: state.itemId,
          preview: state.preview,
          loading: false,
          saving: false,
          error: result.error == null ? null : mcpErrorMessage(result.error!),
        ));
      return result.committed;
    } catch (error) {
      if (!isClosed)
        emit((
          raw: state.raw,
          itemId: state.itemId,
          preview: state.preview,
          loading: false,
          saving: false,
          error: mcpErrorMessage(error),
        ));
      return false;
    }
  }

  bool mayExit() {
    if (state.saving) return false;
    if (state.raw == original && state.itemId == null) return true;
    emit((
      raw: state.raw,
      itemId: state.itemId,
      preview: state.preview,
      loading: state.loading,
      saving: false,
      error: 'Завершите редактирование перед закрытием приложения',
    ));
    return false;
  }

  bool _current(int generation) => !isClosed && generation == _generation;
  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
