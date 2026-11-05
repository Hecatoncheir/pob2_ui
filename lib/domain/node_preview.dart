import 'dart:typed_data';

import 'build_report.dart';
import 'original_tree_scene.dart';

class NodePreview {
  NodePreview({
    required JsonMap tooltip,
    this.scene,
    Map<String, Uint8List> images = const {},
  }) : lines = List.unmodifiable(_normalize(jsonRows(tooltip['lines']))),
       path = List.unmodifiable(
         tooltip['path'] is List
             ? (tooltip['path'] as List).cast<int>()
             : <int>[],
       ),
       images = Map.unmodifiable(images);
  final List<JsonMap> lines;
  final List<int> path;
  final OriginalTreeScene? scene;
  final Map<String, Uint8List> images;
  static bool _information(JsonMap line) =>
      !cleanPoB('${line['text'] ?? ''}').startsWith('Tip:');

  static Iterable<JsonMap> _normalize(List<JsonMap> lines) sync* {
    var content = false;
    JsonMap? separator;
    for (final line in lines) {
      if (line['separator'] == true) {
        separator = line;
        continue;
      }
      if (!_information(line) || cleanPoB('${line['text'] ?? ''}').isEmpty)
        continue;
      if (content && separator != null) yield separator;
      separator = null;
      content = true;
      yield line;
    }
  }
}
