import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/engine_session_client.dart';
import 'package:pob2_ui/domain/engine_session.dart';

import 'support/engine_mcp_peer.dart';
import 'support/temporary_directory.dart';

void main() {
  final executable = Platform.environment['POB2_ENGINE_TEST_EXECUTABLE'];
  test(
    'Настоящие CLI/MCP доставляют правки Dart-клиенту, повтор и перезапуск не теряют события',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'pob2-engine-process-',
      );
      final options = EngineOptions(
        executable: executable!,
        profile: 'test',
        runtimeDirectory: root.uri.resolve('runtime').toFilePath(),
        dataDirectory: root.uri.resolve('data').toFilePath(),
      );
      final args = [
        '--profile',
        options.profile,
        '--runtime-dir',
        options.runtimeDirectory,
        '--data-dir',
        options.dataDirectory,
      ];
      addTearDown(() async {
        await Process.run(executable, ['shutdown', ...args]);
        await _waitForShutdown(options);
        await removeTemporaryDirectory(root);
      });
      var connection = await EngineSessionClient.open(options);
      addTearDown(() => connection.close());
      await connection.create('main', 'Начальная', 'create');
      final xml = await File('integration_test/fixtures/witch_fireball.xml')
          .readAsString();
      final imported = await connection.create(
        'workshop',
        'Ведьма',
        'create-with-xml',
        xml: xml,
      );
      expect(imported.revision, 1);
      expect(imported.buildName, 'Ведьма');
      expect(imported.build?.xml, contains('<PathOfBuilding2>'));
      expect(
        (await connection.snapshot('workshop')).build?.xml,
        imported.build?.xml,
      );
      var events = StreamIterator(connection.watch('main', 1));
      addTearDown(() => events.cancel());
      await _cli(executable, [
        'session',
        'rename',
        '--session',
        'main',
        '--name',
        'CLI',
        '--revision',
        '1',
        '--request-id',
        'cli',
        ...args,
      ]);
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.buildName, 'CLI');
      final process = await Process.start(executable, [
        'mcp',
        '--attach',
        'main',
        ...args,
      ]);
      final mcp = EngineMcpPeer(process);
      addTearDown(mcp.close);
      await mcp.initialize();
      final command = {
        'name': 'rename_build',
        'arguments': {
          'build_name': 'MCP',
          'expected_revision': 2,
          'request_id': 'mcp',
        },
      };
      for (var i = 0; i < 2; i++) {
        expect(
          (await mcp.request('tools/call', command))['isError'],
          isNot(true),
        );
      }
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.revision, 3);
      expect(events.current.previousName, 'CLI');
      await events.cancel();
      await connection.close();
      await _cli(executable, [
        'session',
        'rename',
        '--session',
        'main',
        '--name',
        'Пропущенная',
        '--revision',
        '3',
        '--request-id',
        'missed',
        ...args,
      ]);
      // Новый helper и новая аренда читают историю с последней применённой ревизии.
      connection = await EngineSessionClient.open(options);
      events = StreamIterator(connection.watch('main', 3));
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.buildName, 'Пропущенная');
      expect(events.current.snapshot.revision, 4);
      await events.cancel();
      await connection.close();
      await mcp.close();
      await _waitForShutdown(options);
      connection = await EngineSessionClient.open(options);
      events = StreamIterator(connection.watch('main', 3));
      expect(await events.moveNext().timeout(const Duration(seconds: 5)), true);
      expect(events.current.snapshot.buildName, 'Пропущенная');
      expect(events.current.snapshot.revision, 4);
      await events.cancel();
      await connection.close();
    },
    skip: executable == null
        ? 'Нужен POB2_ENGINE_TEST_EXECUTABLE; CI запускает этот сценарий на Linux'
        : false,
    timeout: const Timeout(Duration(seconds: 35)),
  );
}

Future<void> _cli(String executable, List<String> args) async {
  final result = await Process.run(executable, args);
  expect(result.exitCode, 0, reason: '${result.stderr}');
}

Future<void> _waitForShutdown(EngineOptions options) async {
  final record = File.fromUri(
    Directory(options.runtimeDirectory).uri
        .resolve('pob2-engine/test/connection.json'),
  );
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (await record.exists()) {
    if (DateTime.now().isAfter(deadline))
      throw StateError('Сервер не завершился после отключения клиентов');
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}
