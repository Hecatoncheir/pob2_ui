import 'dart:convert';
import 'dart:io';

import '../lib/data/component_repository.dart';
import '../lib/data/installation_store.dart';
import '../lib/data/mcp_client.dart';
import '../lib/domain/component.dart';

Future<void> main(List<String> arguments) async {
  final repository = ComponentRepository(
    store: InstallationStore(InstallationStore.defaultRoot()),
  );
  await repository.load();
  if (arguments.contains('--install')) {
    for (final component in Component.values) {
      final release = await repository.github.latest(component);
      if (repository.active[component]?.tag == release.tag) continue;
      await repository.install(component, release, stderr.writeln);
    }
  }
  final client = McpClient();
  try {
    final health = await repository.doctor();
    await client.connect(repository.active);
    final classes = await client.call('pob_catalog', {'kind': 'classes'});
    final entries = classes['entries'] as List<dynamic>;
    final selected = entries.first as Map<String, dynamic>;
    await client.call('pob_create_build', {
      'name': 'Проверка pob2_ui',
      'classId': selected['id'],
      'level': 90,
    });
    final before = await client.call('pob_check_build');
    final report = before['report'] as Map<String, dynamic>;
    final stats = report['stats'] as Map<String, dynamic>;
    if (report['source'] != 'original-lua' || (stats['Life'] as num) <= 0) {
      throw StateError('Не получены реальные показатели Lua');
    }
    final exported = await client.call('pob_export_xml');
    await client.call('pob_import_xml', {'xml': exported['xml']});
    final restored = await client.call('pob_check_build');
    final restoredReport = restored['report'] as Map<String, dynamic>;
    final restoredStats = restoredReport['stats'] as Map<String, dynamic>;
    if (restoredStats['Life'] != stats['Life']) {
      throw StateError('Показатели изменились после экспорта/импорта');
    }
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'ok': true,
        'doctor': health,
        'class': selected,
        'life': stats['Life'],
        'source': report['source'],
        'xmlRoundTrip': true,
        'versions': {
          for (final entry in repository.active.entries)
            entry.key.name: entry.value.toJson(),
        },
      }),
    );
  } finally {
    await client.close();
  }
}
