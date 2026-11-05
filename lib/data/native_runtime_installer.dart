import 'dart:convert';
import 'dart:io';

import '../domain/app_release.dart';
import 'app_http.dart';
import 'managed_installation.dart';
import 'process_service.dart';
import 'verified_download.dart';

class NativeRuntimeInstaller {
  NativeRuntimeInstaller({AppHttp? http, VerifiedDownload? download})
    : http = http ?? AppHttp(),
      download = download ?? VerifiedDownload();
  final AppHttp http;
  final VerifiedDownload download;

  Future<void> install(
    Directory candidate,
    String tag,
    ProcessService processes,
    void Function(String) log,
  ) async {
    if (Platform.isWindows) return;
    final target = currentAppTarget();
    if (target == null)
      throw UnsupportedError('Нет Lua runtime для этой архитектуры');
    final name = 'pob-poe2-mcp-native-$target.zip';
    log('Загрузка LuaJIT и lua-utf8 для $target…');
    final asset = await _metadata(tag, name);
    final cache = Directory.fromUri(candidate.uri.resolve('.native-download/'));
    final package = await download.download(asset, cache, onProgress: (_) {});
    final python = await processes.python();
    await processes.run(python, [
      '-X',
      'utf8',
      '-c',
      extractionScript,
      package.path,
      candidate.path,
    ]);
  }

  Future<AppAsset> _metadata(String tag, String name) async {
    final client = http.createClient();
    try {
      final response = await http.get(
        client,
        Uri.https(
          'api.github.com',
          '/repos/Hecatoncheir/pob-poe2-mcp/releases/tags/$tag',
        ),
      );
      if (response.statusCode != 200)
        throw HttpException('Нативный выпуск MCP: HTTP ${response.statusCode}');
      final data =
          jsonDecode(await http.readText(response)) as Map<String, dynamic>;
      final assets = (data['assets'] as List<dynamic>)
          .whereType<Map<String, dynamic>>();
      final matches = assets.where((value) => value['name'] == name).toList();
      if (matches.length != 1)
        throw StateError('В $tag нет $name; требуется MCP 0.4.0 или новее');
      return await _asset(client, matches.single, tag, name);
    } finally {
      client.close(force: true);
    }
  }

  Future<AppAsset> _asset(
    HttpClient client,
    Map<String, dynamic> raw,
    String tag,
    String name,
  ) async {
    final expected = Uri.parse(
      'https://github.com/Hecatoncheir/pob-poe2-mcp/releases/download/$tag/$name',
    );
    if (raw['browser_download_url'] != '$expected')
      throw const FormatException('Неожиданный источник Lua runtime');
    final size = raw['size'] as int;
    if (size <= 0 || size > 100 * 1024 * 1024)
      throw const FormatException('Некорректный размер Lua runtime');
    return AppAsset(
      name: name,
      url: expected,
      size: size,
      sha256: await _digest(client, raw, tag, name),
    );
  }

  Future<String> _digest(
    HttpClient client,
    Map<String, dynamic> raw,
    String tag,
    String name,
  ) async {
    final digest = RegExp(r'^sha256:([a-fA-F0-9]{64})$')
        .firstMatch(raw['digest'] as String? ?? '')?[1]
        ?.toLowerCase();
    if (digest != null) return digest;
    final response = await http.get(
      client,
      Uri.parse(
        'https://github.com/Hecatoncheir/pob-poe2-mcp/releases/download/$tag/SHA256SUMS',
      ),
    );
    if (response.statusCode != 200)
      throw const HttpException('Нет контрольной суммы Lua runtime');
    final text = await http.readText(response, limit: 64 * 1024);
    final lines = RegExp(
      r'^([a-fA-F0-9]{64}) [ *]' + RegExp.escape(name) + r'$',
      multiLine: true,
    ).allMatches(text.replaceAll('\r', '')).toList();
    if (lines.length != 1)
      throw const FormatException(
        'Неоднозначная контрольная сумма Lua runtime',
      );
    return lines.single[1]!.toLowerCase();
  }

  static const extractionScript = r'''
import pathlib, stat, sys, zipfile
root = pathlib.Path(sys.argv[2]) / 'pob_poe2_mcp' / 'native'
if root.exists() or root.is_symlink():
    raise ValueError('Каталог native уже существует')
allowed = {'libluajit-5.1.so.2', 'libluajit-5.1.dylib', 'lua-utf8.so', 'LICENSE-LuaJIT.txt', 'LICENSE-luautf8.txt', 'sources.json'}
with zipfile.ZipFile(sys.argv[1]) as archive:
    seen = set()
    total = 0
    for item in archive.infolist():
        path = pathlib.PurePosixPath(item.filename)
        if len(path.parts) != 2 or path.parts[0] != 'native' or path.parts[1] not in allowed or item.is_dir():
            raise ValueError('Недопустимый путь в архиве native')
        if path.name in seen or stat.S_ISLNK(item.external_attr >> 16):
            raise ValueError('Ссылка или повторяющийся файл в архиве native')
        total += item.file_size
        if total > 100 * 1024 * 1024:
            raise ValueError('Архив native слишком велик')
        seen.add(path.name)
    if 'lua-utf8.so' not in seen or not seen.intersection({'libluajit-5.1.so.2', 'libluajit-5.1.dylib'}):
        raise ValueError('В архиве нет обязательных библиотек')
    root.mkdir()
    for item in archive.infolist():
        (root / pathlib.PurePosixPath(item.filename).name).write_bytes(archive.read(item))
''';
}
