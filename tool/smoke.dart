import 'dart:convert';
import 'dart:io';

import '../lib/data/engine_components.dart';
import '../lib/data/installation_store.dart';
import '../lib/data/workbench_client.dart';
import '../lib/data/tree_icon_repository.dart';
import '../lib/domain/tree_geometry.dart';
import '../lib/domain/component.dart';

Future<void> main(List<String> arguments) async {
  final repository = EngineComponents(
    store: InstallationStore(InstallationStore.defaultRoot()),
  );
  await repository.load();
  if (arguments case ['--install']) {
    await repository.installPair(
      repository.availableReleases(),
      stderr.writeln,
    );
  } else if (arguments.isNotEmpty) {
    throw const FormatException(
      'Используйте --install для установки данных PoB',
    );
  }
  final client = WorkbenchClient(repository.executable);
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
    final tree =
        await TreeIconRepository(
          root: Directory.fromUri(
            repository.store.root.uri.resolve('tree-cache/'),
          ),
        ).load(
          TreeGeometry.fromJson(
            await client.call('pob_get_tree', {'includeScene': true}),
          ),
          client,
          repository.active[Component.pob]!.commit,
        );
    if (tree.nodes.length < 1000 ||
        tree.original == null ||
        tree.icons.isEmpty ||
        tree.iconError != null) {
      throw StateError(
        'Дерево или оригинальные иконки недоступны: ${tree.iconError}',
      );
    }
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
        'treeNodes': tree.nodes.length,
        'treeTextures': tree.icons.length,
        'treeDrawCommands': tree.original!.commands.length,
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
