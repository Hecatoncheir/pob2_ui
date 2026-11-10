import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../domain/build_report.dart';
import 'atomic_text_file.dart';

typedef McpEditorRequest = Future<JsonMap> Function(
  String tool,
  JsonMap arguments,
  int? revision,
);

class McpEditorFault implements Exception {
  const McpEditorFault(this.code, this.message);
  final String code, message;
}

class McpEditorGateway {
  McpEditorGateway(Directory profile)
    : endpoint = File.fromUri(profile.uri.resolve('mcp-editor/endpoint.json'));

  final File endpoint;
  HttpServer? _server;
  String? _token;

  Future<void> start(McpEditorRequest execute) async {
    await endpoint.parent.create(recursive: true);
    if (!Platform.isWindows) {
      final permissions = await Process.run('chmod', [
        '700',
        endpoint.parent.path,
      ]);
      if (permissions.exitCode != 0) {
        throw FileSystemException(
          'Не удалось защитить каталог подключения MCP',
          endpoint.parent.path,
        );
      }
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final random = Random.secure();
    final token = base64UrlEncode(
      List.generate(32, (_) => random.nextInt(256)),
    );
    _server = server;
    _token = token;
    try {
      server.listen((request) => unawaited(_handle(request, token, execute)));
      await AtomicTextFile().write(
        endpoint,
        jsonEncode({'port': server.port, 'token': token}),
      );
    } catch (_) {
      await stop();
      rethrow;
    }
  }

  Future<void> stop() async {
    final server = _server;
    final token = _token;
    _server = null;
    _token = null;
    if (server == null) return;
    await server.close(force: true);
    try {
      if (jsonDecode(await endpoint.readAsString())
          case {'token': final String current} when current == token) {
        await endpoint.delete();
      }
    } on FileSystemException {
      // Закрытый порт недоступен даже при оставшемся файле подключения.
    } on FormatException {
      // Файл подключения мог заменить другой экземпляр приложения.
    }
  }

  Future<void> _handle(
    HttpRequest request,
    String token,
    McpEditorRequest execute,
  ) async {
    final response = request.response;
    try {
      response.headers.contentType = ContentType.json;
      if (_token != token ||
          request.headers.value(HttpHeaders.authorizationHeader) !=
              'Bearer $token') {
        response.statusCode = HttpStatus.unauthorized;
        return;
      }
      if (request.method != 'POST' || request.uri.path != '/edit') {
        response.statusCode = HttpStatus.notFound;
        return;
      }
      response.write(jsonEncode(await _execute(request, token, execute)));
    } on IOException {
      // Клиент мог завершиться во время расчёта.
    } finally {
      await response.close().catchError((Object _) {});
    }
  }

  Future<JsonMap> _execute(
    HttpRequest request,
    String token,
    McpEditorRequest execute,
  ) async {
    try {
      final body = await _read(request).timeout(const Duration(seconds: 10));
      if (_token != token)
        throw const McpEditorFault(
          'EDITOR_DISABLED',
          'Доступ к редактору PoB II отключён.',
        );
      if (jsonDecode(body) case {
        'tool': final String tool,
        'arguments': final JsonMap arguments,
        'revision': final int? revision,
      }) {
        return await execute(tool, arguments, revision);
      }
      throw const FormatException();
    } on McpEditorFault catch (error) {
      return {
        'error': {'code': error.code, 'message': error.message},
      };
    } on FormatException {
      return _invalidRequest;
    } on TimeoutException {
      return _invalidRequest;
    } catch (_) {
      return {
        'error': {
          'code': 'EDITOR_FAILED',
          'message': 'Редактор PoB II не выполнил команду.',
        },
      };
    }
  }

  Future<String> _read(HttpRequest request) async {
    final bytes = <int>[];
    await for (final chunk in request) {
      if (bytes.length + chunk.length > 8 * 1024 * 1024)
        throw const FormatException();
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes);
  }
}

const _invalidRequest = {
  'error': {
    'code': 'INVALID_REQUEST',
    'message': 'Некорректная команда редактора PoB II.',
  },
};
