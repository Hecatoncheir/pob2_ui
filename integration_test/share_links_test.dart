import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/pob_share_links.dart';
import 'package:pob2_ui/installer_check.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

const _fixturesPath = 'integration_test/fixtures';
const _witch = 'witch_fireball';
const _fixtures = [_witch, 'warrior_rolling_slam', 'sorceress_spark'];
const _live = bool.fromEnvironment('POB2_LIVE_SHARE_LINK');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Импорт Ведьмы с pobb.in и расчёт на оригинальном Lua', (
    tester,
  ) async {
    final root = await _testProfile();
    final model = await _open(tester, root);
    final baseline = await _importXml(model, _witch);
    final link = await File('$_fixturesPath/$_witch.poblink').readAsString();
    final imported = await _importLink(tester, model, link);
    expect(imported, baseline);
    _expectWitch(imported);
    // ignore: avoid_print
    print(
      'pobb.in: ${imported['source']}, TotalDPS ${model.state.report!.stats['TotalDPS']}',
    );
  }, skip: !_live);

  testWidgets('Три сборки по ссылкам и повторное открытие без HTTP', (
    tester,
  ) async {
    final root = await _testProfile();
    final model = await _open(tester, root, shareLinks: await _localLinks());
    final snapshots = <String, Map<String, Object?>>{};
    for (final fixture in _fixtures) {
      final baseline = await _importXml(model, fixture);
      final imported = await _importLink(tester, model, _link(fixture));
      expect(imported, baseline);
      snapshots[model.state.library.activeId!] = baseline;
    }
    _expectWitch(snapshots.values.first);
    await _verifyReopen(tester, model, root, snapshots);
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets('Ошибки импорта по ссылке сохраняют сборку и историю', (
    tester,
  ) async {
    final root = await _testProfile();
    final model = await _open(tester, root, shareLinks: await _localLinks());
    await _importXml(model, _witch);
    await _rejectLinks(tester, model);
    _expectWitch(await _importLink(tester, model, _link(_witch)));
  });
}

String _link(String id) => 'https://pobb.in/$id';

Future<PobShareLinks> _localLinks() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  final codes = {
    for (final fixture in _fixtures)
      '/pob/$fixture': await File('$_fixturesPath/$fixture.pobcode')
          .readAsString(),
    '/pob/damaged': '***',
    '/pob/poe1': base64Url.encode(
      zlib.encode(utf8.encode('<PathOfBuilding><Build/></PathOfBuilding>')),
    ),
  };
  server.listen((request) async {
    final path = request.uri.path;
    if (path == '/pob/slow') return;
    final code = codes[path];
    if (code == null) {
      request.response.statusCode = HttpStatus.notFound;
    } else {
      request.response.write(code);
    }
    await request.response.close();
  });
  return PobShareLinks(
    origin: Uri.http('127.0.0.1:${server.port}'),
    timeout: const Duration(seconds: 3),
  );
}

Future<void> _verifyReopen(
  WidgetTester tester,
  WorkshopCubit current,
  Directory root,
  Map<String, Map<String, Object?>> snapshots,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await current.close();
  final previousHttp = HttpOverrides.current;
  HttpOverrides.global = OfflineInstallerCheck();
  addTearDown(() => HttpOverrides.global = previousHttp);
  final reopened = await _open(tester, root);
  expect(await _snapshot(reopened), snapshots.values.last);
  for (final MapEntry(:key, :value) in snapshots.entries) {
    await reopened.openBuild(key);
    expect(await _snapshot(reopened), value);
  }
}

