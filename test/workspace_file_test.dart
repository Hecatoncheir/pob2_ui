import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_window_repository.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/data/xml_file_service.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/domain/library_entry.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/file_fakes.dart';
import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

class FileEngine extends McpClient {
  int value = 1;
  @override
  Future<void> connect(Installations pair) async {}
  @override
  bool get connected => true;
  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    switch (name) {
      case 'pob_catalog':
        return {'entries': <dynamic>[]};
      case 'pob_export_xml':
        return {'xml': '<build value="$value"/>'};
      case 'pob_import_xml':
        final xml = arguments['xml'] as String;
        value = xml.contains('bad')
            ? 999
            : int.parse(RegExp(r'\d+').firstMatch(xml)![0]!);
        return {};
      case 'pob_check_build':
        if (value == 999) throw StateError('Lua отклонил XML');
        return {
          'report': {
            ...fixture.raw,
            'stats': {'Life': 100 + value},
          },
        };
      case 'pob_tree_action':
        value++;
        return {};
      case 'pob_add_skill_group':
        value++;
        final gems = arguments['gems'] as List;
        if ((gems.first as Map)['level'] == 999) {
          throw StateError('Lua отклонил уровень камня');
        }
        return {};
      default:
        throw StateError(name);
    }
  }
}

class MemoryLibrary extends BuildLibrary {
  MemoryLibrary(super.data);

  @override
  Future<void> writeIndex(LibraryState state, {bool backup = true}) async {}
}

class WindowSource extends PobWindowRepository {
  String? xml = '<build value="42"/>';

  @override
  bool get supported => true;

  @override
  Future<String> readXml(Installations components) async =>
      xml ??
      (throw StateError(
        '{"code":"BRIDGE_NOT_RUNNING","message":"Нет связи с окном PoB"}',
      ));
}

class ImportButtonWorkshop extends WorkshopCubit {
  ImportButtonWorkshop(
    super.components,
    super.engine, {
    super.initialState,
    super.pobWindow,
  });

  int requests = 0;

  @override
  Future<void> importFromPob() async => requests++;
}

