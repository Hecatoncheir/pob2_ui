import 'package:flutter/material.dart';

import '../domain/equipment_item.dart';
import 'core/app_text.dart';
import 'core/frosted_surface.dart';
import 'core/pob_text.dart';
import 'core/spark_theme.dart';

class ItemDescription extends StatelessWidget {
  const ItemDescription(this.inspection, {super.key});
  final ItemInspection inspection;
  @override
  Widget build(BuildContext context) => FrostedSurface(
    showShadow: false,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
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
      ),
    ),
  );
}
