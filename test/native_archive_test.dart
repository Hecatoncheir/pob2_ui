import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/native_runtime_installer.dart';
import 'package:pob2_ui/data/process_service.dart';

void main() {
  for (final scenario in [
    'valid',
    'traversal',
    'symlink',
    'duplicate',
    'missing',
  ]) {
    test('Архив Lua runtime: $scenario', () async {
      final root = await Directory.systemTemp.createTemp('pob2-native-test-');
      addTearDown(() => root.delete(recursive: true));
      await Directory.fromUri(root.uri.resolve('pob_poe2_mcp/')).create();
      final python = await ProcessService().python();
      final package = File.fromUri(root.uri.resolve('runtime.zip'));
      final entries = <Map<String, dynamic>>[
        {'name': 'native/libluajit-5.1.so.2'},
        if (scenario != 'missing') {'name': 'native/lua-utf8.so'},
        if (scenario == 'traversal') {'name': '../outside'},
        if (scenario == 'symlink')
          {'name': 'native/sources.json', 'link': true},
        if (scenario == 'duplicate') {'name': 'native/lua-utf8.so'},
      ];
      final created = await Process.run(python, [
        '-c',
        r'''
import json, sys, zipfile
with zipfile.ZipFile(sys.argv[1], 'w') as archive:
    for entry in json.loads(sys.argv[2]):
        item = zipfile.ZipInfo(entry['name'])
        if entry.get('link'):
            item.create_system = 3
            item.external_attr = 0o120777 << 16
        archive.writestr(item, b'library')
''',
        package.path,
        jsonEncode(entries),
      ]);
      expect(created.exitCode, 0, reason: '${created.stderr}');
      final result = await Process.run(python, [
        '-c',
        NativeRuntimeInstaller.extractionScript,
        package.path,
        root.path,
      ]);
      expect(
        result.exitCode,
        scenario == 'valid' ? 0 : isNot(0),
        reason: '${result.stderr}',
      );
      final native = Directory.fromUri(
        root.uri.resolve('pob_poe2_mcp/native/'),
      );
      expect(await native.exists(), scenario == 'valid');
      expect(await File.fromUri(root.uri.resolve('outside')).exists(), isFalse);
    });
  }
}
