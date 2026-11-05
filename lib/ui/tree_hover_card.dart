import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../domain/build_report.dart';
import 'core/spark_theme.dart';
import 'tree_hover_cubit.dart';

class NodeTooltipLayout extends SingleChildLayoutDelegate {
  NodeTooltipLayout(this.point);
  final Offset point;
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(
        Size(
          math.min(440, math.max(0, constraints.maxWidth - 24)),
          math.min(560, math.max(0, constraints.maxHeight - 24)),
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
  Widget build(BuildContext context) => Material(
    color: Spark.ink.withValues(alpha: .97),
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF978D6E)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Spark.paper,
              fontFamily: 'Nunito',
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (state.loading) const LinearProgressIndicator(minHeight: 2),
          if (state.error case final error?)
            Text(
              'Не удалось получить подсказку: $error',
              style: const TextStyle(color: Spark.paper),
            ),
          if (state.preview case final preview?)
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [for (final line in preview.lines) _line(line)],
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _line(JsonMap line) {
    if (line['separator'] == true)
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Divider(color: Color(0xFF4B5044)),
      );
    final text = '${line['text'] ?? ''}';
    if (cleanPoB(text) == title) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text.rich(
        TextSpan(children: _spans(text)),
        style: const TextStyle(fontSize: 12, height: 1.35, color: Spark.paper),
      ),
    );
  }

  List<TextSpan> _spans(String source) {
    final result = <TextSpan>[];
    var start = 0;
    var color = Spark.paper;
    for (final match in RegExp(
      r'\^x([a-fA-F0-9]{6})|\^[0-9]',
    ).allMatches(source)) {
      result.add(
        TextSpan(
          text: source.substring(start, match.start),
          style: TextStyle(color: color),
        ),
      );
      final hex = match.group(1);
      color = hex == null
          ? Spark.paper
          : Color(0xFF000000 | int.parse(hex, radix: 16));
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
}
