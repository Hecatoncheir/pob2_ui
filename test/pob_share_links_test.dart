import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/pob_share_links.dart';

void main() {
  late HttpServer server;
  late PobShareLinks links;
  late List<Uri> requests;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    links = PobShareLinks(origin: Uri.http('127.0.0.1:${server.port}'));
    requests = [];
    server.listen((request) async {
      requests.add(request.uri);
      final response = request.response;
      if (request.uri.path == '/pob/redirect') {
        response.statusCode = HttpStatus.found;
        response.headers.set(HttpHeaders.locationHeader, '/other');
      } else {
        response.write('  TEST_CODE\n');
      }
      await response.close();
    });
  });

  test('Из ссылки pobb.in запрашивается только код указанной сборки', () async {
    expect(
      await links.download(' https://pobb.in/Witch-Ab_c/?view=tree#skills '),
      'TEST_CODE',
    );
    expect(requests, [Uri.parse('/pob/Witch-Ab_c')]);
  });

  test('Неподдерживаемые адреса отклоняются до HTTP-запроса', () async {
    for (final link in [
      '',
      'http://pobb.in/witch',
      'https://pobb.in.example.com/witch',
      'https://pobb.in:8443/witch',
      'https://user@pobb.in/witch',
      'https://pobb.in/',
      'https://pobb.in/pob/witch',
      'https://pobb.in/witch%2Fother',
    ]) {
      await expectLater(links.download(link), throwsFormatException);
    }
    expect(requests, isEmpty);
  });

  test('Импорт не переходит по перенаправлению сервера', () async {
    await expectLater(
      links.download('https://pobb.in/redirect'),
      throwsFormatException,
    );
    expect(requests, [Uri.parse('/pob/redirect')]);
  });
}
