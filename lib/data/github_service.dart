import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'app_http.dart';

class GitHubService {
  GitHubService({AppHttp? http}) : http = http ?? AppHttp();
  final AppHttp http;

  Future<Release> latest(Component component) async {
    final client = http.createClient();
    try {
      final response = await http.get(
        client,
        Uri.https(
          'api.github.com',
          '/repos/${component.repository}/releases/latest',
        ),
      );
      if (response.statusCode != 200) {
        throw HttpException(
          'GitHub: HTTP ${response.statusCode}. '
          'Проверьте сеть и лимит запросов.',
        );
      }
      final body = await http.readText(response);
      return Release.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } finally {
      client.close(force: true);
    }
  }
}
