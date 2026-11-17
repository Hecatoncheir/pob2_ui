import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/pob_share_code.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/data/xml_file_service.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/installer_check.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import '../test/support/file_fakes.dart';

const _fixtures = ['witch_fireball', 'warrior_rolling_slam', 'sorceress_spark'];
const _paste = 'Вставить код PoB';
const _copy = 'Скопировать код PoB';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Коды PoB, расчёт Lua, сохранение и повторное открытие без сети',
    (tester) async {
      expect(Platform.environment['POB2_UI_HOME'], isNotNull);
      final initialClipboard = await Clipboard.getData(Clipboard.kTextPlain);
      addTearDown(
        () => Clipboard.setData(
          initialClipboard ?? const ClipboardData(text: ''),
        ),
      );
      final initialHttp = HttpOverrides.current;
      HttpOverrides.global = OfflineInstallerCheck();
      addTearDown(() => HttpOverrides.global = initialHttp);

      final profile = InstallationStore.defaultRoot();
      final root = await profile.createTemp('share-codes-');
      final builds = await Directory.fromUri(root.uri.resolve('builds/'))
          .create();
      addTearDown(() => root.delete(recursive: true));
      await File.fromUri(profile.uri.resolve('components.json'))
          .copy(File.fromUri(root.uri.resolve('components.json')).path);
      await PobBuildLibrary(root).configure(builds.path);

      final dialogs = SelectPaths();
      final initial = await _open(tester, root, dialogs);
      final checks =
          <
            ({
              String xml,
              String code,
              String path,
              Map<String, Object?> report,
            })
          >[];
      for (final fixture in _fixtures) {
        checks.add(await _exchange(tester, initial, dialogs, fixture));
      }
      await _rejectInvalid(tester, initial);

      final originals = await _verifyInOriginalPob(
        initial.components.active,
        checks,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await initial.close();

      final reopened = await _open(tester, root, dialogs);
      expect(await _report(reopened), checks.last.report);
      for (final (index, check) in checks.indexed) {
        dialogs.openPath = check.path;
        await reopened.openXmlFile();
        expect(await _report(reopened), check.report);
        await reopened.importXml(originals[index]);
        expect(await _report(reopened), check.report);
      }
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<WorkshopCubit> _open(
  WidgetTester tester,
  Directory root,
  SelectPaths dialogs,
) async {
  final model = WorkshopCubit(
    ComponentRepository(store: InstallationStore(root)),
    McpClient(),
    library: PobBuildLibrary(root),
    files: XmlFileService(dialogs: dialogs),
  );
  addTearDown(() async {
    if (!model.isClosed) await model.close();
  });
  await model.initialize();
  expect(model.state.error, isNull);
  expect(model.luaReady, isTrue);
  await tester.pumpWidget(PobApp(model: model));
  await tester.pumpAndSettle();
  return model;
}

Future<({String xml, String code, String path, Map<String, Object?> report})>
_exchange(
  WidgetTester tester,
  WorkshopCubit model,
  SelectPaths dialogs,
  String fixture,
) async {
  final base = 'integration_test/fixtures/$fixture';
  final xml = await File('$base.xml').readAsString();
  final code = (await File('$base.pobcode').readAsString()).trim();
  await model.importXml(xml);
  await tester.pumpAndSettle();
  final baseline = await _report(model);
  final previous = model.state.library.activeId;
  final entries = model.state.library.entries.length;
  await Clipboard.setData(ClipboardData(text: code));
  await _menu(tester, _paste);
  await _wait(
    tester,
    () => !model.state.busy && model.state.library.activeId != previous,
  );

  expect(model.state.library.entries, hasLength(entries + 1));
  expect(await _report(model), baseline);
  if (fixture == _fixtures.first) {
    expect(model.state.report!.stats['TotalDPS'], closeTo(12.817708, 0.00001));
  }

  await _menu(tester, _copy);
  await _wait(
    tester,
    () => !model.state.busy && model.state.status == 'Код PoB скопирован',
  );
  final exported = (await Clipboard.getData(Clipboard.kTextPlain))!.text!;
  expect(await decodePobShareCode(exported), startsWith('<?xml'));
  final path = File.fromUri(
    model.components.store.root.uri.resolve('$fixture-export.xml'),
  ).path;
  dialogs.savePath = path;
  await model.saveXmlFile();
  expect(model.state.error, isNull);
  expect(await File(path).exists(), isTrue);
  return (xml: xml, code: exported, path: path, report: baseline);
}

Future<Map<String, Object?>> _report(WorkshopCubit model) async {
  expect(model.state.error, isNull);
  final report = model.state.report!;
  final xml = (await model.exportXml())!;
  return {
    'source': report.raw['source'],
    'class': report.characterClass,
    'level': report.level,
    'skill': report.mainSkill,
    'stats': report.stats,
    'groups': report.groups,
    'config': report.config,
    'items': report.items,
    'nodes': PobBuildDocument(xml).allocatedNodes,
  };
}

Future<void> _rejectInvalid(WidgetTester tester, WorkshopCubit model) async {
  expect((await model.setCondition('enemyLevel', 68)).committed, isTrue);
  expect((await model.setCondition('enemyLevel', 69)).committed, isTrue);
  await model.undo();
  expect(model.state.history, (undo: 1, redo: 1));
  final history = model.state.history;
  final id = model.state.library.activeId!;
  final notes = model.buildNotes;
  await notes.readNotes(id);
  await notes.saveNotes(id, 'Заметки для проверки импорта');
  final before = await model.library.read(id);
  final valid = (await File(
    'integration_test/fixtures/witch_fireball.pobcode',
  ).readAsString()).trim();
  final incompatible = base64Url.encode(
    zlib.encode(utf8.encode('<PathOfBuilding><Build/></PathOfBuilding>')),
  );
  for (final code in [
    '***',
    valid.substring(0, valid.length - 8),
    incompatible,
  ]) {
    await Clipboard.setData(ClipboardData(text: code));
    await tester.pumpAndSettle();
    final operation = model.stream.firstWhere((state) => state.busy);
    await _menu(tester, _paste);
    await operation.timeout(const Duration(seconds: 10));
    await _wait(tester, () => !model.state.busy && model.state.error != null);
    expect(model.state.library.activeId, id);
    expect(model.state.history, history);
    expect(await model.library.read(id), before);
    expect(await notes.readNotes(id), 'Заметки для проверки импорта');
    expect(model.state.report!.config['enemyLevel'], 68);
  }
  await model.undo();
}

Future<void> _menu(WidgetTester tester, String action) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Ещё'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action));
}

Future<void> _wait(WidgetTester tester, bool Function() complete) async {
  for (var attempt = 0; attempt < 900; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (complete()) return;
  }
  fail('Интерфейс не завершил обмен кодом PoB');
}

Future<List<String>> _verifyInOriginalPob(
  Installations pair,
  List<({String xml, String code, String path, Map<String, Object?> report})>
  checks,
) async {
  final mcp = pair[Component.mcp]!;
  final runner = File.fromUri(
    Directory(mcp.directory).uri.resolve('pob_poe2_mcp/runner.py'),
  );
  final process = await Process.start(
    await ProcessService().runtimePython(mcp),
    [
      '-X',
      'utf8',
      runner.path,
      '--pob-dir',
      pair[Component.pob]!.directory,
      '--script',
      File('tool/fixtures/pob_share_codes.lua').absolute.path,
    ],
  );
  final output = process.stdout.transform(utf8.decoder).join();
  final errors = process.stderr.transform(utf8.decoder).join();
  process.stdin.add(
    utf8.encode(
      jsonEncode([
        for (final check in checks) {'xml': check.xml, 'code': check.code},
      ]),
    ),
  );
  await process.stdin.close();
  try {
    expect(
      await process.exitCode.timeout(const Duration(minutes: 2)),
      0,
      reason: await errors,
    );
    return (jsonDecode(await output) as List<Object?>).cast<String>();
  } finally {
    process.kill();
  }
}
