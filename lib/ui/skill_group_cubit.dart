import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/game_catalog_repository.dart';
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
    this.support = (loading: false, ids: const {}, error: null),
    this.selectedKey,
  }) : catalog = List.unmodifiable(catalog),
       gems = List.unmodifiable(gems);
  final List<SkillGem> catalog;
  final List<GemDraft> gems;
  final String query, label;
  final bool loading, saving;
  final String? error;
  final bool showSupports;
  final SupportSelection support;
  final int? selectedKey;
  GemDraft? get selected =>
      gems.where((gem) => gem.key == selectedKey).firstOrNull;
  bool get canSave =>
      !saving &&
      !support.loading &&
      gems.isNotEmpty &&
      gems.skip(1).every((gem) => support.ids.contains(gem.gem.id));
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
    support: support ?? this.support,
    selectedKey: selectedKey ?? this.selectedKey,
  );
}

class SkillGroupCubit extends Cubit<SkillGroupState> {
  SkillGroupCubit(this.repository, this.commit) : super(SkillGroupState());
  final GameCatalogRepository repository;
  final SaveSkillGroup commit;
  int _nextKey = 0;
  Timer? _timer;
  int _generation = 0, _checkedGeneration = -1;
  bool _checking = false;

  bool mayExit() {
    if (state.saving) return false;
    if (state.gems.isEmpty && state.label.trim().isEmpty) return true;
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
      if (!repository.hasGemEditor)
        throw const FormatException(
          'Обновите MCP для оригинальных иконок и совместимости',
        );
      final entries = await repository.gems();
      if (!isClosed) emit(state.copyWith(catalog: entries, loading: false));
    } catch (error) {
      if (!isClosed)
        emit(
          state.copyWith(
            loading: false,
            error: error is FormatException ? error.message : '$error',
          ),
        );
    }
  }

  void search(String value) {
    if (!state.saving) emit(state.copyWith(query: value));
  }

  void label(String value) {
    if (!state.saving) emit(state.copyWith(label: value));
  }

  void chooseSupports(bool value) {
    if (!state.saving && value != state.showSupports)
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
      (gem.support
          ? index > 0 &&
                state.gems.isNotEmpty &&
                state.support.ids.contains(gem.id)
          : index == 0);

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
    if (state.gems.firstOrNull?.key == key && state.gems.length > 1) return;
    emit(
      state.copyWith(gems: state.gems.where((gem) => gem.key != key).toList()),
    );
    refreshSupports();
  }

  void change(int key, {String? level, String? quality, bool? enabled}) {
    if (state.saving) return;
    final gems = state.gems
        .map(
          (draft) => draft.key == key
              ? (
                  key: key,
                  gem: draft.gem,
                  level: level ?? draft.level,
                  quality: quality ?? draft.quality,
                  enabled: enabled ?? draft.enabled,
                )
              : draft,
        )
        .toList();
    emit(state.copyWith(gems: gems));
    refreshSupports();
  }

  void refreshSupports() {
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
      final ids = await repository.supports(
        state.gems.map(gemRequest).toList(),
      );
      _applySupport(generation, (loading: false, ids: ids, error: null));
    } catch (error) {
      _applySupport(generation, (
        loading: false,
        ids: const {},
        error: '$error',
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
    if (!state.canSave) return false;
    emit(state.copyWith(saving: true));
    try {
      final result = await commit(
        state.label.trim(),
        state.gems.map(gemRequest).toList(),
      );
      if (!isClosed) emit(state.copyWith(saving: false, error: result.error));
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

  @override
  Future<void> close() async {
    _timer?.cancel();
    _generation++;
    await super.close();
  }
}
