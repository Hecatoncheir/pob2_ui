import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/game_catalog_repository.dart';
import '../data/mcp_error_message.dart';
import '../domain/build_report.dart';
import '../domain/build_edit_result.dart';
import '../domain/skill_gem.dart';

typedef SaveSkillGroup = Future<BuildEditResult> Function(
  String label,
  List<JsonMap> gems,
);
typedef SupportSelection = ({bool loading, Set<String> ids, String? error});

class SkillGroupState {
  SkillGroupState({
    List<SkillGem> catalog = const [],
    List<GemDraft> gems = const [],
    this.query = '',
    this.label = '',
    this.loading = true,
    this.saving = false,
    this.error,
    this.showSupports = false,
    this.locksPrimary = false,
    this.support = (loading: false, ids: const {}, error: null),
    this.selectedKey,
  }) : catalog = List.unmodifiable(catalog),
       gems = List.unmodifiable(gems);
  final List<SkillGem> catalog;
  final List<GemDraft> gems;
  final String query, label;
  final bool loading, saving;
  final String? error;
  final bool showSupports, locksPrimary;
  final SupportSelection support;
  final int? selectedKey;
  GemDraft? get selected =>
      gems.where((gem) => gem.key == selectedKey).firstOrNull;
  bool get canSave =>
      !saving &&
      !support.loading &&
      (!locksPrimary || (!loading && support.error == null)) &&
      gems.isNotEmpty &&
      gems
          .skip(1)
          .every(
            (gem) =>
                (locksPrimary && gem.sourceIndex != null) ||
                support.ids.contains(gem.gem.id),
          );
  SkillGroupState copyWith({
    List<SkillGem>? catalog,
    List<GemDraft>? gems,
    String? query,
    String? label,
    bool? loading,
    bool? saving,
    String? error,
    bool? showSupports,
    SupportSelection? support,
    int? selectedKey,
  }) => SkillGroupState(
    catalog: catalog ?? this.catalog,
    gems: gems ?? this.gems,
    query: query ?? this.query,
    label: label ?? this.label,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    error: error,
    showSupports: showSupports ?? this.showSupports,
    locksPrimary: locksPrimary,
    support: support ?? this.support,
    selectedKey: selectedKey ?? this.selectedKey,
  );
}

class SkillGroupCubit extends Cubit<SkillGroupState> {
  SkillGroupCubit(
    this.repository,
    this.commit, {
    List<GemDraft> initial = const [],
    String label = '',
    this.groupId,
    this.group,
  }) : super(
         SkillGroupState(
           gems: initial,
           label: label,
           showSupports: isGrantedSkillGroup(group),
           locksPrimary: isGrantedSkillGroup(group),
           selectedKey: initial.firstOrNull?.key,
         ),
       ) {
    _nextKey = initial.length;
    _original = _signature();
  }
  final GameCatalogRepository repository;
  final SaveSkillGroup commit;
  final int? groupId;
  final JsonMap? group;
  bool get locksPrimary => state.locksPrimary;
  String? get supportScope => group?['supportScope'] as String?;
  late String _original;
  bool get dirty => _signature() != _original;
  int _nextKey = 0;
  Timer? _timer;
  int _generation = 0, _checkedGeneration = -1;
  bool _checking = false;

