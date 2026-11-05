import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'github_service.dart';
import 'installation_store.dart';
import 'process_service.dart';

class ComponentRepository {
  ComponentRepository({
    required this.store,
    GitHubService? github,
    ProcessService? processes,
  }) : github = github ?? GitHubService(),
       processes = processes ?? ProcessService();

  final InstallationStore store;
  final GitHubService github;
  final ProcessService processes;
  Installations active = {};
  bool _mutating = false;
  RandomAccessFile? _lock;

  Future<void> load() async {
    active = await store.load();
  }

  Future<void> _acquire() async {
    if (_mutating) throw StateError('Уже выполняется установка');
    _mutating = true;
    try {
      await store.root.create(recursive: true);
      _lock = await File.fromUri(store.root.uri.resolve('.install.lock'))
          .open(mode: FileMode.append);
      await _lock!.lock(FileLock.exclusive);
      await load();
    } catch (_) {
      await _release();
      rethrow;
    }
  }

  Future<void> _release() async {
    await _lock?.close();
    _lock = null;
    _mutating = false;
  }

  Future<Installation> install(
    Component component,
    Release release,
    void Function(String) log,
  ) async {
    if (!Platform.isWindows)
      throw UnsupportedError('Пока поддерживается Windows x64');
    await _acquire();
    try {
      final versions = await Directory.fromUri(
        store.root.uri.resolve('versions/'),
      ).create(recursive: true);
      final candidate = await versions.createTemp('${component.name}-');
      log('Загрузка ${component.title} ${release.tag}…');
      await _git(candidate, ['init', '--quiet']);
      await _git(candidate, [
        'remote',
        'add',
        'origin',
        '${component.url}.git',
      ]);
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
      final installation = Installation(
        tag: release.tag,
        commit: commit,
        directory: candidate.path,
      );
      await _validate(component, candidate);
      final next = {...active, component: installation};
      if (next.length == Component.values.length) {
        log('Проверка совместимости: запуск исходного Lua…');
        final result = await doctor(next);
        log('Lua отвечает. Классов в каталоге: ${result['classes']}');
      }
      await store.save(next, active);
      active = next;
      log('${component.title} ${release.tag} готов. Git: $commit');
      return installation;
    } finally {
      await _release();
    }
  }

  Future<String> _git(
    Directory directory,
    List<String> arguments, [
    void Function(String)? log,
  ]) =>
      processes.run('git', ['-C', directory.path, ...arguments], onOutput: log);

  Future<void> _validate(Component component, Directory directory) async {
    final files = component == Component.pob
        ? ['src/Launch.lua', 'runtime/lua51.dll', 'src/Modules/Main.lua']
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

  Future<void> rollback() async {
    await _acquire();
    try {
      final previous = Map<Component, Installation>.of(store.previous);
      if (previous.length != Component.values.length) {
        throw StateError('Предыдущей полной пары компонентов пока нет');
      }
      await doctor(previous);
      await store.save(previous, active);
      active = previous;
    } finally {
      await _release();
    }
  }
}
