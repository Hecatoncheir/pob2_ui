import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/interface_scale.dart';
import 'interface_scale_cubit.dart';
import '../domain/workspace_preferences.dart';
import 'workspace_preferences_cubit.dart';
import 'keyboard_bindings.dart';

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
          bindings: _bindings(
            context.read<InterfaceScaleCubit>(),
            context.watch<WorkspacePreferencesCubit?>()?.state.preferences ??
                WorkspacePreferences(),
          ),
          child: Focus(
            autofocus: true,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _layout(context, constraints.biggest, state.percent / 100),
            ),
          ),
        ),
      );

  Map<ShortcutActivator, VoidCallback> _bindings(
    InterfaceScaleCubit scale,
    WorkspacePreferences preferences,
  ) => commandCallbacks(preferences, {
    AppCommand.zoomIn: () => scale.changeBy(10),
    AppCommand.zoomOut: () => scale.changeBy(-10),
    AppCommand.resetZoom: () => scale.setPercent(100),
  });

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
