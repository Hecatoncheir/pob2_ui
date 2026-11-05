import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/tree_icon_repository.dart';
import 'package:pob2_ui/domain/tree_geometry.dart';

class IconEngine extends McpClient {
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

void main() {
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
