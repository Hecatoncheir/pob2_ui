import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;

import '../domain/original_tree_scene.dart';

class OriginalTreeArtwork {
  OriginalTreeArtwork(OriginalTreeScene scene, Map<String, ui.Image> images) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    for (final command in scene.commands) {
      final image = images[command.texture];
      if (image == null || _isBackdrop(scene, command)) continue;
      _draw(canvas, command, image);
    }
    picture = recorder.endRecording();
  }
  late final ui.Picture picture;
  final _shaders = <(ui.Image, bool), ui.ImageShader>{};

  bool _isBackdrop(OriginalTreeScene scene, TreeDrawCommand command) {
    // main:DrawBackground рисует первым прямоугольник фона всего окна.
    // Фон окна задаёт Flutter; игровые изображения остаются в сцене.
    if (!identical(command, scene.commands.first)) return false;
    return listEquals(command.positions, [
      0.0,
      0.0,
      scene.width,
      0.0,
      scene.width,
      scene.height,
      0.0,
      scene.height,
    ]);
  }

  void _draw(ui.Canvas canvas, TreeDrawCommand command, ui.Image image) {
    final shader = _shaders.putIfAbsent((image, command.clamp), () {
      final mode = command.clamp ? ui.TileMode.clamp : ui.TileMode.repeated;
      return ui.ImageShader(
        image,
        mode,
        mode,
        Float64List.fromList([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]),
        filterQuality: ui.FilterQuality.medium,
      );
    });
    final tint = ui.Color.from(
      alpha: command.color[3],
      red: command.color[0],
      green: command.color[1],
      blue: command.color[2],
    );
    final positions = _points(command.positions);
    final uv = _points(command.uv)
        .map(
          (point) => ui.Offset(point.dx * image.width, point.dy * image.height),
        )
        .toList();
    final vertices = ui.Vertices(
      ui.VertexMode.triangleFan,
      positions,
      textureCoordinates: uv,
      colors: List.filled(4, tint),
    );
    canvas.drawVertices(
      vertices,
      ui.BlendMode.modulate,
      ui.Paint()
        ..shader = shader
        ..blendMode = _blend(command.blend),
    );
    vertices.dispose();
  }

  List<ui.Offset> _points(List<double> values) => [
    for (var i = 0; i < values.length; i += 2)
      ui.Offset(values[i], values[i + 1]),
  ];
  ui.BlendMode _blend(String mode) => switch (mode) {
    'ALPHA' || 'PREALPHA' => ui.BlendMode.srcOver,
    'ADDITIVE' => ui.BlendMode.plus,
    _ => throw FormatException('Неизвестный режим сцены PoB: $mode'),
  };

  void dispose() {
    picture.dispose();
    for (final shader in _shaders.values) {
      shader.dispose();
    }
  }
}
