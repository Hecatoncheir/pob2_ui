import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'process_service.dart';

class McpClient {
  Process? _process;
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  final _subscriptions = <StreamSubscription<dynamic>>[];
  int _counter = 0;
  final diagnostics = StringBuffer();
  bool get connected => _process != null;
  Set<String> tools = const {};
  void Function(Object)? onDisconnected;

  Future<void> connect(Installations pair) =>
      _connect(pair[Component.mcp]!, 'engine', pair[Component.pob]!.directory);

  Future<void> connectToPobWindow(Installation mcp, {String? directory}) =>
      _connect(mcp, 'app', directory);

  Future<void> _connect(
    Installation mcp,
    String mode,
    String? pobDirectory,
  ) async {
    await close();
    final python = await ProcessService().python();
    final process = await Process.start(python, [
      '-X',
      'utf8',
      'run.py',
      'serve',
      '--mode',
      mode,
      if (pobDirectory != null) ...['--pob-dir', pobDirectory],
    ], workingDirectory: mcp.directory);
    _process = process;
    diagnostics.clear();
    _subscriptions.add(
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _receive,
            onError: _fail,
            onDone: () {
              if (_process != process) return;
              _process = null;
              final error = StateError('MCP завершился. $diagnostics');
              _fail(error);
              onDisconnected?.call(error);
            },
          ),
    );
    _subscriptions.add(
      process.stderr.transform(const Utf8Decoder(allowMalformed: true)).listen((
        value,
      ) {
        if (diagnostics.length > 16000) diagnostics.clear();
        diagnostics.write(value);
      }),
    );
    try {
      await request('initialize', {
        'protocolVersion': '2024-11-05',
        'capabilities': <String, dynamic>{},
        'clientInfo': {'name': 'pob2_ui', 'version': '0.1.0'},
      });
      process.stdin.writeln(
        jsonEncode({'jsonrpc': '2.0', 'method': 'notifications/initialized'}),
      );
      final available = await request('tools/list');
      tools = (available['tools'] as List<dynamic>)
          .map((tool) => (tool as Map<String, dynamic>)['name'] as String)
          .toSet();
    } catch (_) {
      await close();
      rethrow;
    }
  }

  void _receive(String line) {
    try {
      final message = jsonDecode(line) as Map<String, dynamic>;
      final pending = _pending.remove(message['id']);
      if (pending == null) return;
      if (message['error'] != null) {
        pending.completeError(StateError('${message['error']}'));
        return;
      }
      pending.complete(message['result'] as Map<String, dynamic>);
    } catch (error) {
      _fail(error);
    }
  }

  void _fail(Object error) {
    for (final pending in _pending.values) {
      if (!pending.isCompleted) pending.completeError(error);
    }
    _pending.clear();
  }

  Future<Map<String, dynamic>> request(
    String method, [
    Map<String, dynamic> params = const {},
  ]) async {
    final process = _process;
    if (process == null) throw StateError('Подключите Lua');
    final id = ++_counter;
    final pending = Completer<Map<String, dynamic>>();
    _pending[id] = pending;
    try {
      process.stdin.writeln(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'method': method,
          'params': params,
        }),
      );
      return await pending.future.timeout(const Duration(seconds: 90));
    } on TimeoutException {
      // Ответ на изменение мог потеряться. Не повторяем операцию автоматически.
      await close();
      throw StateError(
        'Нет ответа MCP. Сессия закрыта; повторно импортируйте XML.',
      );
    } finally {
      _pending.remove(id);
    }
  }

  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    final response = await request('tools/call', {
      'name': name,
      'arguments': arguments,
    });
    if (response['isError'] == true) {
      final content = response['content'] as List<dynamic>;
      throw StateError(
        content
            .map((item) => (item as Map<String, dynamic>)['text'])
            .join('\n'),
      );
    }
    final structured = response['structuredContent'] as Map<String, dynamic>?;
    if (structured != null) return structured['result'] as Map<String, dynamic>;
    final content = response['content'] as List<dynamic>;
    final text = (content.first as Map<String, dynamic>)['text'] as String;
    return (jsonDecode(text) as Map<String, dynamic>)['result']
        as Map<String, dynamic>;
  }

  Future<String> exportBuildXml() async =>
      switch (await call('pob_export_xml')) {
        {'xml': final String xml} when xml.trim().isNotEmpty => xml,
        _ => throw const FormatException('Lua не вернул XML сборки'),
      };

  Future<void> close() async {
    final process = _process;
    _process = null;
    tools = const {};
    _fail(StateError('Сессия закрыта'));
    if (process != null) {
      await process.stdin.close();
      try {
        await process.exitCode.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        process.kill();
      }
    }
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
