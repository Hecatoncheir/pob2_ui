import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';
import '../data/pob_window_repository.dart';
import '../domain/component.dart';

typedef PobBridgeTarget = ({List<String> candidates, String? directory});
typedef PobBridgeState = ({
  PobBridgeTarget target,
  bool busy,
  bool needsRestart,
  String? message,
  String? buildsPath,
  String? error,
});

class PobBridgeCubit extends Cubit<PobBridgeState> {
  PobBridgeCubit(this.repository, this.mcp)
    : super((
        target: (candidates: const [], directory: null),
        busy: false,
        needsRestart: false,
        message: null,
        buildsPath: null,
        error: null,
      ));

  final PobWindowRepository repository;
  final Installation mcp;

  Future<void> discover() => _run(() async {
    final candidates = await repository.findInstallations(mcp);
    _show((
      candidates: candidates,
      directory: candidates.length == 1 ? candidates.single : null,
    ));
  });

  void select(String directory) {
    if (state.busy) return;
    final candidates = state.target.candidates;
    _show((
      candidates: candidates.contains(directory)
          ? candidates
          : List.unmodifiable([...candidates, directory]),
      directory: directory,
    ), needsRestart: false);
  }

  Future<void> install() => _withDirectory((directory) async {
    await repository.installBridge(mcp, directory);
    return repository.canRestart
        ? 'Мост установлен. Перезапустите PoB для проверки связи.'
        : 'Перезапустите PoB через Wine и нажмите «Проверить связь».';
  }, needsRestart: true);

  Future<void> restart() => _withDirectory(
    (directory) async {
      await repository.restartAndCheckBridge(mcp, directory);
      return 'Связь с PoB подтверждена. Откройте сборку для импорта.';
    },
    needsRestart: false,
    progress: 'Если PoB попросит сохранить сборку, ответьте в его окне.',
  );

  Future<void> check() => _run(() async {
    final target = state.target;
    final directory = target.directory;
    if (directory == null) return;
    final buildsPath = await repository.checkBridge(mcp, directory);
    _show(
      target,
      message: 'Связь с PoB подтверждена',
      buildsPath: buildsPath,
      needsRestart: false,
    );
  });

  Future<void> _withDirectory(
    Future<String> Function(String directory) action, {
    bool? needsRestart,
    String? progress,
  }) async {
    final target = state.target;
    final directory = target.directory;
    if (directory == null) return;
    await _run(
      () async => _show(
        target,
        message: await action(directory),
        needsRestart: needsRestart,
      ),
      progress: progress,
    );
  }

  Future<void> _run(Future<void> Function() action, {String? progress}) async {
    if (isClosed || state.busy) return;
    _show(state.target, busy: true, message: progress);
    try {
      await action();
    } catch (error) {
      _show(state.target, error: mcpErrorMessage(error));
    }
  }

  void _show(
    PobBridgeTarget target, {
    bool busy = false,
    bool? needsRestart,
    String? message,
    String? buildsPath,
    String? error,
  }) {
    if (!isClosed) {
      emit((
        target: target,
        busy: busy,
        needsRestart: needsRestart ?? state.needsRestart,
        message: message,
        buildsPath: buildsPath,
        error: error,
      ));
    }
  }
}
