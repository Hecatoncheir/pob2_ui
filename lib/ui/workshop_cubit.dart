import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:io';

import '../data/component_repository.dart';
import '../data/mcp_client.dart';
import '../data/session_repository.dart';
import '../data/build_library.dart';
import '../data/tree_icon_repository.dart';
import '../domain/build_report.dart';
import '../domain/tree_geometry.dart';
import '../domain/library_entry.dart';
import '../domain/component.dart';
import 'workshop_state.dart';

class WorkshopCubit extends Cubit<WorkshopState> {
  WorkshopCubit(this.components, this.engine, {WorkshopState? initialState})
    : session = SessionRepository(components.store.root),
      library = BuildLibrary(components.store.root),
      super(initialState ?? WorkshopState());
  final ComponentRepository components;
  final McpClient engine;
  final SessionRepository session;
  final BuildLibrary library;
  late final treeIcons = TreeIconRepository(
    root: Directory.fromUri(components.store.root.uri.resolve('tree-cache/')),
  );
  String? _nextTitle;

  bool get ready => components.active.length == Component.values.length;
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
    if (await session.exists()) {
      if (state.library.active == null) _nextTitle = 'Восстановленная сборка';
      await engine.call('pob_import_xml', {'xml': await session.read()});
      await _readReport();
    }
  }

  Future<void> _connect() async {
    engine.onDisconnected = _lostConnection;
    await engine.connect(components.active);
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
    _markStale();
    await engine.call('pob_import_xml', {'xml': xml});
    _beginDocument('Импортированная сборка');
    await _readReport();
  });

  Future<void> createBuild(
    int classId,
    int level, {
    String name = 'Новая сборка',
  }) => _run(() async {
    _markStale();
    await engine.call('pob_create_build', {
      'name': name,
      'classId': classId,
      'level': level,
    });
    _beginDocument(name);
    await _readReport();
  });

  Future<void> refreshReport() => _run(() async {
    _markStale();
    await _readReport();
  });

  Future<void> restoreSession() => _run(() async {
    await engine.call('pob_import_xml', {'xml': await session.read()});
    await _readReport();
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

  Future<void> _readReport() async {
    final (:report, :xml) = await _readResult();
    final (:tree, :error) = await _readTree();
    await session.save(xml);
    final builds = await library.save(
      state.library,
      report,
      xml,
      title: _nextTitle,
    );
    _nextTitle = null;
    _update(
      state.copyWith(
        document: (report: report, tree: tree, stale: false, treeError: error),
        library: builds,
        sessionSaved: true,
        status: 'Сборка рассчитана исходным Lua',
      ),
    );
    addLog(state.status);
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

  void _beginDocument(String title) {
    _nextTitle = title;
    _update(
      state.copyWith(library: LibraryState(entries: state.library.entries)),
    );
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
    _markStale();
    await engine.call('pob_import_xml', {'xml': await library.read(id)});
    _update(
      state.copyWith(
        library: LibraryState(entries: state.library.entries, activeId: id),
      ),
    );
    await _readReport();
  });

  Future<void> copyBuild() => _run(() async {
    if (state.report == null) return;
    final xml = await _currentXml();
    final title =
        '${state.library.active?.title ?? state.report!.name} · копия';
    _beginDocument(title);
    final builds = await library.save(
      state.library,
      state.report!,
      xml,
      title: title,
    );
    _nextTitle = null;
    _update(state.copyWith(library: builds));
  });

  Future<void> renameBuild(String title) => _run(() async {
    if (state.report == null || title.trim().isEmpty) return;
    final builds = await library.save(
      state.library,
      state.report!,
      await _currentXml(),
      title: title.trim(),
    );
    _update(state.copyWith(library: builds));
  });

  Future<void> treeAction(int id, bool allocated, {int? attribute}) =>
      _run(() async {
        _markStale();
        await engine.call('pob_tree_action', {
          'id': id,
          'action': allocated ? 'refund' : 'allocate',
          if (attribute != null) 'attribute': attribute,
        });
        await _readReport();
      });

  Future<void> selectMain(String control, int id) => _run(() async {
    _markStale();
    await engine.call('pob_select_main_skill', {'control': control, 'id': id});
    await _readReport();
  });

  Future<void> setCondition(String key, dynamic value) => _run(() async {
    _markStale();
    await engine.call('pob_set_config', {
      'values': {key: value},
    });
    await _readReport();
  });

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
    _update(state.copyWith(classes: [], clearReport: true));
  }

  void editDraft(String value) =>
      _update(state.copyWith(draft: (xml: value, edited: true)));

  Future<void> checkpoint() async {
    if (state.busy) throw StateError('Дождитесь завершения текущей операции');
    await session.saveDraft(state.draftXml);
    if (engine.connected && state.report != null)
      await session.save(await _currentXml());
  }

  @override
  Future<void> close() async {
    await engine.close();
    await super.close();
  }
}
