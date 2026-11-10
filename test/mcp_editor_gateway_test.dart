import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/mcp_editor_gateway.dart';

import 'support/temporary_directory.dart';

void main() {
  test('Редактор принимает команды только по токену открытой сессии', () async {
    final profile = await Directory.systemTemp.createTemp('pob2-editor-test-');
    addTearDown(() => removeTemporaryDirectory(profile));
    final gateway = McpEditorGateway(profile);
    addTearDown(gateway.stop);
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    var calls = 0;
    await gateway.start((tool, arguments, revision) async {
      calls++;
      expect(tool, 'pob_tree_action');
      expect(arguments, {'id': 42, 'action': 'allocate'});
      expect(revision, 9);
      return {
        'result': {'allocated': true},
        'revision': 10,
      };
    });
    final endpoint = jsonDecode(
      await gateway.endpoint.readAsString(),
    ) as Map<String, dynamic>;
    final uri = Uri.http('127.0.0.1:${endpoint['port']}', '/edit');
    expect(
      (await _request(client, uri, 'bad')).status,
      HttpStatus.unauthorized,
    );
    expect(calls, 0);
    final result = await _request(client, uri, endpoint['token'] as String);
    expect(result.status, HttpStatus.ok);
    expect(jsonDecode(result.body), {
      'result': {'allocated': true},
      'revision': 10,
    });
    expect(calls, 1);
    await gateway.stop();
    expect(await gateway.endpoint.exists(), isFalse);
    await expectLater(
      _request(client, uri, endpoint['token'] as String),
      throwsA(isA<IOException>()),
    );
  });
}

Future<({int status, String body})> _request(
  HttpClient client,
  Uri uri,
  String token,
) async {
  final request = await client.postUrl(uri);
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  request.write(
    jsonEncode({
      'tool': 'pob_tree_action',
      'arguments': {'id': 42, 'action': 'allocate'},
      'revision': 9,
    }),
  );
  final response = await request.close();
  return (
    status: response.statusCode,
    body: await utf8.decoder.bind(response).join(),
  );
}