void main() {
  late Directory root;
  late FailingTextFiles storage;
  late SelectPaths dialogs;
  late FileEngine engine;
  late WindowSource window;
  late WorkshopCubit model;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-workspace-file-');
    storage = FailingTextFiles();
    dialogs = SelectPaths();
    engine = FileEngine();
    window = WindowSource();
    final library = BuildLibrary(root, files: storage);
    final initial = await library.save(
      LibraryState(),
      fixture,
      '<build value="1"/>',
      title: 'Рабочая',
    );
    final session = SessionRepository(root);
    await session.save('<build value="1"/>');
    model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(root)),
      engine,
      library: library,
      session: session,
      files: XmlFileService(dialogs: dialogs),
      pobWindow: window,
      initialState: WorkshopState(
        library: initial,
        document: (report: fixture, tree: tree, stale: false, treeError: null),
      ),
    );
  });
  tearDown(() async {
    storage.failName = null;
    await model.close();
    await removeTemporaryDirectory(root);
  });

  testWidgets('Меню сборки запускает импорт из PoB', (tester) async {
    final widgetModel = ImportButtonWorkshop(
      model.components,
      engine,
      initialState: model.state,
      pobWindow: window,
    );
    addTearDown(widgetModel.close);
    await tester.pumpWidget(PobApp(model: widgetModel));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ещё'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import-from-pob')));
    await tester.pumpAndSettle();
    expect(widgetModel.requests, 1);
  });

  test('Импорт из PoB открывает отдельную копию', () async {
    final previous = model.state.library.activeId!;
    await model.importFromPob();
    expect(model.state.error, isNull);
    final copy = model.state.library.activeId!;
    expect(copy, isNot(previous));
    expect(model.state.library.entries, hasLength(2));
    expect(model.state.report!.stats['Life'], 142);
    expect(await model.library.read(previous), '<build value="1"/>');
    expect(await model.library.read(copy), window.xml);
  });

  test('Отказ моста сохраняет рабочую сборку и историю', () async {
    await model.treeAction(1, false);
    final before = model.state;
    window.xml = null;
    await model.importFromPob();
    expect(model.state.error, 'Нет связи с окном PoB');
    expect(model.state.document, same(before.document));
    expect(model.state.library, same(before.library));
    expect(model.state.history, before.history);
    expect(engine.value, 2);
    expect(await model.session.read(), '<build value="2"/>');
  });

  test('Удаление активной сборки не восстанавливает её при запуске', () async {
    final kept = model.state.library.activeId!;
    await model.importXml('<build value="2"/>');
    final removed = model.state.library.activeId!;
    await model.renameBuild('Лишняя сборка');
    expect(model.state.undoCount, 1);
    await model.session.saveNotes(kept, 'Сохранённая заметка');
    await model.deleteBuild(removed);

    expect(model.state.report, isNull);
    expect(model.state.undoCount, 0);
    expect(await model.session.readNotes(kept), 'Сохранённая заметка');
    await expectLater(model.library.read(removed), throwsFormatException);
    await model.checkpoint();

    final store = InstallationStore(root);
    await store.save({
      for (final component in Component.values)
        component: Installation(
          tag: 'test',
          commit: 'test',
          directory: root.path,
        ),
    }, {});
    final reopened = WorkshopCubit(
      ComponentRepository(store: store),
      FileEngine(),
    );
    addTearDown(reopened.close);
    await reopened.initialize();
    expect(reopened.state.error, isNull);
    expect(reopened.state.library.entries.map((entry) => entry.id), [kept]);
    expect(reopened.state.sessionSaved, isFalse);
    await reopened.restoreSession();
    await reopened.refreshReport();
    expect(await reopened.exportXml(), isNull);
    expect(reopened.state.report, isNull);
    await reopened.openBuild(kept);
    expect(await reopened.exportXml(), '<build value="1"/>');
  });

  test('Сбой записи не удаляет рабочую сборку и её историю', () async {
    final id = model.state.library.activeId!;
    await model.renameBuild('Рабочая переименована');
    storage.failName = 'index.json';
    await model.deleteBuild(id);
    expect(model.state.error, contains('Нет места на диске'));
    expect(model.state.report, isNotNull);
    expect(model.state.undoCount, 1);
    expect(model.state.library.activeId, id);
    expect((await model.library.load()).activeId, id);
  });

  testWidgets('Корзина ждёт подтверждения и удаляет только выбранную сборку', (
    tester,
  ) async {
    final removed = model.state.library.activeId!;
    await tester.runAsync(() => model.importXml('<build value="2"/>'));
    final kept = model.state.library.activeId!;
    final widgetModel = WorkshopCubit(
      model.components,
      engine,
      initialState: model.state,
      library: MemoryLibrary(root),
    );
    addTearDown(widgetModel.close);
    await tester.pumpWidget(PobApp(model: widgetModel));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('page-library')));
    await tester.pumpAndSettle();
    final button = find.byKey(ValueKey('delete-build-$removed'));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Удалить сборку?'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-build')));
    await tester.pumpAndSettle();
    expect(button, findsNothing);
    expect(find.byKey(ValueKey('delete-build-$kept')), findsOneWidget);
    expect(widgetModel.state.library.activeId, kept);
    expect(await widgetModel.exportXml(), '<build value="2"/>');
  });

  test(
    'Ошибка XML восстанавливает Lua, библиотеку, сессию и историю',
    () async {
      await model.treeAction(1, false);
      await model.undo();
      final before = model.state.library.activeId;
      final history = model.state.history;
      await model.importXml('<bad/>');
      expect(model.state.error, contains('Lua отклонил XML'));
      expect(engine.value, 1);
      expect(model.state.library.activeId, before);
      expect(model.state.document!.stale, isFalse);
      expect(model.state.history, history);
      expect(await model.session.read(), '<build value="1"/>');
      expect(await model.library.read(before!), '<build value="1"/>');
    },
  );

  test('Отказ добавления возвращает XML и сохраняет Redo; успешная группа участвует в истории', () async {
    await model.treeAction(1, false);
    await model.undo();
    final history = model.state.history;
    final rejected = await model.addSkillGroup('Ошибка', [
      {'id': 'gem', 'level': 999},
    ]);
    expect(rejected.committed, isFalse);
    expect(engine.value, 1);
    expect(model.state.document!.stale, isFalse);
    expect(model.state.history, history);
    final added = await model.addSkillGroup('Группа', [
      {'id': 'gem', 'level': 5},
    ]);
    expect(added.committed, isTrue);
    expect(model.state.history, (undo: 1, redo: 0));
    await model.undo();
    expect(engine.value, 1);
    await model.redo();
    expect(engine.value, 2);
  });

  test(
    'Ошибка диска при изменении не оставляет неподтверждённую группу в Lua',
    () async {
      final id = model.state.library.activeId!;
      storage.failName = 'index.json';
      final result = await model.addSkillGroup('Группа', [
        {'id': 'gem', 'level': 5},
      ]);
      expect(result.committed, isFalse);
      expect(engine.value, 1);
      expect(await model.library.read(id), '<build value="1"/>');
      expect(model.state.undoCount, 0);
    },
  );

  test('Отмена файлового диалога не меняет сборку; успешный файл получает своё название', () async {
    final id = model.state.library.activeId;
    await model.openXmlFile();
    await model.saveXmlFile();
    expect(model.state.library.activeId, id);
    final file = File.fromUri(root.uri.resolve('Другая.xml'));
    await file.writeAsString('<build value="5"/>');
    dialogs.openPath = file.path;
    await model.openXmlFile();
    expect(model.state.error, isNull);
    expect(model.state.library.active!.title, 'Другая');
    expect(model.state.library.activeId, isNot(id));
    expect(await model.library.read(id!), '<build value="1"/>');
    expect(model.state.history, (undo: 0, redo: 0));
  });

  test(
    'Неудачная запись новой сборки сохраняет прежний активный документ и XML',
    () async {
      final id = model.state.library.activeId;
      storage.failName = 'index.json';
      await model.importXml('<build value="5"/>');
      expect(model.state.error, isNotNull);
      expect(engine.value, 1);
      expect(model.state.library.activeId, id);
      expect(await model.library.read(id!), '<build value="1"/>');
      expect(await model.session.read(), '<build value="1"/>');
    },
  );

  test(
    'Закрытие повторяет неудачное автосохранение перед разрешением выхода',
    () async {
      final id = model.state.library.activeId!;
      storage.failName = 'index.json';
      engine.value++;
      await model.refreshReport();
      expect(model.state.document!.stale, isTrue);
      expect(await model.library.read(id), '<build value="1"/>');
      await expectLater(
        model.checkpoint(),
        throwsA(isA<FileSystemException>()),
      );
      expect(model.state.busy, isFalse);
      storage.failName = null;
      await model.checkpoint();
      expect(model.state.document!.stale, isFalse);
      expect(await BuildLibrary(root).read(id), '<build value="2"/>');
    },
  );

  test('Заметки переживают смену XML и копируются без изменения оригинала; черновик сохраняется сразу', () async {
    final id = model.state.library.activeId!;
    await model.session.saveNotes(id, 'План развития');
    model.editDraft('<bad draft/>');
    await model.checkpoint();
    expect(await SessionRepository(root).readDraft(), '<bad draft/>');
    await model.copyBuild();
    final copy = model.state.library.activeId!;
    expect(copy, isNot(id));
    expect(await model.session.readNotes(copy), 'План развития');
    await model.session.saveNotes(copy, 'Другой план');
    expect(await model.session.readNotes(id), 'План развития');
    await model.openBuild(id);
    expect(await model.session.readNotes(id), 'План развития');
  });
}
