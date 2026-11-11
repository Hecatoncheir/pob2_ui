import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_text.dart';
import 'core/spark_theme.dart';
import 'workspace_preferences_bloc.dart';

class ResizableSidebar extends StatelessWidget {
  const ResizableSidebar({super.key, required this.builder});
  final Widget Function(bool compact, bool adjustable) builder;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkspacePreferencesBloc, WorkspacePreferencesState>(
        builder: (context, state) {
          final adjustable = MediaQuery.sizeOf(context).width >= 1250;
          final width = adjustable ? state.preferences.sidebarWidth : 78.0;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                key: const Key('sidebar-width'),
                width: width,
                child: builder(width < 160, adjustable),
              ),
              if (adjustable) const _ResizeHandle(),
            ],
          );
        },
      );
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle();
  @override
  Widget build(BuildContext context) {
    final preferences = context.read<WorkspacePreferencesBloc>();
    return AppTooltip(
      message: 'Потяните, чтобы изменить ширину панели',
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: GestureDetector(
          key: const Key('sidebar-resize'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) =>
              preferences.add(SidebarDragged(details.delta.dx)),
          onHorizontalDragEnd: (_) => preferences.add(const SidebarDragEnded()),
          onHorizontalDragCancel: () =>
              preferences.add(const SidebarDragEnded()),
          onDoubleTap: () => preferences.add(const SidebarToggled()),
          child: SizedBox(
            width: 6,
            child: Center(
              child: Container(width: 1, color: Spark.of(context).line),
            ),
          ),
        ),
      ),
    );
  }
}
