import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'bundled_engine.dart';
import 'component_source.dart';
import 'installation_store.dart';
import 'process_service.dart';
import 'profile_cleanup.dart';
import 'profile_use.dart';

typedef _Installations = ({Installations current, Installations previous});

class EngineComponents implements ComponentSource {
  EngineComponents({
    required this.store,
    this.profileUse,
    String? executable,
    this.processes = const ProcessService(),
  }) : executable = executable ?? defaultEngineExecutable();

  @override
  final InstallationStore store;
  @override
  final ProfileUse? profileUse;
  final String executable;
  final ProcessService processes;
  @override
  Installations active = {};
  @override
  late final profileCleanup = ProfileCleanup(store, active: () => active);

  @override
  List<Component> get requiredComponents => const [Component.pob];

  @override
  String get engineExecutable => executable;

  @override
  Map<Component, Release> availableReleases() => {
    Component.pob: Release(
      'v0.23.1',
      '${Component.pob.url}/releases/tag/v0.23.1',
      DateTime.utc(2026, 11, 20),
    ),
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

  @override
  Future<CleanupResult> cleanProfile(Set<CleanupEntry> selected) {
    final use = profileUse;
    if (use == null) throw StateError('Очистка профиля сейчас недоступна.');
    return use.exclusively(store.root, () async {
      final lock = await File.fromUri(store.root.uri.resolve('.install.lock'))
          .open(mode: FileMode.append);
      try {
        await lock.lock(FileLock.exclusive);
        return await profileCleanup.apply(selected);
      } finally {
        await lock.close();
      }
    });
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
