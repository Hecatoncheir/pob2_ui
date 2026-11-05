import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'spark_theme.dart';
import 'vector_drawings.dart';

class SparkArt extends StatelessWidget {
  const SparkArt(
    this.name, {
    super.key,
    this.width = 24,
    this.height,
    this.color,
    this.label,
  });
  final String name;
  final double width;
  final double? height;
  final Color? color;
  final String? label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    excludeSemantics: label == null,
    child: SizedBox(
      width: width,
      height: height ?? width,
      child: CustomPaint(
        painter: _VectorPainter(
          name,
          color ?? Spark.of(context).ink,
          Spark.of(context).paper,
        ),
      ),
    ),
  );
}

class _VectorPainter extends CustomPainter {
  const _VectorPainter(this.name, this.color, this.background);
  final String name;
  final Color color, background;
  @override
  void paint(Canvas canvas, Size size) {
    final drawing = vectorDrawings[name]!;
    final scale = math.min(
      size.width / drawing.size.width,
      size.height / drawing.size.height,
    );
    canvas.translate(
      (size.width - drawing.size.width * scale) / 2,
      (size.height - drawing.size.height * scale) / 2,
    );
    canvas.scale(scale);
    drawing.draw(canvas, color, background);
  }

  @override
  bool shouldRepaint(_VectorPainter old) =>
      old.name != name || old.color != color || old.background != background;
}

class ArtIconButton extends StatelessWidget {
  const ArtIconButton(
    this.icon, {
    super.key,
    required this.label,
    this.onPressed,
  });
  final String icon;
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    icon: SparkArt(
      'icons/$icon',
      width: 19,
      color: onPressed == null
          ? Spark.of(context).muted
          : Spark.of(context).ink,
    ),
  );
}
