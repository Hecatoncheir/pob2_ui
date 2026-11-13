import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pob_window_repository.dart';
import '../domain/component.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'pob_bridge_cubit.dart';

Future<void> showPobBridgeSetup(
  BuildContext context,
  PobWindowRepository repository,
  Installation mcp,
) => sparkDialog<void>(
  context,
  barrierDismissible: false,
  BlocProvider(
    create: (_) => PobBridgeCubit(repository, mcp)..discover(),
    child: const _PobBridgeDialog(),
  ),
);

class _PobBridgeDialog extends StatelessWidget {
  const _PobBridgeDialog();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PobBridgeCubit, PobBridgeState>(
        builder: (context, state) {
          final cubit = context.read<PobBridgeCubit>();
          final ready = !state.busy && state.target.directory != null;
          return PopScope(
            canPop: !state.busy,
            child: AlertDialog(
              scrollable: true,
              title: const AppText('Локальный мост PoB'),
              content: SizedBox(width: 500, child: _BridgeContent(state)),
              actions: [
                TextButton(
                  onPressed: state.busy ? null : () => Navigator.pop(context),
                  child: const AppText('Закрыть'),
                ),
                OutlinedButton(
                  onPressed: ready ? cubit.check : null,
                  child: const AppText('Проверить связь'),
                ),
                if (!state.needsRestart || cubit.repository.canRestart)
                  _primaryAction(cubit, ready, state.needsRestart),
              ],
            ),
          );
        },
      );

  Widget _primaryAction(PobBridgeCubit cubit, bool enabled, bool restart) {
    final action = restart ? cubit.restart : cubit.install;
    return FilledButton(
      onPressed: enabled ? action : null,
      child: AppText(restart ? 'Перезапустить PoB' : 'Подключить мост'),
    );
  }
}

class _BridgeContent extends StatelessWidget {
  const _BridgeContent(this.state);
  final PobBridgeState state;

  @override
  Widget build(BuildContext context) {
    final colors = Spark.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InstallationChoice(state),
        TextButton.icon(
          onPressed: state.busy ? null : () => _pick(context),
          icon: const Icon(Icons.folder_open_outlined, size: 18),
          label: const AppText('Выбрать папку'),
        ),
        if (state.busy) const LinearProgressIndicator(),
        if (state.message case final message?)
          AppText(
            message,
            style: TextStyle(color: state.busy ? colors.muted : colors.green),
          ),
        if (state.buildsPath case final path?) SelectableText(path),
        if (state.error case final error?)
          AppText(error, style: TextStyle(color: colors.danger)),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final directory = await getDirectoryPath(
      initialDirectory: state.target.directory,
    );
    if (context.mounted && directory != null) {
      context.read<PobBridgeCubit>().select(directory);
    }
  }
}

class _InstallationChoice extends StatelessWidget {
  const _InstallationChoice(this.state);
  final PobBridgeState state;

  @override
  Widget build(BuildContext context) {
    final (:candidates, :directory) = state.target;
    if (candidates.length > 1) return _dropdown(context);
    if (directory != null) return SelectableText(directory);
    return state.busy || state.error != null
        ? const SizedBox.shrink()
        : const AppText('PoB не найден. Выберите папку с приложением.');
  }

  Widget _dropdown(BuildContext context) => DropdownButton<String>(
    key: const Key('pob-bridge-installation'),
    isExpanded: true,
    value: state.target.directory,
    hint: const AppText('Выберите установку PoB'),
    items: [
      for (final candidate in state.target.candidates)
        DropdownMenuItem(
          value: candidate,
          child: Text(candidate, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: state.busy ? null : (path) => _select(context, path),
  );

  void _select(BuildContext context, String? path) {
    if (path != null) context.read<PobBridgeCubit>().select(path);
  }
}
