import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class FrostedSurface extends StatelessWidget {
  const FrostedSurface({super.key, required this.child});
  final Widget child;
  static const opacity = .84;

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
    final radius = BorderRadius.circular(12);
    final tintOpacity = MediaQuery.highContrastOf(context) ? .96 : opacity;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: tintOpacity),
              borderRadius: radius,
              border: Border.all(
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
