import 'package:flutter/material.dart';

import '../domain/build_report.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';

class AttributePicker extends StatelessWidget {
  const AttributePicker({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<JsonMap> options;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (index, option) in options.indexed) ...[
        if (index > 0) const SizedBox(width: 8),
        Expanded(child: _choice(context, index + 1, option)),
      ],
    ],
  );

  Widget _choice(BuildContext context, int index, JsonMap option) {
    // Lua принимает номер варианта, а option.id — идентификатор самого узла.
    final selected = value == index;
    final (label, icon) = switch (option['name']) {
      'Strength' => ('Сила', 'sword'),
      'Dexterity' => ('Ловкость', 'eye'),
      'Intelligence' => ('Интеллект', 'spark'),
      _ => ('${option['name']}', 'plus'),
    };
    final colors = Spark.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('attribute-$index'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(index),
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            decoration: BoxDecoration(
              color: selected ? colors.sage : colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? colors.green : colors.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SparkArt('icons/$icon', width: 26),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
