import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/component_repository.dart';
import '../data/mcp_client.dart';
import '../data/session_repository.dart';
import '../domain/component.dart';

class WorkshopModel extends ChangeNotifier {
  WorkshopModel(this.components, this.engine)
    : session = SessionRepository(components.store.root);
  final ComponentRepository components;
  final McpClient engine;
  final SessionRepository session;
  bool sessionSaved = false;
  String draftXml = '';
  bool draftEdited = false;
  final releases = <Component, Release>{};
  final log = <String>[];
  bool busy = false;
  String? error;
  String status = 'Установите компоненты и подключите Lua';
  Map<String, dynamic>? report;
  List<Map<String, dynamic>> classes = [];
  bool _disposed = false;
  bool get ready => components.active.length == Component.values.length;
  bool get canRollback =>
      components.store.previous.length == Component.values.length;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void addLog(String value) {
    log.add(value.trim());
    if (log.length > 120) log.removeAt(0);
    _notify();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    _notify();
    try {
      await action();
    } catch (failure) {
      error = failure.toString();
      addLog('Ошибка: $failure');
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> initialize() => _run(() async {
    await components.load();
    sessionSaved = await session.exists();
    final savedDraft = await session.readDraft();
    if (!draftEdited) draftXml = savedDraft;
    status = ready ? 'Компоненты установлены. Можно подключить Lua.' : status;
  });

  Future<void> checkUpdates() => _run(() async {
    for (final component in Component.values) {
      releases[component] = await components.github.latest(component);
    }
    status = 'Проверка выпусков завершена';
    addLog(status);
  });

  Future<void> install(Component component) => _run(() async {
    await _disconnect();
    final release =
        releases[component] ?? await components.github.latest(component);
    releases[component] = release;
    await components.install(component, release, addLog);
    status = '${component.title} ${release.tag} установлен';
  });

  Future<void> rollback() => _run(() async {
    await _disconnect();
    await components.rollback();
    status = 'Предыдущая пара восстановлена и проверена через Lua';
    addLog(status);
  });

  Future<void> connect() => _run(() async {
    await engine.connect(components.active);
    final catalog = await engine.call('pob_catalog', {'kind': 'classes'});
    classes = (catalog['entries'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    status = 'Исходный Lua подключён · ${classes.length} классов';
    addLog(status);
  });

  Future<void> doctor() => _run(() async {
    final result = await components.doctor();
    status =
        'Lua отвечает · ${result['classes']} классов · совместимость проверена';
    addLog(status);
  });

  Future<void> importXml(String xml) => _run(() async {
    report = null;
    await engine.call('pob_import_xml', {'xml': xml});
    await _readReport();
  });

  Future<void> createBuild(int classId, int level) => _run(() async {
    report = null;
    await engine.call('pob_create_build', {
      'name': 'Новая сборка',
      'classId': classId,
      'level': level,
    });
    await _readReport();
  });

  Future<void> refreshReport() => _run(_readReport);

  Future<void> restoreSession() => _run(() async {
    report = null;
    await engine.call('pob_import_xml', {'xml': await session.read()});
    await _readReport();
  });

  Future<void> _readReport() async {
    final result = await engine.call('pob_check_build');
    report = result['report'] as Map<String, dynamic>;
    final exported = await engine.call('pob_export_xml');
    await session.save(exported['xml'] as String);
    sessionSaved = true;
    status = 'Сборка рассчитана исходным Lua';
    addLog(status);
  }

  Future<String?> exportXml() async {
    String? xml;
    await _run(() async {
      final result = await engine.call('pob_export_xml');
      xml = result['xml'] as String;
    });
    return xml;
  }

  Future<void> _disconnect() async {
    await engine.close();
    classes = [];
    report = null;
  }

  void editDraft(String value) {
    draftEdited = true;
    draftXml = value;
  }

  Future<void> checkpoint() async {
    if (busy) throw StateError('Дождитесь завершения текущей операции');
    await session.saveDraft(draftXml);
    if (engine.connected && report != null) {
      final result = await engine.call('pob_export_xml');
      await session.save(result['xml'] as String);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(engine.close());
    super.dispose();
  }
}
