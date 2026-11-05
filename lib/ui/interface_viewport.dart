import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/interface_scale.dart';
import 'interface_scale_cubit.dart';

class InterfaceViewport extends StatelessWidget {
  const InterfaceViewport({
    super.key,
    required this.child,
    required this.motion,
  });
  final Widget child;
  final bool motion;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<InterfaceScaleCubit, InterfaceScaleState>(
        builder: (context, state) => CallbackShortcuts(
          bindings: _bindings(context.read<InterfaceScaleCubit>()),
          child: Focus(
            autofocus: true,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _layout(context, constraints.biggest, state.percent / 100),
            ),
          ),
        ),
      );

  Map<ShortcutActivator, VoidCallback> _bindings(InterfaceScaleCubit scale) => {
    const SingleActivator(LogicalKeyboardKey.minus, control: true): () =>
        scale.changeBy(-10),
    const SingleActivator(LogicalKeyboardKey.equal, control: true): () =>
        scale.changeBy(10),
    const SingleActivator(LogicalKeyboardKey.add, control: true): () =>
        scale.changeBy(10),
    const SingleActivator(
      LogicalKeyboardKey.add,
      control: true,
      shift: true,
    ): () =>
        scale.changeBy(10),
    const SingleActivator(
      LogicalKeyboardKey.equal,
      control: true,
      shift: true,
    ): () =>
        scale.changeBy(10),
    const SingleActivator(
      LogicalKeyboardKey.numpadSubtract,
      control: true,
    ): () =>
        scale.changeBy(-10),
    const SingleActivator(LogicalKeyboardKey.numpadAdd, control: true): () =>
        scale.changeBy(10),
    const SingleActivator(LogicalKeyboardKey.digit0, control: true): () =>
        scale.setPercent(100),
  };

  Widget _layout(BuildContext context, Size viewport, double scale) {
    final media = MediaQuery.of(context);
    final size = viewport / scale;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: MediaQuery(
            data: media.copyWith(
              size: size,
              padding: media.padding / scale,
              viewPadding: media.viewPadding / scale,
              viewInsets: media.viewInsets / scale,
              disableAnimations: media.disableAnimations || !motion,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
