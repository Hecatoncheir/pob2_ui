import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:material_ui/material_ui.dart';

import 'support/legacy/component_repository.dart';

import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/engine_session_client.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/domain/engine_session.dart';
import 'package:pob2_ui/ui/engine_session_cubit.dart';
import 'package:pob2_ui/ui/engine_session_view.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/engine_connection_fake.dart';
import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';
import 'support/dispose_widget_bloc.dart';

class _XmlEngine extends WorkbenchClient {
  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async => switch (name) {
    'pob_export_xml' => {
      'xml': '<PathOfBuilding2><Build className="Witch" level="90"/><Notes/></PathOfBuilding2>',
    },
    'pob_import_xml' => {},
    'pob_check_build' => {'report': fixture.raw},
    _ => throw StateError(name),
  };
}

class _EquipmentConnection extends FakeEngineConnection {
  final applied = <EngineEquipmentEdit>[];

  @override
  bool get supportsEquipmentPreview => true;

  @override
  Future<EngineEquipmentPreview> previewEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
  ) async {
    const report = EngineCalculation(status: 'complete', warnings: []);
    return (
      revision: current.revision,
      before: report,
      after: report,
      deltas: const <EngineStatDelta>[],
    );
  }

  @override
  Future<EngineSnapshot> editEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
    String requestId,
  ) async {
    applied.add(edit);
    return current;
  }
}

class _SkillChoiceConnection extends FakeEngineConnection
    implements EngineSkillChoiceWriter {
  _SkillChoiceConnection(EngineBuild original, this.freshBuild)
    : super(EngineSnapshot('main', 'Начальная', 1, build: original));

  final EngineBuild freshBuild;
  final attemptedRevisions = <int>[];

  @override
  bool get supportsSkillChoice => true;

  @override
  Future<EngineSnapshot> chooseSkill(
    EngineSnapshot snapshot,
    String control,
    int id,
    String requestId,
  ) async {
    attemptedRevisions.add(snapshot.revision);
    if (attemptedRevisions.length == 1) {
      current = EngineSnapshot('main', 'Начальная', 2, build: freshBuild);
      throw const GrpcError.aborted();
    }
    return snapshot;
  }
}

