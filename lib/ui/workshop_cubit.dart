import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../data/component_repository.dart';
import '../data/mcp_client.dart';
import '../data/mcp_editor_gateway.dart';
import '../data/mcp_error_message.dart';
import '../data/pob_window_repository.dart';
import '../data/pob_build_library.dart';
import '../data/pob_build_locations.dart';
import '../data/session_repository.dart';
import '../data/build_library.dart';
import '../data/tree_icon_repository.dart';
import '../data/tree_progression_exchange.dart';
import '../data/tree_progression_repository.dart';
import '../domain/build_report.dart';
import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import '../domain/original_tree_scene.dart';
import '../domain/node_preview.dart';
import '../domain/library_entry.dart';
import '../domain/component.dart';
import 'workshop_state.dart';
import 'mcp_editor_cubit.dart';
import '../domain/tree_allocation_mode.dart';
import '../data/xml_file_service.dart';
import '../data/game_catalog_repository.dart';
import '../domain/build_edit_result.dart';

typedef _BuildSnapshot = ({String xml, String title});

class WorkshopCubit extends Cubit<WorkshopState> {
  WorkshopCubit(
    this.components,
    this.engine, {
    WorkshopState? initialState,
    SessionRepository? session,
    BuildStorage? library,
    XmlFileService? files,
    PobWindowRepository? pobWindow,
    PobBuildLocations? buildLocations,
  }) : session = session ?? SessionRepository(components.store.root),
       library = library ?? BuildLibrary(components.store.root),
       files = files ?? XmlFileService(),
       pobWindow = pobWindow ?? PobWindowRepository(),
       buildLocations = buildLocations ?? PobBuildLocations(),
       super(initialState ?? WorkshopState());
  final ComponentRepository components;
  final McpClient engine;
  final SessionRepository session;
  final BuildStorage library;
  PobBuildLibrary? get sharedLibrary =>
      library is PobBuildLibrary ? library as PobBuildLibrary : null;
  BuildNotesStorage get buildNotes =>
      sharedLibrary ?? session as BuildNotesStorage;
  bool get buildFolderReady =>
      sharedLibrary == null || sharedLibrary?.directory != null;
  final XmlFileService files;
  TreeProgressionKey? get progressionKey {
    final id = state.library.activeId;
    final document = state.document;
    final tree = document?.tree;
    if (id == null || tree == null) return null;
    return _progressionKey(id, tree.version, document!.report.characterClass);
  }

  TreeProgressionKey _progressionKey(
    String id,
    String version,
    String characterClass,
  ) => (
    folder: sharedLibrary?.directory ?? '',
    build: id,
    version: version,
    characterClass: characterClass,
  );

  TreeProgressionRepository progressionRepository(TreeProgressionKey key) =>
      TreeProgressionRepository(components.store.root, key);

  final PobWindowRepository pobWindow;
  final PobBuildLocations buildLocations;
  McpEditorCubit? _mcpEditor;
  McpEditorCubit get mcpEditor => _mcpEditor ??= McpEditorCubit(this);
  late final catalogs = GameCatalogRepository(engine);
  late final treeIcons = TreeIconRepository(
    root: Directory.fromUri(components.store.root.uri.resolve('tree-cache/')),
  );
  String? _nextTitle;
  Timer? _buildChangeDelay;
  StreamSubscription<FileSystemEvent>? _buildChanges;
  ({String directory, String id})? _watchedBuild;
  bool _closing = false;
  String? _seenBuildXml;
  Completer<void>? _buildSync;
  bool _buildSyncPending = false;
  bool Function()? modalOpen;
  final List<_BuildSnapshot> _undoHistory = [];
  final List<_BuildSnapshot> _redoHistory = [];

  bool get ready => components.active.length == Component.values.length;
  bool get luaReady => engine.connected && state.classes.isNotEmpty;
  String get _componentSource =>
      Component.values.map((key) => components.active[key]!.commit).join('-');

  Future<NodePreview> previewNode(int id) async {
    if (!engine.tools.contains('pob_tree_hover')) {
      return NodePreview(
        tooltip: await engine.call('pob_node_tooltip', {
          'id': id,
          'compare': true,
        }),
      );
    }
    final result = await engine.call('pob_tree_hover', {
      'id': id,
      'compare': true,
    });
    final scene = OriginalTreeScene.fromJson(jsonMap(result['scene']));
    final images = await loadTreeSceneImages(scene);
    return NodePreview(
      tooltip: jsonMap(result['tooltip']),
      scene: scene,
      images: images,
    );
  }

