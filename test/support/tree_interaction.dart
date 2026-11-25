import 'package:flutter/rendering.dart' show RenderBox;
import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/ui/core/tree_glass.dart';

Finder treeInteractionViewport() {
  final viewport = find.byKey(const Key('tree-interaction-viewport'));
  return viewport.evaluate().isNotEmpty
      ? viewport
      : find.byKey(const Key('passive-tree'));
}

Offset treeInteractionCenter(WidgetTester tester) {
  final viewport = tester
      .widgetList<TreeFrost>(find.byType(TreeFrost))
      .firstOrNull
      ?.viewport;
  if (viewport == null) return tester.getCenter(treeInteractionViewport());
  final canvas = tester.renderObject<RenderBox>(
    find.byKey(const Key('passive-tree')),
  );
  return canvas.localToGlobal(viewport.center);
}
