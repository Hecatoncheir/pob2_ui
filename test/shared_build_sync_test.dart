import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

String buildXml(int level, {String notes = ''}) =>
    '<PathOfBuilding2><Build className="Witch" level="$level"/><Notes>$notes</Notes></PathOfBuilding2>';

class _SyncEngine extends McpClient {
  int level = 0;
  int loads = 0;
  Completer<void>? editStarted, resumeEdit;

  @override
  bool get connected => true;

  @override
  Future<JsonMap> call(String tool, [JsonMap arguments = const {}]) async {
    switch (tool) {
      case 'pob_import_xml':
        loads++;
        level = PobBuildDocument(arguments['xml'] as String).level;
        return {};
      case 'pob_export_xml':
        return {'xml': buildXml(level)};
      case 'pob_tree_action':
        editStarted?.complete();
        await resumeEdit?.future;
        level++;
        return {};
      case 'pob_check_build':
        return {
          'report': {
            ...fixture.raw,
            'snapshot': {
              'buildInfo': {...fixture.character, 'level': level},
            },
            'stats': {'Life': level * 10},
          },
        };
      default:
        throw StateError(tool);
    }
  }
}

void main() {
  const id = 'Общая.xml';
  late Directory root, profile, builds;
  late File original;
  late PobBuildLibrary library;
  late _SyncEngine engine;
  late WorkshopCubit model;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-sync-');
    profile = Directory(path.join(root.path, 'profile'));
    builds = await Directory(path.join(root.path, 'builds')).create();
    original = await File(path.join(builds.path, id))
        .writeAsString(buildXml(40));
    library = PobBuildLibrary(profile);
    await library.configure(builds.path);
    engine = _SyncEngine();
    model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(profile)),
      engine,
      library: library,
    );
    await model.openBuild(id);
    expect(model.state.error, isNull);
  });

  tearDown(() async {
    if (!model.isClosed) await model.close();
    await removeTemporaryDirectory(root);
  });

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
