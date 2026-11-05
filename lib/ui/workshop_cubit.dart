import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/component_repository.dart';
import '../data/mcp_client.dart';
import '../data/session_repository.dart';
import '../domain/component.dart';
import 'workshop_state.dart';

class WorkshopCubit extends Cubit<WorkshopState> {
  WorkshopCubit(this.components, this.engine)
    : session = SessionRepository(components.store.root),
      super(WorkshopState());
  final ComponentRepository components;
  final McpClient engine;
  final SessionRepository session;

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
    _update(state.copyWith(busy: true, clearError: true));
    try {
      await action();
    } catch (failure) {
      _update(state.copyWith(error: '$failure'));
      addLog('Ошибка: $failure');
    } finally {
      _update(state.copyWith(busy: false));
    }
  }

  Future<void> initialize() => _run(() async {
    await components.load();
    final saved = await session.exists();
    final draft = await session.readDraft();
    _update(
      state.copyWith(
        sessionSaved: saved,
        draftXml: state.draftEdited ? state.draftXml : draft,
        status: ready
            ? 'Компоненты установлены. Можно подключить Lua.'
            : state.status,
      ),
    );
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

  Future<void> connect() => _run(() async {
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
  });

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
    await engine.call('pob_import_xml', {'xml': xml});
    await _readReport();
  });

  Future<void> createBuild(int classId, int level) => _run(() async {
    await engine.call('pob_create_build', {
      'name': 'Новая сборка',
      'classId': classId,
      'level': level,
    });
    await _readReport();
  });

  Future<void> refreshReport() => _run(_readReport);

  Future<void> restoreSession() => _run(() async {
    await engine.call('pob_import_xml', {'xml': await session.read()});
    await _readReport();
  });

  Future<({Map<String, dynamic> report, String xml})> _readResult() async {
    final result = await engine.call('pob_check_build');
    final report = switch (result) {
      {'report': final Map<String, dynamic> report} =>
        Map<String, dynamic>.unmodifiable(report),
      _ => throw const FormatException('Lua не вернул отчёт сборки'),
    };
    return (report: report, xml: await _currentXml());
  }

  Future<void> _readReport() async {
    final (:report, :xml) = await _readResult();
    await session.save(xml);
    _update(
      state.copyWith(
        report: report,
        sessionSaved: true,
        status: 'Сборка рассчитана исходным Lua',
      ),
    );
    addLog(state.status);
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
    _update(state.copyWith(classes: [], clearReport: true));
  }

  void editDraft(String value) =>
      _update(state.copyWith(draftXml: value, draftEdited: true));

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
