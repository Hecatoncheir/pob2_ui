import 'build_report.dart';

class OriginalTreeScene {
  OriginalTreeScene.fromJson(JsonMap json)
    : scale = (json['scale'] as num).toDouble(),
      offsetX = (json['offsetX'] as num).toDouble(),
      offsetY = (json['offsetY'] as num).toDouble(),
      commands = List.unmodifiable(
        jsonRows(json['commands']).map(TreeDrawCommand.fromJson),
      );
  final double scale, offsetX, offsetY;
  final List<TreeDrawCommand> commands;
}

class TreeDrawCommand {
  TreeDrawCommand.fromJson(JsonMap json)
    : texture = json['texture'] as String,
      positions = _coordinates(json['positions'], 8),
      uv = _coordinates(json['uv'], 8),
      color = _coordinates(json['color'], 4),
      blend = json['blend'] as String,
      clamp = json['clamp'] as bool;
  final String texture, blend;
  final bool clamp;
  final List<double> positions, uv, color;

  static List<double> _coordinates(dynamic value, int count) {
    if (value is! List || value.length != count)
      throw const FormatException('Неполная команда отрисовки PoB');
    final result = value.map((v) => (v as num).toDouble()).toList();
    if (result.any((v) => !v.isFinite))
      throw const FormatException('Некорректные координаты PoB');
    return List.unmodifiable(result);
  }
}
