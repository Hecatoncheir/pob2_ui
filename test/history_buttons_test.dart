import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/workshop_fixture.dart';

class ButtonHistoryWorkshop extends WorkshopCubit {
  ButtonHistoryWorkshop()
    : super(
        ComponentRepository(
          store: InstallationStore(Directory('unused-history-buttons')),
        ),
        McpClient(),
        initialState: WorkshopState(
          history: (undo: 1, redo: 0),
          document: (
            report: fixture,
            tree: tree,
            stale: false,
            treeError: null,
          ),
        ),
      );
  @override
  Future<void> undo() async =>
      emit(state.copyWith(history: (undo: 0, redo: 1)));
  @override
  Future<void> redo() async =>
      emit(state.copyWith(history: (undo: 1, redo: 0)));
  void busy(bool value) =>
      emit(state.copyWith(operation: (busy: value, error: null)));
}

void main() {
  testWidgets(
    'Redo находится рядом с Undo и доступна только для повтора; операция блокирует обе кнопки',
    (tester) async {
      final model = ButtonHistoryWorkshop();
      await tester.pumpWidget(PobApp(model: model));
      await tester.pumpAndSettle();
      final undo = find.byKey(const Key('undo-build'));
      final redo = find.byKey(const Key('redo-build'));
      expect(
        tester.getRect(redo).left,
        greaterThanOrEqualTo(tester.getRect(undo).right),
      );
      expect(tester.widget<IconButton>(redo).onPressed, isNull);
      await tester.tap(undo);
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(undo).onPressed, isNull);
      expect(tester.widget<IconButton>(redo).onPressed, isNotNull);
      model.busy(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.widget<IconButton>(undo).onPressed, isNull);
      expect(tester.widget<IconButton>(redo).onPressed, isNull);
      model.busy(false);
      await tester.pumpAndSettle();
      await tester.tap(redo);
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(undo).onPressed, isNotNull);
      expect(tester.widget<IconButton>(redo).onPressed, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await model.close();
    },
  );
}
