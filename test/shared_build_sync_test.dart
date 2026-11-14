import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/tree_progression_exchange.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/domain/library_entry.dart';
import 'package:pob2_ui/domain/tree_progression.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

String buildXml(int level, {String notes = ''}) =>
    '<PathOfBuilding2><Build className="Witch" level="$level"/><Notes>$notes</Notes></PathOfBuilding2>';

class _SyncEngine extends McpClient {
  _SyncEngine() {
    tools = {'pob_get_tree'};
  }

  int level = 0;
  int loads = 0;
  int treeEdits = 0;
  String notes = '';
  Completer<void>? editStarted, resumeEdit;
  bool exitDuringEdit = false;
  bool _connected = true;

  @override
  bool get connected => _connected;

  @override
  Future<void> connect(Installations pair) async {
    _connected = true;
    level = 0;
  }

  @override
  Future<JsonMap> call(String tool, [JsonMap arguments = const {}]) async {
    if (!connected) throw StateError('Подключите Lua');
    switch (tool) {
      case 'pob_catalog':
        return {
          'entries': [
            {'id': 1, 'name': 'Witch'},
          ],
        };
      case 'pob_import_xml':
        loads++;
        final build = PobBuildDocument(arguments['xml'] as String);
        level = build.level;
        notes = build.notes;
        return {};
      case 'pob_export_xml':
        if (level == 0) throw StateError('Сначала загрузите сборку');
        return {'xml': buildXml(level, notes: notes)};
      case 'pob_tree_action':
        treeEdits++;
        editStarted?.complete();
        await resumeEdit?.future;
        level++;
        if (exitDuringEdit) {
          _connected = false;
          final error = StateError('MCP завершился во время правки');
          onDisconnected?.call(error);
          throw error;
        }
        return {};
      case 'pob_check_build':
        return {
          'report': {
            ...fixture.raw,
            'snapshot': {
              'treeVersion': tree.version,
              'buildInfo': {...fixture.character, 'level': level},
            },
            'stats': {'Life': level * 10},
          },
        };
      case 'pob_get_tree':
        return {
          'version': tree.version,
          'nodes': [
            for (final node in tree.nodes)
              {
                'id': node.id,
                'x': node.x,
                'y': node.y,
                'name': node.name,
                'type': node.kind,
                'allocated': node.allocated,
              },
          ],
          'edges': [
            for (final (from, to) in tree.edges) [from, to],
          ],
        };
      default:
        throw StateError(tool);
    }
  }
}

class _SyncLibrary extends PobBuildLibrary {
  _SyncLibrary(super.profile);

  Completer<void>? preserveStarted, resumePreserve;

  @override
  Future<LibraryEntry?> preserveLocal(PobBuildVersion disk) async {
    preserveStarted?.complete();
    await resumePreserve?.future;
    return super.preserveLocal(disk);
  }
}

