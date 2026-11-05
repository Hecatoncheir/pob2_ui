import 'dart:typed_data';

import 'build_report.dart';
import 'original_tree_scene.dart';

class TreeNode {
  const TreeNode({
    required this.id,
    required this.x,
    required this.y,
    required this.name,
    required this.kind,
    required this.allocated,
    this.icon,
    this.drawSize = 37,
  });
  factory TreeNode.fromJson(JsonMap json) => switch (json) {
    {
      'id': final int id,
      'x': final num x,
      'y': final num y,
      'name': final String name,
      'type': final String kind,
      'allocated': final bool allocated,
    }
        when x.isFinite && y.isFinite =>
      TreeNode(
        id: id,
        x: x.toDouble(),
        y: y.toDouble(),
        name: name,
        kind: kind,
        allocated: allocated,
        icon: json['icon'] as String?,
        drawSize: (json['drawSize'] as num?)?.toDouble() ?? 37,
      ),
    _ => throw const FormatException('Некорректный узел дерева Lua'),
  };
  final int id;
  final double x, y;
  final String name, kind;
  final bool allocated;
  final String? icon;
  final double drawSize;
  bool matches(String query) =>
      name.toLowerCase().contains(query.toLowerCase()) || '$id' == query.trim();
}

class TreeGeometry {
  TreeGeometry.fromJson(JsonMap json)
    : nodes = List.unmodifiable(jsonRows(json['nodes']).map(TreeNode.fromJson)),
      edges = List.unmodifiable((json['edges'] as List<dynamic>).map(_edge)),
      version = '${json['version']}',
      original = json['scene'] is JsonMap
          ? OriginalTreeScene.fromJson(json['scene'] as JsonMap)
          : null,
      icons = const {},
      iconError = null {
    if (nodes.isEmpty) throw const FormatException('Lua вернул пустое дерево');
  }
  TreeGeometry._(
    this.nodes,
    this.edges,
    this.version,
    this.icons,
    this.iconError,
    this.original,
  );
  TreeGeometry withIcons(Map<String, Uint8List> values, String? error) =>
      TreeGeometry._(
        nodes,
        edges,
        version,
        Map.unmodifiable(values),
        error,
        original,
      );
  final List<TreeNode> nodes;
  TreeGeometry withScene(OriginalTreeScene scene) =>
      TreeGeometry._(nodes, edges, version, const {}, null, scene);
  final List<(int, int)> edges;
  final String version;
  final Map<String, Uint8List> icons;
  final String? iconError;
  final OriginalTreeScene? original;
  static (int, int) _edge(dynamic value) => switch (value) {
    [final int a, final int b] => (a, b),
    _ => throw const FormatException('Некорректная связь дерева Lua'),
  };
}
