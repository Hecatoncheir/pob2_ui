import 'dart:convert';
import 'dart:io';

import 'ui/workshop_cubit.dart';

const _name = 'Installer check';
const _notes = 'Installer check notes';
const _ring =
    'Item Class: Rings\nRarity: Rare\nTide Loop\nLazuli Ring\n'
    '--------\nItem Level: 80\n--------\n+50 to maximum Life\n';

Future<int> checkInstalledBuild(
  WorkshopCubit model,
  Future<void> initialization,
  String stage,
) async {
  final root = model.components.store.root;
  model.modalOpen = () => true;
  try {
    final result = await _checkBuild(model, initialization, stage);
    await _writeResult(root, stage, result);
    return 0;
  } catch (error, trace) {
    await _writeResult(root, stage, {'error': '$error', 'trace': '$trace'});
    return 1;
  }
}

Future<Map<String, Object?>> _checkBuild(
  WorkshopCubit model,
  Future<void> initialization,
  String stage,
) async {
  try {
    await initialization;
    if (stage == 'save') {
      if (!model.ready) await model.prepareComponents();
      _require(model.state.error == null && model.luaReady, model);
      await _saveBuild(model);
    }
    final report = model.state.report;
    final id = model.state.library.activeId;
    _require(model.state.error == null && model.luaReady, model);
    _require(report != null && id != null, model);
    _require(await model.buildNotes.readNotes(id!) == _notes, model);
    return {
      'source': report!.raw['source'],
      'id': id,
      'level': report.level,
      'life': report.stats['Life'],
    };
  } finally {
    await model.close();
  }
}

Future<void> _saveBuild(WorkshopCubit model) async {
  _require(model.state.library.entries.isEmpty, model);
  final witch = model.state.classes.firstWhere((row) => row['name'] == 'Witch');
  await model.createBuild(witch['id'] as int, 90, name: _name);
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
