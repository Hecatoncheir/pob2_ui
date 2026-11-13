import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/build_report.dart';
import '../domain/skill_gem.dart';
import 'gem_drag.dart';
import 'skill_group_cubit.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';

typedef SkillWorkspaceState = ({
  int? groupId,
  SkillGroupState? draft,
  bool busy,
  String? error,
});

class SkillWorkspaceCubit extends Cubit<SkillWorkspaceState> {
  SkillWorkspaceCubit(this.model)
    : super((groupId: null, draft: null, busy: false, error: null)) {
    _reportSubscription = model.stream.listen(_reportChanged);
  }
  final WorkshopCubit model;
  SkillGroupCubit? editor;
  StreamSubscription<WorkshopState>? _reportSubscription;
  StreamSubscription<SkillGroupState>? _draftSubscription;
  BuildReport? _lastReport;
  Future<void> _pending = Future.value();
  bool _closing = false;

  Future<void> initialize() async {
    _lastReport = model.state.report;
    final group = model.state.report?.skillGroups.firstOrNull;
    if (group != null) await select(group['id'] as int);
  }

  void _publish({String? error, bool? busy}) {
    if (!isClosed)
      emit((
        groupId: editor?.groupId,
        draft: editor?.state,
        busy: busy ?? state.busy,
        error: error ?? (busy == null ? state.error : null),
      ));
  }

  Future<void> select(int id) => _run(() => _select(id));

  Future<void> _select(int id) async {
    if (editor?.groupId == id) return;
    await _replace(id);
  }

  Future<void> _replace(int id) async {
    final group = _group(id);
    final initial = groupGemDrafts(group);
    final query = editor?.groupId == id ? editor!.state.query : '';
    unawaited(_draftSubscription?.cancel());
    unawaited(editor?.close());
    editor = SkillGroupCubit(
      model.catalogs,
      (label, gems) => model.updateSkillGroup(id, label, gems),
      groupId: id,
      group: group,
      initial: initial,
      label: group['customLabel'] as String? ?? '',
    );
    editor!.chooseSupports(true);
    editor!.search(query);
    _draftSubscription = editor!.stream.listen((_) => _publish());
    _publish();
    await editor!.load();
  }

  JsonMap _group(int id) =>
      model.state.report?.groups
          .where((group) => group['id'] == id)
          .firstOrNull ??
      (throw const FormatException('Группа больше не существует'));

  Future<void> add(int groupId, GemDrag data) => _run(() async {
    if (data.groupId != null) return;
    await _select(groupId);
    final current = editor!;
    await _ready(current);
    if (!current.accepts(data.gem, current.state.gems.length))
      throw const FormatException(
        'Эта поддержка не подходит выбранному умению',
      );
    current.add(data.gem);
    await _save(current);
  });

  Future<void> remove(GemDrag data) => _run(() async {
    if (!data.gem.support || data.groupId == null) return;
    await _select(data.groupId!);
    final current = editor!;
    final draft = current.state.gems
        .where(
          (draft) =>
              draft.sourceIndex == data.sourceIndex &&
              draft.gem.id == data.gem.id,
        )
        .firstOrNull;
    if (draft == null)
      throw const FormatException('Состав группы изменился; повторите перенос');
    current.remove(draft.key);
    await _save(current);
  });

  Future<void> delete(int id) => _run(() async {
    if (!model.engine.tools.contains('pob_delete_skill_group'))
      throw const FormatException('Обновите MCP для удаления умения');
    final result = await model.deleteSkillGroup(id);
    if (!result.committed)
      throw FormatException(result.error ?? 'Не удалось удалить умение');
    final report = model.state.report!;
    final groups = report.skillGroups;
    if (groups.isEmpty) {
      await _clear();
      return;
    }
    final main = report.groupSelector['selected'] as int?;
    final next = groups.where((group) => group['id'] == main).firstOrNull;
    await _replace((next ?? groups.first)['id'] as int);
  });

  Future<void> _ready(SkillGroupCubit current) async {
    if (current.state.loading || current.state.support.loading)
      await current.stream.firstWhere(
        (state) => !state.loading && !state.support.loading,
      );
    if (current.state.support.error case final error?)
      throw FormatException(error);
    if (current.state.error case final error?) throw FormatException(error);
  }

  Future<void> _save(SkillGroupCubit current) async {
    if (!current.dirty) return;
    try {
      await _ready(current);
      if (!await current.save())
        throw FormatException(
          current.state.error ?? 'Не удалось сохранить группу',
        );
    } catch (_) {
      await _replace(current.groupId!);
      rethrow;
    }
  }

  Future<void> _run(Future<void> Function() action) {
    if (state.busy || model.state.busy || _closing) return Future.value();
    _publish(busy: true);
    _pending = _perform(action);
    return _pending;
  }

  Future<void> _perform(Future<void> Function() action) async {
    try {
      await action();
      _publish(busy: false);
    } catch (error) {
      _publish(
        busy: false,
        error: error is FormatException ? error.message : '$error',
      );
    }
  }

  void _reportChanged(WorkshopState state) {
    if (state.busy || state.report == _lastReport) return;
    _lastReport = state.report;
    if (this.state.busy || _closing) return;
    final groups = state.report?.skillGroups ?? const <JsonMap>[];
    final group =
        groups.where((group) => group['id'] == editor?.groupId).firstOrNull ??
        groups.firstOrNull;
    final id = group?['id'] as int?;
    if (id != null)
      unawaited(_run(() => _replace(id)));
    else
      unawaited(_run(_clear));
  }

  Future<void> _clear() async {
    unawaited(_draftSubscription?.cancel());
    unawaited(editor?.close());
    editor = null;
    _publish();
  }

  @override
  Future<void> close() async {
    _closing = true;
    await _reportSubscription?.cancel();
    await _pending;
    await _draftSubscription?.cancel();
    await editor?.close();
    await super.close();
  }
}
