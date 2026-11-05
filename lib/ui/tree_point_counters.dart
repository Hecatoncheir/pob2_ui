import 'core/app_text.dart';

import 'package:flutter/material.dart';

import 'core/spark_theme.dart';
import 'core/gruvbox.dart';

class TreePointCounters extends StatelessWidget {
  const TreePointCounters(this.display, {super.key});
  final String display;

  @override
  Widget build(BuildContext context) {
    // Значения и лимиты уже посчитаны Lua; разбираем только строку для показа.
    final pairs = RegExp(r'(\d+)\s*/\s*(\d+)').allMatches(display).toList();
    if (pairs.length != 4) return AppText('Очки: $display');
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        for (final (index, label) in const [
          'Пассивные',
          'Оружие I',
          'Оружие II',
          'Восхождение',
        ].indexed)
          AppTooltip(
            message:
                '$label: потрачено ${pairs[index][1]} из ${pairs[index][2]} очков',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Spark.of(context).muted,
                  ),
                ),
                const SizedBox(height: 2),
                AppText(
                  '${pairs[index][1]} / ${pairs[index][2]}',
                  key: ValueKey('tree-counter-$index'),
                  style: Spark.mono.copyWith(
                    fontSize: 11,
                    color: _color(context, index),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _color(BuildContext context, int index) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (index) {
      0 => dark ? Gruvbox.yellow : const Color(0xFF8A5A13),
      1 =>
        dark ? Color.lerp(Gruvbox.red, Gruvbox.brightText, .25)! : Spark.danger,
      2 => dark ? Gruvbox.aqua : Spark.green,
      _ => dark ? Gruvbox.brightText : const Color(0xFF525D82),
    };
  }
}
