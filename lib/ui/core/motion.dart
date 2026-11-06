import 'package:flutter/material.dart';

import 'spark_theme.dart';

Duration motionDuration(BuildContext context, {int milliseconds = 380}) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

class SoftSwitch extends StatelessWidget {
  const SoftSwitch({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: motionDuration(context),
    reverseDuration: motionDuration(context, milliseconds: 140),
    switchInCurve: Spark.curve,
    switchOutCurve: Curves.easeOut,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .025),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    layoutBuilder: (current, previous) => Stack(
      alignment: Alignment.topCenter,
      children: [...previous, ?current],
    ),
    child: child,
  );
}

Future<T?> sparkDialog<T>(
  BuildContext context,
  Widget child, {
  bool barrierDismissible = true,
}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: barrierDismissible,
  barrierLabel: 'Закрыть',
  barrierColor: Spark.ink.withValues(alpha: .25),
  transitionDuration: motionDuration(context, milliseconds: 300),
  pageBuilder: (context, animation, secondary) => child,
  transitionBuilder: (context, animation, secondary, child) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween(
        begin: .97,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Spark.curve)),
      child: child,
    ),
  ),
);
