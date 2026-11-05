import 'package:flutter/material.dart';

class ScrollableWorkspace extends StatelessWidget {
  const ScrollableWorkspace({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final minimumHeight = MediaQuery.sizeOf(context).width >= 1250
          ? 680.0
          : 620.0;
      return SingleChildScrollView(
        key: const Key('workspace-overflow-scroll'),
        primary: false,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight.clamp(minimumHeight, double.infinity),
          child: child,
        ),
      );
    },
  );
}
