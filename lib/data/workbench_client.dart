import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:pob2_engine_api/pob2/v1/workbench.pbgrpc.dart' as api;

import '../domain/component.dart';
import 'bundled_engine.dart';

class WorkbenchClient {
  WorkbenchClient([String? executable])
    : executable = executable ?? defaultEngineExecutable();

  final String executable;
  final diagnostics = StringBuffer();
  Set<String> tools = const {};
  void Function(Object)? onDisconnected;
  Process? _worker;
  ClientChannel? _channel;
  api.WorkbenchServiceClient? _rpc;
  final _subscriptions = <StreamSubscription<String>>[];

  bool get connected => _rpc != null;

  Future<void> connect(Installations pair) async {
    await close();
    final pob = pair[Component.pob]!;
    diagnostics.clear();
    final worker = await Process.start(
      executable,
      ['workbench', '--grpc'],
      environment: {
        'POB2_ENGINE_POB_DIR': pob.directory,
        'POB2_ENGINE_POB_NATIVE_DIR': pob.nativeDirectory ?? '',
      },
    );
    _worker = worker;
    final ready = Completer<String>();
    _readWorker(worker, ready);
    try {
      final credentials = _decodeReady(
        await ready.future.timeout(const Duration(seconds: 90)),
      );
      final channel = _channel = ClientChannel(
        '127.0.0.1',
        port: credentials.port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );
      final rpc = api.WorkbenchServiceClient(
        channel,
        options: CallOptions(
          metadata: {'authorization': 'Bearer ${credentials.token}'},
        ),
      );
      final result = await rpc.listWorkbenchTools(
        api.ListWorkbenchToolsRequest(),
        options: CallOptions(timeout: const Duration(seconds: 5)),
      );
      if (_worker != worker) throw StateError('Рабочая копия закрыта');
      tools = result.names.toSet();
      _rpc = rpc;
    } catch (_) {
      if (_worker == worker) await close();
      rethrow;
    }
  }

  void _readWorker(Process worker, Completer<String> ready) {
    _subscriptions.add(
      worker.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!ready.isCompleted) ready.complete(line);
            },
            onError: (Object error) {
              if (!ready.isCompleted) ready.completeError(error);
            },
            onDone: () {
              if (!ready.isCompleted) {
                ready.completeError(
                  StateError('Движок завершился. $diagnostics'),
                );
              }
            },
          ),
    );
    _subscriptions.add(
      worker.stderr
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(_recordDiagnostic),
    );
    unawaited(worker.exitCode.then((_) => _workerStopped(worker)));
  }

  void _recordDiagnostic(String text) {
    if (diagnostics.length > 16000) diagnostics.clear();
    diagnostics.write(text);
  }

  Future<void> _workerStopped(Process worker) async {
    if (_worker != worker || !connected) return;
    final error = StateError('Движок завершился. $diagnostics');
    await close();
    onDisconnected?.call(error);
  }

  ({int port, String token}) _decodeReady(String line) {
    if (jsonDecode(line)
        case {'address': final String address, 'token': final String token}
        when token.isNotEmpty) {
      final endpoint = Uri.tryParse('http://$address');
      if (endpoint?.host == '127.0.0.1' &&
          endpoint!.hasPort &&
          endpoint.port > 0 &&
          endpoint.port <= 65535) {
        return (port: endpoint.port, token: token);
      }
    }
    throw const FormatException('Некорректный адрес рабочей копии движка');
  }

  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async => (await callWithContent(name, arguments)).result;

  Future<String> exportBuildXml() async =>
      switch (await call('pob_export_xml')) {
        {'xml': final String xml} when xml.trim().isNotEmpty => xml,
        _ => throw const FormatException('Lua не вернул XML сборки'),
      };

  Future<({Map<String, dynamic> result, List<dynamic> content})>
  callWithContent(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    final rpc = _rpc;
    if (rpc == null) throw StateError('Подключите Lua');
    final reply = await _callTool(rpc, name, arguments);
    if (reply.hasError()) {
      throw StateError(
        jsonEncode({'code': reply.error.code, 'message': reply.error.message}),
      );
    }
    return (
      result: jsonDecode(utf8.decode(reply.resultJson)) as Map<String, dynamic>,
      content: [
        if (reply.png.isNotEmpty)
          {
            'type': 'image',
            'mimeType': 'image/png',
            'data': base64Encode(reply.png),
          },
      ],
    );
  }

  Future<api.CallWorkbenchToolResponse> _callTool(
    api.WorkbenchServiceClient rpc,
    String name,
    Map<String, dynamic> arguments,
  ) async {
    try {
      return await rpc.callWorkbenchTool(
        api.CallWorkbenchToolRequest(
          name: name,
          argumentsJson: utf8.encode(jsonEncode(arguments)),
        ),
        options: CallOptions(timeout: const Duration(seconds: 90)),
      );
    } on GrpcError catch (error) {
      if (error.code == StatusCode.deadlineExceeded ||
          error.code == StatusCode.unavailable) {
        if (_rpc == rpc) await close();
        throw StateError('Связь с движком потеряна. Повторно откройте сборку.');
      }
      rethrow;
    }
  }

  Future<void> close() async {
    final worker = _worker;
    final channel = _channel;
    final subscriptions = [..._subscriptions];
    _worker = null;
    _channel = null;
    _rpc = null;
    _subscriptions.clear();
    tools = const {};
    await channel?.terminate();
    if (worker != null) await _stopWorker(worker);
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  }

  Future<void> _stopWorker(Process worker) async {
    await worker.stdin.close();
    try {
      await worker.exitCode.timeout(const Duration(seconds: 4));
    } on TimeoutException {
      worker.kill();
      await worker.exitCode;
    }
  }
}
