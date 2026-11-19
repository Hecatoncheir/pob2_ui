import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'spark_theme.dart';

class TreeGlassScope extends InheritedWidget {
  const TreeGlassScope({super.key, required this.active, required super.child});
  final bool active;

  static bool activeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TreeGlassScope>()?.active ??
      false;

  static Color surface(
    BuildContext context,
    Color color, {
    double opacity = .18,
  }) => activeOf(context) ? color.withValues(alpha: opacity) : color;

  @override
  bool updateShouldNotify(TreeGlassScope oldWidget) =>
      active != oldWidget.active;
}

class TreeFrost extends StatelessWidget {
  const TreeFrost({super.key, required this.viewport});
  final Rect? viewport;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ClipPath(
      clipper: _TreeChromeClipper(viewport),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: ColoredBox(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF262626).withValues(alpha: .75)
              : Spark.of(context).surface.withValues(alpha: .78),
        ),
      ),
    ),
  );
}

class _TreeChromeClipper extends CustomClipper<Path> {
  const _TreeChromeClipper(this.viewport);
  final Rect? viewport;

  @override
  Path getClip(Size size) {
    final path = Path()..fillType = PathFillType.evenOdd;
    path.addRect(Offset.zero & size);
    if (viewport case final rect? when !rect.isEmpty) {
      path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)));
    }
    return path;
  }

  @override
  bool shouldReclip(_TreeChromeClipper oldClipper) =>
      viewport != oldClipper.viewport;
}
