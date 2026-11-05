import 'core/app_text.dart';

import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../domain/build_report.dart';
import 'core/frosted_surface.dart';
import 'core/gruvbox.dart';
import 'tree_hover_cubit.dart';
import 'core/language_scope.dart';
import 'core/spark_theme.dart';

class NodeTooltipLayout extends SingleChildLayoutDelegate {
  NodeTooltipLayout(this.point);
  final Offset point;
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(
        Size(
          math.min(480, math.max(0, constraints.maxWidth - 24)),
          math.min(640, math.max(0, constraints.maxHeight - 24)),
        ),
      );
  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    (point.dx + 18).clamp(
      12.0,
      math.max(12.0, size.width - childSize.width - 12),
    ),
    (point.dy + 18).clamp(
      12.0,
      math.max(12.0, size.height - childSize.height - 12),
    ),
  );
  @override
  bool shouldRelayout(NodeTooltipLayout old) => point != old.point;
}

class TreeHoverCard extends StatelessWidget {
  const TreeHoverCard({super.key, required this.title, required this.state});
  final String title;
  final TreeHoverState state;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = scheme.brightness == Brightness.dark
        ? scheme.copyWith(onSurface: Gruvbox.brightText)
        : scheme;
    return FrostedSurface(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              title,
              game: true,
              style: TextStyle(
                color: colors.onSurface,
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (state.loading) const LinearProgressIndicator(minHeight: 2),
            if (state.error case final error?)
              AppText(
                'Не удалось получить подсказку: $error',
                style: TextStyle(color: colors.onSurface),
              ),
            if (state.preview case final preview?)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final line in preview.lines)
                        _line(context, line, colors),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, JsonMap line, ColorScheme colors) {
    if (line['separator'] == true)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: colors.outlineVariant),
      );
    final text = '${line['text'] ?? ''}';
    if (cleanPoB(text) == title) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text.rich(
        TextSpan(children: _localizedSpans(context, text, colors)),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: colors.onSurface,
        ),
      ),
    );
  }

  List<TextSpan> _localizedSpans(
    BuildContext context,
    String text,
    ColorScheme colors,
  ) {
    final translated = translateGame(context, cleanPoB(text));
    final spans = _spans(text, colors);
    if (translated == cleanPoB(text)) return spans;
    final style = spans
        .where((span) => span.text?.isNotEmpty == true)
        .firstOrNull
        ?.style;
    return [TextSpan(text: translated, style: style)];
  }

  List<TextSpan> _spans(String source, ColorScheme colors) {
    final result = <TextSpan>[];
    var start = 0;
    var color = colors.onSurface;
    for (final match in RegExp(
      r'\^x([a-fA-F0-9]{6})|\^[0-9]',
    ).allMatches(source)) {
      result.add(
        TextSpan(
          text: source.substring(start, match.start),
          style: TextStyle(color: color),
        ),
      );
      color = _readableColor(_sourceColor(match, colors), colors);
      start = match.end;
    }
    result.add(
      TextSpan(
        text: source.substring(start),
        style: TextStyle(color: color),
      ),
    );
    return result;
  }

  Color _readableColor(Color source, ColorScheme colors) {
    final effect = _effectColor(source, colors);
    final minimumContrast = effect == null ? 7.0 : 4.5;
    source = effect ?? _themeColor(source, colors);
    final background = FrostedSurface.contrastBackground(colors)
        .computeLuminance();
    for (final amount in const [0.0, .15, .3, .45, .6, .75, .9]) {
      final color = Color.lerp(source, colors.onSurface, amount)!;
      final foreground = color.computeLuminance();
      final contrast =
          (math.max(foreground, background) + .05) /
          (math.min(foreground, background) + .05);
      if (contrast >= minimumContrast) return color;
    }
    return colors.onSurface;
  }

  Color _sourceColor(RegExpMatch match, ColorScheme colors) {
    if (match.group(1) case final hex?)
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    return switch (match[0]) {
      '^1' => const Color(0xFFFF0000),
      '^2' => const Color(0xFF00FF00),
      '^8' => colors.onSurfaceVariant,
      _ => colors.onSurface,
    };
  }

  Color? _effectColor(Color source, ColorScheme colors) {
    final dark = colors.brightness == Brightness.dark;
    // Смысл изменения уже определён Lua. Знак числа здесь не оценивается.
    return switch (source.toARGB32()) {
      0xFF33FF77 || 0xFF00FF00 => dark ? Gruvbox.aqua : Spark.green,
      0xFFDD0022 || 0xFFFF0000 => dark ? Gruvbox.red : Spark.danger,
      _ => null,
    };
  }

  Color _themeColor(Color source, ColorScheme colors) {
    if (colors.brightness != Brightness.dark) return source;
    final hsv = HSVColor.fromColor(source);
    if (hsv.saturation < .15) return colors.onSurfaceVariant;
    return switch (hsv.hue) {
      >= 15 && < 50 => Gruvbox.orange,
      >= 50 && < 80 => Gruvbox.yellow,
      >= 80 && < 160 => Gruvbox.green,
      >= 160 && < 200 => Gruvbox.aqua,
      >= 200 && < 270 => Gruvbox.blue,
      >= 270 && < 330 => Gruvbox.purple,
      _ => Gruvbox.red,
    };
  }
}
