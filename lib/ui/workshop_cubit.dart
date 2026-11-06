import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:io';
import 'dart:typed_data';

import '../data/component_repository.dart';
import '../data/mcp_client.dart';
import '../data/session_repository.dart';
import '../data/build_library.dart';
import '../data/tree_icon_repository.dart';
import '../domain/build_report.dart';
import '../domain/tree_geometry.dart';
import '../domain/original_tree_scene.dart';
import '../domain/node_preview.dart';
import '../domain/library_entry.dart';
import '../domain/component.dart';
import 'workshop_state.dart';
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
    BuildLibrary? library,
    XmlFileService? files,
  }) : session = session ?? SessionRepository(components.store.root),
       library = library ?? BuildLibrary(components.store.root),
       files = files ?? XmlFileService(),
       super(initialState ?? WorkshopState());
  final ComponentRepository components;
  final McpClient engine;
  final SessionRepository session;
  final BuildLibrary library;
  final XmlFileService files;
  late final catalogs = GameCatalogRepository(engine);
  late final treeIcons = TreeIconRepository(
    root: Directory.fromUri(components.store.root.uri.resolve('tree-cache/')),
  );
  String? _nextTitle;
  final List<_BuildSnapshot> _undoHistory = [];
  final List<_BuildSnapshot> _redoHistory = [];

  bool get ready => components.active.length == Component.values.length;
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
    if (!isClosed) emit(next);
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
      _update(state.copyWith(operation: (busy: true, error: '$failure')));
      addLog('Ошибка: $failure');
    } finally {
      _update(state.copyWith(operation: (busy: false, error: state.error)));
    }
  }

  Future<void> initialize() => _run(() async {
    await components.load();
    final saved = await session.exists();
    final draft = await session.readDraft();
    final builds = await library.load();
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
      await _loadXml(await library.read(active.id));
      await _readReport();
      return true;
    } catch (error) {
      addLog(
        'Не удалось открыть последнюю сборку, проверяем копию восстановления: $error',
      );
      return false;
    }
  }

  Future<void> _connect() async {
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

  Future<void> importXml(String xml) => _run(() async {
    await _switchBuild(
      () => _loadXml(xml),
      target: LibraryState(entries: state.library.entries),
      title: 'Импортированная сборка',
    );
  });

  Future<void> openXmlFile() => _run(() async {
    final selected = await files.open();
    if (selected == null) return;
    await _switchBuild(
      () => _loadXml(selected.xml),
      target: LibraryState(entries: state.library.entries),
      title: selected.title,
    );
  });

  Future<void> saveXmlFile() => _run(() async {
    if (state.report == null) return;
    await session.flushText();
    final path = await files.save(
      await _currentXml(),
      state.library.active?.title ?? state.report!.name,
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
    _markStale();
    await _readReport();
  });

  Future<void> restoreSession() => _run(() async {
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

  Future<void> _readReport({LibraryState? target, String? title}) async {
    final (:report, :xml) = await _readResult();
    final (:tree, :error) = await _readTree();
    final builds = await library.save(
      target ?? state.library,
      report,
      xml,
      title: title ?? _nextTitle,
    );
    final saved = await _saveRecovery(xml);
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

  Future<void> openBuild(String id) => _run(() async {
    final xml = await library.read(id);
    await _switchBuild(
      () => _loadXml(xml),
      target: LibraryState(entries: state.library.entries, activeId: id),
    );
  });

  Future<void> _switchBuild(
    Future<void> Function() action, {
    required LibraryState target,
    String? title,
  }) async {
    await session.flushText();
    final previous = state.document;
    final previousLibrary = state.library;
    final xml = previous == null ? null : await _currentXml();
    _markStale();
    try {
      await action();
      await _readReport(target: target, title: title);
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
    final xml = await _currentXml();
    final title =
        '${state.library.active?.title ?? state.report!.name} · копия';
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

  Future<BuildEditResult> setCondition(String key, dynamic value) =>
      _changeBuild(() async {
        await engine.call('pob_set_config', {
          'values': {key: value},
        });
      });

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
      await _restoreSnapshot(snapshot);
    } catch (error) {
      _markStale();
      addLog('Не удалось восстановить состояние после ошибки: $error');
    }
  }

  Future<String> _currentXml() async =>
      switch (await engine.call('pob_export_xml')) {
        {'xml': final String xml} => xml,
        _ => throw const FormatException('Lua не вернул XML сборки'),
      };

  Future<String?> exportXml() async {
    String? xml;
    await _run(() async {
      xml = await _currentXml();
    });
    return xml;
  }

  Future<void> _disconnect() async {
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

  Future<void> checkpoint() async {
    if (state.busy) throw StateError('Дождитесь завершения текущей операции');
    _update(state.copyWith(operation: (busy: true, error: state.error)));
    try {
      await session.saveDraft(state.draftXml);
      await session.flushText();
      await _checkpointBuild();
    } finally {
      _update(state.copyWith(operation: (busy: false, error: state.error)));
    }
  }

  Future<void> _checkpointBuild() async {
    if (!engine.connected || state.report == null) return;
    if (state.document?.stale == true) {
      await _readReport();
    }
    await session.save(await _currentXml());
  }

  @override
  Future<void> close() async {
    await session.flushText();
    await engine.close();
    await super.close();
  }
}
