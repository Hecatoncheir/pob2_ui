import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'github_service.dart';
import 'installation_store.dart';
import 'process_service.dart';
import 'native_runtime_installer.dart';
import 'managed_installation.dart';

enum ComponentInstallStage { pob, mcp, compatibility }

class ComponentRepository {
  ComponentRepository({
    required this.store,
    GitHubService? github,
    ProcessService? processes,
    NativeRuntimeInstaller? runtimeInstaller,
  }) : github = github ?? GitHubService(),
       processes = processes ?? ProcessService(),
       _runtimeInstaller = runtimeInstaller ?? NativeRuntimeInstaller();

  final InstallationStore store;
  final GitHubService github;
  final ProcessService processes;
  final NativeRuntimeInstaller _runtimeInstaller;
  Installations active = {};
  static final _lockedRoots = <String>{};

  Future<void> load() async {
    active = await store.load();
  }

  Future<T> _withLock<T>(
    Future<T> Function(Installations current, Installations previous) apply,
  ) async {
    await store.root.create(recursive: true);
    final root = await store.root.resolveSymbolicLinks();
    if (!_lockedRoots.add(root)) throw StateError('Уже выполняется установка');
    try {
      final lock = await File.fromUri(store.root.uri.resolve('.install.lock'))
          .open(mode: FileMode.append);
      try {
        await lock.lock(FileLock.exclusive);
        final saved = await store.read();
        return await apply(saved.active, saved.previous);
      } finally {
        await lock.close();
      }
    } finally {
      _lockedRoots.remove(root);
    }
  }

  void _checkTarget() {
    if (currentAppTarget() == null) {
      throw UnsupportedError(
        'Поддерживаются Windows x64, Linux x64 и macOS arm64',
      );
    }
  }

  Future<Installation> install(
    Component component,
    Release release,
    void Function(String) log,
  ) async {
    _checkTarget();
    return _withLock((current, _) async {
      final installation = await _download(component, release, log);
      final next = {...current, component: installation};
      if (next.length == Component.values.length) {
        await _checkPair(next, log);
      }
      await _activate(next, current);
      return installation;
    });
  }

  Future<void> installPair(
    Map<Component, Release> releases,
    void Function(String) log, {
    Future<void> Function(Installations)? validate,
    void Function(ComponentInstallStage)? onStage,
  }) async {
    _checkTarget();
    final requested = Map.of(releases);
    await _withLock((current, previous) async {
      final next = await _preparePair(current, requested, log, onStage);
      onStage?.call(ComponentInstallStage.compatibility);
      if (_samePair(next, current)) {
        await _adoptSavedPair(current, previous, log, validate);
        return;
      }
      await _checkPair(next, log, validate);
      await _activate(next, current);
    });
  }

  Future<Installations> _preparePair(
    Installations current,
    Map<Component, Release> requested,
    void Function(String) log,
    void Function(ComponentInstallStage)? onStage,
  ) async {
    if ({...current.keys, ...requested.keys}.length !=
        Component.values.length) {
      throw StateError('Сначала выберите версии обоих компонентов');
    }
    final next = Map<Component, Installation>.of(current);
    for (final MapEntry(:key, :value) in requested.entries) {
      if (next[key]?.tag != value.tag) {
        onStage?.call(switch (key) {
          Component.pob => ComponentInstallStage.pob,
          Component.mcp => ComponentInstallStage.mcp,
        });
        next[key] = await _download(key, value, log);
      } else if (value.expectedCommit != null) {
        await _checkInstalledCommit(key, value, next[key]!);
      }
    }
    return next;
  }

  Future<void> _adoptSavedPair(
    Installations current,
    Installations previous,
    void Function(String) log,
    Future<void> Function(Installations)? validate,
  ) async {
    if (!_samePair(active, current)) await _checkPair(current, log, validate);
    store.previous = previous;
    active = current;
  }

  bool _samePair(Installations left, Installations right) =>
      Component.values.every(
        (component) =>
            _revision(left[component]) == _revision(right[component]),
      );

  (String, String, String)? _revision(Installation? installation) =>
      switch (installation) {
        Installation(:final tag, :final commit, :final directory) => (
          tag,
          commit,
          directory,
        ),
        null => null,
      };

