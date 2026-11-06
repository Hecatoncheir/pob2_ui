import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/data/xml_file_service.dart';
import 'package:pob2_ui/domain/library_entry.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/file_fakes.dart';
import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

class FileEngine extends McpClient {
  int value = 1;
  @override
  bool get connected => true;
  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    switch (name) {
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
      default:
        throw StateError(name);
    }
  }
}

void main() {
  late Directory root;
  late FailingTextFiles storage;
  late SelectPaths dialogs;
  late FileEngine engine;
  late WorkshopCubit model;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-workspace-file-');
    storage = FailingTextFiles();
    dialogs = SelectPaths();
    engine = FileEngine();
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
      await model.treeAction(1, false);
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
