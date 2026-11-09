import 'package:flutter/material.dart';

import '../data/item_art_catalog.dart';
import '../domain/equipment_item.dart';
import 'core/app_text.dart';
import 'core/frosted_surface.dart';
import 'core/pob_text.dart';
import 'core/spark_theme.dart';
import 'item_artwork_image.dart';

class ItemDescription extends StatelessWidget {
  const ItemDescription(this.inspection, {super.key});
  final ItemInspection inspection;
  @override
  Widget build(BuildContext context) => FrostedSurface(
    showShadow: false,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: FutureBuilder<ItemArtCatalog>(
        future: ItemArtCatalog.shared,
        builder: (context, snapshot) {
          final details = _details(context);
          final image = snapshot.data?.imageFor(inspection.item);
          return image == null ? details : _withImage(image, details);
        },
      ),
    ),
  );

  Widget _withImage(String image, Widget details) => LayoutBuilder(
    builder: (context, constraints) {
      final artwork = _ItemArtwork(image);
      if (constraints.maxWidth < 340) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: artwork),
            const SizedBox(height: 14),
            details,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          artwork,
          const SizedBox(width: 16),
          Expanded(child: details),
        ],
      );
    },
  );

  Widget _details(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final line in inspection.lines)
        if (line['separator'] == true)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Divider(),
          )
        else
          PoBText(
            '${line['text'] ?? ''}',
            size: (line['size'] as num? ?? 14) >= 20 ? 18 : 14,
            bold: (line['size'] as num? ?? 14) >= 20,
            textAlign: TextAlign.center,
          ),
      if (inspection.item.unsupported.isNotEmpty) ...[
        const SizedBox(height: 16),
        const AppText(
          'Не распознано Lua',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        for (final line in inspection.item.unsupported)
          AppText(
            '${line['line']}',
            game: true,
            style: TextStyle(color: Spark.of(context).danger),
          ),
      ],
    ],
  );
}

class _ItemArtwork extends StatelessWidget {
  const _ItemArtwork(this.url);
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = Spark.of(context);
    final placeholder = Icon(Icons.inventory_2_outlined, color: colors.muted);
    return Container(
      key: const Key('item-artwork'),
      width: 106,
      height: 122,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.ink.withValues(alpha: .04),
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ItemArtworkImage(url: url, placeholder: placeholder),
    );
  }
}
