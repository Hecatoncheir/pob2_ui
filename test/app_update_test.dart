import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/app_http.dart';
import 'package:pob2_ui/data/app_installer.dart';
import 'package:pob2_ui/data/app_release_service.dart';
import 'package:pob2_ui/data/file_digest.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/managed_installation.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/data/verified_download.dart';
import 'package:pob2_ui/domain/app_release.dart';
import 'package:pob2_ui/ui/app_update_cubit.dart';
import 'package:pob2_ui/ui/app_update_state.dart';

const digestAbc =
    'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';

class RoutedClient implements HttpClient {
  RoutedClient(this.server);
  final HttpServer server;
  final HttpClient inner = HttpClient();
  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      inner.getUrl(Uri.http('127.0.0.1:${server.port}', url.path));
  @override
  set connectionTimeout(Duration? value) => inner.connectionTimeout = value;
  @override
  void close({bool force = false}) => inner.close(force: force);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeInstaller extends AppInstaller {
  bool started = false;
  @override
  Future<void> start(
    File package,
    ManagedInstallation installation, {
    required String version,
  }) async {
    started = true;
  }
}

void main() {
  late Directory temporary;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('pob2-update-test-');
  });
  tearDown(() async {
    await temporary.delete(recursive: true);
  });

  test('Версии сравниваются числами; нестабильные теги отклоняются', () {
    expect(
      AppVersion.parse('v0.10.0').compareTo(AppVersion.parse('0.9.9')),
      greaterThan(0),
    );
    expect('${AppVersion.parse('1.2.3+4')}', '1.2.3');
    for (final value in ['v01.2.3', 'v1.2.3-beta', '../1.2.3', '1.2']) {
      expect(() => AppVersion.parse(value), throwsFormatException);
    }
  });

  test('Подмена источника и неподходящий пакет не принимаются', () {
    final name = installerName('1.2.3', 'windows-x64');
    final json = <String, dynamic>{
      'tag_name': 'v1.2.3',
      'assets': [
        {
          'name': name,
          'size': 3,
          'browser_download_url': 'https://evil.example/$name',
        },
      ],
    };
    expect(() => AppRelease.parse(json, 'windows-x64'), throwsFormatException);
    expect(AppRelease.parse(json, 'linux-x64')!.installer, isNull);
    expect(
      AppRelease.parse({...json, 'prerelease': true}, 'windows-x64'),
      isNull,
    );
    for (final url in [
      'http://github.com/a',
      'https://github.com.evil.test/a',
      'https://user@github.com/a',
      'https://github.com:444/a',
    ]) {
      expect(AppHttp.trusted(Uri.parse(url)), isFalse);
    }
  });

  test(
    'SHA-256 проверяет реальное содержимое, включая путь с пробелами',
    () async {
      final file = await File.fromUri(
        temporary.uri.resolve('данные%20с%20пробелом'),
      ).writeAsString('abc');
      expect(await fileSha256(file), digestAbc);
      final asset = AppAsset(
        name: 'test.run',
        url: Uri.https('github.com', '/test'),
        size: 3,
        sha256: digestAbc,
      );
      expect(await VerifiedDownload().verify(file, asset), isTrue);
      await file.writeAsString('abd');
      expect(await VerifiedDownload().verify(file, asset), isFalse);
    },
  );

  test('Загрузка продолжает Range и отклоняет неверную сумму', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    var range = '';
    server.listen((request) async {
      range = request.headers.value('range') ?? '';
      request.response.statusCode = 206;
      request.response.headers.set('content-range', 'bytes 1-2/3');
      request.response.write('bc');
      await request.response.close();
    });
    final http = AppHttp(clientFactory: () => RoutedClient(server));
    final asset = AppAsset(
      name: 'test.run',
      url: Uri.https('github.com', '/test'),
      size: 3,
      sha256: digestAbc,
    );
    await File.fromUri(temporary.uri.resolve('test.run.part'))
        .writeAsString('a');
    final result = await VerifiedDownload(http: http)
        .download(asset, temporary, onProgress: (_) {});
    expect(range, 'bytes=1-');
    expect(await result.readAsString(), 'abc');
    await result.delete();
    await File.fromUri(temporary.uri.resolve('test.run.part'))
        .writeAsString('x');
    await expectLater(
      VerifiedDownload(http: http)
          .download(asset, temporary, onProgress: (_) {}),
      throwsFormatException,
    );
    expect(
      await File.fromUri(temporary.uri.resolve('test.run.part')).exists(),
      isFalse,
    );
  });

  test('Перенаправление за пределы GitHub блокируется', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = 302;
      request.response.headers.set('location', 'https://evil.example/file');
      await request.response.close();
    });
    final http = AppHttp(clientFactory: () => RoutedClient(server));
    final client = http.createClient();
    addTearDown(() => client.close(force: true));
    await expectLater(
      http.get(client, Uri.https('github.com', '/test')),
      throwsA(isA<HttpException>()),
    );
  });

  test('404 означает отсутствие релиза, 500 — ошибку проверки', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    var status = 404;
    server.listen((request) async {
      request.response.statusCode = status;
      await request.response.close();
    });
    final service = AppReleaseService(
      http: AppHttp(clientFactory: () => RoutedClient(server)),
    );
    expect(await service.latest('windows-x64'), isNull);
    status = 500;
    await expectLater(
      service.latest('windows-x64'),
      throwsA(isA<HttpException>()),
    );
  });

  test('Неудачное сохранение сборки блокирует запуск установщика', () async {
    final file = await File.fromUri(temporary.uri.resolve('update.run'))
        .writeAsString('abc');
    final installer = FakeInstaller();
    final model = AppUpdateCubit(
      root: temporary,
      installer: installer,
      initialState: AppUpdateState(
        release: AppRelease(
          version: AppVersion.parse('9.0.0'),
          notes: '',
          installer: AppAsset(
            name: 'update.run',
            url: Uri.https('github.com', '/test'),
            size: 3,
            sha256: digestAbc,
          ),
        ),
        installation: ManagedInstallation(root: temporary, kind: 'linux-run'),
        package: file,
        phase: UpdatePhase.ready,
      ),
    );
    addTearDown(model.close);
    expect(
      await model.install(() async {
        throw StateError('Сохранение невозможно');
      }),
      isFalse,
    );
    expect(installer.started, isFalse);
    expect(await model.install(() async {}), isTrue);
    expect(installer.started, isTrue);
  });

  test('Черновик XML сохраняется отдельно от рассчитанной сборки', () async {
    final sessions = SessionRepository(temporary);
    await sessions.save('<build/>');
    await sessions.saveDraft('<незаконченный');
    expect(await sessions.read(), '<build/>');
    expect(await sessions.readDraft(), '<незаконченный');
  });

  test('Каталоги данных соответствуют каждой ОС', () {
    expect(
      InstallationStore.defaultRoot(
        system: 'linux',
        environment: {'HOME': '/home/test'},
      ).uri.path,
      endsWith('/home/test/.local/share/pob2_ui/'),
    );
    expect(
      InstallationStore.defaultRoot(
        system: 'linux',
        environment: {'HOME': '/home/test', 'XDG_DATA_HOME': '/data'},
      ).uri.path,
      endsWith('/data/pob2_ui/'),
    );
    expect(
      Uri.decodeComponent(
        InstallationStore.defaultRoot(
          system: 'macos',
          environment: {'HOME': '/Users/test'},
        ).uri.path,
      ),
      endsWith('/Users/test/Library/Application Support/pob2_ui/'),
    );
    expect(
      InstallationStore.defaultRoot(
        environment: {'POB2_UI_HOME': temporary.path},
      ).path,
      temporary.absolute.path,
    );
  });

  test(
    'Автоматическая загрузка выключена по умолчанию и сохраняется явно',
    () async {
      final model = AppUpdateCubit(root: temporary);
      addTearDown(model.close);
      expect(model.state.autoDownload, isFalse);
      await model.setAutoDownload(true);
      expect(jsonDecode(await model.preferences.readAsString()), {
        'autoDownload': true,
      });
    },
  );
}
