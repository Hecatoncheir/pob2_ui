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
import 'mcp_editor_commands.dart';

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
  'pob_node_tooltip',
  'pob_render_image',
  'pob_get_tree',
  'pob_tree_icons',
  'pob_tree_textures',
  'pob_tree_hover',
  'pob_node_power',
  'pob_gem_icons',
  'pob_gem_supports',
  'pob_preview_support',
  'pob_gem_tooltip',
  'pob_compare_item',
  'pob_trade_catalog',
  'pob_trade_search',
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
  'pob_set_custom_mods': WorkshopTab.conditions,
  'pob_tree_options': WorkshopTab.tree,
  'pob_import_character': WorkshopTab.tree,
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
  bool remoteChanging = false;
  bool _executing = false;
  Future<void>? _jobFuture;
  JsonMap _job = const {'state': 'idle'};
  int _jobId = 0;
  Future<void> Function()? closePermissionDialog;
  bool Function()? permissionDialogCurrent;
  Future<JsonMap> Function(JsonMap arguments)? uiAction;
  JsonMap Function()? uiStatus;
  Future<void> Function(String action)? lifecycleAction;
  late final commands = McpEditorCommands(model);
  String? _buildId;
  BuildReport? _report;
  int _revision = 0;

  bool get enabled => state.command != null;
  bool get canEnable => model.components.active[Component.mcp] != null;

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
      await _gateway.start(_execute, afterReply: _afterReply);
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

  bool _matches(String? id) => canEnable && model.state.library.activeId == id;

  void checkBuild() {
    if (!enabled || remoteChanging || _creating && canEnable) return;
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
    final python = await process.runtimePython(mcp);
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
    final appRead = mcpApplicationRead(tool, arguments);
    _checkAccess(tool, appRead || _reads.contains(tool));
    _syncRevision();
    if (tool == 'pob_editor_status') return _reply(_status());
    if (tool == 'pob_editor_job') return _reply(_job);
    if (_executing)
      throw const McpEditorFault('APP_BUSY', 'Выполняется другая команда MCP.');
    if (_background(tool, arguments)) {
      _checkRevision(revision, arguments['expectedRevision']);
      return _startJob(tool, arguments);
    }
    _executing = true;
    remoteChanging = !appRead && !_reads.contains(tool);
    try {
      if (mcpApplicationTools.contains(tool))
        return await _appTool(tool, arguments, revision, appRead);
      if (tool == 'pob_import_xml') {
        _checkRevision(revision, arguments['expectedRevision']);
        final result = await commands.call('pob_editor_files', {
          'action': 'import_xml',
          'text': arguments['xml'],
        });
        _buildId = model.state.library.activeId;
        _syncRevision();
        return _reply(result);
      }
      if (tool == _create) return await _createBuild(arguments);
      return await _engineTool(tool, arguments, revision);
    } finally {
      remoteChanging = false;
      _executing = false;
      checkBuild();
    }
  }

  bool _background(String tool, JsonMap args) =>
      tool == 'pob_editor_components' &&
      {'update', 'rollback', 'select_installed'}.contains(args['action']);

  JsonMap _startJob(String tool, JsonMap args) {
    final previousMcp = model.components.active[Component.mcp]?.directory;
    _executing = true;
    remoteChanging = true;
    final id = ++_jobId;
    _job = {
      'id': id,
      'state': 'running',
      'tool': tool,
      'action': args['action'],
    };
    _jobFuture = Future<void>(() async {
      try {
        final result = await _application(tool, args);
        await _refreshConnectionCommand(previousMcp);
        _buildId = model.state.library.activeId;
        _syncRevision();
        _revision++;
        _job = {..._job, 'state': 'complete', 'result': result};
      } catch (error) {
        final code = error is McpEditorFault ? error.code : 'EDITOR_FAILED';
        final message = error is McpEditorFault ? error.message : '$error';
        _job = {
          ..._job,
          'state': 'failed',
          'error': {'code': code, 'message': message},
        };
      } finally {
        remoteChanging = false;
        _executing = false;
        checkBuild();
      }
    });
    return _reply(_job);
  }

  Future<void> _refreshConnectionCommand(String? previousMcp) async {
    if (model.components.active[Component.mcp]?.directory == previousMcp)
      return;
    try {
      final command = await _connectionCommand();
      if (!enabled || _closing) return;
      emit((busy: false, command: command, error: null, change: state.change));
    } catch (error) {
      model.addLog('Не удалось обновить команду подключения MCP: $error');
    }
  }

  Future<JsonMap> _appTool(
    String tool,
    JsonMap arguments,
    int? revision,
    bool read,
  ) async {
    if (!read) _checkRevision(revision, arguments['expectedRevision']);
    final result = await _application(tool, arguments);
    _buildId = model.state.library.activeId;
    _syncRevision();
    if (!read) _revision++;
    return _reply(result);
  }

  JsonMap _reply(JsonMap result) => {'result': result, 'revision': _revision};

  JsonMap _status() => {
    'enabled': enabled,
    'connectionCommand': state.command,
    'connected': model.engine.connected,
    'busy': model.state.busy || _executing,
    'dialogOpen': model.modalOpen?.call() ?? false,
    'canCloseDialog': permissionDialogCurrent?.call() ?? false,
    'activeBuild': model.state.library.activeId,
    'revision': _revision,
    'job': _job,
    'status': model.state.status,
    'error': model.state.error,
    'history': {'undo': model.state.undoCount, 'redo': model.state.redoCount},
    'components': {
      for (final e in model.components.active.entries)
        e.key.name: e.value.toJson(),
    },
    'ui': uiStatus?.call(),
    'capabilities': [
      ...mcpApplicationTools,
      _create,
      'pob_import_xml',
      ..._reads,
      ..._edits.keys,
    ],
    'engineTools': model.engine.tools.toList(),
    'log': model.state.log.reversed.take(20).toList().reversed.toList(),
  };

  Future<JsonMap> _application(String tool, JsonMap args) async {
    if (tool == 'pob_editor_ui') {
      if (args['action'] == 'status') return uiStatus?.call() ?? {};
      final action = uiAction;
      if (action == null)
        throw const McpEditorFault('UNAVAILABLE', 'Интерфейс не подключён.');
      return action(args);
    }
    if (tool != 'pob_editor_app') return commands.call(tool, args);
    return _appAction(args);
  }

  Future<JsonMap> _appAction(JsonMap args) async {
    switch (args['action']) {
      case 'connect':
        await model.connect();
      case 'disconnect':
        await model.disconnectMcpEngine();
      case 'recalculate':
        await model.refreshReport();
      case 'save':
        await model.checkpoint();
      case 'doctor':
        await model.doctor();
      case 'close_dialog':
        await _closePermissionDialog();
      case 'disable_access':
        return {'scheduled': 'disable_access'};
      case 'close' || 'restart':
        if (lifecycleAction == null)
          throw const McpEditorFault(
            'UNAVAILABLE',
            'Завершение приложения недоступно.',
          );
        await model.checkpoint();
        return {'scheduled': args['action']};
      default:
        throw const McpEditorFault(
          'INVALID_ARGUMENTS',
          'Неизвестное действие приложения.',
        );
    }
    _checkActionError(args['action']);
    return _status();
  }

  void _checkActionError(Object? action) {
    if (!{'connect', 'recalculate', 'doctor'}.contains(action)) return;
    if (model.state.error case final error?)
      throw McpEditorFault('EDITOR_FAILED', error);
  }

  Future<void> _closePermissionDialog() async {
    final close = closePermissionDialog;
    if (close == null || permissionDialogCurrent?.call() != true) {
      throw const McpEditorFault(
        'DIALOG_PROTECTED',
        'Диалог MCP не открыт; другие диалоги требуют завершения ввода.',
      );
    }
    await close();
  }

  Future<void> _afterReply(JsonMap reply) async {
    if (reply['result'] case {'scheduled': final String action}) {
      if (action == 'disable_access') {
        await disable();
      } else {
        await lifecycleAction?.call(action);
      }
    }
  }

  Future<JsonMap> _engineTool(
    String tool,
    JsonMap arguments,
    int? revision,
  ) async {
    if (!model.engine.connected)
      throw const McpEditorFault(
        'ENGINE_DISCONNECTED',
        'Подключите Lua через pob_editor_app.',
      );
    if (tool != 'pob_catalog' && model.state.report == null) {
      throw const McpEditorFault(
        'NO_BUILD',
        'Сначала создайте или откройте сборку.',
      );
    }
    final tab = _editorTab(tool, arguments['control']);
    if (tab == null && !_reads.contains(tool)) {
      throw const McpEditorFault(
        'INVALID_REQUEST',
        'Команда недоступна в редакторе PoB II.',
      );
    }
    _syncRevision();
    if (tab != null) _checkRevision(revision, arguments['expectedRevision']);
    final clean = {...arguments}..remove('expectedRevision');
    if (tool == 'pob_render_image') {
      final response = await model.executeMcpEditorRead(tool, clean);
      return {..._reply(response.result), 'content': response.content};
    }
    final result = await model.executeMcpEditorTool(
      tool,
      clean,
      edit: tab != null,
    );
    _syncRevision();
    if (tab != null && enabled) _showChange(tab, clean);
    return {'result': result, 'revision': _revision};
  }

  WorkshopTab? _editorTab(String tool, Object? control) =>
      switch ((tool, control)) {
        ('pob_select_main_skill', 'parts' || 'statSets') =>
          WorkshopTab.calculations,
        _ => _edits[tool],
      };

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

  void _checkAccess(String tool, bool read) {
    if (!enabled || !_matches(_buildId)) {
      throw const McpEditorFault(
        'EDITOR_DISABLED',
        'Включите правки через MCP.',
      );
    }
    if (tool == 'pob_editor_status' || tool == 'pob_editor_job') return;
    if (model.state.busy || (!read && _protectedDialog(tool))) {
      throw const McpEditorFault(
        'APP_BUSY',
        'Завершите текущую операцию или закройте диалог PoB II.',
      );
    }
  }

  bool _protectedDialog(String tool) =>
      model.modalOpen?.call() == true &&
      !(tool == 'pob_editor_app' && permissionDialogCurrent?.call() == true);

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
    await _jobFuture;
    await _starting;
    await disable();
    await super.close();
  }
}