  Future<Map<String, Uint8List>> loadTreeSceneImages(OriginalTreeScene scene) =>
      treeIcons.overlay(
        state.document!.tree!.withScene(scene),
        engine,
        _componentSource,
      );

  bool get canRollback =>
      components.store.previous.length == Component.values.length;

  void _update(WorkshopState next) {
    if (isClosed) return;
    final wasBusy = state.busy;
    emit(next);
    _mcpEditor?.checkBuild();
    _watchOpenBuild();
    if (wasBusy && !next.busy) resumeBuildSync();
  }

  void addLog(String value) {
    final lines = [...state.log, value.trim()];
    _update(
      state.copyWith(
        log: lines.length > 120 ? lines.sublist(lines.length - 120) : lines,
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isClosed || state.busy) return;
    _update(state.copyWith(operation: (busy: true, error: null)));
    try {
      await action();
    } catch (failure) {
      if (failure is PobBuildSaveConflict) {
        _update(state.copyWith(library: _withEntry(failure.copy)));
      }
      final message = mcpErrorMessage(failure);
      _update(state.copyWith(operation: (busy: true, error: message)));
      addLog('Ошибка: $failure');
    } finally {
      _update(state.copyWith(operation: (busy: false, error: state.error)));
    }
  }

  Future<void> initialize() => _run(() async {
    await components.load();
    final builds = await _loadLibrary();
    final saved = !builds.skipSessionRecovery && await session.exists();
    final draft = await session.readDraft();
    _update(
      state.copyWith(
        sessionSaved: saved,
        library: builds,
        draft: state.draftEdited ? state.draft : (xml: draft, edited: false),
        status: ready
            ? 'Компоненты установлены. Можно подключить Lua.'
            : state.status,
      ),
    );
    await _resume();
  });

  Future<LibraryState> _loadLibrary() async {
    try {
      return await library.load();
    } on FileSystemException catch (error) {
      if (sharedLibrary == null) rethrow;
      addLog('Папка сборок PoB недоступна: $error');
      return LibraryState(skipSessionRecovery: true);
    }
  }

  Future<void> selectPobBuildFolder(String folder) =>
      _run(() => _usePobBuildFolder(folder));

  Future<void> detectPobBuildFolder() => _run(() async {
    final live = await _liveBuildDirectory();
    if (live != null) {
      await _usePobBuildFolder(live);
      return;
    }
    if (sharedLibrary?.directory != null) return;
    final directory = await buildLocations.find();
    if (directory == null) {
      throw StateError(
        'Стандартная папка PoB не найдена. Выберите папку вручную.',
      );
    }
    await _usePobBuildFolder(directory);
    _update(state.copyWith(status: 'Подключена стандартная папка PoB'));
  });

  Future<String?> _liveBuildDirectory() async {
    if (!pobWindow.supported || !ready) return null;
    try {
      final directory = await pobWindow.buildDirectory(components.active);
      if (await Directory(directory).exists()) return directory;
      throw StateError('Папка сборок из настроек PoB недоступна.');
    } catch (error) {
      if (buildFolderReady) rethrow;
      addLog('Не удалось получить папку через мост PoB: $error');
      return null;
    }
  }

  Future<void> _usePobBuildFolder(String folder) async {
    final shared = sharedLibrary;
    if (shared == null) return;
    await buildNotes.flushText();
    final previous = shared.directory;
    final builds = await shared.configure(folder);
    final changed = previous != shared.directory;
    _setSharedLibrary(builds, changingFolder: changed);
    if (changed && engine.connected) await _resumeLibrary();
  }

  Future<void> refreshPobBuilds() => _run(() async {
    final shared = sharedLibrary;
    if (shared != null) {
      _setSharedLibrary(await shared.scan());
      requestBuildSync();
    }
  });

  void _setSharedLibrary(LibraryState scanned, {bool changingFolder = false}) {
    final opened = changingFolder || state.report == null
        ? null
        : state.library.active;
    final builds = opened == null
        ? scanned
        : LibraryState(
            entries: [
              opened,
              ...scanned.entries.where((entry) => entry.id != opened.id),
            ],
            activeId: opened.id,
            skipSessionRecovery: true,
          );
    _update(
      state.copyWith(
        library: builds,
        clearReport: changingFolder,
        sessionSaved: builds.active != null,
      ),
    );
    if (changingFolder) _clearHistory();
  }

  Future<void> prepareComponents() => _run(() async {
    if (!ready) await _installMissingComponents();
    if (!luaReady) await _resume();
  });

  Future<void> _installMissingComponents() async {
    await _checkInstallationTools();
    for (final component in Component.values) {
      if (components.active.containsKey(component)) continue;
      final release = await components.github.latest(component);
      _update(
        state.copyWith(releases: {...state.releases, component: release}),
      );
      await components.install(component, release, addLog);
    }
  }

  Future<void> _checkInstallationTools() async {
    try {
      await components.processes.python();
    } on ProcessException {
      throw StateError(
        'Установите 64-битный Python 3.11+ и перезапустите PoB II.',
      );
    }
    try {
      await components.processes.run('git', [
        '--version',
      ], timeout: const Duration(seconds: 10));
    } on ProcessException {
      throw StateError('Установите Git и перезапустите PoB II.');
    }
  }

  Future<void> checkUpdates() => _run(() async {
    final releases = <Component, Release>{};
    for (final component in Component.values) {
      releases[component] = await components.github.latest(component);
    }
    _update(
      state.copyWith(releases: releases, status: 'Проверка выпусков завершена'),
    );
    addLog(state.status);
  });

  Future<void> install(Component component) => _run(() async {
    await _disconnect();
    final release =
        state.releases[component] ?? await components.github.latest(component);
    _update(state.copyWith(releases: {...state.releases, component: release}));
    await components.install(component, release, addLog);
    _update(
      state.copyWith(status: '${component.title} ${release.tag} установлен'),
    );
    await _resume();
  });

  Future<void> rollback() => _run(() async {
    await _disconnect();
    await components.rollback();
    _update(
      state.copyWith(
        status: 'Предыдущая пара восстановлена и проверена через Lua',
      ),
    );
    addLog(state.status);
  });

  Future<void> connect() => _run(_resume);

  Future<void> _resume() async {
    if (!ready) return;
    await _connect();
    if (await _resumeLibrary()) return;
    if (sharedLibrary != null || state.library.skipSessionRecovery) return;
    if (await session.exists()) {
      await _loadXml(await session.read());
      await _readReport(
        target: LibraryState(entries: state.library.entries),
        title: 'Восстановленная сборка',
      );
      _clearHistory();
    }
  }

  Future<bool> _resumeLibrary() async {
    final active = state.library.active;
    if (active == null) return false;
    try {
      await _openBuild(active.id);
      return true;
    } catch (error) {
      addLog(
        'Не удалось открыть последнюю сборку, проверяем копию восстановления: $error',
      );
      return false;
    }
  }

  Future<void> _connect() async {
    _update(state.copyWith(classes: []));
    engine.onDisconnected = _lostConnection;
    await engine.connect(components.active);
    catalogs.clear();
    final result = await engine.call('pob_catalog', {'kind': 'classes'});
    final classes = switch (result) {
      {'entries': final List<dynamic> entries} =>
        entries.map(_classEntry).toList(),
      _ => throw const FormatException('Lua не вернул каталог классов'),
    };
    _update(
      state.copyWith(
        classes: classes,
        status: 'Исходный Lua подключён · ${classes.length} классов',
      ),
    );
    addLog(state.status);
  }

  void _lostConnection(Object error) {
    if (isClosed) return;
    _markStale();
    _update(
      state.copyWith(
        classes: [],
        status: 'Соединение с Lua прервано',
        operation: (busy: state.busy, error: '$error'),
      ),
    );
  }

  Map<String, dynamic> _classEntry(dynamic value) => switch (value) {
    final Map<String, dynamic> entry => Map.unmodifiable(entry),
    _ => throw const FormatException('Неверная запись каталога Lua'),
  };

  Future<void> doctor() => _run(() async {
    final result = await components.doctor();
    _update(
      state.copyWith(
        status:
            'Lua отвечает · ${result['classes']} классов · совместимость проверена',
      ),
    );
    addLog(state.status);
  });

  Future<void> importXml(String xml) => _run(() => _importCopy(xml));

  Future<void> importFromPob() => _run(() async {
    final xml = await pobWindow.readXml(components.active);
    await _importCopy(xml);
  });

  Future<void> importPobCharacter(String name) => _run(() async {
    if (!engine.tools.contains('pob_import_character')) {
      throw StateError('Обновите MCP в разделе «Компоненты».');
    }
    final character = await pobWindow.readCharacter(components.active, name);
    await _switchBuild(
      () async {
        await engine.call('pob_import_character', {'character': character});
        await _restoreTreeMode();
      },
      target: LibraryState(entries: state.library.entries),
      title: name,
    );
  });

  Future<void> _importCopy(
    String xml, {
    String title = 'Импортированная сборка',
  }) => _switchXml(
    xml,
    target: LibraryState(entries: state.library.entries),
    title: title,
  );

  Future<void> openXmlFile() => _run(() async {
    final selected = await files.open();
    if (selected == null) return;
    if (sharedLibrary?.idForPath(selected.path) case final id?) {
      await _openBuild(id);
      return;
    }
    await _importCopy(selected.xml, title: selected.title);
  });

  Future<void> saveXmlFile() => _run(() async {
    if (state.report == null) return;
    await _flushText();
    final path = await files.save(
      await _exportedXml(),
      state.library.active?.title ?? state.report!.name,
      beforeSave: sharedLibrary?.checkExport,
    );
    if (path != null) _update(state.copyWith(status: 'XML сохранён'));
  });

  Future<void> createBuild(
    int classId,
    int level, {
    String name = 'Новая сборка',
  }) => _run(() async {
    await _switchBuild(
      () async {
        await engine.call('pob_create_build', {
          'name': name,
          'classId': classId,
          'level': level,
        });
        await _restoreTreeMode();
      },
      target: LibraryState(entries: state.library.entries),
      title: name,
    );
  });

  Future<void> refreshReport() => _run(() async {
    if (state.report == null) return;
    _markStale();
    await _readReport(persist: sharedLibrary == null);
  });

  Future<void> restoreSession() => _run(() async {
    if (sharedLibrary != null) {
      await _resumeLibrary();
      return;
    }
    if (state.library.skipSessionRecovery) return;
    await _switchBuild(
      () async => _loadXml(await session.read()),
      target: state.library,
    );
  });

  Future<({BuildReport report, String xml})> _readResult() async {
    final result = await engine.call('pob_check_build');
    final report = switch (result) {
      {'report': final Map<String, dynamic> report} => BuildReport.fromJson(
        report,
      ),
      _ => throw const FormatException('Lua не вернул отчёт сборки'),
    };
    return (report: report, xml: await _currentXml());
  }

  Future<void> _readReport({
    LibraryState? target,
    String? title,
    bool persist = true,
    TreeProgressionTransfer? progression,
  }) async {
    final (:report, :xml) = await _readResult();
    final (:tree, :error) = await _readTree();
    if (progression != null) _checkProgression(progression, report, tree);
    final builds = persist
        ? await library.save(
            target ?? state.library,
            report,
            attachTreeProgression(xml, progression),
            title: title ?? _nextTitle,
          )
        : target ?? state.library;
    if ((progression, builds.activeId) case (final plan?, final id?)) {
      final key = _progressionKey(id, plan.version, plan.characterClass);
      await progressionRepository(key).restoreIfMissing(plan.steps);
    }
    final saved = sharedLibrary != null
        ? builds.active != null
        : await _saveRecovery(xml);
    _nextTitle = null;
    _update(
      state.copyWith(
        document: (report: report, tree: tree, stale: false, treeError: error),
        library: builds,
        sessionSaved: saved,
        status: 'Сборка рассчитана исходным Lua',
      ),
    );
    addLog(state.status);
  }

  void _checkProgression(
    TreeProgressionTransfer plan,
    BuildReport report,
    TreeGeometry? tree,
  ) {
    if (plan.characterClass != report.characterClass ||
        (tree != null && tree.version != plan.version)) {
      throw const FormatException('Некорректный план прокачки');
    }
  }

  Future<bool> _saveRecovery(String xml) async {
    try {
      await session.save(xml);
      return true;
    } catch (error) {
      reportPersistenceError(
        'Сборка сохранена в библиотеке, но копия восстановления недоступна: $error',
      );
      return false;
    }
  }

  Future<({TreeGeometry? tree, String? error})> _readTree() async {
    if (!engine.tools.contains('pob_get_tree'))
      return (
        tree: null,
        error: 'Для дерева нужен MCP 0.5.0. Обновите компонент MCP.',
      );
    try {
      final geometry = TreeGeometry.fromJson(
        await engine.call('pob_get_tree', {
          if (engine.tools.contains('pob_tree_textures')) 'includeScene': true,
        }),
      );
      final source = Component.values
          .map((key) => components.active[key]!.commit)
          .join('-');
      final tree = await treeIcons.load(
        geometry,
        engine,
        source,
        onProgress: (loaded, total) {
          _update(
            state.copyWith(
              status: 'Загрузка оригинального дерева PoB · $loaded / $total',
            ),
          );
        },
      );
      return (tree: tree, error: null);
    } catch (error) {
      return (tree: null, error: 'Дерево недоступно: $error');
    }
  }

  void _markStale() {
    if (state.document case final document?) {
      _update(
        state.copyWith(
          document: (
            report: document.report,
            tree: document.tree,
            stale: true,
            treeError: document.treeError,
          ),
        ),
      );
    }
  }

  Future<void> openBuild(String id) => _run(() => _openBuild(id));

  Future<void> _openBuild(String id) async {
    final shared = sharedLibrary;
    if (shared != null) {
      await _openShared(shared, await shared.open(id));
      return;
    }
    final xml = await library.read(id);
    await _switchXml(
      xml,
      target: LibraryState(entries: state.library.entries, activeId: id),
    );
  }

  LibraryState _withEntry(LibraryEntry entry, {String? activeId}) =>
      LibraryState(
        entries: [
          entry,
          ...state.library.entries.where((item) => item.id != entry.id),
        ],
        activeId: activeId ?? state.library.activeId,
        skipSessionRecovery: true,
      );

  Future<void> _openShared(
    PobBuildLibrary shared,
    PobBuildVersion disk, {
    bool automatic = false,
  }) async {
    final copy = await shared.preserveLocal(disk);
    if (copy != null) _update(state.copyWith(library: _withEntry(copy)));
    _seenBuildXml = disk.xml;
    final entry = disk.entry;
    if (!automatic || entry.revision != state.library.active?.revision) {
      await _switchXml(
        disk.xml,
        target: _withEntry(entry, activeId: entry.id),
        persist: false,
      );
      await shared.activate(entry.id);
      if (automatic) {
        _update(state.copyWith(status: 'Сборка обновлена из Path of Building'));
      }
    }
    if (copy != null) {
      final message = 'Правки PoB II сохранены отдельно: ${copy.title}';
      _update(state.copyWith(status: message));
      addLog(message);
    }
  }

  void _watchOpenBuild() {
    if (_closing) return;
    final shared = sharedLibrary;
    final directory = shared?.directory;
    final id = state.library.activeId;
    final target = state.report == null || directory == null || id == null
        ? null
        : (directory: directory, id: id);
    if (target == _watchedBuild) return;
    unawaited(_buildChanges?.cancel());
    _buildChangeDelay?.cancel();
    _watchedBuild = target;
    _buildChanges = target == null
        ? null
        : shared!
              .watchBuild(target.id)
              .listen((_) => requestBuildSync(), onError: (Object _) {});
    if (target != null) requestBuildSync();
  }

  void requestBuildSync() {
    if (_watchedBuild == null) return;
    _buildSyncPending = true;
    resumeBuildSync();
  }

  void resumeBuildSync() {
    if (!_buildSyncPending || _buildSync != null || !_canSyncBuild) return;
    _buildChangeDelay?.cancel();
    _buildChangeDelay = Timer(
      const Duration(milliseconds: 120),
      () => unawaited(syncOpenBuild()),
    );
  }

  bool get _canSyncBuild =>
      !_closing &&
      !isClosed &&
      !state.busy &&
      engine.connected &&
      state.report != null &&
      modalOpen?.call() != true;

  Future<void> syncOpenBuild() async {
    final shared = sharedLibrary;
    final active = state.library.active;
    if (shared == null || active == null) return;
    _buildSyncPending = true;
    if (_buildSync != null || !_canSyncBuild) return;
    _buildSyncPending = false;
    _buildChangeDelay?.cancel();
    final sync = _buildSync = Completer<void>();
    try {
      final disk = await shared.changed(active.id, _seenBuildXml);
      if (disk == null) return;
      if (!_canSyncBuild || state.library.active != active) {
        _buildSyncPending = true;
        return;
      }
      await _run(() => _openShared(shared, disk, automatic: true));
    } finally {
      _buildSync = null;
      sync.complete();
      resumeBuildSync();
    }
  }

  Future<void> deleteBuild(String id) => _run(() async {
    await _flushText();
    final removedActive = state.library.activeId == id;
    final builds = await library.remove(state.library, id);
    _update(
      state.copyWith(
        library: builds,
        clearReport: removedActive,
        sessionSaved: removedActive ? false : null,
        status: 'Сборка удалена',
      ),
    );
    if (removedActive) _clearHistory();
  });

  Future<void> _switchXml(
    String source, {
    required LibraryState target,
    String? title,
    bool persist = true,
  }) {
    final (:xml, :progression) = splitTreeProgression(source);
    return _switchBuild(
      () => _loadXml(xml),
      target: target,
      title: title,
      persist: persist,
      progression: progression,
    );
  }

  Future<void> _switchBuild(
    Future<void> Function() action, {
    required LibraryState target,
    String? title,
    bool persist = true,
    TreeProgressionTransfer? progression,
  }) async {
    await _flushText();
    final previous = state.document;
    final previousLibrary = state.library;
    final xml = previous == null ? null : await _currentXml();
    _markStale();
    try {
      await action();
      await _readReport(
        target: target,
        title: title,
        persist: persist,
        progression: progression,
      );
      _clearHistory();
    } catch (_) {
      _nextTitle = null;
      if (xml != null && previous != null) {
        await _restoreWorking(xml, previous, previousLibrary);
      }
      rethrow;
    }
  }

  Future<void> _restoreWorking(
    String xml,
    WorkshopDocument document,
    LibraryState builds,
  ) async {
    try {
      await _loadXml(xml);
      final restored = await _readResult();
      _update(
        state.copyWith(
          library: builds,
          document: (
            report: restored.report,
            tree: document.tree,
            stale: false,
            treeError: document.treeError,
          ),
        ),
      );
    } catch (error) {
      _markStale();
      addLog('Рабочая сборка сохранена; не удалось восстановить Lua: $error');
    }
  }

  Future<void> copyBuild() => _run(() async {
    if (state.report == null) return;
    final title =
        '${state.library.active?.title ?? state.report!.name} · копия';
    if (sharedLibrary != null) {
      final xml = await _savedXml();
      await _switchBuild(
        () => _loadXml(xml),
        target: LibraryState(entries: state.library.entries),
        title: title,
      );
      return;
    }
    final xml = await _currentXml();
    final id = library.newId();
    if (state.library.activeId case final source?) {
      await session.saveNotes(id, await session.readNotes(source));
    }
    final builds = await library.save(
      LibraryState(entries: state.library.entries, activeId: id),
      state.report!,
      xml,
      title: title,
    );
    _nextTitle = null;
    _update(state.copyWith(library: builds));
    _clearHistory();
  });

  Future<void> renameBuild(String title) => _run(() async {
    if (state.report == null || title.trim().isEmpty) return;
    final previousTitle = state.library.active?.title ?? state.report!.name;
    if (previousTitle == title.trim()) return;
    final xml = await _currentXml();
    final builds = await library.save(
      state.library,
      state.report!,
      xml,
      title: title.trim(),
    );
    _update(state.copyWith(library: builds));
    _pushUndo(xml, title: previousTitle);
  });

  Future<bool> isAttributeNode(int id) async {
    final catalog = await engine.call('pob_catalog', {
      'kind': 'nodes',
      'query': '$id',
      'limit': 200,
    });
    final node = jsonRows(catalog['entries'])
        .where((entry) => entry['id'] == id)
        .firstOrNull;
    if (node == null)
      throw const FormatException('Lua не вернул сведения об узле');
    return jsonRows(node['attributeOptions']).isNotEmpty;
  }

  Future<void> treeAction(int id, bool allocated, {int? attribute}) =>
      _changeBuild(() async {
        await engine.call('pob_tree_action', {
          'id': id,
          'action': allocated && attribute == null ? 'refund' : 'allocate',
          if (attribute != null) 'attribute': attribute,
        });
      });

  Future<void> selectTreeMode(TreeAllocationMode mode) => _run(() async {
    if (state.report == null) return;
    if (mode == state.treeMode && state.document?.stale == false) return;
    _markStale();
    await engine.call('pob_tree_options', {'mode': mode.luaValue});
    _update(state.copyWith(treeMode: mode));
    await _readReport();
  });

  Future<void> _restoreTreeMode() async {
    if (state.treeMode == TreeAllocationMode.common) return;
    await engine.call('pob_tree_options', {'mode': state.treeMode.luaValue});
  }

  Future<void> _loadXml(String xml) async {
    await engine.call('pob_import_xml', {'xml': xml});
    await _restoreTreeMode();
  }

  Future<void> selectMain(String control, int id) => _changeBuild(() async {
    await engine.call('pob_select_main_skill', {'control': control, 'id': id});
  });

  Future<BuildEditResult> addSkillGroup(String label, List<JsonMap> gems) =>
      _changeBuild(() async {
        await engine.call('pob_add_skill_group', {
          'label': label,
          'gems': gems,
        });
      });

  Future<BuildEditResult> updateSkillGroup(
    int id,
    String label,
    List<JsonMap> gems,
  ) => _changeBuild(() async {
    await engine.call('pob_update_skill_group', {
      'groupId': id,
      'label': label,
      'gems': gems,
    });
  });

  Future<BuildEditResult> deleteSkillGroup(int id) => _changeBuild(() async {
    await engine.call('pob_delete_skill_group', {'groupId': id});
  });

  Future<BuildEditResult> equipItem(
    String slot, {
    String? raw,
    int? itemId,
    int? expectedRevision,
  }) => _changeBuild(() async {
    await engine.call('pob_equip_item', {
      'slot': slot,
      if (raw != null) 'raw': raw,
      if (itemId != null) 'itemId': itemId,
      if (expectedRevision != null) 'expectedRevision': expectedRevision,
    });
  });

  Future<BuildEditResult> selectWeaponSet(int index) => _changeBuild(() async {
    await engine.call('pob_select_weapon_set', {'index': index});
  });

  Future<BuildEditResult> setCondition(String key, dynamic value) =>
      _changeBuild(() async {
        await engine.call('pob_set_config', {
          'values': {key: value},
        });
      });

  Future<JsonMap> executeMcpEditorTool(
    String tool,
    JsonMap arguments, {
    required bool edit,
  }) async {
    JsonMap? response;
    Future<void> execute() async =>
        response = await engine.call(tool, arguments);
    if (edit) {
      final result = await _changeBuild(execute);
      if (!result.committed)
        throw McpEditorFault('EDITOR_EDIT_FAILED', result.error!);
    } else {
      await _run(execute);
    }
    return response ??
        (throw McpEditorFault(
          'EDITOR_FAILED',
          state.error ?? 'Действие недоступно',
        ));
  }

  Future<BuildEditResult> _changeBuild(Future<void> Function() action) async {
    var committed = false;
    await _run(() async {
      final document = state.document;
      if (document == null) return;
      final builds = state.library;
      final before = await _currentXml();
      _markStale();
      try {
        await action();
        final changed = await _currentXml() != before;
        await _readReport();
        if (changed) _pushUndo(before);
        committed = true;
      } catch (_) {
        await _restoreWorking(before, document, builds);
        rethrow;
      }
    });
    return (
      committed: committed,
      error: committed ? null : state.error ?? 'Действие недоступно',
    );
  }

  void _pushUndo(String xml, {String? title}) {
    _appendSnapshot(_undoHistory, (
      xml: xml,
      title: title ?? state.library.active?.title ?? state.report!.name,
    ));
    _redoHistory.clear();
    _publishHistory();
  }

  void _appendSnapshot(List<_BuildSnapshot> history, _BuildSnapshot snapshot) {
    history.add(snapshot);
    if (history.length > 50) history.removeAt(0);
  }

  void _publishHistory() => _update(
    state.copyWith(
      history: (undo: _undoHistory.length, redo: _redoHistory.length),
    ),
  );

  void _clearHistory() {
    _undoHistory.clear();
    _redoHistory.clear();
    _publishHistory();
  }

  Future<void> undo() => _moveHistory(_undoHistory, _redoHistory);

  Future<void> redo() => _moveHistory(_redoHistory, _undoHistory);

  Future<void> _moveHistory(
    List<_BuildSnapshot> source,
    List<_BuildSnapshot> destination,
  ) => _run(() async {
    if (source.isEmpty) return;
    final before = (
      xml: await _currentXml(),
      title: state.library.active?.title ?? state.report!.name,
    );
    try {
      await _restoreSnapshot(source.last);
    } catch (_) {
      await _recoverSnapshot(before);
      rethrow;
    }
    source.removeLast();
    _appendSnapshot(destination, before);
    _publishHistory();
  });

  Future<void> _restoreSnapshot(_BuildSnapshot snapshot) async {
    _markStale();
    await _loadXml(snapshot.xml);
    _nextTitle = snapshot.title;
    try {
      await _readReport();
    } finally {
      _nextTitle = null;
    }
  }

  Future<void> _recoverSnapshot(_BuildSnapshot snapshot) async {
    try {
      if (sharedLibrary != null) {
        await _loadXml(snapshot.xml);
        await _readReport(persist: false);
      } else {
        await _restoreSnapshot(snapshot);
      }
    } catch (error) {
      _markStale();
      addLog('Не удалось восстановить состояние после ошибки: $error');
    }
  }

  Future<String> _currentXml() => engine.exportBuildXml();

  Future<String> _savedXml() async {
    final xml = await _currentXml();
    final id = state.library.activeId;
    if (sharedLibrary case final shared? when id != null)
      return shared.withCurrentNotes(id, xml);
    return xml;
  }

  Future<String?> exportXml() async {
    String? xml;
    await _run(() async {
      if (state.report == null) return;
      xml = await _exportedXml();
    });
    return xml;
  }

  Future<String> _exportedXml() async {
    final xml = await _savedXml();
    final key = progressionKey;
    if (key == null) return xml;
    return attachTreeProgression(xml, (
      version: key.version,
      characterClass: key.characterClass,
      steps: await progressionRepository(key).load(),
    ));
  }

  Future<void> _disconnect() async {
    await _mcpEditor?.disable();
    await engine.close();
    catalogs.clear();
    _update(state.copyWith(classes: [], clearReport: true));
    _clearHistory();
  }

  void editDraft(String value) {
    _update(state.copyWith(draft: (xml: value, edited: true)));
    _saveDraft(value);
  }

  Future<void> _saveDraft(String value) async {
    try {
      await session.saveDraft(value);
    } catch (error) {
      reportPersistenceError('Не удалось сохранить черновик XML: $error');
    }
  }

  void reportPersistenceError(Object error) {
    _update(state.copyWith(operation: (busy: state.busy, error: '$error')));
    addLog('$error');
  }

  Future<void> checkpoint({bool closePob = false}) => _protectExit(() async {
    await session.saveDraft(state.draftXml);
    await _flushText();
    await _checkpointBuild();
    if (closePob) await pobWindow.closeLaunchedWindows();
  });

  Future<void> closeLaunchedPob() =>
      _protectExit(pobWindow.closeLaunchedWindows);

  Future<void> _protectExit(Future<void> Function() action) async {
    if (state.busy) throw StateError('Дождитесь завершения текущей операции');
    _update(state.copyWith(operation: (busy: true, error: state.error)));
    try {
      await action();
    } finally {
      _update(state.copyWith(operation: (busy: false, error: state.error)));
    }
  }

  Future<void> _checkpointBuild() async {
    if (sharedLibrary != null) return;
    if (!engine.connected || state.report == null) return;
    if (state.document?.stale == true) {
      await _readReport();
    }
    await session.save(await _currentXml());
  }

  Future<void> _flushText() async {
    await session.flushText();
    if (sharedLibrary case final shared?) await shared.flushText();
  }

  @override
  Future<void> close() async {
    _closing = true;
    _buildChangeDelay?.cancel();
    await _buildChanges?.cancel();
    await _buildSync?.future;
    await _mcpEditor?.close();
    await _flushText();
    await engine.close();
    await super.close();
  }
}
