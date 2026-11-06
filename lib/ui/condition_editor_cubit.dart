import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/condition_definition.dart';
import '../domain/build_edit_result.dart';

typedef ConditionEditorState = ({
  Object? selection,
  String text,
  bool saving,
  String? error,
});

class ConditionEditorCubit extends Cubit<ConditionEditorState> {
  ConditionEditorCubit(this.definition, Object? current, this.commit)
    : super((
        selection: definition.selection(current),
        text: current == null ? '' : '$current',
        saving: false,
        error: null,
      )) {
    _original = (selection: state.selection, text: state.text);
  }
  final ConditionDefinition definition;
  final Future<BuildEditResult> Function(String id, Object value) commit;
  late final ({Object? selection, String text}) _original;

  bool mayExit() {
    if (state.saving) return false;
    if (state.selection == _original.selection && state.text == _original.text)
      return true;
    emit((
      selection: state.selection,
      text: state.text,
      saving: false,
      error: 'Завершите редактирование перед закрытием приложения',
    ));
    return false;
  }

  void text(String value) {
    if (state.saving) return;
    emit((
      selection: state.selection,
      text: value,
      saving: state.saving,
      error: null,
    ));
  }

  void select(Object? value) {
    if (state.saving) return;
    emit((
      selection: value,
      text: state.text,
      saving: state.saving,
      error: null,
    ));
  }

  Future<bool> save() async {
    if (state.saving) return false;
    emit((
      selection: state.selection,
      text: state.text,
      saving: true,
      error: null,
    ));
    try {
      final value = definition.parse(state.text, state.selection);
      final result = await commit(definition.id, value);
      if (!isClosed)
        emit((
          selection: state.selection,
          text: state.text,
          saving: false,
          error: result.error,
        ));
      return result.committed;
    } catch (error) {
      if (!isClosed)
        emit((
          selection: state.selection,
          text: state.text,
          saving: false,
          error: error is FormatException ? error.message : '$error',
        ));
      return false;
    }
  }
}
