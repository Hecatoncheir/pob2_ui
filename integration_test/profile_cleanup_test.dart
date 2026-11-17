import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/component_ownership.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/file_digest.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/profile_use.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/components_view.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

const _commit = '0123456789abcdef0123456789abcdef01234567';
const _button = 'Проверить место в профиле';
const _title = 'Предпросмотр очистки профиля';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Предпросмотр профиля сохраняет имена, размеры и SHA-256', (
    tester,
  ) async {
    final fixture = await _profile();
    final before = await _snapshot(fixture.root);
    await _open(tester, fixture.root);
    await _preview(tester);
    expect(find.text(_title), findsOneWidget);
    expect(
      find.text('Доступно для очистки: ${fixture.bytes} байт'),
      findsOneWidget,
    );
    expect(find.text(path.join('versions', 'pob-obsolete')), findsOneWidget);
    expect(find.text(fixture.tree), findsOneWidget);
    expect(find.text(path.join('versions', 'pob-active')), findsNothing);
    expect(find.text(path.join('versions', 'pob-previous')), findsNothing);
    expect(find.text(path.join('versions', 'pob-unknown')), findsNothing);
    expect(await _snapshot(fixture.root), before);
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
    expect(await _snapshot(fixture.root), before);
    // ignore: avoid_print
    print(
      'Предпросмотр: ${fixture.bytes} байт, проверено записей: ${before.length}',
    );
  });

  testWidgets('Отмена и подтверждение выбранной очистки', (tester) async {
    final fixture = await _profile();
    await _open(tester, fixture.root, withUse: true);
    final before = await _snapshot(fixture.root);
    await _preview(tester);
    await _tap(tester, 'Очистить выбранное');
    await _tap(tester, 'Отмена');
    expect(await _snapshot(fixture.root), before);

    await tester.tap(find.text(path.join('versions', 'pob-obsolete')));
    await _tap(tester, 'Очистить выбранное');
    await _tap(tester, 'Подтвердить очистку');
    await _waitFor(tester, find.text('Удалено: 31 байт'));
    final after = await _snapshot(fixture.root);
    expect(before.keys.toSet().difference(after.keys.toSet()), {
      fixture.tree,
      path.join(fixture.tree, '${'a' * 64}.png'),
    });
    final protected = path.join('versions', 'pob-previous', 'компонент.bin');
    expect(after[protected], before[protected]);
    await _tap(tester, 'Закрыть');
    await _preview(tester);
    expect(
      find.text('Доступно для очистки: ${fixture.bytes - 31} байт'),
      findsOneWidget,
    );
  });

  testWidgets('Очистка ждёт завершения другого процесса с тем же профилем', (
    tester,
  ) async {
    final fixture = await _profile();
    final model = await _open(tester, fixture.root, withUse: true);
    final process = await Process.start('dart', [
      'run',
      'tool/fixtures/hold_profile.dart',
      fixture.root.path,
    ], runInShell: Platform.isWindows);
    final errors = process.stderr.transform(utf8.decoder).join();
    try {
      final ready = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      expect(await ready.first.timeout(const Duration(seconds: 30)), 'ready');
      final before = await _snapshot(fixture.root);
      final entries = await model.components.profileCleanup.preview();
      await expectLater(model.cleanProfile(entries.toSet()), throwsStateError);
      expect(await _snapshot(fixture.root), before);
    } finally {
      await process.stdin.close();
      final code = await process.exitCode.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          process.kill();
          return -1;
        },
      );
      expect(code, 0, reason: await errors);
    }
    final entries = await model.components.profileCleanup.preview();
    expect((await model.cleanProfile(entries.toSet())).bytes, fixture.bytes);
  });
}

Future<({Directory root, String tree, int bytes})> _profile() async {
  final root = await Directory.systemTemp.createTemp('pob2-cleanup-');
  addTearDown(() => root.delete(recursive: true));
  final active = await _pair(root, 'active');
  final previous = await _pair(root, 'previous');
  await InstallationStore(root).save(active, previous);
  final obsolete = await _installation(root, Component.pob, 'obsolete');
  final obsoleteBytes = await _total(Directory(obsolete.directory));
  await _write(root, path.join('versions', 'pob-unknown', 'данные.xml'), 15);
  final tree = path.join('tree-cache', '$_commit-$_commit', '0_5');
  await _write(root, path.join(tree, '${'a' * 64}.png'), 31);
  await _write(
    root,
    path.join('component-downloads', 'b' * 64, 'pob.zip.part'),
    16,
  );
  await _write(root, path.join('builds', 'ведьма.xml'), 19);
  return (root: root, tree: tree, bytes: obsoleteBytes + 31);
}

Future<Installations> _pair(Directory root, String name) async => {
  for (final component in Component.values)
    component: await _installation(root, component, name),
};

Future<Installation> _installation(
  Directory root,
  Component component,
  String name,
) async {
  final relative = path.join('versions', '${component.name}-$name');
  final installation = Installation(
    tag: 'v0.6.0',
    commit: _commit,
    directory: path.join(root.path, relative),
  );
  await _write(root, path.join(relative, 'компонент.bin'), 17);
  await recordComponent(
    Directory(installation.directory),
    component,
    installation,
  );
  return installation;
}

Future<void> _write(Directory root, String relative, int bytes) async {
  final file = File(path.join(root.path, relative));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(List.filled(bytes, 120));
}

Future<int> _total(Directory root) async {
  var bytes = 0;
  await for (final item in root.list(recursive: true)) {
    if (item is File) bytes += await item.length();
  }
  return bytes;
}

Future<Map<String, (int, String, DateTime)>> _snapshot(Directory root) async {
  final entries = <String, (int, String, DateTime)>{};
  await for (final item in root.list(recursive: true, followLinks: false)) {
    final name = path.relative(item.path, from: root.path);
    final stat = await item.stat();
    entries[name] = (
      stat.size,
      item is File ? await fileSha256(item) : '',
      stat.modified,
    );
  }
  return entries;
}

Future<WorkshopCubit> _open(
  WidgetTester tester,
  Directory root, {
  bool withUse = false,
}) async {
  final use = withUse ? await ProfileUse.open(root) : null;
  if (withUse) expect(use, isNotNull);
  final repository = ComponentRepository(
    store: InstallationStore(root),
    profileUse: use,
  );
  await repository.load();
  final model = WorkshopCubit(repository, McpClient());
  addTearDown(model.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: Spark.theme(),
      home: Scaffold(body: ComponentsView(model: model)),
    ),
  );
  await tester.pumpAndSettle();
  return model;
}

Future<void> _preview(WidgetTester tester) async {
  final button = find.text(_button);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  await _waitFor(tester, find.textContaining('Доступно для очистки:'));
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _waitFor(WidgetTester tester, Finder content) async {
  for (var attempt = 0; attempt < 200; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (content.evaluate().isNotEmpty) return;
  }
  fail('Не появился ожидаемый результат: $content');
}
