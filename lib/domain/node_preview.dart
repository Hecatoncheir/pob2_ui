import 'dart:typed_data';

import 'build_report.dart';
import 'original_tree_scene.dart';

class NodePreview {
  NodePreview({
    required JsonMap tooltip,
    this.scene,
    Map<String, Uint8List> images = const {},
  }) : lines = List.unmodifiable(
         jsonRows(tooltip['lines']).where(_information),
       ),
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
}
