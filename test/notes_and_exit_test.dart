import 'dart:io';
import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_window_repository.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/ui/build_notes_dialog.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/exit_protection.dart';
import 'package:pob2_ui/ui/notes_cubit.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

class MemoryText extends SessionRepository {
  MemoryText() : super(Directory('unused-notes-tests'));
  String text = 'План сборки';
  String? pending;
  bool failRead = false;
  bool failWrite = false;
  @override
  Future<String> readNotes(String id) async {
    if (failRead) throw const FileSystemException('Нет доступа');
    return pending ?? text;
  }

  @override
  Future<void> saveNotes(String id, String value) async {
    pending = value;
    await flushText();
  }

  @override
  Future<void> saveDraft(String xml) => flushText();

  @override
  Future<void> flushText() async {
    if (failWrite) throw const FileSystemException('Нет места на диске');
    text = pending ?? text;
    pending = null;
  }
}

class OwnedWindows extends PobWindowRepository {
  int closeRequests = 0;
  bool refuseClose = false;

  @override
  Future<void> closeLaunchedWindows() async {
    closeRequests++;
    if (refuseClose) throw StateError('PoB ещё открыт');
  }
}

WorkshopCubit createModel(MemoryText session, {PobWindowRepository? windows}) =>
    WorkshopCubit(
      ComponentRepository(store: InstallationStore(session.root)),
      McpClient(),
      session: session,
      pobWindow: windows,
    );

Future<bool> nativeClose(WidgetTester tester) async {
  const codec = StandardMethodCodec();
  final response = Completer<bool>();
  tester.binding.channelBuffers.push(
    'pob2_ui/window',
    codec.encodeMethodCall(const MethodCall('requestClose')),
    (data) => response.complete(codec.decodeEnvelope(data!) as bool),
  );
  return response.future;
}

void main() {
  test(
    'Ошибка чтения не разрешает затереть заметки; повтор загружает оригинал',
    () async {
      final session = MemoryText()..failRead = true;
      final notes = NotesCubit(session, 'a' * 32);
      addTearDown(notes.close);
      await notes.load();
      notes.edit('Потерянный текст');
      expect(notes.canEdit, isFalse);
      expect(session.text, 'План сборки');
      session.failRead = false;
      await notes.load();
      expect(notes.canEdit, isTrue);
      expect(notes.state.text, 'План сборки');
    },
  );

  testWidgets(
    'Ошибка записи удерживает диалог и текст; повтор сохраняет и закрывает',
    (tester) async {
      final session = MemoryText();
      final model = createModel(session);
      addTearDown(model.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: Spark.theme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showBuildNotes(context, model, 'a' * 32),
                child: const Text('Заметки'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Заметки'));
      await tester.pumpAndSettle();
      final field = find.byKey(const Key('build-notes'));
      expect(tester.widget<TextField>(field).controller!.text, 'План сборки');
      session.failWrite = true;
      await tester.enterText(field, 'Новый план');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Повторить сохранение'));
      await tester.pumpAndSettle();
      expect(field, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(field, findsOneWidget);
      expect(tester.widget<TextField>(field).controller!.text, 'Новый план');
      expect(session.text, 'План сборки');
      session.failWrite = false;
      await tester.tap(find.text('Повторить сохранение'));
      await tester.pumpAndSettle();
      expect(field, findsNothing);
      expect(session.text, 'Новый план');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'При выходе PoB закрывается после сохранения и согласия диалогов',
    (tester) async {
      final session = MemoryText()..failWrite = true;
      final windows = OwnedWindows();
      final model = createModel(session, windows: windows);
      addTearDown(model.close);
      await tester.pumpWidget(
        ExitProtection(
          model: model,
          child: const MaterialApp(home: SizedBox()),
        ),
      );
      expect(await nativeClose(tester), isFalse);
      expect(model.state.error, contains('Приложение остаётся открытым'));
      expect(windows.closeRequests, 0);
      session.failWrite = false;
      final dialog = AppLifecycleListener(
        onExitRequested: () async => AppExitResponse.cancel,
      );
      expect(await nativeClose(tester), isFalse);
      dialog.dispose();
      expect(windows.closeRequests, 0);
      windows.refuseClose = true;
      expect(await nativeClose(tester), isFalse);
      expect(model.state.error, 'PoB ещё открыт');
      windows.refuseClose = false;
      expect(await nativeClose(tester), isTrue);
      expect(windows.closeRequests, 2);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
}
