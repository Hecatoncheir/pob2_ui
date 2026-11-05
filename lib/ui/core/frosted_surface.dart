import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    super.key,
    required this.child,
    this.showShadow = true,
    this.backgroundOpacity = opacity,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.border,
  });
  final Widget child;
  final bool showShadow;
  final double backgroundOpacity;
  final BorderRadius borderRadius;
  final Border? border;
  static const opacity = .85;

  static Color contrastBackground(ColorScheme colors) {
    final light =
        ThemeData.estimateBrightnessForColor(colors.surface) ==
        Brightness.light;
    return Color.alphaBlend(
      colors.surface.withValues(alpha: opacity),
      light ? Colors.black : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tintOpacity = MediaQuery.highContrastOf(context)
        ? .98
        : backgroundOpacity;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (showShadow)
            BoxShadow(
              color: colors.shadow.withValues(alpha: .16),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: tintOpacity),
              borderRadius: borderRadius,
              border:
                  border ??
                  Border.all(
                    color: colors.outlineVariant.withValues(alpha: .8),
                  ),
            ),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}
