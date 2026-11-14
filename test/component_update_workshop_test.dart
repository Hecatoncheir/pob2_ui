import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/github_service.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';

const _buildId = 'Рабочая.xml';
const _oldTag = 'v1.0.0';
const _newTag = 'v2.0.0';
const _previousTag = 'v0.9.0';
const _notes = 'Сохранённые заметки';

String _xml(int level) =>
    '<PathOfBuilding2><Build className="Witch" level="$level"/>'
    '<Notes>$_notes</Notes></PathOfBuilding2>';

Installations _pair(String tag) => {
  for (final component in Component.values)
    component: Installation(
      tag: tag,
      commit: '${component.name}-$tag',
      directory: '${component.name}-$tag',
    ),
};

List<String> _tags(Installations pair) => [
  for (final component in Component.values) pair[component]!.tag,
];

class _LatestReleases extends GitHubService {
  @override
  Future<Release> latest(Component component) async =>
      Release(_newTag, '', DateTime.utc(2026));
}

class _InstallationTools extends ProcessService {
  @override
  Future<String> python() async => 'python';

  @override
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) async => 'git version';
}

class _ComponentUpdates extends ComponentRepository {
  _ComponentUpdates(InstallationStore store)
    : super(
        store: store,
        github: _LatestReleases(),
        processes: _InstallationTools(),
      );

  bool failCommit = false;

  @override
  Future<void> installPair(
    Map<Component, Release> releases,
    void Function(String) log, {
    Future<void> Function(Installations)? validate,
    void Function(ComponentInstallStage)? onStage,
  }) async {
    expect(releases.keys, unorderedEquals(Component.values));
    final candidate = {
      for (final entry in releases.entries)
        entry.key: _pair(entry.value.tag)[entry.key]!,
    };
    await _activate(candidate, validate);
  }

  @override
  Future<void> rollback({Future<void> Function(Installations)? validate}) =>
      _activate(store.previous, validate);

  Future<void> _activate(
    Installations candidate,
    Future<void> Function(Installations)? validate,
  ) async {
    expect(validate, isNotNull);
    await validate!(candidate);
    if (failCommit) throw StateError('Не удалось сохранить версии');
    await store.save(candidate, active);
    active = candidate;
  }
}

class _Engine extends McpClient {
  _Engine({this.importStarted, this.allowImport, this.rejectImport = false});

  final Completer<void>? importStarted, allowImport;
  final bool rejectImport;
  final imported = <String>[];
  String? tag;
  String xml = '';

  @override
  bool get connected => tag != null;

  @override
  Future<void> connect(Installations pair) async {
    tag = pair[Component.mcp]!.tag;
    tools = {
      'pob_catalog',
      'pob_create_build',
      'pob_import_xml',
      'pob_export_xml',
      'pob_check_build',
      'pob_tree_action',
      'pob_get_tree',
    };
  }

  @override
  Future<void> close() async {
    tag = null;
    tools = {};
  }

  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    if (!connected) throw StateError('Lua отключён');
    return switch (name) {
      'pob_catalog' => {
        'entries': [
          {'id': 1, 'name': 'Witch'},
        ],
      },
      'pob_import_xml' => _import(arguments['xml'] as String),
      'pob_create_build' => _setLevel(1),
      'pob_tree_action' => _setLevel(PobBuildDocument(xml).level + 1),
      'pob_export_xml' => {'xml': xml},
      'pob_check_build' => _report(),
      'pob_get_tree' => {
        'version': '0_5',
        'nodes': [
          {
            'id': 1,
            'x': 0,
            'y': 0,
            'name': 'Узел',
            'type': 'Normal',
            'allocated': true,
          },
        ],
        'edges': <List<int>>[],
      },
      _ => throw StateError(name),
    };
  }

  Future<JsonMap> _import(String source) async {
    imported.add(source);
    if (importStarted case final started? when !started.isCompleted) {
      started.complete();
    }
    await allowImport?.future;
    if (rejectImport) throw StateError('Новый Lua отклонил XML');
    xml = source;
    return {};
  }

  JsonMap _setLevel(int level) {
    xml = _xml(level);
    return {};
  }

  JsonMap _report() {
    final level = PobBuildDocument(xml).level;
    return {
      'report': {
        'source': 'original-lua',
        'snapshot': {
          'treeVersion': '0_5',
          'buildInfo': {'class': 'Witch', 'level': level},
        },
        'stats': {'Life': level + (tag == _newTag ? 200 : 100)},
      },
    };
  }
}

