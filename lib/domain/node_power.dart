import 'dart:typed_data';

import 'build_report.dart';
import 'original_tree_scene.dart';

typedef NodePowerOptions = ({String stat, int? distance, String allocation});
typedef NodePowerState = ({
  List<JsonMap> metrics,
  NodePowerOptions options,
  double? progress,
  NodePowerReport? report,
  String? error,
});

class NodePowerReport {
  NodePowerReport.fromJson(JsonMap json, Map<String, Uint8List> images)
    : entries = List.unmodifiable(jsonRows(json['entries'])),
      scene = OriginalTreeScene.fromJson(jsonMap(json['scene'])),
      images = Map.unmodifiable(images);
  final List<JsonMap> entries;
  final OriginalTreeScene scene;
  final Map<String, Uint8List> images;
}

String nodePowerLabel(JsonMap metric) {
  final id = '${metric['id']}';
  final label = statLabel(id);
  if (label != id) return label;
  return switch (id) {
    'OffenceDefence' => 'Урон / защита',
    'CombinedDPS' => 'Суммарный DPS',
    'TotalAttr' => 'Все характеристики',
    'TotalEHP' => 'Эффективное здоровье',
    'EffectiveMovementSpeedMod' => 'Скорость передвижения',
    _ => '${metric['label']}',
  };
}
