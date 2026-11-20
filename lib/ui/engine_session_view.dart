import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_text.dart';
import 'engine_session_cubit.dart';

class EngineSessionBar extends StatelessWidget {
  const EngineSessionBar({
    super.key,
    required this.cubit,
    required this.configure,
    this.fallback,
  });
  final EngineSessionCubit cubit;
  final VoidCallback configure;
  final String? fallback;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EngineSessionCubit, EngineSessionState>(
        bloc: cubit,
        builder: (context, state) => Padding(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              IconButton(
                key: const Key('engine-session-settings'),
                onPressed: configure,
                icon: Icon(state.connected ? Icons.sync : Icons.link),
                tooltip: 'Общая сессия',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: AppText(
                    _label(state),
                    key: const Key('engine-session-status'),
                    localize: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  String _label(EngineSessionState state) {
    final snapshot = state.snapshot;
    if (snapshot == null)
      return state.connecting ? state.message : fallback ?? state.message;
    return '${snapshot.buildName} · ревизия ${snapshot.revision} · ${state.message}';
  }
}

class EngineSessionHistory extends StatelessWidget {
  const EngineSessionHistory({super.key, required this.cubit});
  final EngineSessionCubit cubit;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EngineSessionCubit, EngineSessionState>(
        bloc: cubit,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(state.message, localize: false),
            for (final change in state.changes.reversed)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: AppText(
                  'r${change.snapshot.revision} · ${change.description}',
                  localize: false,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      );
}
