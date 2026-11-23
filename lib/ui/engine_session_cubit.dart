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

typedef EngineSupportOffer = ({
  String sessionId,
  int connectionId,
  EngineSupportSelection selection,
  EngineSupportPreview preview,
});

typedef EngineEquipmentOffer = ({
  String sessionId,
  int connectionId,
  EngineEquipmentEdit edit,
  EngineEquipmentPreview preview,
});

typedef EngineTreeOffer = ({
  String sessionId,
  int connectionId,
  EngineTreeEdit edit,
  EngineTreePreview preview,
});

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
  int _connectionId = 0;
  Future<void> _applying = Future.value();

  Future<void> connect(
    EngineOptions options, {
    String? createName,
    String? createXml,
  }) async {
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
              xml: createXml,
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

  Future<void> waitForSnapshot() => _applying;

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

  Future<EngineSnapshot> setCondition(
    EngineSnapshot current,
    String name,
    Object? value,
  ) async {
    try {
      return await _connectedTo(current)
          .setCondition(current, name, value, engineRequestId());
    } on GrpcError catch (error) {
      throw StateError(engineError(error));
    }
  }

  Future<void> calculate(EngineSnapshot current) =>
      _connectedTo(current).calculate(current, engineRequestId());

  bool get supportsAddSupport =>
      state.connected && (_connection?.supportsAddSupport ?? false);

  Future<EngineSupportPage> findSupports(
    EngineSnapshot current,
    String query,
    int offset,
  ) => _connectedTo(current).findSupports(query, offset);

  Future<EngineSupportOffer> previewSupport(
    EngineSnapshot current,
    EngineSupportSelection selection,
  ) async {
    final connectionId = _connectionId;
    final preview = await _connectedTo(current)
        .previewSupport(current, selection);
    return (
      sessionId: current.sessionId,
      connectionId: connectionId,
      selection: selection,
      preview: preview,
    );
  }

  bool isCurrentSupportOffer(EngineSupportOffer offer) =>
      supportsAddSupport &&
      _isCurrentOffer(
        offer.sessionId,
        offer.connectionId,
        offer.preview.revision,
      );

  Future<void> addSupport(EngineSupportOffer offer) async {
    if (!isCurrentSupportOffer(offer)) {
      throw StateError('Выполните предпросмотр для текущей ревизии');
    }
    if (!offer.preview.compatible) {
      throw StateError('PoB не подтвердил совместимость поддержки');
    }
    final snapshot = state.snapshot!;
    await _connectedTo(snapshot)
        .addSupport(snapshot, offer.selection, engineRequestId());
  }

  bool get supportsEquipmentPreview =>
      state.connected && (_connection?.supportsEquipmentPreview ?? false);

  Future<EngineEquipmentOffer> previewEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
  ) async {
    final connectionId = _connectionId;
    final preview = await _connectedTo(current).previewEquipment(current, edit);
    return (
      sessionId: current.sessionId,
      connectionId: connectionId,
      edit: edit,
      preview: preview,
    );
  }

  bool isCurrentEquipmentOffer(EngineEquipmentOffer offer) =>
      supportsEquipmentPreview &&
      _isCurrentOffer(
        offer.sessionId,
        offer.connectionId,
        offer.preview.revision,
      );

  Future<void> editEquipment(EngineEquipmentOffer offer) async {
    if (!isCurrentEquipmentOffer(offer)) {
      throw StateError('Выполните предпросмотр для текущей ревизии');
    }
    final snapshot = state.snapshot!;
    await _connectedTo(snapshot)
        .editEquipment(snapshot, offer.edit, engineRequestId());
  }

  bool get supportsTreePreview =>
      state.connected && (_connection?.supportsTreePreview ?? false);

  bool get supportsTreeAttributes =>
      state.connected && (_connection?.supportsTreeAttributes ?? false);

  bool get supportsTreeAllocationModes =>
      state.connected && (_connection?.supportsTreeAllocationModes ?? false);

  bool get supportsTreeSockets =>
      state.connected && (_connection?.supportsTreeSockets ?? false);

  Future<EnginePassivePage> findPassives(
    EngineSnapshot current,
    String version,
    String query,
    int offset,
  ) => _connectedTo(current).findPassives(version, query, offset);

  Future<EngineTreeOffer> previewTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
  ) async {
    final connectionId = _connectionId;
    final preview = await _connectedTo(current).previewTree(current, edit);
    return (
      sessionId: current.sessionId,
      connectionId: connectionId,
      edit: edit,
      preview: preview,
    );
  }

  bool isCurrentTreeOffer(EngineTreeOffer offer) =>
      supportsTreePreview &&
      _isCurrentOffer(
        offer.sessionId,
        offer.connectionId,
        offer.preview.comparison.revision,
      );

  Future<EngineSnapshot> editTree(EngineTreeOffer offer) async {
    if (!isCurrentTreeOffer(offer)) {
      throw StateError('Выполните предпросмотр для текущей ревизии');
    }
    final snapshot = state.snapshot!;
    try {
      return await _connectedTo(snapshot)
          .editTree(snapshot, offer.edit, engineRequestId());
    } on GrpcError catch (error) {
      throw StateError(engineError(error));
    }
  }

  bool _isCurrentOffer(String sessionId, int connectionId, int revision) =>
      connectionId == _connectionId &&
      sessionId == state.snapshot?.sessionId &&
      revision == state.snapshot?.revision;

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
    _connectionId++;
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