Future<void> _rejectLinks(WidgetTester tester, WorkshopCubit model) async {
  expect((await model.setCondition('enemyLevel', 68)).committed, isTrue);
  expect((await model.setCondition('enemyLevel', 69)).committed, isTrue);
  await model.undo();
  expect(model.state.history, (undo: 1, redo: 1));
  final id = model.state.library.activeId!;
  const notes = 'Заметки для проверки импорта по ссылке';
  await model.buildNotes.readNotes(id);
  await model.buildNotes.saveNotes(id, notes);
  final xml = await model.library.read(id);
  final entries = model.state.library.entries;
  const failures = {
    'missing': 'Сборка по ссылке не найдена.',
    'slow': 'Сайт pobb.in не ответил вовремя.',
    'damaged': 'Некорректный или обрезанный код PoB.',
    'poe1': 'Ожидался XML сборки Path of Building для PoE 2.',
  };
  for (final MapEntry(:key, :value) in failures.entries) {
    await _submitLink(tester, model, _link(key));
    expect(model.state.error, contains(value));
    expect(model.state.library.activeId, id);
    expect(model.state.library.entries, entries);
    expect(model.state.history, (undo: 1, redo: 1));
    expect(await model.library.read(id), xml);
    expect(await model.buildNotes.readNotes(id), notes);
    expect(model.state.report!.config['enemyLevel'], 68);
  }
}

Future<Directory> _testProfile() async {
  expect(Platform.environment['POB2_UI_HOME'], isNotNull);
  final prepared = InstallationStore.defaultRoot();
  final root = await prepared.createTemp('share-links-');
  addTearDown(() => root.delete(recursive: true));
  final builds = await Directory.fromUri(root.uri.resolve('builds/')).create();
  await File.fromUri(prepared.uri.resolve('components.json'))
      .copy(File.fromUri(root.uri.resolve('components.json')).path);
  await PobBuildLibrary(root).configure(builds.path);
  return root;
}

Future<WorkshopCubit> _open(
  WidgetTester tester,
  Directory root, {
  PobShareLinks? shareLinks,
}) async {
  final model = WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    McpClient(),
    library: PobBuildLibrary(root),
    shareLinks: shareLinks,
  );
  addTearDown(() async {
    if (!model.isClosed) await model.close();
  });
  await model.initialize();
  expect(model.luaReady, isTrue, reason: model.state.error);
  await tester.pumpWidget(PobApp(model: model));
  await tester.pumpAndSettle();
  return model;
}

Future<Map<String, Object?>> _importXml(
  WorkshopCubit model,
  String fixture,
) async {
  await model.importXml(
    await File('$_fixturesPath/$fixture.xml').readAsString(),
  );
  return _snapshot(model);
}

Future<Map<String, Object?>> _importLink(
  WidgetTester tester,
  WorkshopCubit model,
  String link,
) async {
  final previous = model.state.library.activeId;
  final length = model.state.library.entries.length;
  await _submitLink(tester, model, link);
  expect(model.state.library.activeId, isNot(previous));
  expect(model.state.library.entries, hasLength(length + 1));
  return _snapshot(model);
}

Future<void> _submitLink(
  WidgetTester tester,
  WorkshopCubit model,
  String link,
) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Ещё'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Импортировать по ссылке'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('pob-link-input')), link.trim());
  final operation = model.stream
      .where((state) => state.busy)
      .first
      .then((_) => model.stream.firstWhere((state) => !state.busy));
  await tester.tap(find.byKey(const Key('pob-link-submit')));
  await tester.pumpAndSettle();
  await operation.timeout(const Duration(seconds: 90));
  await tester.pumpAndSettle();
}

Future<Map<String, Object?>> _snapshot(WorkshopCubit model) async {
  expect(model.state.error, isNull);
  final report = model.state.report!;
  return {
    'source': report.raw['source'],
    'class': report.characterClass,
    'level': report.level,
    'skill': report.mainSkill,
    'stats': report.stats,
    'groups': report.groups,
    'config': report.config,
    'items': report.items,
    'nodes': PobBuildDocument((await model.exportXml())!).allocatedNodes,
  };
}

void _expectWitch(Map<String, Object?> report) {
  expect(report['source'], 'original-lua');
  final stats = report['stats'] as Map<String, Object?>;
  expect(stats['TotalDPS'], closeTo(12.817708, 0.00001));
}
