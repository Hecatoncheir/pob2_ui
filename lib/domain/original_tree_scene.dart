import 'build_report.dart';

typedef TreeTextureReference = ({String file, int index, int targetSize});

class OriginalTreeScene {
  OriginalTreeScene.fromJson(JsonMap json)
    : scale = (json['scale'] as num).toDouble(),
      width = (json['width'] as num?)?.toDouble(),
      height = (json['height'] as num?)?.toDouble(),
      offsetX = (json['offsetX'] as num).toDouble(),
      offsetY = (json['offsetY'] as num).toDouble(),
      assetId = json['assetId'] as String?,
      commands = List.unmodifiable(
        jsonRows(json['commands']).map(TreeDrawCommand.fromJson),
      );
  final double scale, offsetX, offsetY;
  final double? width, height;
  final String? assetId;
  final List<TreeDrawCommand> commands;
}

class TreeDrawCommand {
  TreeDrawCommand.fromJson(JsonMap json)
    : texture = json['texture'] as String,
      positions = _coordinates(json['positions'], 8),
      uv = _coordinates(json['uv'], 8),
      color = _coordinates(json['color'], 4),
      blend = json['blend'] as String,
      clamp = json['clamp'] as bool,
      reference = switch (json['engineTexture']) {
        {
          'file': final String file,
          'index': final int index,
          'targetSize': final int targetSize,
        } =>
          (file: file, index: index, targetSize: targetSize),
        _ => null,
      };
  final String texture, blend;
  final TreeTextureReference? reference;
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
