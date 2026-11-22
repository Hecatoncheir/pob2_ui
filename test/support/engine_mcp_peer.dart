import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class EngineMcpPeer {
  EngineMcpPeer(this._process)
    : _lines = StreamIterator(
        _process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
      ),
      _stderr = _process.stderr.listen((_) {});

  final Process _process;
  final StreamIterator<String> _lines;
  final StreamSubscription<List<int>> _stderr;
  int _nextId = 0;
  bool _closed = false;

  Future<void> initialize() async {
    await request('initialize', {
      'protocolVersion': '2025-11-25',
      'capabilities': <String, dynamic>{},
      'clientInfo': {'name': 'flutter-session-test', 'version': '1'},
    });
    _process.stdin.writeln(
      jsonEncode({'jsonrpc': '2.0', 'method': 'notifications/initialized'}),
    );
  }

  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    final result = await request('tools/call', {
      'name': name,
      'arguments': arguments,
    });
    expect(result['isError'], isNot(true), reason: '${result['content']}');
    return result['structuredContent'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> request(
    String method,
    Map<String, dynamic> params,
  ) async {
    final id = ++_nextId;
    _process.stdin.writeln(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        'params': params,
      }),
    );
    while (await _lines.moveNext().timeout(const Duration(seconds: 5))) {
      final json = jsonDecode(_lines.current) as Map<String, dynamic>;
      if (json['id'] != id) continue;
      expect(json['error'], isNull);
      return json['result'] as Map<String, dynamic>;
    }
    throw StateError('MCP закрыл stdout');
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _process.stdin.close();
      await _process.exitCode.timeout(const Duration(seconds: 5));
    } finally {
      _process.kill();
      await _lines.cancel();
      await _stderr.cancel();
    }
  }
}
