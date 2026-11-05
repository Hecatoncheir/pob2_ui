import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/tree_geometry.dart';
import 'core/spark_theme.dart';

class TreeScene {
  TreeScene(this.tree) {
    final xs = tree.nodes.map((node) => node.x);
    final ys = tree.nodes.map((node) => node.y);
    final left = xs.reduce(math.min), top = ys.reduce(math.min);
    if (tree.original case final original?) {
      scale = original.scale;
      for (final node in tree.nodes) {
        points[node.id] = Offset(
          original.offsetX + node.x * scale,
          original.offsetY + node.y * scale,
        );
        nodes[node.id] = node;
      }
      return;
    }
    scale =
        1660 /
        math.max(
          1,
          math.max(xs.reduce(math.max) - left, ys.reduce(math.max) - top),
        );
    for (final node in tree.nodes) {
      points[node.id] = Offset(
        70 + (node.x - left) * scale,
        70 + (node.y - top) * scale,
      );
      nodes[node.id] = node;
    }
  }
  final TreeGeometry tree;
  late final double scale;
  final points = <int, Offset>{};
  final nodes = <int, TreeNode>{};
}

class TreePainter extends CustomPainter {
  TreePainter(
    this.scene,
    this.selected,
    this.hovered,
    this.query,
    this.icons,
    this.transform,
    this.viewport,
    this.artwork,
    this.hoverArtwork, {
    this.matches,
  }) : super(repaint: transform);
  final TreeScene scene;
  final int? selected;
  final int? hovered;
  final String query;
  final Map<String, ui.Image> icons;
  final TransformationController transform;
  final Size viewport;
  final ui.Picture? artwork;
  final ui.Picture? hoverArtwork;
  final Set<int>? matches;
  late double zoom;
  late Rect visible;
  @override
  void paint(Canvas canvas, Size size) {
    zoom = transform.value.getMaxScaleOnAxis();
    visible = MatrixUtils.transformRect(
      Matrix4.inverted(transform.value),
      Offset.zero & viewport,
    ).inflate(100 / zoom);
    _art(canvas);
    if (hoverArtwork case final picture?) canvas.drawPicture(picture);
  }

  void _art(Canvas canvas) {
    if (artwork case final picture?)
      canvas.drawPicture(picture);
    else
      _connections(canvas);
    for (final node in scene.tree.nodes) {
      if (!visible.contains(scene.points[node.id]!)) continue;
      if (artwork == null)
        _node(canvas, node);
      else
        _highlight(canvas, node);
    }
  }

  void _highlight(Canvas canvas, TreeNode node) {
    if (node.id != selected && node.id != hovered && !_matches(node)) return;
    canvas.drawCircle(
      scene.points[node.id]!,
      _radius(node) + 3 / zoom,
      Paint()
        ..color = Spark.paper
        ..strokeWidth = 2 / zoom
        ..style = PaintingStyle.stroke,
    );
  }

  void _connections(Canvas canvas) {
    final line = Paint()
      ..color = const Color(0xFF494F44)
      ..strokeWidth = 1.2 / zoom;
    final active = Paint()
      ..color = Spark.sage
      ..strokeWidth = 2.2 / zoom;
    for (final (a, b) in scene.tree.edges) {
      _connection(canvas, a, b, line, active);
    }
  }

  void _connection(Canvas canvas, int a, int b, Paint line, Paint active) {
    final start = scene.points[a], end = scene.points[b];
    if (start == null || end == null) return;
    if (_hiddenConnection(a, b)) return;
    if (!visible.overlaps(Rect.fromPoints(start, end).inflate(2))) return;
    canvas.drawLine(
      start,
      end,
      scene.nodes[a]!.allocated && scene.nodes[b]!.allocated ? active : line,
    );
  }

  bool _hiddenConnection(int a, int b) {
    final kinds = {scene.nodes[a]!.kind, scene.nodes[b]!.kind};
    return kinds.contains('ClassStart') && kinds.contains('AscendClassStart');
  }

  bool _matches(TreeNode node) =>
      query.trim().isNotEmpty &&
      (matches?.contains(node.id) ?? node.matches(query));

  double _radius(TreeNode node) => math.max(
    scene.tree.original == null ? 2.8 : 1,
    node.drawSize * scene.scale / 2,
  );

  void _node(Canvas canvas, TreeNode node) {
    final match = _matches(node);
    final radius = _radius(node);
    final point = scene.points[node.id]!;
    final fill = node.allocated ? Spark.sage : const Color(0xFF69715E);
    canvas.drawCircle(
      point,
      radius,
      Paint()..color = match ? const Color(0xFFE9C68F) : fill,
    );
    final image = icons[node.icon];
    if (image != null && radius * zoom >= 6) {
      _icon(canvas, image, point, radius);
      canvas.drawCircle(
        point,
        radius,
        Paint()
          ..color = node.allocated ? Spark.sage : const Color(0xFF9D9272)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 / zoom,
      );
    }
    if (selected == node.id || hovered == node.id || match)
      canvas.drawCircle(
        point,
        radius + 3 / zoom,
        Paint()
          ..color = Spark.paper
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 / zoom,
      );
  }

  void _icon(Canvas canvas, ui.Image image, Offset point, double radius) {
    final target = Rect.fromCircle(center: point, radius: radius);
    canvas.save();
    canvas.clipPath(Path()..addOval(target));
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      target,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(TreePainter old) => true;
}