  bool mayExit() {
    if (state.saving) return false;
    if (!dirty) return true;
    emit(
      state.copyWith(
        error: 'Завершите редактирование перед закрытием приложения',
      ),
    );
    return false;
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      _checkEditorAvailable();
      final entries = await repository.gems();
      if (!isClosed) emit(state.copyWith(catalog: entries, loading: false));
      if (!isClosed && state.gems.isNotEmpty) refreshSupports();
    } catch (error) {
      if (!isClosed)
        emit(state.copyWith(loading: false, error: mcpErrorMessage(error)));
    }
  }

  void _checkEditorAvailable() {
    if (!repository.hasGemEditor) {
      throw const FormatException(
        'Обновите MCP для оригинальных иконок и совместимости',
      );
    }
    final canUpdate = repository.engine.tools.contains(
      'pob_update_skill_group',
    );
    if ((groupId != null && !canUpdate) ||
        (locksPrimary && supportScope == null)) {
      throw const FormatException('Обновите MCP для редактирования группы');
    }
  }

  void search(String value) {
    if (!state.saving) emit(state.copyWith(query: value));
  }

  void label(String value) {
    if (!state.saving && !locksPrimary) emit(state.copyWith(label: value));
  }

  void chooseSupports(bool value) {
    if (!state.saving && !locksPrimary && value != state.showSupports)
      emit(state.copyWith(showSupports: value, query: ''));
  }

  void add(SkillGem gem) => insert(gem, gem.support ? state.gems.length : 0);

  void selectGem(int key) {
    if (!state.saving)
      emit(
        state.copyWith(
          selectedKey: state.selectedKey == key ? state.gems.first.key : key,
        ),
      );
  }

  bool accepts(SkillGem gem, int index) =>
      !state.saving &&
      supportScope != 'none' &&
      (gem.support
          ? index > 0 &&
                state.gems.isNotEmpty &&
                state.support.ids.contains(gem.id)
          : index == 0 && !locksPrimary);

  void insert(SkillGem gem, int index) {
    if (!accepts(gem, index)) return;
    final gems = [...state.gems];
    if (!gem.support && gems.isNotEmpty) gems.removeAt(0);
    if (gem.support && gems.any((draft) => draft.gem.id == gem.id)) return;
    gems.insert(index.clamp(0, gems.length), (
      key: _nextKey++,
      gem: gem,
      level: '1',
      quality: '0',
      enabled: true,
      sourceIndex: null,
    ));
    emit(
      state.copyWith(
        gems: gems,
        showSupports: true,
        query: gem.support ? state.query : '',
        selectedKey: gem.support ? state.selectedKey : gems.first.key,
      ),
    );
    refreshSupports();
  }

  void move(int key, int destination) {
    if (state.saving) return;
    final index = state.gems.indexWhere((draft) => draft.key == key);
    if (index <= 0) return;
    final gems = [...state.gems];
    final draft = gems.removeAt(index);
    gems.insert(destination.clamp(1, gems.length), draft);
    emit(state.copyWith(gems: gems));
  }

  void remove(int key) {
    if (state.saving) return;
    if (state.gems.firstOrNull?.key == key &&
        (locksPrimary || state.gems.length > 1))
      return;
    emit(
      state.copyWith(gems: state.gems.where((gem) => gem.key != key).toList()),
    );
    refreshSupports();
  }

  void change(int key, {String? level, String? quality, bool? enabled}) {
    if (state.saving) return;
    if (locksPrimary && state.gems.first.key == key) return;
    final gems = state.gems
        .map(
          (draft) => draft.key == key
              ? (
                  key: key,
                  gem: draft.gem,
                  level: level ?? draft.level,
                  quality: quality ?? draft.quality,
                  enabled: enabled ?? draft.enabled,
                  sourceIndex: draft.sourceIndex,
                )
              : draft,
        )
        .toList();
    emit(state.copyWith(gems: gems));
    refreshSupports();
  }

  void refreshSupports() {
    if (supportScope == 'none') return;
    _timer?.cancel();
    final generation = ++_generation;
    emit(
      state.copyWith(
        support: (loading: state.gems.isNotEmpty, ids: const {}, error: null),
      ),
    );
    if (state.gems.isEmpty) return;
    _timer = Timer(const Duration(milliseconds: 300), () => _check(generation));
  }

  Future<void> _check(int generation) async {
    if (_checking || generation == _checkedGeneration || isClosed) return;
    _checking = true;
    _checkedGeneration = generation;
    try {
      final ids = await repository.supports(_gemRequests(), groupId: groupId);
      _applySupport(generation, (loading: false, ids: ids, error: null));
    } catch (error) {
      _applySupport(generation, (
        loading: false,
        ids: const {},
        error: mcpErrorMessage(error),
      ));
    } finally {
      _checking = false;
      _checkLatest(generation);
    }
  }

  void _applySupport(int generation, SupportSelection support) {
    if (!isClosed && generation == _generation)
      emit(state.copyWith(support: support));
  }

  void _checkLatest(int generation) {
    if (!isClosed && state.gems.isNotEmpty && generation != _generation)
      unawaited(_check(_generation));
  }

  Future<bool> save() async {
    if (!state.canSave || supportScope == 'none') return false;
    emit(state.copyWith(saving: true));
    try {
      final result = await commit(state.label.trim(), _gemRequests());
      if (!isClosed) {
        if (result.committed) _acknowledge();
        emit(state.copyWith(saving: false, error: result.error));
      }
      return result.committed;
    } catch (error) {
      if (!isClosed)
        emit(
          state.copyWith(
            saving: false,
            error: error is FormatException ? error.message : '$error',
          ),
        );
      return false;
    }
  }

  List<JsonMap> _gemRequests() {
    if (!locksPrimary) return state.gems.map(gemRequest).toList();
    final primary = jsonRows(group!['gems']).first;
    return [
      {'id': primary['skillId'] ?? primary['id'], 'sourceIndex': 1},
      ...state.gems.skip(1).map(gemRequest),
    ];
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    _generation++;
    await super.close();
  }

  String _signature() => jsonEncode({
    'label': state.label,
    'gems': state.gems
        .map(
          (draft) => {
            'id': draft.gem.id,
            'level': draft.level,
            'quality': draft.quality,
            'enabled': draft.enabled,
            'sourceIndex': draft.sourceIndex,
          },
        )
        .toList(),
  });

  void _acknowledge() {
    if (groupId != null) {
      final gems = state.gems.indexed
          .map(
            (entry) => (
              key: entry.$2.key,
              gem: entry.$2.gem,
              level: entry.$2.level,
              quality: entry.$2.quality,
              enabled: entry.$2.enabled,
              sourceIndex: entry.$1 + 1,
            ),
          )
          .toList();
      emit(state.copyWith(gems: gems));
    }
    _original = _signature();
  }
}
