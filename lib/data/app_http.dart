import 'dart:convert';
import 'dart:io';

import '../domain/app_info.dart';

typedef HttpClientFactory = HttpClient Function();

class AppHttp {
  AppHttp({HttpClientFactory? clientFactory, String? apiToken})
    : _factory = clientFactory ?? HttpClient.new,
      _apiToken = apiToken ?? Platform.environment['POB2_GITHUB_TOKEN'];
  final HttpClientFactory _factory;
  final String? _apiToken;

  HttpClient createClient() =>
      _factory()..connectionTimeout = const Duration(seconds: 20);

  static bool trusted(Uri uri) =>
      uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      uri.port == 443 &&
      const {
        'api.github.com',
        'github.com',
        'release-assets.githubusercontent.com',
        'objects.githubusercontent.com',
      }.contains(uri.host);

  Future<HttpClientResponse> get(
    HttpClient client,
    Uri uri, {
    int offset = 0,
  }) async {
    var current = uri;
    for (var attempt = 0; attempt < 6; attempt++) {
      if (!trusted(current))
        throw const HttpException('Небезопасный адрес обновления');
      final request = await client
          .getUrl(current)
          .timeout(const Duration(seconds: 25));
      request.followRedirects = false;
      request.headers.set('User-Agent', 'pob2-ui/$appVersion');
      request.headers.set('Accept', 'application/vnd.github+json');
      if (current.host == 'api.github.com' && _apiToken != null) {
        request.headers.set('Authorization', 'Bearer $_apiToken');
      }
      if (offset > 0)
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (![301, 302, 303, 307, 308].contains(response.statusCode))
        return response;
      final location = response.headers.value(HttpHeaders.locationHeader);
      await response.drain<void>();
      if (location == null)
        throw const HttpException('У перенаправления нет адреса');
      current = current.resolve(location);
    }
    throw const HttpException('Слишком много перенаправлений');
  }

  Future<String> readText(
    HttpClientResponse response, {
    int limit = 2 * 1024 * 1024,
  }) async {
    final bytes = <int>[];
    await for (final chunk in response.timeout(const Duration(seconds: 30))) {
      bytes.addAll(chunk);
      if (bytes.length > limit)
        throw const HttpException('Ответ превышает допустимый размер');
    }
    return utf8.decode(bytes);
  }
}
