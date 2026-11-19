import 'dart:io';

import 'package:path/path.dart' as path;

import '../data/atomic_text_file.dart';
import '../data/mcp_editor_gateway.dart';
import '../data/pob_share_code.dart';
import '../domain/build_report.dart';
import '../domain/component.dart';
import '../domain/tree_progression.dart';
import 'workshop_cubit.dart';

const mcpApplicationTools = {
  'pob_editor_status',
  'pob_editor_app',
  'pob_editor_components',
  'pob_editor_library',
  'pob_editor_history',
  'pob_editor_notes',
  'pob_editor_files',
  'pob_editor_progression',
  'pob_editor_ui',
  'pob_editor_job',
};

bool mcpApplicationRead(String tool, JsonMap args) => switch (tool) {
  'pob_editor_status' || 'pob_editor_job' => true,
  'pob_editor_library' => args['action'] == 'list',
  'pob_editor_components' ||
  'pob_editor_history' ||
  'pob_editor_ui' => args['action'] == 'status',
  'pob_editor_notes' => args['action'] == 'read',
  'pob_editor_progression' => args['action'] == 'list',
  'pob_editor_files' => {'export_xml', 'export_code'}.contains(args['action']),
  _ => false,
};

String mcpRequiredText(JsonMap args, String key) => switch (args[key]) {
  final String value when value.trim().isNotEmpty => value,
  _ => throw McpEditorFault('INVALID_ARGUMENTS', 'Укажите $key.'),
};

class McpEditorCommands {
  McpEditorCommands(this.model);
  final WorkshopCubit model;

  Future<JsonMap> call(String tool, JsonMap args) => switch (tool) {
    'pob_editor_library' => _library(args),
    'pob_editor_components' => _components(args),
    'pob_editor_history' => _history(args),
    'pob_editor_notes' => _notes(args),
    'pob_editor_files' => _files(args),
    'pob_editor_progression' => _progression(args),
    _ => throw const McpEditorFault('INVALID_REQUEST', 'Неизвестная команда.'),
  };

  JsonMap libraryState() => {
    'activeId': model.state.library.activeId,
    'folder': model.sharedLibrary?.directory,
    'builds': model.state.library.entries.map((e) => e.toJson()).toList(),
  };

  Future<JsonMap> _library(JsonMap args) async {
    if (args['action'] == 'list') return libraryState();
    switch (args['action']) {
      case 'list':
        break;
      case 'refresh':
        await model.refreshPobBuilds();
      case 'open':
        await model.openBuild(mcpRequiredText(args, 'id'));
      case 'copy':
        _requireBuild();
        await model.copyBuild();
      case 'rename':
        _requireBuild();
        await model.renameBuild(mcpRequiredText(args, 'title'));
      case 'delete':
        await model.deleteBuild(mcpRequiredText(args, 'id'));
      case 'set_folder':
        await model.selectPobBuildFolder(mcpRequiredText(args, 'path'));
      case 'detect_folder':
        await model.detectPobBuildFolder();
      default:
        _invalid();
    }
    _checkError();
    return libraryState();
  }

  Future<JsonMap> componentState() async => {
    'active': _pair(model.components.active),
    'previous': _pair(model.components.store.previous),
    'installed': [
      for (final pair in await model.components.installedPairs()) _pair(pair),
    ],
    'available': {
      for (final e in model.components.availableReleases().entries)
        e.key.name: {'tag': e.value.tag, 'commit': e.value.expectedCommit},
    },
  };

  JsonMap _pair(Installations pair) => {
    for (final e in pair.entries) e.key.name: e.value.toJson(),
  };

  Future<JsonMap> _components(JsonMap args) async {
    if (args['action'] == 'status') return componentState();
    switch (args['action']) {
      case 'status':
        break;
      case 'check_updates':
        await model.checkUpdates();
      case 'update':
        _checkDevReplacement(args);
        await model.updateComponents();
      case 'rollback':
        await model.rollback();
      case 'select_installed':
        final component = Component.values
            .where((e) => e.name == args['component'])
            .firstOrNull;
        if (component == null) _invalid();
        await model.selectMcpComponent(
          component,
          mcpRequiredText(args, 'commit'),
        );
      default:
        _invalid();
    }
    _checkError();
    return componentState();
  }

  void _checkDevReplacement(JsonMap args) {
    if (args['allowReplaceDev'] == true) return;
    final releases = model.components.availableReleases();
    for (final e in model.components.active.entries) {
      if (e.value.tag.startsWith('dev-') &&
          e.value.tag != releases[e.key]?.tag) {
        throw const McpEditorFault(
          'VERSION_REPLACEMENT',
          'Обновление заменит dev-версию закреплённым выпуском. Проверьте status и укажите allowReplaceDev=true.',
        );
      }
    }
  }

  Future<JsonMap> _history(JsonMap args) async {
    switch (args['action']) {
      case 'status':
        break;
      case 'undo':
        if (model.state.undoCount == 0) _invalid();
        await model.undo();
      case 'redo':
        if (model.state.redoCount == 0) _invalid();
        await model.redo();
      default:
        _invalid();
    }
    if (args['action'] != 'status') _checkError();
    return {'undo': model.state.undoCount, 'redo': model.state.redoCount};
  }

