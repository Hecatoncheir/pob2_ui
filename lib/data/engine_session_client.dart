import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:pob2_engine_api/pob2/v1/session.pbgrpc.dart' as pb;

import '../domain/engine_session.dart';

abstract interface class EngineConnection {
  Future<EngineSnapshot> snapshot(String sessionId);
  Future<EngineSnapshot> create(
    String sessionId,
    String name,
    String requestId,
  );
  Future<EngineSnapshot> rename(
    EngineSnapshot current,
    String name,
    String requestId,
  );
  Stream<EngineChange> watch(String sessionId, int afterRevision);
  Future<void> close();
}

String engineRequestId() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

// Дочерний connect владеет обнаружением и одной арендой приложения.
class EngineSessionClient implements EngineConnection {
  EngineSessionClient._(
    this._helper,
    this._output,
    this._errors,
    this._channel,
    this._rpc,
  );
  final Process _helper;
  final StreamSubscription<String> _output;
  final StreamSubscription<List<int>> _errors;
  final ClientChannel _channel;
  final pb.SessionServiceClient _rpc;
  bool _closed = false;

  static Future<EngineConnection> open(EngineOptions options) async {
    final helper = await Process.start(options.executable, [
      'connect',
      '--kind',
      'ui',
      '--connection-json',
      '--start-server',
      '--profile',
      options.profile,
      if (options.runtimeDirectory.isNotEmpty) ...[
        '--runtime-dir',
        options.runtimeDirectory,
      ],
      if (options.dataDirectory.isNotEmpty) ...[
        '--data-dir',
        options.dataDirectory,
      ],
    ]);
    final first = Completer<String>();
    final output = helper.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (!first.isCompleted) first.complete(line);
          },
          onError: (Object error) {
            if (!first.isCompleted) first.completeError(error);
          },
          onDone: () {
            if (!first.isCompleted)
              first.completeError(
                StateError('Движок не сообщил параметры подключения'),
              );
          },
        );
    // Диагностика процесса может содержать локальные пути; токен не журналируется.
    final errors = helper.stderr.listen((_) {});
    ClientChannel? channel;
    try {
      final credentials = _decodeCredentials(
        await first.future.timeout(const Duration(seconds: 12)),
      );
      channel = ClientChannel(
        credentials.host,
        port: credentials.port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );
      final rpc = pb.SessionServiceClient(
        channel,
        options: CallOptions(
          metadata: {
            'authorization': 'Bearer ${credentials.token}',
            'pob2-lease': credentials.lease,
          },
        ),
      );
      final info = await rpc.getServerInfo(
        pb.GetServerInfoRequest(),
        options: CallOptions(timeout: const Duration(seconds: 5)),
      );
      _validateServer(info, credentials.instance);
      return EngineSessionClient._(helper, output, errors, channel, rpc);
    } catch (_) {
      await channel?.terminate();
      helper.kill();
      await output.cancel();
      await errors.cancel();
      rethrow;
    }
  }

  static ({String host, int port, String token, String lease, String instance})
  _decodeCredentials(String line) {
    try {
      return _credentials(jsonDecode(line));
    } on FormatException {
      throw const FormatException(
        'Движок вернул некорректные параметры подключения',
      );
    }
  }

  static ({String host, int port, String token, String lease, String instance})
  _credentials(dynamic json) {
    if (json case {
      'address': final String address,
      'token': final String token,
      'lease_id': final String lease,
      'instance_id': final String instance,
      'protocol_version': 'pob2.v1',
    }) {
      final uri = Uri.tryParse('http://$address');
      if (uri != null &&
          uri.host == '127.0.0.1' &&
          uri.port > 0 &&
          token.isNotEmpty &&
          lease.isNotEmpty &&
          instance.isNotEmpty) {
        return (
          host: uri.host,
          port: uri.port,
          token: token,
          lease: lease,
          instance: instance,
        );
      }
    }
    throw const FormatException(
      'Движок вернул несовместимые параметры подключения',
    );
  }

  static void _validateServer(pb.GetServerInfoResponse info, String instance) {
    if (info.protocolVersion != 'pob2.v1' ||
        info.instanceId != instance ||
        info.state != 'ready' ||
        !info.capabilities.contains('session.events')) {
      throw const FormatException(
        'Сервер не поддерживает подписки общей сессии',
      );
    }
  }

  static EngineSnapshot _snapshot(pb.SessionSnapshot value) =>
      EngineSnapshot(value.sessionId, value.buildName, value.revision.toInt());
  CallOptions get _timeout => CallOptions(timeout: const Duration(seconds: 5));

  @override
  Future<EngineSnapshot> snapshot(String sessionId) async => _snapshot(
    (await _rpc.getSnapshot(
      pb.GetSnapshotRequest(sessionId: sessionId),
      options: _timeout,
    )).snapshot,
  );
  @override
  Future<EngineSnapshot> create(
    String sessionId,
    String name,
    String requestId,
  ) async => _snapshot(
    (await _rpc.createSession(
      pb.CreateSessionRequest(
        sessionId: sessionId,
        buildName: name,
        requestId: requestId,
      ),
      options: _timeout,
    )).snapshot,
  );
  @override
  Future<EngineSnapshot> rename(
    EngineSnapshot current,
    String name,
    String requestId,
  ) async => _snapshot(
    (await _rpc.renameBuild(
      pb.RenameBuildRequest(
        sessionId: current.sessionId,
        buildName: name,
        expectedRevision: Int64(current.revision),
        requestId: requestId,
      ),
      options: _timeout,
    )).snapshot,
  );

  @override
  Stream<EngineChange> watch(String sessionId, int afterRevision) => _rpc
      .watchSession(
        pb.WatchSessionRequest(
          sessionId: sessionId,
          afterRevision: Int64(afterRevision),
        ),
      )
      .map(
        (event) => EngineChange(
          snapshot: _snapshot(event.snapshot),
          kind: event.kind,
          requestId: event.requestId,
          previousName: event.previousBuildName,
          fields: List.unmodifiable(event.changedFields),
        ),
      );

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _channel.terminate();
    try {
      await _helper.stdin.close();
    } on IOException {
      /* Процесс уже завершился. */
    }
    try {
      await _helper.exitCode.timeout(const Duration(seconds: 3));
    } on TimeoutException {
      _helper.kill();
    }
    await _output.cancel();
    await _errors.cancel();
  }
}
