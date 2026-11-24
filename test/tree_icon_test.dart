import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/data/tree_icon_repository.dart';
import 'package:pob2_ui/domain/tree_geometry.dart';
import 'package:pob2_ui/domain/original_tree_scene.dart';

class IconEngine extends WorkbenchClient {
  IconEngine() {
    tools = {'pob_tree_icons'};
  }
  final requests = <List<String>>[];
  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    final keys = List<String>.from(arguments['icons'] as List);
    requests.add(keys);
    return {
      'icons': [
        for (final key in keys)
          {
            'key': key,
            'png': base64Encode([1, 2, 3]),
          },
      ],
    };
  }
}

TreeGeometry geometry() => TreeGeometry.fromJson({
  'version': '0_5',
  'nodes': [
    for (final icon in ['', 'real-icon', 'real-icon'])
      {
        'id': icon.isEmpty ? 1 : 2,
        'x': 0,
        'y': 0,
        'name': 'Узел',
        'type': 'Normal',
        'allocated': false,
        'icon': icon,
      },
  ],
  'edges': [],
});

Map<String, Object> textureCommand(String file, int index, int x) => {
  'texture': '$file/$index',
  'engineTexture': {'file': file, 'index': index, 'targetSize': 40},
  'positions': [x, 0, x + 10, 0, x + 10, 10, x, 10],
  'uv': [0, 0, 1, 0, 1, 1, 0, 1],
  'color': [1, 1, 1, 1],
  'blend': 'ALPHA',
  'clamp': true,
};

TreeGeometry nativeGeometry() => geometry().withScene(
  OriginalTreeScene.fromJson({
    'scale': 1,
    'offsetX': 0,
    'offsetY': 0,
    'assetId': 'assets',
    'commands': [
      textureCommand('first', 1, 90),
      textureCommand('visibleAtlas', 1, 90),
      textureCommand('visibleAtlas', 2, 0),
    ],
  }),
);

void main() {
  test(
    'Видимый слой приходит первым в пакете, кеш повторно не запрашивается',
    () async {
      final requests = <List<TreeTextureReference>>[];
      final frames = <TreeGeometry>[];
      final png = base64Decode('iVBORw0KGgo=');
      final repository = TreeIconRepository(
        readShared: (_) => throw StateError('Ожидался пакет'),
        readSharedBatch: (layers) {
          requests.add(layers);
          return Stream<Uint8List>.fromIterable(layers.map((_) => png));
        },
      );
      final tree = nativeGeometry();
      final result = await repository.load(
        tree,
        IconEngine(),
        'component',
        viewport: const Rectangle<double>(0, 0, 15, 15),
        onVisible: frames.add,
      );
      expect(
        requests.map(
          (group) => group.map((layer) => (layer.file, layer.index)),
        ),
        [
          [('visibleAtlas', 2), ('visibleAtlas', 1)],
          [('first', 1)],
        ],
      );
      expect(frames.single.partialArtwork, isTrue);
      expect(frames.single.icons.keys, ['visibleAtlas/2']);
      expect(result.icons, hasLength(3));
      expect(result.partialArtwork, isFalse);
      await repository.load(tree, IconEngine(), 'component');
      expect(requests, hasLength(2));
    },
  );

  test('Одиночные запросы работают с прежним сервером', () async {
    final png = base64Decode('iVBORw0KGgo=');
    final calls = <TreeTextureReference>[];
    final repository = TreeIconRepository(
      readSharedBatch: (_) => null,
      readShared: (reference) async {
        calls.add(reference);
        return png;
      },
    );
    final result = await repository.load(
      nativeGeometry(),
      IconEngine(),
      'component',
    );
    expect(result.iconError, isNull);
    expect(result.icons, hasLength(3));
    expect(calls, hasLength(3));
  });
  test(
    'Пустая иконка не запрашивается; повторения и пересчёты используют кеш',
    () async {
      final engine = IconEngine(), repository = TreeIconRepository();
      final first = await repository.load(geometry(), engine, 'component-a');
      final second = await repository.load(geometry(), engine, 'component-a');
      expect(first.iconError, isNull);
      expect(second.icons.keys, ['real-icon']);
      expect(engine.requests, [
        ['real-icon'],
      ]);
      await repository.load(geometry(), engine, 'component-b');
      expect(engine.requests, hasLength(2));
    },
  );
  test('Старый MCP показывает точную причину отсутствия иконок', () async {
    final engine = IconEngine()..tools = {};
    final tree = await TreeIconRepository().load(geometry(), engine, 'old');
    expect(tree.icons, isEmpty);
    expect(tree.iconError, contains('0.6.0'));
    expect(engine.requests, isEmpty);
  });
  test('Пустое дерево отклоняется, поиск понимает имя и идентификатор', () {
    expect(
      () => TreeGeometry.fromJson({'nodes': [], 'edges': []}),
      throwsFormatException,
    );
    expect(geometry().nodes.first.matches('1'), isTrue);
    expect(geometry().nodes.first.matches('уЗел'), isTrue);
  });
}
