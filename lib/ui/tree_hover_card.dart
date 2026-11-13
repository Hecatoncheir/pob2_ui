import 'core/app_text.dart';

import 'package:material_ui/material_ui.dart';

import 'dart:math' as math;

import '../domain/build_report.dart';
import 'core/frosted_surface.dart';
import 'core/gruvbox.dart';
import 'tree_hover_cubit.dart';
import 'core/pob_text.dart';

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
      child: PoBText(text),
    );
  }
}
