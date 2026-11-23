import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'domain/component.dart';
import 'ui/workshop_cubit.dart';

const _name = 'Installer check';
const _notes = 'Installer check notes';
const _ring =
    'Item Class: Rings\nRarity: Rare\nTide Loop\nLazuli Ring\n'
    '--------\nItem Level: 80\n--------\n+50 to maximum Life\n';

class OfflineInstallerCheck extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw const SocketException.closed();
}

class InstallerCheckProgress {
  InstallerCheckProgress(Directory root, String stage)
    : _output = File.fromUri(
        root.uri.resolve('installer-progress-$stage.jsonl'),
      );

  final File _output;
  final _watch = Stopwatch()..start();

  void record(String step) {
    _output.parent.createSync(recursive: true);
    final entry = jsonEncode({
      'step': step,
      'elapsedMs': _watch.elapsedMilliseconds,
      'timestampMs': DateTime.now().millisecondsSinceEpoch,
    });
    _output.writeAsStringSync('$entry\n', mode: FileMode.append, flush: true);
  }
}

Future<int> checkInstalledBuild(
  WorkshopCubit model,
  Future<void> initialization,
  String stage,
  InstallerCheckProgress progress,
) async {
  final root = model.components.store.root;
  model.modalOpen = () => true;
  final log = model.stream
      .map((state) => state.log.lastOrNull)
      .distinct()
      .listen((message) {
        if (message != null) progress.record(message);
      });
  try {
    final result = await _checkBuild(model, initialization, stage, progress);
    await _writeResult(root, stage, result);
    return 0;
  } catch (error, trace) {
    await _writeResult(root, stage, {'error': '$error', 'trace': '$trace'});
    return 1;
  } finally {
    await log.cancel();
  }
}

Future<Map<String, Object?>> _checkBuild(
  WorkshopCubit model,
  Future<void> initialization,
  String stage,
  InstallerCheckProgress progress,
) async {
  try {
    progress.record('initialize');
    await initialization;
    if (stage == 'link') return await _checkLink(model, progress);
    if (stage == 'cleanup') await _cleanAndRollback(model, progress);
    if (stage == 'save') {
      progress.record('components');
      if (!model.ready) await model.prepareComponents();
      _require(model.state.error == null && model.luaReady, model);
      await _saveBuild(model, progress);
    }
    progress.record(stage == 'save' ? 'xml-saved' : 'xml-reopened');
    final report = model.state.report;
    final id = model.state.library.activeId;
    _require(model.state.error == null && model.luaReady, model);
    _require(report != null && id != null, model);
    _require(await model.buildNotes.readNotes(id!) == _notes, model);
    await _checkRestoredTreeArtwork(model, stage, progress);
    return {
      'source': report!.raw['source'],
      'id': id,
      'level': report.level,
      'life': report.stats['Life'],
      'dps': report.stats['TotalDPS'],
    };
  } finally {
    await model.close();
  }
}

Future<void> _checkRestoredTreeArtwork(
  WorkshopCubit model,
  String stage,
  InstallerCheckProgress progress,
) async {
  if (stage != 'restore' ||
      Platform.environment['POB2_UI_CHECK_TREE_CACHE'] != '1') {
    return;
  }
  progress.record('restore-tree-artwork');
  await model.waitForTreeArtwork();
  final tree = model.state.document?.tree;
  if (tree?.iconError case final error?) throw StateError(error);
  _require(tree != null && tree.icons.isNotEmpty, model);
  progress.record('tree-artwork-ready');
}

Future<void> _cleanAndRollback(
  WorkshopCubit model,
  InstallerCheckProgress progress,
) async {
  final repository = model.components;
  final root = repository.store.root;
  final original = repository.active[Component.pob]!.directory;
  final rollback = repository.store.previous[Component.pob]!.directory;
  _require(!path.equals(original, rollback), model);
  _checkWitch(model);
  final obsolete = path.join('versions', 'pob-obsolete');
  final entries = await model.previewProfileCleanup();
  _require(entries.any((entry) => entry.relativePath == obsolete), model);
  _require(
    entries.any(
      (entry) => path.split(entry.relativePath).first == 'tree-cache',
    ),
    model,
  );
  final result = await model.cleanProfile(entries.toSet());
  if (result.skipped.isNotEmpty) {
    throw StateError(result.skipped.toString());
  }
  _require(result.bytes > 0, model);
  _require(!await Directory(path.join(root.path, obsolete)).exists(), model);
  _checkWitch(model);
  progress.record('profile-cleaned');
  await model.rollback();
  _require(repository.active[Component.pob]?.directory == rollback, model);
  _checkWitch(model);
  progress.record('components-rollback-checked');
}

Future<Map<String, Object?>> _checkLink(
  WorkshopCubit model,
  InstallerCheckProgress progress,
) async {
  final path = Platform.environment['POB2_UI_CHECK_LINK'];
  final previous = model.state.library.activeId;
  _require(path != null && previous != null && model.luaReady, model);
  final count = model.state.library.entries.length;
  progress.record('open-share-link');
  await model.importShareLink(await File(path!).readAsString());
  _checkWitch(model);
  final id = model.state.library.activeId;
  _require(id != null && id != previous, model);
  _require(model.state.library.entries.length == count + 1, model);
  progress.record('share-link-imported');
  return {
    'source': model.state.report!.raw['source'],
    'id': id,
    'dps': model.state.report!.stats['TotalDPS'],
  };
}

Future<void> _saveBuild(
  WorkshopCubit model,
  InstallerCheckProgress progress,
) async {
  _require(model.state.library.entries.isEmpty, model);
  progress.record('open-build');
  await _openWitch(model);
  progress.record('calculate-and-save');
  final before = model.state.report?.stats['Life'];
  _require(before is num && before > 0, model);
  final edited = await model.equipItem('Ring 1', raw: _ring);
  final after = model.state.report?.stats['Life'];
  _require(edited.committed && after is num && after > (before as num), model);
  final id = model.state.library.activeId!;
  await model.buildNotes.readNotes(id);
  await model.buildNotes.saveNotes(id, _notes);
  await model.checkpoint();
}

Future<void> _openWitch(WorkshopCubit model) async {
  final environment = Platform.environment;
  if (environment['POB2_UI_CHECK_CODE'] case final path?) {
    await model.importShareCode(await File(path).readAsString());
    _checkWitch(model);
    return;
  }
  if (environment['POB2_UI_CHECK_FIXTURE'] case final path?) {
    await model.importXml(await File(path).readAsString());
    _checkWitch(model);
    return;
  }
  final witch = model.state.classes.firstWhere((row) => row['name'] == 'Witch');
  await model.createBuild(witch['id'] as int, 90, name: _name);
}

void _checkWitch(WorkshopCubit model) {
  final report = model.state.report;
  _require(report?.raw['source'] == 'original-lua', model);
  final dps = report?.stats['TotalDPS'];
  _require(dps is num && (dps - 12.817708).abs() < 0.00001, model);
}

void _require(bool condition, WorkshopCubit model) {
  if (condition) return;
  throw StateError(model.state.error ?? model.state.log.join('\n'));
}

Future<void> _writeResult(
  Directory root,
  String stage,
  Map<String, Object?> data,
) =>
    File.fromUri(root.uri.resolve('installer-check-$stage.json'))
        .writeAsString(jsonEncode(data), flush: true);