void main() {
  late Directory root;
  late File buildFile;
  late PobBuildLibrary library;
  late _ComponentUpdates components;
  late _Engine working;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-component-update-');
    addTearDown(() => removeTemporaryDirectory(root));
    final builds = await Directory.fromUri(root.uri.resolve('builds/'))
        .create();
    buildFile = await File.fromUri(builds.uri.resolve(_buildId))
        .writeAsString(_xml(40));
    library = PobBuildLibrary(root);
    await library.configure(builds.path);
    await library.activate(_buildId);
    final store = InstallationStore(root);
    await store.save(_pair(_oldTag), _pair(_previousTag));
    components = _ComponentUpdates(store);
    working = _Engine();
  });

  Future<WorkshopCubit> openWorkshop(List<_Engine> candidates) async {
    final pending = candidates.iterator;
    final model = WorkshopCubit(
      components,
      working,
      library: library,
      createEngine: () {
        expect(pending.moveNext(), isTrue);
        return pending.current;
      },
    );
    addTearDown(model.close);
    await model.initialize();
    expect(model.state.error, isNull);
    expect(model.state.library.activeId, _buildId);
    expect(model.state.report?.level, 40);
    return model;
  }

  Future<void> expectVersions(String active, String previous) async {
    expect(_tags(components.active), [active, active]);
    final reopened = InstallationStore(root);
    expect(_tags(await reopened.load()), [active, active]);
    expect(_tags(reopened.previous), [previous, previous]);
  }

  test('Отказ кандидата оставляет открытый XML, движок и историю', () async {
    final started = Completer<void>();
    final resume = Completer<void>();
    final candidate = _Engine(
      importStarted: started,
      allowImport: resume,
      rejectImport: true,
    );
    final model = await openWorkshop([candidate]);
    await model.treeAction(1, false);
    await model.treeAction(2, false);
    await model.undo();
    final report = model.state.report;
    expect(model.state.history, (undo: 1, redo: 1));

    final updating = model.updateComponents();
    try {
      await started.future.timeout(const Duration(seconds: 5));
      expect(model.state.busy, isTrue);
      expect(model.engine, same(working));
      expect(working.connected, isTrue);
      expect(model.state.report, same(report));
    } finally {
      resume.complete();
      await updating;
    }

    expect(model.state.error, contains('Новый Lua отклонил XML'));
    expect(model.state.library.activeId, _buildId);
    expect(model.state.report, same(report));
    expect(model.state.document?.stale, isFalse);
    expect(model.state.history, (undo: 1, redo: 1));
    expect(model.engine, same(working));
    expect(working.connected, isTrue);
    expect(candidate.connected, isFalse);
    expect(await buildFile.readAsString(), _xml(41));
    await expectVersions(_oldTag, _previousTag);

    await model.redo();
    expect(model.state.error, isNull);
    expect(model.state.report?.level, 42);
  });

  test('Отказ записи версий после проверки сохраняет прежнюю сессию', () async {
    final candidate = _Engine();
    final model = await openWorkshop([candidate]);
    components.failCommit = true;

    await model.updateComponents();
    expect(model.state.error, contains('Не удалось сохранить версии'));
    expect(candidate.imported, contains(_xml(40)));
    expect(candidate.connected, isFalse);
    expect(model.engine, same(working));
    expect(working.connected, isTrue);
    expect(model.state.library.activeId, _buildId);
    expect(model.state.report?.stats['Life'], 140);
    expect(await buildFile.readAsString(), _xml(40));
    await expectVersions(_oldTag, _previousTag);
  });

  test('Успешное обновление и откат оставляют ту же сборку открытой', () async {
    final updated = _Engine();
    final restored = _Engine();
    final model = await openWorkshop([updated, restored]);
    await model.treeAction(1, false);

    await model.updateComponents();
    expect(model.state.error, isNull);
    expect(model.engine, same(updated));
    expect(working.connected, isFalse);
    expect(model.state.library.activeId, _buildId);
    expect(model.state.report?.stats['Life'], 241);
    expect(updated.xml, _xml(41));
    expect(await buildFile.readAsString(), _xml(41));
    await expectVersions(_newTag, _oldTag);

    await model.rollback();
    expect(model.state.error, isNull);
    expect(model.engine, same(restored));
    expect(updated.connected, isFalse);
    expect(model.state.library.activeId, _buildId);
    expect(model.state.report?.stats['Life'], 141);
    expect(restored.xml, _xml(41));
    expect(await buildFile.readAsString(), _xml(41));
    await expectVersions(_oldTag, _newTag);
  });
}
