import 'dart:async';
import 'dart:io';

import '../domain/app_info.dart';
import '../domain/build_import_link.dart';
import 'app_http.dart';
import 'pob_share_code.dart';

class PobShareLinks {
  PobShareLinks({Uri? origin, this.timeout = const Duration(seconds: 20)})
    : _origin = origin;

  final Uri? _origin;
  final Duration timeout;
  final _http = AppHttp();

  Future<String> download(String link) async {
    final source = BuildImportLink.parse(link);
    if (source.needsExport) throw const FormatException(poeNinjaExportHint);
    final client = _http.createClient();
    try {
      return await _download(client, source).timeout(timeout);
    } on TimeoutException {
      throw FormatException('Сайт ${source.site} не ответил вовремя.');
    } on IOException {
      throw FormatException('Не удалось загрузить сборку с ${source.site}.');
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _download(HttpClient client, BuildImportLink source) async {
    final uri = _origin?.resolve(source.download!.path) ?? source.download!;
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'PoB-II/$appVersion (+https://github.com/$appRepository)',
    );
    final response = await request.close();
    if (response.statusCode == 404 || response.statusCode == 410) {
      throw const FormatException('Сборка по ссылке не найдена.');
    }
    if (response.statusCode != 200) {
      throw FormatException('Не удалось загрузить сборку с ${source.site}.');
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
