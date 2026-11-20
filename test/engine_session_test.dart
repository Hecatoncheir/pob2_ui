import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/engine_session.dart';
import 'package:pob2_ui/ui/engine_session_cubit.dart';
import 'package:pob2_ui/ui/engine_session_view.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/engine_connection_fake.dart';
import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';
import 'support/dispose_widget_bloc.dart';

class _XmlEngine extends McpClient {
  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async => switch (name) {
    'pob_export_xml' => {'xml': '<PathOfBuilding/>'},
    _ => throw StateError(name),
  };
}

void main() {
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
