import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';

class GitHubService {
  Future<Release> latest(Component component) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.getUrl(
        Uri.https(
          'api.github.com',
          '/repos/${component.repository}/releases/latest',
        ),
      );
      request.headers.set('User-Agent', 'pob2-ui/0.1.0');
      request.headers.set('Accept', 'application/vnd.github+json');
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw HttpException(
          'GitHub: HTTP ${response.statusCode}. '
          'Проверьте сеть и лимит запросов.',
        );
      }
      return Release.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } finally {
      client.close(force: true);
    }
  }
}
