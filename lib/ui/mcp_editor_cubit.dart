import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_editor_gateway.dart';
import '../data/process_service.dart';
import '../domain/build_report.dart';
import '../domain/component.dart';
import 'shell_bloc.dart';
import 'workshop_cubit.dart';

typedef McpEditorChange = ({WorkshopTab tab, int? node, int revision});
typedef McpEditorState = ({
  bool busy,
  String? command,
  String? error,
  McpEditorChange? change,
});

const _off = (busy: false, command: null, error: null, change: null);
const _create = 'pob_create_build';
const _reads = {
  'pob_catalog',
  'pob_check_build',
  'pob_export_xml',
  'pob_inspect_item',
};
const _edits = {
  'pob_tree_action': WorkshopTab.tree,
  'pob_add_item': WorkshopTab.items,
  'pob_equip_item': WorkshopTab.items,
  'pob_select_weapon_set': WorkshopTab.items,
  'pob_add_skill_group': WorkshopTab.skills,
  'pob_update_skill_group': WorkshopTab.skills,
  'pob_delete_skill_group': WorkshopTab.skills,
  'pob_select_main_skill': WorkshopTab.skills,
  'pob_set_config': WorkshopTab.conditions,
};

class McpEditorCubit extends Cubit<McpEditorState> {
  McpEditorCubit(this.model)
    : _gateway = McpEditorGateway(model.components.store.root),
      super(_off);

  final WorkshopCubit model;
  final McpEditorGateway _gateway;
  Future<void>? _starting;
  bool _closing = false;
  bool _creating = false;
  String? _buildId;
  BuildReport? _report;
  int _revision = 0;

  bool get enabled => state.command != null;
  bool get canEnable => model.engine.connected && model.buildFolderReady;

  Future<void> enable() async {
    if (enabled || state.busy || _closing) return;
    final id = model.state.library.activeId;
    if (!canEnable || model.state.busy) return;
    emit((busy: true, command: null, error: null, change: null));
    final starting = _start(id);
    _starting = starting;
    await starting;
    _starting = null;
  }

  Future<void> _start(String? id) async {
    try {
      final command = await _connectionCommand();
      if (_closing || !_matches(id)) {
        if (!_closing) emit(_off);
        return;
      }
      await _gateway.start(_execute);
      if (_closing || !_matches(id)) {
        await disable();
        return;
      }
      _buildId = id;
      _report = model.state.report;
      _revision = 0;
      emit((busy: false, command: command, error: null, change: null));
    } catch (_) {
      if (!_closing) {
        emit((
          busy: false,
          command: null,
          error: 'Не удалось включить правки через MCP. Проверьте, что установлен обновлённый MCP.',
          change: null,
        ));
      }
    }
  }

  bool _matches(String? id) =>
      canEnable &&
      model.state.library.activeId == id &&
      (id == null || model.state.report != null);

  void checkBuild() {
    if (!enabled || _creating && canEnable) return;
    if (!_matches(_buildId)) unawaited(disable());
  }

  Future<void> disable() async {
    _buildId = null;
    final stopping = _gateway.stop();
    if (!_closing) emit((busy: true, command: null, error: null, change: null));
    await stopping;
    if (!_closing) emit(_off);
  }

  Future<String> _connectionCommand() async {
    final mcp = model.components.active[Component.mcp]!;
    final process = ProcessService();
    final python = await process.python();
    final script = File.fromUri(
      Directory(mcp.directory).absolute.uri.resolve('run.py'),
    ).path;
    final config = await process.run(python, [
      '-X',
      'utf8',
      script,
      'config',
      '--mode',
      'editor',
      '--editor-endpoint',
      _gateway.endpoint.path,
    ], timeout: const Duration(seconds: 15));
    if (jsonDecode(config) case {
      'mcpServers': {
        'pob2-editor': {
          'command': final String command,
          'args': final List<Object?> args,
        },
      },
    }) {
      final invocation = [
        command,
        ...args.cast<String>(),
      ].map(_quote).join(' ');
      return 'codex mcp add pob2-editor -- $invocation';
    }
    throw const FormatException();
  }

  String _quote(String argument) {
    if (Platform.isWindows) return "'${argument.replaceAll("'", "''")}'";
    return "'${argument.replaceAll("'", "'\"'\"'")}'";
  }

  Future<JsonMap> _execute(
    String tool,
    JsonMap arguments,
    int? revision,
  ) async {
    _checkAccess();
    if (tool == _create) return _createBuild(arguments);
    if (tool != 'pob_catalog' && model.state.report == null) {
      throw const McpEditorFault(
        'NO_BUILD',
        'Сначала создайте или откройте сборку.',
      );
    }
    final tab = _edits[tool];
    if (tab == null && !_reads.contains(tool)) {
      throw const McpEditorFault(
        'INVALID_REQUEST',
        'Команда недоступна в редакторе PoB II.',
      );
    }
    _syncRevision();
    if (tab != null) _checkRevision(revision, arguments['expectedRevision']);
    final clean = {...arguments}..remove('expectedRevision');
    final result = await model.executeMcpEditorTool(
      tool,
      clean,
      edit: tab != null,
    );
    _syncRevision();
    if (tab != null && enabled) _showChange(tab, clean);
    return {'result': result, 'revision': _revision};
  }

  Future<JsonMap> _createBuild(JsonMap arguments) async {
    _creating = true;
    try {
      final result = await model.createMcpBuild(arguments);
      if (enabled) {
        _buildId = model.state.library.activeId;
        _syncRevision();
        _showChange(WorkshopTab.tree, const {});
      }
      return {'result': result, 'revision': _revision};
    } finally {
      _creating = false;
      checkBuild();
    }
  }

  void _checkAccess() {
    if (!enabled || !_matches(_buildId)) {
      throw const McpEditorFault(
        'EDITOR_DISABLED',
        'Включите правки через MCP.',
      );
    }
    if (model.state.busy || model.modalOpen?.call() == true) {
      throw const McpEditorFault(
        'APP_BUSY',
        'Завершите текущую операцию или закройте диалог PoB II.',
      );
    }
  }

  void _syncRevision() {
    final current = model.state.report;
    if (identical(_report, current)) return;
    _report = current;
    _revision++;
  }

  void _checkRevision(int? revision, Object? expected) {
    if (revision != _revision || (expected != null && expected != _revision)) {
      throw const McpEditorFault(
        'STALE_REVISION',
        'Сначала получите актуальный отчёт сборки через pob_check_build.',
      );
    }
  }

  void _showChange(WorkshopTab tab, JsonMap arguments) {
    final node = tab == WorkshopTab.tree && arguments['id'] is int
        ? arguments['id'] as int
        : null;
    emit((
      busy: false,
      command: state.command,
      error: null,
      change: (tab: tab, node: node, revision: _revision),
    ));
  }

  @override
  Future<void> close() async {
    _closing = true;
    await _starting;
    await disable();
    await super.close();
  }
}
