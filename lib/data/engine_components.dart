import 'dart:convert';

import '../domain/component.dart';
import 'component_repository.dart';

typedef _Installations = ({Installations current, Installations previous});

class EngineComponents extends ComponentRepository {
  EngineComponents({
    required super.store,
    required super.profileUse,
    required this.executable,
  });

  final String executable;

  @override
  List<Component> get requiredComponents => const [Component.pob];

  @override
  String get engineExecutable => executable;

  @override
  Map<Component, Release> availableReleases() => {
    Component.pob: super.availableReleases()[Component.pob]!,
  };

  @override
  bool needsInstall(Component component, Release release) =>
      active[component]?.tag != release.tag;

  @override
  Future<void> load() async => _adopt(await _read('status'));

  @override
  Future<List<Installations>> installedPairs() async {
    final state = await _read('status');
    return [
      if (state.current.isNotEmpty) state.current,
      if (state.previous.isNotEmpty) state.previous,
    ];
  }

  @override
  Future<Installation> install(
    Component component,
    Release release,
    void Function(String) log,
  ) async {
    if (component != Component.pob) {
      throw StateError('Установками PoB управляет комплектный движок');
    }
    await installPair({component: release}, log);
    return active[component]!;
  }

  @override
  Future<void> installPair(
    Map<Component, Release> releases,
    void Function(String) log, {
    Future<void> Function(Installations)? validate,
    void Function(ComponentInstallStage)? onStage,
  }) async {
    final state = await _read('status');
    final current = state.current[Component.pob];
    final requested = releases[Component.pob]?.tag;
    if (current != null && (requested == null || current.tag == requested)) {
      _adopt(state);
      return;
    }
    onStage?.call(ComponentInstallStage.pob);
    final updated = await _installPoB(current, requested, log);
    onStage?.call(ComponentInstallStage.compatibility);
    await _validateUpdate(updated, current, validate);
  }

  Future<_Installations> _installPoB(
    Installation? current,
    String? requested,
    void Function(String) log,
  ) async {
    log('Подготовка исходного Lua PoB через комплектный движок');
    if (current == null) {
      final initial = await _read('ensure');
      if (requested == null ||
          initial.current[Component.pob]?.tag == requested) {
        return initial;
      }
    }
    return _read('update', tag: requested);
  }

  Future<void> _validateUpdate(
    _Installations updated,
    Installation? previous,
    Future<void> Function(Installations)? validate,
  ) async {
    try {
      await validate?.call(updated.current);
    } catch (_) {
      if (previous != null &&
          updated.previous[Component.pob]?.commit == previous.commit) {
        _adopt(await _read('rollback'));
      }
      rethrow;
    }
    _adopt(updated);
  }

  @override
  Future<void> rollback({
    Future<void> Function(Installations)? validate,
  }) async {
    final state = await _read('status');
    if (state.previous.isEmpty) {
      throw StateError('Нет предыдущей установки PoB');
    }
    await validate?.call(state.previous);
    _adopt(await _read('rollback'));
  }

  @override
  Future<void> selectInstalled(
    Component component,
    String commit, {
    Future<void> Function(Installations)? validate,
  }) async {
    final state = await _read('status');
    if (state.current[component]?.commit == commit) return;
    if (state.previous[component]?.commit != commit) {
      throw StateError('Установленная версия не найдена');
    }
    await rollback(validate: validate);
  }

  @override
  Future<Map<String, dynamic>> doctor([Installations? installations]) async {
    final pair = installations ?? active;
    final pob = pair[Component.pob];
    return {
      'status': pob == null ? 'not_installed' : 'ok',
      'pob': pob?.toJson(),
    };
  }

  void _adopt(_Installations state) {
    active = state.current;
    store.previous = state.previous;
  }

  Future<_Installations> _read(String action, {String? tag}) async {
    final raw = await processes.run(executable, [
      'pob-data',
      if (tag != null) ...['--tag', tag],
      action,
    ]);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (
      current: _decode(data['current']),
      previous: _decode(data['previous']),
    );
  }

  Installations _decode(Object? value) => switch (value) {
    final Map<String, dynamic> installation => {
      Component.pob: Installation.fromJson(installation),
    },
    _ => {},
  };
}
