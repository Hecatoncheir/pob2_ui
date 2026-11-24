import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/legacy/component_repository.dart';

import 'package:pob2_ui/data/engine_maintenance.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/data/pob_window_repository.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/domain/engine_session.dart';
import 'package:pob2_ui/ui/components_view.dart';
import 'package:pob2_ui/ui/core/panels.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/pob_bridge_cubit.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

void main() {
  const mcp = Installation(tag: '', commit: '', directory: '');

  test('При нескольких установках мост ждёт явного выбора папки', () async {
    final repository = _WindowRepository(directories: ['C:/PoB', 'D:/PoB']);
    final cubit = PobBridgeCubit(repository, mcp);
    addTearDown(cubit.close);
    await cubit.discover();
    expect(cubit.state.target.directory, isNull);
    await cubit.install();
    expect(repository.installed, isNull);
    cubit.select('E:/Portable PoB');
    await cubit.install();
    expect(repository.installed, 'E:/Portable PoB');
    expect(cubit.state.target.candidates, containsAll(['C:/PoB', 'D:/PoB']));
  });

  testWidgets('Мост находит PoB и устанавливается только по кнопке', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _WindowRepository();
    final components = ComponentRepository(
      store: InstallationStore(Directory('unused-bridge-test')),
    );
    components.active = {Component.pob: mcp};
    final model = WorkshopCubit(
      components,
      WorkbenchClient(),
      pobWindow: repository,
    );
    addTearDown(model.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: Spark.theme(),
        home: Scaffold(body: ComponentsView(model: model)),
      ),
    );
    await tester.tap(find.text('Настроить мост PoB'));
    await tester.pumpAndSettle();
    expect(find.text('C:/PoB'), findsOneWidget);
    expect(repository.installed, isNull);
    expect(find.text('Перезапустить PoB'), findsNothing);
    await tester.tap(find.text('Подключить мост'));
    await tester.pumpAndSettle();
    expect(repository.installed, 'C:/PoB');
    expect(find.textContaining('Перезапустите PoB'), findsOneWidget);
    final restart = find.text('Перезапустить PoB');
    repository.rejectRestart = true;
    await tester.tap(restart);
    await tester.pumpAndSettle();
    expect(find.text('PoB ещё открыт'), findsOneWidget);
    expect(restart, findsOneWidget);
    repository.rejectRestart = false;
    await tester.tap(restart);
    await tester.pumpAndSettle();
    expect(repository.restarted, 'C:/PoB');
    expect(find.textContaining('Связь с PoB подтверждена'), findsOneWidget);
    expect(restart, findsNothing);
    await tester.tap(find.text('Проверить связь'));
    await tester.pumpAndSettle();
    expect(repository.checked, 'C:/PoB');
    expect(find.text('Связь с PoB подтверждена'), findsOneWidget);
    expect(find.text('C:/PoB/Builds'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('После установки моста Wine доступна проверка связи', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _WindowRepository(
      directories: ['/home/user/PoB'],
      canRestart: false,
    );
    final components = ComponentRepository(
      store: InstallationStore(Directory('unused-wine-bridge-test')),
    )..active = {Component.pob: mcp};
    final model = WorkshopCubit(
      components,
      WorkbenchClient(),
      pobWindow: repository,
    );
    addTearDown(model.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: Spark.theme(),
        home: Scaffold(body: ComponentsView(model: model)),
      ),
    );
    await tester.tap(find.text('Настроить мост PoB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подключить мост'));
    await tester.pumpAndSettle();
    expect(repository.installed, '/home/user/PoB');
    expect(find.textContaining('через Wine'), findsOneWidget);
    expect(find.text('Перезапустить PoB'), findsNothing);
    await tester.tap(find.text('Проверить связь'));
    await tester.pumpAndSettle();
    expect(repository.checked, '/home/user/PoB');
    expect(find.text('/home/user/PoB/Builds'), findsOneWidget);
  });

  testWidgets('Панель показывает версии и результат doctor', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final model = WorkshopCubit(
      ComponentRepository(
        store: InstallationStore(Directory('unused-engine-test')),
      ),
      WorkbenchClient(),
    );
    addTearDown(model.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: Spark.theme(),
        home: Scaffold(
          body: ComponentsView(model: model, maintenance: const _Maintenance()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Установлена: v0.0.15'), findsOneWidget);
    await tester.tap(find.text('Проверить обновления'));
    await tester.pumpAndSettle();
    expect(find.text('Последняя: v0.0.16'), findsOneWidget);
    expect(find.text('Последняя: v0.24.0'), findsOneWidget);
    expect(find.text('Обновить PoB2Engine'), findsOneWidget);
    expect(find.text('Обновить данные PoB'), findsOneWidget);
    await tester.tap(find.text('Запустить doctor'));
    await tester.pumpAndSettle();
    expect(find.text('Локальная проверка пройдена'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [420.0, 1200.0]) {
    testWidgets('Карточки движка и данных адаптируются к ширине $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const directory = 'C:/PoB/data/PathOfBuildingCommunity/v0.23.1';
      const logLine = 'Подключён PoB2Engine';
      final components =
          ComponentRepository(
              store: InstallationStore(Directory('unused-components-test')),
            )
            ..active = {
              Component.pob: const Installation(
                tag: 'v0.23.1',
                commit: '7d6f530cbdab20389ff8bc6ba97a37ac27f74e41',
                directory: directory,
              ),
            };
      final model = WorkshopCubit(components, WorkbenchClient())
        ..addLog(logLine);
      await tester.pumpWidget(
        MaterialApp(
          theme: Spark.theme(),
          home: Scaffold(body: ComponentsView(model: model)),
        ),
      );
      await tester.pumpAndSettle();
      final pob = tester.getRect(find.byKey(const Key('component-card-pob')));
      final engine = tester.getRect(
        find.byKey(const Key('engine-management-panel')),
      );
      if (width > 760) {
        expect(pob.top, engine.top);
        expect(pob.left, greaterThan(engine.right));
      } else {
        expect(pob.top, greaterThan(engine.bottom));
        expect(pob.left, engine.left);
      }
      final source = find.byKey(const Key('component-source-pob'));
      final journal = find.byKey(const Key('engine-profile-log'));
      expect(tester.widget(source), isA<PanelExpansionTile>());
      expect(tester.widget(journal), isA<PanelExpansionTile>());
      const bridgeHelp =
          'Локальный мост нужен для связи PoB II с окном оригинального Path of Building. Через него PoB2Engine может забрать открытую там сборку, импортировать персонажа или узнать папку сборок из настроек оригинального PoB.';
      final help = find.descendant(
        of: find.byKey(const Key('component-card-pob')),
        matching: find.byTooltip(bridgeHelp),
      );
      expect(help, findsOneWidget);
      expect(find.text(bridgeHelp), findsNothing);
      await tester.ensureVisible(help);
      await tester.tap(help);
      await tester.pumpAndSettle();
      expect(find.text(bridgeHelp), findsOneWidget);
      Tooltip.dismissAllToolTips();
      await tester.pumpAndSettle();
      await _checkExpansion(tester, source, directory);
      await _checkExpansion(tester, journal, logLine);

      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await model.close();
    });
  }
}

Future<void> _checkExpansion(
  WidgetTester tester,
  Finder tile,
  String detail,
) async {
  final content = find.descendant(
    of: tile,
    matching: find.textContaining(detail),
  );
  final heading = find.descendant(of: tile, matching: find.byType(ListTile));
  await tester.ensureVisible(heading);
  await tester.pumpAndSettle();
  expect(content, findsNothing);
  await tester.tap(heading);
  await tester.pumpAndSettle();
  expect(content, findsOneWidget);
  await tester.tap(heading);
  await tester.pumpAndSettle();
  expect(content, findsNothing);
}

class _WindowRepository extends PobWindowRepository {
  _WindowRepository({
    this.directories = const ['C:/PoB'],
    this.canRestart = true,
  });

  final List<String> directories;
  String? installed;
  String? checked;
  String? restarted;
  bool rejectRestart = false;

  @override
  bool get supported => true;

  @override
  final bool canRestart;

  @override
  Future<List<String>> findInstallations(Installation mcp) async => directories;

  @override
  Future<void> installBridge(Installation mcp, String directory) async {
    installed = directory;
  }

  @override
  Future<String?> checkBridge(Installation mcp, String directory) async {
    checked = directory;
    return '$directory/Builds';
  }

  @override
  Future<void> restartAndCheckBridge(Installation mcp, String directory) async {
    if (rejectRestart) throw StateError('PoB ещё открыт');
    restarted = directory;
  }
}

class _Maintenance extends EngineMaintenance {
  const _Maintenance() : super('fixture');

  @override
  Future<Map<String, dynamic>> version() async => {
    'version': 'v0.0.15',
    'protocol_version': 'pob2.v1',
  };

  @override
  Future<EngineUpdates> checkUpdates() async => (
    engine: (latest: 'v0.0.16', status: 'available', message: null),
    pob: (latest: 'v0.24.0', status: 'available', message: null),
  );

  @override
  Future<Map<String, dynamic>> doctor([EngineOptions? options]) async => {
    'status': 'ok',
  };
}
