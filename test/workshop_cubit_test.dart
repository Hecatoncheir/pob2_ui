import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/github_service.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';

class DelayedComponents extends ComponentRepository {
  DelayedComponents(InstallationStore store) : super(store: store);
  final gate = Completer<void>();
  int loads = 0;
  @override
  Future<void> load() async {
    loads++;
    await gate.future;
    await super.load();
  }
}

class _SetupComponents extends ComponentRepository {
  _SetupComponents(InstallationStore store)
    : super(store: store, github: _SetupGitHub(), processes: _SetupProcesses());

  final installed = <Component>[];
  bool failMcp = true;

  @override
  Future<Installation> install(
    Component component,
    Release release,
    void Function(String) log,
  ) async {
    installed.add(component);
    if (component == Component.mcp && failMcp) throw StateError('Нет сети');
    final result = Installation(
      tag: release.tag,
      commit: 'test',
      directory: '',
    );
    active = {...active, component: result};
    return result;
  }
}

class _SetupGitHub extends GitHubService {
  @override
  Future<Release> latest(Component component) async =>
      Release('v1.0.0', '', DateTime.utc(2026));
}

class _SetupProcesses extends ProcessService {
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

class _SetupEngine extends McpClient {
  int connections = 0;

  @override
  bool get connected => connections > 0;

  @override
  Future<void> connect(Installations pair) async => connections++;

  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async => {
    'entries': [
      {'id': 1, 'name': 'Witch'},
    ],
  };
}

void main() {
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-cubit-test-');
  });
  tearDown(() => removeTemporaryDirectory(root));

  test(
    'Снимок состояния неизменяем; загрузка не затирает новый черновик',
    () async {
      final components = DelayedComponents(InstallationStore(root));
      final cubit = WorkshopCubit(components, McpClient());
      addTearDown(cubit.close);
      await cubit.session.saveDraft('старый XML');
      final before = cubit.state;
      final initializing = cubit.initialize();
      expect(cubit.state.busy, isTrue);
      await cubit.initialize();
      expect(components.loads, 1);
      cubit.editDraft('новый XML');
      components.gate.complete();
      await initializing;
      expect(cubit.state.draftXml, 'новый XML');
      expect(before.draftXml, '');
      expect(cubit.state.busy, isFalse);
      expect(() => cubit.state.log.add('изменение'), throwsUnsupportedError);
      await cubit.checkpoint();
      expect(await cubit.session.readDraft(), 'новый XML');
    },
  );

  test('Первичная настройка продолжает с недостающего компонента', () async {
    final components = _SetupComponents(InstallationStore(root));
    final engine = _SetupEngine();
    final model = WorkshopCubit(components, engine);
    addTearDown(model.close);

    await model.prepareComponents();
    expect(model.state.error, 'Нет сети');
    expect(engine.connections, 0);

    components.failMcp = false;
    await model.prepareComponents();
    await model.prepareComponents();
    expect(model.state.error, isNull);
    expect(components.installed, [Component.pob, Component.mcp, Component.mcp]);
    expect(engine.connections, 1);
  });

  test('Обновление ждёт окончания операции; закрытый Cubit не получает новые состояния', () async {
    final components = DelayedComponents(InstallationStore(root));
    final cubit = WorkshopCubit(components, McpClient());
    final pending = cubit.initialize();
    await expectLater(cubit.checkpoint(), throwsStateError);
    await cubit.close();
    components.gate.complete();
    await pending;
    expect(cubit.isClosed, isTrue);
  });
}
