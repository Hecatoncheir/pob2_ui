import 'dart:convert';
import 'dart:io';

import '../domain/app_info.dart';
import '../domain/app_release.dart';
import 'app_http.dart';

class AppReleaseService {
  AppReleaseService({AppHttp? http}) : http = http ?? AppHttp();
  final AppHttp http;

  Future<AppRelease?> latest(String target) async {
    final client = http.createClient();
    try {
      final response = await http.get(
        client,
        Uri.https('api.github.com', '/repos/$appRepository/releases/latest'),
      );
      if (response.statusCode == 404) {
        await response.drain<void>();
        return null;
      }
      if (response.statusCode != 200)
        throw HttpException('Проверка выпуска: HTTP ${response.statusCode}');
      final json =
          jsonDecode(await http.readText(response)) as Map<String, dynamic>;
      final release = AppRelease.parse(json, target);
      if (release?.installer == null || release!.installer!.sha256 != null)
        return release;
      final digest = await _manifestDigest(client, json, release);
      return release.withInstaller(
        digest == null ? null : release.installer!.withDigest(digest),
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<String?> _manifestDigest(
    HttpClient client,
    Map<String, dynamic> json,
    AppRelease release,
  ) async {
    final assets = json['assets'] as List<dynamic>? ?? [];
    final hasSums = assets.whereType<Map<String, dynamic>>().any(
      (asset) => asset['name'] == 'SHA256SUMS',
    );
    if (!hasSums) return null;
    final response = await http.get(
      client,
      Uri.parse('$appReleasesUrl/download/v${release.version}/SHA256SUMS'),
    );
    if (response.statusCode != 200)
      throw const HttpException('Не удалось получить SHA256SUMS');
    final contents = await http.readText(response, limit: 64 * 1024);
    final expression = RegExp(
      r'^([a-fA-F0-9]{64}) [ *]' +
          RegExp.escape(release.installer!.name) +
          r'$',
      multiLine: true,
    );
    final matches = expression
        .allMatches(contents.replaceAll('\r', ''))
        .toList();
    if (matches.length != 1)
      throw const FormatException('Нет единственной контрольной суммы пакета');
    return matches.single[1]!.toLowerCase();
  }
}
