import 'dart:async';
import 'dart:io';

import 'app_http.dart';
import 'pob_share_code.dart';

class PobShareLinks {
  PobShareLinks({Uri? origin, this.timeout = const Duration(seconds: 20)})
    : _origin = origin ?? Uri.https('pobb.in');

  static final _path = RegExp(r'^/([A-Za-z0-9_-]{1,128})/?$');
  final Uri _origin;
  final Duration timeout;
  final _http = AppHttp();

  Future<String> download(String link) async {
    final id = _buildId(link);
    final client = _http.createClient();
    try {
      return await _download(client, id).timeout(timeout);
    } on TimeoutException {
      throw const FormatException('Сайт pobb.in не ответил вовремя.');
    } on IOException {
      throw const FormatException('Не удалось загрузить сборку с pobb.in.');
    } finally {
      client.close(force: true);
    }
  }

  String _buildId(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'pobb.in' &&
        uri.port == 443 &&
        uri.userInfo.isEmpty) {
      final match = _path.firstMatch(uri.path);
      if (match != null) return match.group(1)!;
    }
    throw const FormatException('Введите ссылку на сборку с pobb.in.');
  }

  Future<String> _download(HttpClient client, String id) async {
    final request = await client.getUrl(_origin.resolve('/pob/$id'));
    request.followRedirects = false;
    final response = await request.close();
    if (response.statusCode == 404 || response.statusCode == 410) {
      throw const FormatException('Сборка по ссылке не найдена.');
    }
    if (response.statusCode != 200) {
      throw const FormatException('Не удалось загрузить сборку с pobb.in.');
    }
    final code = (await _http.readText(
      response,
      limit: pobShareCodeLimit,
    )).trim();
    if (code.isEmpty) {
      throw const FormatException('Некорректный или обрезанный код PoB.');
    }
    return code;
  }
}
