import 'package:flutter/material.dart';

import '../domain/build_report.dart';
import 'core/app_text.dart';
import 'core/spark_theme.dart';
import 'equipment_presentation.dart';

// Координаты задают только расположение ячеек; доступность приходит из Lua.
const _positions = <String, Rect>{
  'Weapon 1': Rect.fromLTWH(18, 35, 128, 230),
  'Weapon 2': Rect.fromLTWH(414, 35, 128, 230),
  'Helmet': Rect.fromLTWH(224, 10, 112, 105),
  'Body Armour': Rect.fromLTWH(216, 128, 128, 190),
  'Gloves': Rect.fromLTWH(94, 323, 110, 115),
  'Boots': Rect.fromLTWH(356, 323, 110, 115),
  'Belt': Rect.fromLTWH(216, 332, 128, 66),
  'Amulet': Rect.fromLTWH(350, 135, 60, 68),
  'Ring 1': Rect.fromLTWH(150, 230, 60, 68),
  'Ring 2': Rect.fromLTWH(350, 230, 60, 68),
  'Flask 1': Rect.fromLTWH(151, 448, 58, 110),
  'Flask 2': Rect.fromLTWH(351, 448, 58, 110),
  'Charm 1': Rect.fromLTWH(218, 462, 38, 65),
  'Charm 2': Rect.fromLTWH(261, 462, 38, 65),
  'Charm 3': Rect.fromLTWH(304, 462, 38, 65),
};

class EquipmentBoard extends StatelessWidget {
  const EquipmentBoard({
    super.key,
    required this.report,
    required this.selected,
    required this.select,
    required this.busy,
  });
  final BuildReport report;
  final String? selected;
  final void Function(String) select;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    final slots = equipmentSlots(report);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 250)
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots
                .map(
                  (slot) => SizedBox(
                    width: (constraints.maxWidth - 10) / 2,
                    height: 130,
                    child: _tile(slot),
                  ),
                )
                .toList(),
          );
        final mapped = slots
            .where((slot) => _position(slot['name'] as String) != null)
            .toList();
        final other = slots
            .where((slot) => _position(slot['name'] as String) == null)
            .toList();
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 560 / 570,
              child: FittedBox(
                child: SizedBox(
                  width: 560,
                  height: 570,
                  child: Stack(
                    children: mapped
                        .map(
                          (slot) => Positioned.fromRect(
                            rect: _position(slot['name'] as String)!,
                            child: _tile(slot),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            if (other.isNotEmpty)
              ExpansionTile(
                title: const AppText('Дополнительные ячейки'),
                shape: const Border(),
                collapsedShape: const Border(),
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: other
                        .map(
                          (slot) => SizedBox(
                            width: 120,
                            height: 120,
                            child: _tile(slot),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Rect? _position(String name) => _positions[name.replaceFirst(' Swap', '')];

  Widget _tile(JsonMap slot) {
    final name = slot['name'] as String;
    final item = report.items
        .where((item) => item['id'] == slot['itemId'])
        .firstOrNull;
    return _EquipmentTile(
      name: name,
      item: item,
      selected: selected == name,
      onTap: busy ? null : () => select(name),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.name,
    required this.item,
    required this.selected,
    this.onTap,
  });
  final String name;
  final JsonMap? item;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = _rarity(colors);
    return AppTooltip(
      message: item == null ? equipmentLabel(name) : '${item!['name']}',
      game: item != null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? colors.primary.withValues(alpha: .12)
              : colors.surfaceContainerHighest.withValues(alpha: .55),
          border: Border.all(
            color: selected ? colors.primary : tint.withValues(alpha: .55),
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: ValueKey('equipment-slot-$name'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    _body(context, constraints, tint),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, BoxConstraints constraints, Color tint) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          equipmentIcon(name),
          color: item == null ? Spark.of(context).muted : tint,
          size: constraints.maxHeight < 70 ? 20 : 36,
        ),
        const SizedBox(height: 5),
        Flexible(
          child: AppText(
            equipmentLabel(name),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: constraints.maxWidth < 55 ? 8 : 10,
              color: Spark.of(context).muted,
            ),
          ),
        ),
        if (item != null && constraints.maxHeight > 75) ...[
          const SizedBox(height: 5),
          Flexible(
            child: AppText(
              '${item!['name']}',
              game: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: tint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _rarity(ColorScheme colors) => switch (item?['rarity']) {
    'RARE' => colors.primary,
    'UNIQUE' || 'RELIC' => const Color(0xFFB97846),
    'MAGIC' => colors.tertiary,
    _ => item == null ? colors.outline : colors.onSurface,
  };
}
