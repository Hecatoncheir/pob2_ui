import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'component_archive.dart';
import 'component_packages.dart';
import 'github_service.dart';
import 'installation_store.dart';
import 'process_service.dart';
import 'native_runtime_installer.dart';
import 'managed_installation.dart';
import 'verified_download.dart';

enum ComponentInstallStage { pob, mcp, compatibility }

class ComponentRepository {
  ComponentRepository({
    required this.store,
    GitHubService? github,
    ProcessService? processes,
    NativeRuntimeInstaller? runtimeInstaller,
    VerifiedDownload? packageDownload,
    this.keepArchives = false,
  }) : github = github ?? GitHubService(),
       processes = processes ?? ProcessService(),
       _runtimeInstaller = runtimeInstaller ?? NativeRuntimeInstaller(),
       _packageDownload = packageDownload ?? VerifiedDownload();

  final InstallationStore store;
  final GitHubService github;
  final ProcessService processes;
  final NativeRuntimeInstaller _runtimeInstaller;
  final VerifiedDownload _packageDownload;
  final bool keepArchives;
  Installations active = {};
  static final _lockedRoots = <String>{};

  Map<Component, Release> availableReleases() => componentReleases();

  bool needsInstall(Component component, Release release) =>
      _needsInstall(active[component], release);

  bool _needsInstall(Installation? installed, Release release) =>
      installed?.tag != release.tag ||
      (release.package != null &&
          installed?.archiveSha256 != release.package!.sha256);

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
        await _cleanupCandidates(saved.active, saved.previous);
        try {
          return await apply(saved.active, saved.previous);
        } finally {
          final stored = await store.read();
          await _cleanupCandidates(stored.active, stored.previous);
        }
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
      if (_needsInstall(next[key], value)) {
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
    if (release.package != null) {
      return _downloadArchive(component, release, candidate, log);
    }
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
    final installation = Installation(
      tag: release.tag,
      commit: commit,
      directory: candidate.path,
    );
    await _validate(component, installation);
    log('${component.title} ${release.tag} загружен. Git: $commit');
    return installation;
  }

  Future<Installation> _downloadArchive(
    Component component,
    Release release,
    Directory candidate,
    void Function(String) log,
  ) async {
    await _pendingMarker(candidate).create();
    final asset = release.package!;
    final commit = release.expectedCommit;
    final digest = asset.sha256 ?? '';
    if (commit == null ||
        !RegExp(r'^[a-f0-9]{40}$').hasMatch(commit) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
      throw const FormatException('Для архива нужна закреплённая ревизия');
    }
    final cache = Directory.fromUri(
      store.root.uri.resolve('component-downloads/$digest/'),
    );
    final source = await _packageDownload.download(
      asset,
      cache,
      onCacheHit: () => log('Используется проверенный архив ${asset.name}'),
      onProgress: (progress) {
        if (progress == 1) log('Проверка SHA-256 архива ${asset.name}');
      },
    );
    log('Распаковка архива ${asset.name}');
    await extractComponentArchive(source.path, candidate.path);
    final installation = Installation(
      tag: release.tag,
      commit: commit,
      directory: candidate.path,
      archiveSha256: digest,
    );
    log('Проверка файлов ${component.title}');
    await _validate(component, installation);
    if (!keepArchives) await cache.delete(recursive: true);
    return installation;
  }

  File _pendingMarker(Directory directory) =>
      File.fromUri(directory.uri.resolve('.component-candidate'));

  Future<void> _cleanupCandidates(
    Installations current,
    Installations previous,
  ) async {
    final protected = {
      for (final installation in [...current.values, ...previous.values])
        Directory(installation.directory).absolute.path,
    };
    final versions = Directory.fromUri(store.root.uri.resolve('versions/'));
    if (!await versions.exists()) return;
    await for (final entity in versions.list(followLinks: false)) {
      if (entity is Directory) await _cleanupCandidate(entity, protected);
    }
  }

  Future<void> _cleanupCandidate(
    Directory candidate,
    Set<String> protected,
  ) async {
    final marker = _pendingMarker(candidate);
    if (!await marker.exists()) return;
    try {
      if (protected.contains(candidate.absolute.path)) {
        await marker.delete();
      } else {
        await candidate.delete(recursive: true);
      }
    } on FileSystemException {
      // Повторим очистку при следующей операции, если файл ещё занят.
    }
  }

  Future<void> _checkInstalledCommit(
    Component component,
    Release release,
    Installation installation,
  ) async {
    _checkCommit(component, release, installation.commit);
    if (installation.archiveSha256 != null) return;
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

  Future<void> _validate(Component component, Installation installation) async {
    final directory = Directory(installation.directory);
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
      final python = await processes.runtimePython(installation);
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
    final python = await processes.runtimePython(mcp);
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