  Future<void> _checkPair(
    Installations pair,
    void Function(String) log, [
    Future<void> Function(Installations)? validate,
  ]) async {
    log('Проверка совместимости: запуск исходного Lua…');
    final result = await doctor(pair);
    log('Lua отвечает. Классов в каталоге: ${result['classes']}');
    await validate?.call(Map.unmodifiable(pair));
  }

  Future<void> _activate(Installations next, Installations current) async {
    await store.save(next, current);
    active = next;
  }

  Future<Installation> _download(
    Component component,
    Release release,
    void Function(String) log,
  ) async {
    final versions = await Directory.fromUri(
      store.root.uri.resolve('versions/'),
    ).create(recursive: true);
    final candidate = await versions.createTemp('${component.name}-');
    log('Загрузка ${component.title} ${release.tag}…');
    await _git(candidate, ['init', '--quiet']);
    await _git(candidate, ['remote', 'add', 'origin', '${component.url}.git']);
    if (component == Component.pob) {
      await _git(candidate, ['sparse-checkout', 'init', '--cone']);
      await _git(candidate, ['sparse-checkout', 'set', 'src', 'runtime']);
    }
    await _git(candidate, [
      'fetch',
      '--depth=1',
      '--filter=blob:none',
      'origin',
      'refs/tags/${release.tag}',
    ], log);
    await _git(candidate, ['checkout', '--detach', 'FETCH_HEAD'], log);
    final commit = await _git(candidate, ['rev-parse', 'HEAD']);
    _checkCommit(component, release, commit);
    if (component == Component.mcp) {
      await _runtimeInstaller.install(candidate, release.tag, processes, log);
    }
    await _validate(component, candidate);
    log('${component.title} ${release.tag} загружен. Git: $commit');
    return Installation(
      tag: release.tag,
      commit: commit,
      directory: candidate.path,
    );
  }

  Future<void> _checkInstalledCommit(
    Component component,
    Release release,
    Installation installation,
  ) async {
    _checkCommit(component, release, installation.commit);
    final actual = await _git(Directory(installation.directory), [
      'rev-parse',
      'HEAD',
    ]);
    _checkCommit(component, release, actual);
  }

  void _checkCommit(Component component, Release release, String actual) {
    final expected = release.expectedCommit;
    if (expected == null || actual == expected) return;
    throw StateError(
      'Ревизия ${component.title} ${release.tag} не совпадает: ожидалась $expected, получена $actual.',
    );
  }

  Future<String> _git(
    Directory directory,
    List<String> arguments, [
    void Function(String)? log,
  ]) =>
      processes.run('git', ['-C', directory.path, ...arguments], onOutput: log);

  Future<void> _validate(Component component, Directory directory) async {
    final files = component == Component.pob
        ? [
            'src/Launch.lua',
            'runtime/lua/dkjson.lua',
            'src/Modules/Main.lua',
            if (Platform.isWindows) 'runtime/lua51.dll',
          ]
        : ['run.py', 'pob_poe2_mcp/server.py'];
    for (final relative in files) {
      if (!await File.fromUri(directory.uri.resolve(relative)).exists()) {
        throw StateError(
          'В компоненте отсутствует $relative. Рабочая версия сохранена.',
        );
      }
    }
    if (component == Component.mcp) {
      final python = await processes.python();
      await processes.run(
        python,
        ['-X', 'utf8', 'run.py', '--version'],
        directory: directory.path,
        timeout: const Duration(seconds: 20),
      );
    }
  }

  Future<Map<String, dynamic>> doctor([Installations? installations]) async {
    final pair = installations ?? active;
    final pob = pair[Component.pob];
    final mcp = pair[Component.mcp];
    if (pob == null || mcp == null)
      throw StateError('Сначала установите оба компонента');
    final python = await processes.python();
    final output = await processes.run(
      python,
      [
        '-X',
        'utf8',
        'run.py',
        'doctor',
        '--mode',
        'engine',
        '--pob-dir',
        pob.directory,
      ],
      directory: mcp.directory,
      timeout: const Duration(seconds: 90),
    );
    final result = jsonDecode(output) as Map<String, dynamic>;
    if (result['ok'] != true) throw StateError('Lua не прошёл проверку');
    return result;
  }

  Future<void> rollback({Future<void> Function(Installations)? validate}) =>
      _withLock((current, previous) async {
        if (previous.length != Component.values.length) {
          throw StateError('Предыдущей полной пары компонентов пока нет');
        }
        await doctor(previous);
        await validate?.call(Map.unmodifiable(previous));
        await _activate(previous, current);
      });
}