void main() {
  const id = 'Общая.xml';
  late Directory root, profile, builds;
  late File original;
  late _SyncLibrary library;
  late _SyncEngine engine;
  late WorkshopCubit model;

  WorkshopCubit createWorkshop() {
    final components = ComponentRepository(store: InstallationStore(profile));
    components.active = {
      for (final component in Component.values)
        component: Installation(
          tag: 'v0.0.1',
          commit: component.name,
          directory: root.path,
        ),
    };
    engine = _SyncEngine();
    return WorkshopCubit(components, engine, library: library);
  }

  Future<void> reopenWorkshop(String buildId) async {
    await model.close();
    library = _SyncLibrary(profile);
    await library.load();
    model = createWorkshop();
    await model.openBuild(buildId);
    expect(model.state.error, isNull);
  }

  Future<void> expectPlan(List<TreeProgressionStep> steps) async {
    expect(model.progressionKey, isNotNull);
    final plan = await model
        .progressionRepository(model.progressionKey!)
        .load();
    expect(encodeProgressionSteps(plan), encodeProgressionSteps(steps));
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-sync-');
    profile = Directory(path.join(root.path, 'profile'));
    builds = await Directory(path.join(root.path, 'builds')).create();
    original = await File(path.join(builds.path, id))
        .writeAsString(buildXml(40));
    library = _SyncLibrary(profile);
    await library.configure(builds.path);
    model = createWorkshop();
    await model.openBuild(id);
    expect(model.state.error, isNull);
  });

  tearDown(() async {
    if (!model.isClosed) await model.close();
    await removeTemporaryDirectory(root);
  });

  final step = TreeProgressionStep(
    42,
    [2, 3],
    title: 'Следующий этап',
    note: 'Проверить сопротивления',
    tasks: const [(text: 'Заменить посох', done: false)],
    keyNodes: const [3, 2],
  );

  test('План следует за сборкой при переименовании и Undo/Redo', () async {
    await model.progressionRepository(model.progressionKey!).save([step]);

    await model.renameBuild('Переименованная');
    expect(model.state.error, isNull);
    final renamedId = model.state.library.activeId!;
    expect(renamedId, isNot(id));
    await expectPlan([step]);

    final edited = step.withProgress(completed: true);
    await model.progressionRepository(model.progressionKey!).save([edited]);
    await model.undo();
    expect(model.state.error, isNull);
    expect(model.state.library.activeId, id);
    await expectPlan([edited]);

    await model.redo();
    expect(model.state.error, isNull);
    expect(model.state.library.activeId, renamedId);
    await expectPlan([edited]);
    await reopenWorkshop(renamedId);
    await expectPlan([edited]);

    await original.writeAsString(buildXml(28));
    await model.openBuild(id);
    expect(model.state.error, isNull);
    expect(model.state.report?.level, 28);
    await expectPlan([]);
  });

  test(
    'Создание копии переносит план и заметки независимо от оригинала',
    () async {
      await model.progressionRepository(model.progressionKey!).save([step]);
      await library.readNotes(id);
      await library.saveNotes(id, 'Заметка о сборке');

      await model.copyBuild();
      expect(model.state.error, isNull);
      final copyId = model.state.library.activeId!;
      expect(copyId, isNot(id));
      expect(await library.readNotes(copyId), 'Заметка о сборке');
      await expectPlan([step]);

      final copyStep = step.withProgress(
        tasks: const [(text: 'Заменить посох', done: true)],
        keyNodes: const [2, 3],
      );
      await model.progressionRepository(model.progressionKey!).save([copyStep]);
      await reopenWorkshop(copyId);
      await expectPlan([copyStep]);
      await model.openBuild(id);
      expect(model.state.error, isNull);
      expect(model.state.library.activeId, id);
      await expectPlan([step]);
    },
  );

  test('Занятое имя оставляет сборку и оба плана без изменений', () async {
    final source = model.progressionKey!;
    await model.progressionRepository(source).save([step]);
    const takenId = 'Занятая.xml';
    final taken = File(path.join(builds.path, takenId));
    await taken.writeAsString(buildXml(65));
    final otherKey = (
      folder: source.folder,
      build: takenId,
      version: source.version,
      characterClass: source.characterClass,
    );
    final otherStep = TreeProgressionStep(65, [1]);
    await model.progressionRepository(otherKey).save([otherStep]);

    await model.renameBuild('Занятая');
    expect(model.state.error, isNotNull);
    expect(model.state.library.activeId, id);
    expect(model.state.undoCount, 0);
    expect(await original.readAsString(), buildXml(40));
    expect(await taken.readAsString(), buildXml(65));
    await expectPlan([step]);
    final other = await model.progressionRepository(otherKey).load();
    expect(encodeProgressionSteps(other), encodeProgressionSteps([otherStep]));
  });

  test(
    'Сбой записи плана сохраняет исходный XML и позволяет повторить',
    () async {
      final source = model.progressionKey!;
      await model.progressionRepository(source).save([step]);
      const title = 'Переименованная';
      final key = sha256.convert(
        utf8.encode(
          jsonEncode([
            source.folder,
            '$title.xml',
            source.version,
            source.characterClass,
          ]),
        ),
      );
      final blocked = await Directory.fromUri(
        profile.uri.resolve('tree-progression/$key.json'),
      ).create();

      await model.renameBuild(title);
      expect(model.state.error, isNotNull);
      expect(model.state.library.activeId, id);
      expect(model.state.undoCount, 0);
      expect(await original.readAsString(), buildXml(40));
      expect((await library.scan()).entries, hasLength(1));
      await expectPlan([step]);

      await blocked.delete();
      await model.renameBuild(title);
      expect(model.state.error, isNull);
      await expectPlan([step]);
    },
  );

  test(
    'Внешний XML подхватывается автоматически, Lua пересчитывает показатели',
    () async {
      final updated = model.stream.firstWhere(
        (state) => !state.busy && state.report?.level == 55,
      );
      final temporary = await File(path.join(builds.path, '~~temp~~.xml'))
          .writeAsString(buildXml(55), flush: true);
      await temporary.rename(original.path);
      await updated.timeout(const Duration(seconds: 5));
      expect(model.state.report!.stats['Life'], 550);
      expect(model.state.library.activeId, id);
      expect(model.state.library.entries, hasLength(1));
      expect(await original.readAsString(), buildXml(55));
    },
  );

  test(
    'Свои записи и неполный XML не перезагружаются, диалог защищён',
    () async {
      await model.treeAction(10, false);
      await model.syncOpenBuild();
      expect(engine.loads, 1);
      expect(model.state.undoCount, 1);
      await original.writeAsString('<PathOfBuilding2>');
      await model.syncOpenBuild();
      expect(model.state.error, isNull);
      expect(model.state.report!.level, 41);
      model.modalOpen = () => true;
      await original.writeAsString(buildXml(55, notes: 'Новые заметки'));
      await model.syncOpenBuild();
      expect(model.state.report!.level, 41);
      final updated = model.stream.firstWhere(
        (state) => !state.busy && state.report?.level == 55,
      );
      model.modalOpen = null;
      model.resumeBuildSync();
      await updated.timeout(const Duration(seconds: 5));
      expect(model.state.report!.level, 55);
      expect(model.state.undoCount, 0);
      final copy = model.state.library.entries.singleWhere(
        (entry) => entry.id != id,
      );
      expect(await library.read(copy.id), buildXml(41));
      await model.syncOpenBuild();
      expect(model.state.library.entries, hasLength(2));
    },
  );

  test('Последние правки и заметки переживают перезапуск PoB II', () async {
    await model.treeAction(10, false);
    await library.readNotes(id);
    await library.saveNotes(id, 'Мой план');
    final localXml = await original.readAsString();
    await model.close();
    await original.writeAsString(buildXml(48, notes: 'План из PoB'));
    final reopened = PobBuildLibrary(profile);
    await reopened.load();
    final disk = await reopened.open(id);
    final copy = await reopened.preserveLocal(disk);
    expect(copy, isNotNull);
    expect(await reopened.read(copy!.id), localXml);
    expect(await reopened.readNotes(copy.id), 'Мой план');
    expect(await original.readAsString(), buildXml(48, notes: 'План из PoB'));
    expect(await reopened.preserveLocal(disk), isNull);
  });

  test('После завершения MCP открывается сохранённая сборка и правка не повторяется', () async {
    await model.close();
    model = createWorkshop();
    await model.connect();
    expect(model.state.error, isNull);
    await model.openBuild(id);
    expect(model.state.error, isNull);
    await library.readNotes(id);
    await library.saveNotes(id, 'Рабочие заметки');
    await model.treeAction(10, false);
    expect(model.state.error, isNull);
    expect(model.state.report?.stats['Life'], 410);
    final savedXml = await original.readAsString();
    engine.exitDuringEdit = true;

    await model.treeAction(11, false);

    expect(engine.level, 42);
    expect(engine.connected, isFalse);
    expect(model.state.status, 'Соединение с Lua прервано');
    expect(model.state.error, contains('MCP завершился во время правки'));
    expect(model.state.document?.stale, isTrue);
    expect(await original.readAsString(), savedXml);

    await model.connect();

    expect(model.state.error, isNull);
    expect(model.state.document?.stale, isFalse);
    expect(model.state.library.activeId, id);
    expect(model.state.report?.stats['Life'], 410);
    expect(await library.readNotes(id), 'Рабочие заметки');
    expect(await original.readAsString(), savedXml);
    expect(engine.treeEdits, 2);
  });

  test('Закрытие ждёт сохранения копии при синхронизации', () async {
    await model.treeAction(10, false);
    final started = library.preserveStarted = Completer<void>();
    final resume = library.resumePreserve = Completer<void>();
    await original.writeAsString(buildXml(55));
    final sync = model.syncOpenBuild();
    await started.future.timeout(const Duration(seconds: 5));
    final closed = Completer<void>();
    final closing = model.close().then((_) => closed.complete());
    try {
      await expectLater(
        closed.future.timeout(const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );
    } finally {
      resume.complete();
      await sync;
      await closing;
    }
    final reopened = PobBuildLibrary(profile);
    final builds = await reopened.load();
    final copy = builds.entries.singleWhere((entry) => entry.id != id);
    expect(await reopened.read(copy.id), buildXml(41));
  });

  test(
    'Правка, которую Lua ещё считает при внешней записи, сохраняется отдельно',
    () async {
      final started = engine.editStarted = Completer<void>();
      final resume = engine.resumeEdit = Completer<void>();
      final localEdit = model.treeAction(10, false);
      final updated = model.stream.firstWhere(
        (state) => !state.busy && state.report?.level == 60,
      );
      await started.future.timeout(const Duration(seconds: 3));
      await original.writeAsString(buildXml(60));
      resume.complete();
      await localEdit;
      final copy = model.state.library.entries.singleWhere(
        (entry) => entry.id != id,
      );
      expect(model.state.error, contains(copy.title));
      expect(await library.read(copy.id), buildXml(41));
      await updated.timeout(const Duration(seconds: 5));
      expect(model.state.report!.level, 60);
      expect(model.state.library.entries, hasLength(2));
      expect(await original.readAsString(), buildXml(60));
    },
  );
}
