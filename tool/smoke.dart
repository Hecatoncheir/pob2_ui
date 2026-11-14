import 'dart:convert';
import 'dart:io';

import '../lib/data/component_repository.dart';
import '../lib/data/installation_store.dart';
import '../lib/data/mcp_client.dart';
import '../lib/data/tree_icon_repository.dart';
import '../lib/domain/tree_geometry.dart';
import '../lib/domain/component.dart';

Future<void> main(List<String> arguments) async {
  final repository = ComponentRepository(
    store: InstallationStore(InstallationStore.defaultRoot()),
  );
  await repository.load();
  if (arguments case ['--install', '--lock', final path]) {
    await repository.installPair(await _lockedReleases(path), stderr.writeln);
  } else if (arguments case ['--install']) {
    final releases = {
      for (final component in Component.values)
        component: await repository.github.latest(component),
    };
    await repository.installPair(releases, stderr.writeln);
  } else if (arguments.isNotEmpty) {
    throw const FormatException('Используйте --install [--lock <файл>]');
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
          Component.values
              .map((key) => repository.active[key]!.commit)
              .join('-'),
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

Future<Map<Component, Release>> _lockedReleases(String path) async {
  final data = jsonDecode(await File(path).readAsString());
  if (data case {'pob': final Object? pob, 'mcp': final Object? mcp}) {
    return {
      Component.pob: _lockedRelease(Component.pob, pob),
      Component.mcp: _lockedRelease(Component.mcp, mcp),
    };
  }
  throw const FormatException('В манифесте нужны ревизии PoB и MCP');
}

Release _lockedRelease(Component component, Object? entry) {
  if (entry case {'tag': final String tag, 'commit': final String commit}
      when RegExp(r'^v\d+\.\d+\.\d+$').hasMatch(tag) &&
          RegExp(r'^[a-f0-9]{40}$').hasMatch(commit)) {
    return Release(
      tag,
      '${component.url}/releases/tag/$tag',
      DateTime.utc(1970),
      expectedCommit: commit,
    );
  }
  throw FormatException('Некорректный тег или Git SHA для ${component.title}');
}
