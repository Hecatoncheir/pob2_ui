import 'core/app_text.dart';

import 'package:flutter/material.dart';

import 'core/spark_theme.dart';
import 'core/gruvbox.dart';
import 'core/ui_translation.dart';
import '../domain/tree_allocation_mode.dart';

class TreePointCounters extends StatelessWidget {
  const TreePointCounters(
    this.display, {
    super.key,
    this.mode = TreeAllocationMode.common,
    this.onModeChanged,
  });
  final TreeAllocationMode mode;
  final ValueChanged<TreeAllocationMode>? onModeChanged;
  final String display;

  @override
  Widget build(BuildContext context) {
    // Значения и лимиты уже посчитаны Lua; разбираем только строку для показа.
    final pairs = RegExp(r'(\d+)\s*/\s*(\d+)').allMatches(display).toList();
    if (pairs.length != 4) return AppText('Очки: $display');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (index, label) in const [
          'Пассивные',
          'Оружие I',
          'Оружие II',
          'Восхождение',
        ].indexed)
          _counter(context, index, label, pairs[index]),
      ],
    );
  }

  Widget _counter(
    BuildContext context,
    int index,
    String label,
    RegExpMatch pair,
  ) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            label,
            style: TextStyle(fontSize: 10, color: Spark.of(context).muted),
          ),
          const SizedBox(height: 2),
          AppText(
            '${pair[1]} / ${pair[2]}',
            key: ValueKey('tree-counter-$index'),
            style: Spark.mono.copyWith(
              fontSize: 11,
              color: _color(context, index),
            ),
          ),
        ],
      ),
    );
    return AppTooltip(
      message:
          '${translateUi(context, label)}: потрачено ${pair[1]} из ${pair[2]} очков',
      child: index == 3 ? content : _modeButton(context, index, content),
    );
  }

  Widget _modeButton(BuildContext context, int index, Widget child) {
    final selected = mode.luaValue == index;
    final color = _color(context, index);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onModeChanged != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('tree-mode-$index'),
          borderRadius: BorderRadius.circular(10),
          onTap: onModeChanged == null
              ? null
              : () => onModeChanged!(TreeAllocationMode.values[index]),
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: selected
                  ? color.withValues(alpha: dark ? .12 : .03)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: .7)
                    : Colors.transparent,
              ),
            ),
            child: child,
          ),
        ),
      ),
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
