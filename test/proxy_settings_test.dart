import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/app_http.dart';
import 'package:pob2_ui/data/proxy_http_overrides.dart';
import 'package:pob2_ui/data/proxy_preferences.dart';
import 'package:pob2_ui/domain/proxy_settings.dart';

void main() {
  group('Режимы прокси', () {
    test('Ручной адрес нормализуется с сохранением явного порта', () {
      expect(ProxySettings.manual('proxy.local:080').address, 'proxy.local:80');
      expect(
        ProxySettings.manual(' HTTP://Proxy.Local:3128 ').address,
        'proxy.local:3128',
      );
      expect(ProxySettings.manual('http://[::1]:8080').address, '[::1]:8080');
    });

    test('Неверный адрес отклоняется до сохранения', () {
      for (final address in [
        '',
        'proxy.local',
        'proxy.local:0',
        'proxy.local:65536',
        'proxy.local:a',
        'proxy..local:8080',
        'http://user:pass@proxy.local:8080',
        'http://proxy.local:8080/',
        'http://proxy.local:8080?query',
        'http://proxy.local:8080#fragment',
        'http://proxy.local:8080;DIRECT',
        'http://proxy.local:8080\r\nx: y',
        'https://proxy.local:8080',
        'socks5://proxy.local:8080',
        '::1:8080',
        '[123.0.0.1]:8080',
      ]) {
        expect(() => ProxySettings.manual(address), throwsFormatException);
      }
    });

    test('Локальные адреса всегда открываются напрямую', () {
      for (final settings in [
        const ProxySettings.automatic(),
        const ProxySettings.direct(),
        ProxySettings.manual('proxy.local:8080'),
      ]) {
        for (final url in [
          'http://localhost:8954/',
          'http://localhost.:8954/',
          'http://127.0.0.1:8954/',
          'http://127.42.0.2:8954/',
          'http://[::1]:8954/',
          'http://[::ffff:127.0.0.1]:8954/',
        ]) {
          expect(settings.findProxy(Uri.parse(url)), 'DIRECT', reason: url);
        }
      }
    });

    test('Сетевые запросы используют выбранный режим', () {
      final uri = Uri.https('updates.invalid', '/latest');
      expect(
        const ProxySettings.automatic().findProxy(uri),
        HttpClient.findProxyFromEnvironment(uri),
      );
      expect(const ProxySettings.direct().findProxy(uri), 'DIRECT');
      expect(
        ProxySettings.manual('[::1]:8080').findProxy(uri),
        'PROXY [::1]:8080',
      );
    });

    test('Движок получает прокси или явный сброс окружения', () {
      final manual = ProxySettings.manual('proxy.local:8080').engineEnvironment;
      final direct = const ProxySettings.direct().engineEnvironment;
      expect(const ProxySettings.automatic().engineEnvironment, isEmpty);
      expect(manual['HTTP_PROXY'], 'http://proxy.local:8080');
      expect(manual['HTTPS_PROXY'], 'http://proxy.local:8080');
      expect(manual['ALL_PROXY'], '');
      expect(manual['NO_PROXY'], contains('127.0.0.0/8'));
      expect(manual['NO_PROXY'], contains('::1'));
      expect(direct.keys, unorderedEquals(manual.keys));
      expect(direct.values, everyElement(isEmpty));
      if (Platform.isWindows) {
        expect(manual, isNot(contains('http_proxy')));
      } else {
        expect(manual['http_proxy'], manual['HTTP_PROXY']);
        expect(manual['https_proxy'], manual['HTTPS_PROXY']);
        expect(manual['no_proxy'], manual['NO_PROXY']);
      }
    });
  });

  group('Сохранение прокси', () {
    late Directory profile;
    late ProxyPreferences preferences;

    setUp(() async {
      profile = await Directory.systemTemp.createTemp('pob2-proxy-test-');
      preferences = ProxyPreferences(profile);
    });

    tearDown(() => profile.delete(recursive: true));

    test('Сохраняет выбранный режим между запусками', () async {
      for (final settings in [
        ProxySettings.manual('http://proxy.local:8080'),
        const ProxySettings.direct(),
        const ProxySettings.automatic(),
      ]) {
        await preferences.save(settings);
        expect(await ProxyPreferences(profile).load(), settings);
      }
    });

    test(
      'Старый или повреждённый профиль использует автоматический режим',
      () async {
        expect(await preferences.load(), const ProxySettings.automatic());
        final file = File.fromUri(profile.uri.resolve('proxy.json'));
        for (final content in [
          '{',
          '{"mode":"direct"}',
          '{"schema":2,"mode":"direct"}',
          '{"schema":1,"mode":"manual","address":"user:pass@proxy.local:8080"}',
        ]) {
          await file.writeAsString(content);
          expect(await preferences.load(), const ProxySettings.automatic());
        }
      },
    );
  });

  test('Действующий HTTP-клиент применяет новый адрес прокси', () async {
    final proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => proxy.close(force: true));
    proxy.listen((request) async {
      request.response.write(request.uri.toString());
      await request.response.close();
    });

    var settings = const ProxySettings.direct();
    final client = ProxyHttpOverrides(() => settings).createHttpClient(null);
    addTearDown(() => client.close(force: true));

    final local = Uri.http('127.0.0.1:${proxy.port}', '/local');
    final remote = Uri.http('updates.invalid', '/latest');
    expect(await _get(client, local), '/local');
    settings = ProxySettings.manual('127.0.0.1:${proxy.port}');
    expect(await _get(client, remote), remote.toString());
    expect(await _get(client, local), '/local');
  });

  test(
    'Загрузчик обновлений запрашивает туннель к GitHub через прокси',
    () async {
      final proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => proxy.close(force: true));
      final received = proxy.first.then((request) async {
        request.response.statusCode = HttpStatus.badGateway;
        await request.response.close();
        return (request.method, request.uri.toString());
      });

      final settings = ProxySettings.manual('127.0.0.1:${proxy.port}');
      final http = AppHttp();
      final client = HttpOverrides.runWithHttpOverrides(
        http.createClient,
        ProxyHttpOverrides(() => settings),
      );
      addTearDown(() => client.close(force: true));

      final url = Uri.https(
        'release-assets.githubusercontent.com',
        '/installer',
      );
      await expectLater(http.get(client, url), throwsA(isA<HttpException>()));
      expect(await received, (
        'CONNECT',
        'release-assets.githubusercontent.com:443',
      ));
    },
  );
}

Future<String> _get(HttpClient client, Uri url) async {
  final response = await (await client.getUrl(url)).close();
  return utf8.decoder.bind(response).join();
}
