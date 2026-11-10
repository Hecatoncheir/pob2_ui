import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';
import '../data/pob_window_repository.dart';
import '../domain/component.dart';

typedef PobBridgeTarget = ({List<String> candidates, String? directory});
typedef PobBridgeState = ({
  PobBridgeTarget target,
  bool busy,
  String? message,
  String? error,
});

class PobBridgeCubit extends Cubit<PobBridgeState> {
  PobBridgeCubit(this.repository, this.mcp)
    : super((
        target: (candidates: const [], directory: null),
        busy: false,
        message: null,
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
    ));
  }

  Future<void> install() => _withDirectory((directory) async {
    await repository.installBridge(mcp, directory);
    return 'Мост установлен. Перезапустите PoB, откройте сборку и проверьте связь.';
  });

  Future<void> check() => _withDirectory((directory) async {
    await repository.checkBridge(mcp, directory);
    return 'Связь с открытой сборкой PoB подтверждена';
  });

  Future<void> _withDirectory(
    Future<String> Function(String directory) action,
  ) async {
    final target = state.target;
    final directory = target.directory;
    if (directory == null) return;
    await _run(() async => _show(target, message: await action(directory)));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isClosed || state.busy) return;
    _show(state.target, busy: true);
    try {
      await action();
    } catch (error) {
      _show(state.target, error: mcpErrorMessage(error));
    }
  }

  void _show(
    PobBridgeTarget target, {
    bool busy = false,
    String? message,
    String? error,
  }) {
    if (!isClosed) {
      emit((target: target, busy: busy, message: message, error: error));
    }
  }
}