void main() {
  const original = EngineBuild(xml: '<Build/>', level: 1, inputRevision: 1);
  for (final (name, fresh, retry) in [
    ('Расчёт не мешает выбрать умение', original, true),
    (
      'Новая входная ревизия отклоняет выбор умения',
      const EngineBuild(xml: '<Build/>', level: 1, inputRevision: 2),
      false,
    ),
    (
      'Изменённый XML отклоняет выбор умения',
      const EngineBuild(xml: '<Build level="2"/>', level: 2, inputRevision: 1),
      false,
    ),
  ]) {
    test(name, () async {
      final connection = _SkillChoiceConnection(original, fresh);
      final cubit = EngineSessionCubit(open: (_) async => connection);
      addTearDown(connection.events.close);
      addTearDown(cubit.close);

      await cubit.connect(const EngineOptions());
      final choice = cubit.chooseSkill(cubit.state.snapshot!, 'groups', 2);
      if (retry) {
        expect((await choice).revision, 2);
      } else {
        await expectLater(choice, throwsStateError);
      }
      expect(connection.attemptedRevisions, retry ? [1, 2] : [1]);
    });
  }

  test('После переподключения та же ревизия требует новой примерки', () async {
    final first = _EquipmentConnection();
    final second = _EquipmentConnection();
    var next = first;
    final cubit = EngineSessionCubit(open: (_) async => next);
    addTearDown(first.events.close);
    addTearDown(second.events.close);
    addTearDown(cubit.close);

    const options = EngineOptions();
    const edit = (slot: 'Ring 1', raw: 'Rarity: NORMAL\nIron Ring', itemId: 0);
    await cubit.connect(options);
    final original = await cubit.previewEquipment(cubit.state.snapshot!, edit);
    expect(cubit.isCurrentEquipmentOffer(original), isTrue);

    next = second;
    await cubit.connect(options);
    expect(cubit.state.snapshot!.revision, original.preview.revision);
    await expectLater(cubit.editEquipment(original), throwsStateError);
    expect(second.applied, isEmpty);
    final renewed = await cubit.previewEquipment(cubit.state.snapshot!, edit);
    await cubit.editEquipment(renewed);
    expect(second.applied, [edit]);
  });

  test(
    'Последнее подключение отменяет предыдущее до открытия процесса',
    () async {
      final opened = <String>[];
      final connection = FakeEngineConnection();
      final cubit = EngineSessionCubit(
        open: (options) async {
          opened.add(options.profile);
          return connection;
        },
      );
      addTearDown(connection.events.close);
      addTearDown(cubit.close);
      final first = cubit.connect(const EngineOptions(profile: 'first'));
      final second = cubit.connect(const EngineOptions(profile: 'second'));
      await Future.wait([first, second]);
      expect(opened, ['second']);
      expect(cubit.state.options.profile, 'second');
      expect(cubit.state.connected, true);
    },
  );

  test(
    'Привязка следует за именем XML при внешних правках, правке UI и Undo',
    () async {
      final root = await Directory.systemTemp.createTemp('pob2-engine-xml-');
      addTearDown(() => removeTemporaryDirectory(root));
      final builds = await Directory.fromUri(root.uri.resolve('builds/'))
          .create();
      final library = PobBuildLibrary(root);
      await library.configure(builds.path);
      final connection = FakeEngineConnection();
      final model = WorkshopCubit(
        ComponentRepository(store: InstallationStore(root)),
        _XmlEngine(),
        library: library,
        openEngineSession: (_) async => connection,
        initialState: WorkshopState(
          document: (
            report: fixture,
            tree: tree,
            stale: false,
            treeError: null,
          ),
        ),
      );
      addTearDown(connection.events.close);
      addTearDown(model.close);
      await model.renameBuild('Начальная');
      await model.connectEngine(const EngineOptions(), bindCurrentBuild: true);
      await Future<void>.delayed(Duration.zero);
      for (final name in ['CLI', 'MCP']) {
        final changed = model.stream.firstWhere(
          (state) => state.library.active?.title == name && !state.busy,
        );
        connection.change(name);
        await changed.timeout(const Duration(seconds: 3));
        expect(model.state.library.activeId, '$name.xml');
      }
      final renamed = model.stream.firstWhere(
        (state) => state.library.active?.title == 'UI' && !state.busy,
      );
      await model.renameBuild('UI');
      await renamed.timeout(const Duration(seconds: 3));
      expect(connection.renames.single.name, 'UI');
      await model.undo();
      expect(model.state.error, isNull);
      expect(connection.renames.last.name, 'MCP');
      expect(model.state.library.activeId, 'MCP.xml');
      expect((await library.load()).active!.title, 'MCP');
    },
  );

  testWidgets(
    'Внешняя правка сразу показывает имя, ревизию и изменённое поле',
    (tester) async {
      final connection = FakeEngineConnection();
      final cubit = EngineSessionCubit(open: (_) async => connection);
      addTearDown(() async {
        await disposeWidgetBloc(tester, cubit);
        unawaited(connection.events.close());
        await tester.pump();
      });
      await cubit.connect(const EngineOptions());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EngineSessionBar(cubit: cubit, configure: () {}),
          ),
        ),
      );
      connection.change('Из MCP');
      await tester.pump();
      expect(find.textContaining('Из MCP · ревизия 2'), findsOneWidget);
      expect(find.textContaining('«Начальная» → «Из MCP»'), findsOneWidget);
      connection.events.add(connection.history.single);
      await tester.pump();
      expect(cubit.state.changes.length, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test('Переподключение догружает каждую пропущенную ревизию', () async {
    final first = FakeEngineConnection();
    final second = FakeEngineConnection();
    second.change('CLI');
    second.change('MCP');
    var opens = 0;
    final cubit = EngineSessionCubit(
      open: (_) async => opens++ == 0 ? first : second,
    );
    addTearDown(first.events.close);
    addTearDown(second.events.close);
    addTearDown(cubit.close);
    await cubit.connect(const EngineOptions());
    final lost = cubit.stream.firstWhere((state) => !state.connected);
    final restored = cubit.stream.firstWhere(
      (state) => state.snapshot?.revision == 3,
    );
    first.events.addError(StateError('соединение потеряно'));
    expect((await lost.timeout(const Duration(seconds: 2))).connected, false);
    await restored.timeout(const Duration(seconds: 3));
    expect(second.watchedRevisions, [1]);
    expect(cubit.state.snapshot!.buildName, 'MCP');
    expect(cubit.state.changes.map((event) => event.snapshot.revision), [
      1,
      2,
      3,
    ]);
    await cubit.disconnect();
    expect(second.closed, true);
  });

  test('Правка UI передаёт текущую ревизию и уникальный request_id', () async {
    final connection = FakeEngineConnection();
    final cubit = EngineSessionCubit(open: (_) async => connection);
    addTearDown(connection.events.close);
    addTearDown(cubit.close);
    await cubit.connect(const EngineOptions());
    await Future<void>.delayed(Duration.zero);
    await cubit.rename('Из приложения');
    expect(connection.renames.single.before.revision, 1);
    expect(
      connection.renames.single.requestId,
      matches(RegExp(r'^[a-f0-9]{32}$')),
    );
    expect(cubit.state.snapshot!.buildName, 'Из приложения');
    expect(cubit.state.snapshot!.revision, 2);
  });

  test(
    'Привязанная сборка сохраняет внешнее имя без обратной команды',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'pob2-engine-binding-',
      );
      addTearDown(() => removeTemporaryDirectory(root));
      final connection = FakeEngineConnection();
      final model = WorkshopCubit(
        ComponentRepository(store: InstallationStore(root)),
        _XmlEngine(),
        openEngineSession: (_) async => connection,
        initialState: WorkshopState(
          document: (
            report: fixture,
            tree: tree,
            stale: false,
            treeError: null,
          ),
        ),
      );
      addTearDown(connection.events.close);
      addTearDown(model.close);
      await model.renameBuild('Начальная');
      await model.connectEngine(const EngineOptions(), bindCurrentBuild: true);
      await Future<void>.delayed(Duration.zero);
      connection.change('Через CLI');
      await model.stream
          .firstWhere(
            (state) =>
                state.library.active?.title == 'Через CLI' && !state.busy,
          )
          .timeout(const Duration(seconds: 3));
      expect(connection.renames, isEmpty);
      expect(model.state.error, isNull);
      final entries = await model.library.load();
      expect(entries.active!.title, 'Через CLI');
    },
  );
}
