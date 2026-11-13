import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../data/item_art_catalog.dart';
import '../domain/build_report.dart';
import 'item_artwork_image.dart';
import 'tree_canvas.dart';

class TreeJewelArtwork extends StatelessWidget {
  const TreeJewelArtwork({
    super.key,
    required this.scene,
    required this.report,
    required this.child,
  });
  final TreeScene scene;
  final BuildReport report;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final jewels = report.socketedItems;
    if (jewels.isEmpty) return child;
    return FutureBuilder<ItemArtCatalog>(
      future: ItemArtCatalog.shared,
      builder: (context, snapshot) {
        final catalog = snapshot.data;
        if (catalog == null) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            for (final entry in jewels.entries)
              if (scene.nodes[entry.key]?.allocated == true)
                if (catalog.imageForReport(entry.value) case final url?)
                  _image(entry.key, url),
          ],
        );
      },
    );
  }

  Widget _image(int nodeId, String url) {
    final node = scene.nodes[nodeId]!;
    final size = math.max(24, node.drawSize * .78) * scene.scale;
    return Positioned.fromRect(
      rect: Rect.fromCenter(
        center: scene.points[nodeId]!,
        width: size,
        height: size,
      ),
      child: IgnorePointer(
        child: ItemArtworkImage(key: ValueKey('tree-jewel-$nodeId'), url: url),
      ),
    );
  }
}
