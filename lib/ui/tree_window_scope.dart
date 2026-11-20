import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

Rect visibleTreeViewport(RenderBox viewport, RenderBox root) {
  var visible = MatrixUtils.transformRect(
    viewport.getTransformTo(root),
    Offset.zero & viewport.size,
  );
  RenderObject child = viewport;
  for (
    var ancestor = viewport.parent;
    ancestor != null;
    ancestor = ancestor.parent
  ) {
    final clip = ancestor.describeApproximatePaintClip(child);
    if (clip != null) {
      visible = visible.intersect(
        MatrixUtils.transformRect(ancestor.getTransformTo(root), clip),
      );
    }
    if (ancestor == root) break;
    child = ancestor;
  }
  return visible.intersect(Offset.zero & root.size);
}

class TreeWindowScope extends InheritedWidget {
  const TreeWindowScope({
    super.key,
    required this.chrome,
    required this.viewportPainted,
    required super.child,
  });
  final Widget Function() chrome;
  final void Function(RenderBox box) viewportPainted;

  static TreeWindowScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TreeWindowScope>();

  @override
  bool updateShouldNotify(TreeWindowScope oldWidget) => true;
}

class TreeWindowChrome extends StatelessWidget {
  const TreeWindowChrome({super.key});

  @override
  Widget build(BuildContext context) =>
      TreeWindowScope.maybeOf(context)!.chrome();
}

class TreeWindowViewport extends SingleChildRenderObjectWidget {
  const TreeWindowViewport({super.key}) : super(child: const SizedBox.expand());

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ViewportObserver(TreeWindowScope.maybeOf(context)!.viewportPainted);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _ViewportObserver renderObject,
  ) {
    renderObject.onPaint = TreeWindowScope.maybeOf(context)!.viewportPainted;
  }
}

class _ViewportObserver extends RenderProxyBox {
  _ViewportObserver(this.onPaint);
  void Function(RenderBox box) onPaint;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performLayout() {
    super.performLayout();
    onPaint(this);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    onPaint(this);
  }
}

class TreeInputHole extends SingleChildRenderObjectWidget {
  const TreeInputHole({
    super.key,
    required this.viewport,
    required super.child,
  });
  final Rect? viewport;

  @override
  RenderObject createRenderObject(BuildContext context) => _InputHole(viewport);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _InputHole renderObject,
  ) {
    renderObject.viewport = viewport;
  }
}

class _InputHole extends RenderProxyBox {
  _InputHole(this.viewport);
  Rect? viewport;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final hole = viewport;
    if (hole != null &&
        RRect.fromRectAndRadius(
          hole,
          const Radius.circular(18),
        ).contains(position)) {
      final probe = BoxHitTestResult();
      child?.hitTest(probe, position: position);
      if (probe.path.any((entry) => entry.target is _ViewportObserver))
        return false;
    }
    return super.hitTest(result, position: position);
  }
}
