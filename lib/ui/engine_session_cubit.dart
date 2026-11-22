import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grpc/grpc.dart';

import '../data/engine_session_client.dart';
import '../domain/engine_session.dart';

class EngineSessionState {
  const EngineSessionState({
    this.options = const EngineOptions(),
    this.snapshot,
    this.connected = false,
    this.connecting = false,
    this.message = 'Общая сессия не подключена',
    this.changes = const [],
  });
  final EngineOptions options;
  final EngineSnapshot? snapshot;
  final bool connected;
  final bool connecting;
  final String message;
  final List<EngineChange> changes;
}

class EngineSessionCubit extends Cubit<EngineSessionState> {
  EngineSessionCubit({
    Future<EngineConnection> Function(EngineOptions)? open,
    this.onSnapshot,
  }) : _open = open ?? EngineSessionClient.open,
       super(const EngineSessionState());
  final Future<EngineConnection> Function(EngineOptions) _open;
  final Future<void> Function(EngineSnapshot)? onSnapshot;
  EngineConnection? _connection;
  // Подписка закрывается в _disposeConnection при смене сессии и close.
  // ignore: cancel_subscriptions
  StreamSubscription<EngineChange>? _watch;
  Timer? _retry;
  int _generation = 0;
  Future<void> _applying = Future.value();

  Future<void> connect(EngineOptions options, {String? createName}) async {
    final releasing = disconnect();
    final generation = _generation;
    await releasing;
    if (generation != _generation || isClosed) return;
    emit(
      EngineSessionState(
        options: options,
        connecting: true,
        message: 'Подключение…',
      ),
    );
    try {
      final connection = await _open(options);
      if (generation != _generation) {
        await connection.close();
        return;
      }
      _connection = connection;
      final snapshot = createName == null
          ? await connection.snapshot(options.sessionId)
          : await connection.create(
              options.sessionId,
              createName,
              engineRequestId(),
            );
      if (generation != _generation) return;
      _accept(EngineChange(snapshot: snapshot, kind: 'snapshot'), generation);
      _subscribe(connection, snapshot.revision, generation);
    } catch (error) {
      if (generation != _generation) return;
      await _disposeConnection();
      emit(EngineSessionState(options: options, message: engineError(error)));
      rethrow;
    }
  }

  void _subscribe(EngineConnection connection, int revision, int generation) {
    _watch = connection
        .watch(state.options.sessionId, revision)
        .listen(
          (event) => _accept(event, generation),
          onError: (Object error) => _lost(error, generation),
          onDone: () => _lost(StateError('Поток изменений закрыт'), generation),
          cancelOnError: true,
        );
  }

  void _accept(EngineChange event, int generation) {
    if (generation != _generation || isClosed) return;
    if (event.snapshot.revision <= (state.snapshot?.revision ?? 0)) return;
    final changes = [...state.changes, event];
    emit(
      EngineSessionState(
        options: state.options,
        snapshot: event.snapshot,
        connected: true,
        message: event.description,
        changes: List.unmodifiable(
          changes.skip(changes.length > 8 ? changes.length - 8 : 0),
        ),
      ),
    );
    _applying = _applying.then(
      (_) => _applySnapshot(event.snapshot, generation),
    );
  }

  Future<void> _applySnapshot(EngineSnapshot snapshot, int generation) async {
    if (generation != _generation) return;
    try {
      await onSnapshot?.call(snapshot);
    } catch (error) {
      if (generation == _generation && !isClosed)
        _status(
          'Не удалось применить снимок: $error',
          connected: state.connected,
          connecting: state.connecting,
        );
    }
  }

  void _status(
    String message, {
    bool connected = true,
    bool connecting = false,
  }) => emit(
    EngineSessionState(
      options: state.options,
      snapshot: state.snapshot,
      connected: connected,
      connecting: connecting,
      message: message,
      changes: state.changes,
    ),
  );

  void _lost(Object error, int generation) {
    if (generation != _generation || _retry != null || isClosed) return;
    _status(
      '${engineError(error)}. Переподключение…',
      connected: false,
      connecting: true,
    );
    _retry = Timer(const Duration(seconds: 1), () {
      _retry = null;
      unawaited(_reconnect(generation));
    });
  }

  Future<void> _reconnect(int generation) async {
    if (generation != _generation) return;
    try {
      await _disposeConnection();
      if (generation != _generation) return;
      final connection = await _open(state.options);
      if (generation != _generation) {
        await connection.close();
        return;
      }
      _connection = connection;
      final snapshot = await connection.snapshot(state.options.sessionId);
      if (generation != _generation) return;
      final revision = state.snapshot?.revision ?? 0;
      if (snapshot.revision < revision)
        throw StateError(
          'Сервер вернул более старую сессию; подключите её заново',
        );
      _status('Соединение восстановлено');
      _subscribe(connection, revision, generation);
    } catch (error) {
      _lost(error, generation);
    }
  }

  Future<void> rename(String name) async {
    final current = state.snapshot;
    final connection = _connection;
    if (!state.connected || current == null || connection == null)
      throw StateError('Нет соединения с общей сессией');
    // Ответ может быть старее уже полученного события; состояние меняет поток.
    await connection.rename(current, name.trim(), engineRequestId());
  }

  Future<void> setLevel(EngineSnapshot current, int level) =>
      _connectedTo(current).setLevel(current, level, engineRequestId());

  Future<void> calculate(EngineSnapshot current) =>
      _connectedTo(current).calculate(current, engineRequestId());

  EngineConnection _connectedTo(EngineSnapshot current) {
    final connection = _connection;
    if (!state.connected ||
        connection == null ||
        state.snapshot?.sessionId != current.sessionId) {
      throw StateError('Нет соединения с общей сессией');
    }
    return connection;
  }

  Future<void> _disposeConnection() async {
    final watch = _watch;
    final connection = _connection;
    _watch = null;
    _connection = null;
    await watch?.cancel();
    await connection?.close();
  }

  Future<void> disconnect() async {
    _generation++;
    _retry?.cancel();
    _retry = null;
    await _disposeConnection();
    if (!isClosed) emit(EngineSessionState(options: state.options));
  }

  @override
  Future<void> close() async {
    await disconnect();
    await super.close();
  }
}

String engineError(Object error) => switch (error) {
  GrpcError(code: StatusCode.notFound) => 'Сессия не найдена. Создайте её явно',
  GrpcError(code: StatusCode.alreadyExists) =>
    'Сессия уже существует. Подключитесь без создания',
  GrpcError(code: StatusCode.aborted) =>
    'Сборка изменилась. Дождитесь новой ревизии и повторите действие',
  GrpcError(code: StatusCode.unavailable) => 'Движок недоступен',
  _ => '$error',
};