  Future<JsonMap> _notes(JsonMap args) async {
    final id = _requireBuild();
    switch (args['action']) {
      case 'read':
        break;
      case 'write':
        final text = args['text'];
        if (text is! String) _invalid();
        await model.writeMcpNotes(id, text);
        _checkError();
      default:
        _invalid();
    }
    return {'id': id, 'text': await model.buildNotes.readNotes(id)};
  }

  Future<JsonMap> _files(JsonMap args) async {
    switch (args['action']) {
      case 'import_xml':
        await model.importXml(mcpRequiredText(args, 'text'));
      case 'import_file':
        await model.importXml(await _readFile(args));
      case 'import_code':
        await model.importShareCode(mcpRequiredText(args, 'text'));
      case 'import_link':
        await model.importShareLink(mcpRequiredText(args, 'text'));
      case 'export_xml':
        return {'xml': await _export()};
      case 'export_code':
        return {'code': await encodePobShareCode(await _export())};
      case 'save_file':
        return _saveFile(args);
      default:
        _invalid();
    }
    _checkError();
    return libraryState();
  }

  File _file(JsonMap args) {
    final value = mcpRequiredText(args, 'path');
    if (!path.isAbsolute(value))
      throw const McpEditorFault('INVALID_ARGUMENTS', 'Нужен абсолютный путь.');
    return File(path.normalize(value));
  }

  Future<String> _readFile(JsonMap args) async {
    final file = _file(args);
    if (await file.length() > 8 * 1024 * 1024) _invalid();
    return file.readAsString();
  }

  Future<JsonMap> _saveFile(JsonMap args) async {
    final file = _file(args);
    if (await file.exists() && args['overwrite'] != true) {
      throw const McpEditorFault(
        'FILE_EXISTS',
        'Файл существует. Для замены укажите overwrite=true.',
      );
    }
    await model.sharedLibrary?.checkExport(file);
    await AtomicTextFile().write(file, await _export());
    return {'path': file.path, 'saved': true};
  }

  Future<String> _export() async {
    _requireBuild();
    final xml = await model.exportXml();
    _checkError();
    if (xml == null) _invalid();
    return xml;
  }

  Future<JsonMap> _progression(JsonMap args) async {
    final key = model.progressionKey;
    if (key == null)
      throw const McpEditorFault('NO_BUILD', 'Нет дерева текущей сборки.');
    final repository = model.progressionRepository(key);
    final steps = [...await repository.load()];
    await _editProgression(key, steps, args);
    if ({'capture', 'apply'}.contains(args['action'])) _checkError();
    if (!{'list', 'apply'}.contains(args['action']))
      await repository.save(steps);
    return {
      'steps': [
        for (final (i, s) in steps.indexed)
          {
            'index': i,
            'level': s.level,
            'title': s.title,
            'note': s.note,
            'completed': s.completed,
            'nodes': s.nodes.toList(),
            'parts': s.parts.map((p) => p.name).toList(),
          },
      ],
    };
  }

  Future<void> _editProgression(
    TreeProgressionKey key,
    List<TreeProgressionStep> steps,
    JsonMap args,
  ) async {
    if (args['action'] == 'list') return;
    if (args['action'] == 'capture') {
      steps.add(await _capture(key, args));
      return;
    }
    final index = args['index'];
    if (index is! int || index < 0 || index >= steps.length) _invalid();
    final i = index;
    final step = steps[i];
    switch (args['action']) {
      case 'delete':
        steps.removeAt(i);
      case 'update':
        steps[i] = step.withProgress(
          details: (
            level: step.level,
            title: args['title'] as String? ?? step.title,
            note: args['note'] as String? ?? step.note,
          ),
          completed: args['completed'] as bool?,
        );
      case 'apply':
        final parts = _parts(args);
        if (!step.parts.containsAll(parts) ||
            model.state.document?.stale == true)
          _invalid();
        await model.applyProgression(key, step, parts: parts);
      default:
        _invalid();
    }
  }

  Future<TreeProgressionStep> _capture(
    TreeProgressionKey key,
    JsonMap args,
  ) async {
    final step = await model.captureProgression(key);
    if (step == null) _invalid();
    return step.withDetails((
      level: step.level,
      title: args['title'] as String? ?? '',
      note: args['note'] as String? ?? '',
    ));
  }

  Set<ProgressionPart> _parts(JsonMap args) {
    final values = args['parts'] as List<dynamic>? ?? ['tree'];
    final parts = values
        .map((v) => ProgressionPart.values.byName(v as String))
        .toSet();
    if (parts.isEmpty) _invalid();
    return parts;
  }

  String _requireBuild() =>
      model.state.library.activeId ??
      (throw const McpEditorFault('NO_BUILD', 'Сначала откройте сборку.'));

  void _checkError() {
    if (model.state.error case final error?)
      throw McpEditorFault('EDITOR_FAILED', error);
  }

  Never _invalid() => throw const McpEditorFault(
    'INVALID_ARGUMENTS',
    'Действие или его параметры недоступны.',
  );
}
