import 'dart:io';

import '../domain/app_release.dart';
import 'app_http.dart';
import 'file_digest.dart';

class DownloadCancelled implements Exception {}

class VerifiedDownload {
  VerifiedDownload({AppHttp? http, Future<String> Function(File)? digest})
    : http = http ?? AppHttp(),
      digest = digest ?? fileSha256;
  final AppHttp http;
  final Future<String> Function(File) digest;
  HttpClient? _client;
  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
    _client?.close(force: true);
  }

  Future<bool> verify(File file, AppAsset asset) async {
    if (asset.sha256 == null ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(asset.sha256!))
      return false;
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file)
      return false;
    return await file.length() == asset.size &&
        await digest(file) == asset.sha256;
  }

  Future<File> download(
    AppAsset asset,
    Directory directory, {
    required void Function(double) onProgress,
  }) async {
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(asset.name) ||
        asset.sha256 == null) {
      throw const FormatException(
        'Файл обновления не имеет проверяемой контрольной суммы',
      );
    }
    await directory.create(recursive: true);
    final file = File.fromUri(directory.uri.resolve(asset.name));
    if (await verify(file, asset)) {
      onProgress(1);
      return file;
    }
    final part = File('${file.path}.part');
    if (await FileSystemEntity.type(part.path, followLinks: false) ==
        FileSystemEntityType.link)
      throw const FileSystemException(
        'Вместо файла загрузки обнаружена ссылка',
      );
    var offset = await part.exists() ? await part.length() : 0;
    if (offset >= asset.size) {
      await part.delete();
      offset = 0;
    }
    _cancelled = false;
    final client = http.createClient();
    _client = client;
    try {
      final response = await http.get(client, asset.url, offset: offset);
      final resumed = response.statusCode == 206;
      if (response.statusCode != 200 && !resumed)
        throw HttpException('Загрузка: HTTP ${response.statusCode}');
      if (resumed && !_validRange(response, offset, asset.size))
        throw const HttpException('Неверный диапазон продолжения загрузки');
      if (!resumed) offset = 0;
      await _write(response, part, asset.size, offset, onProgress);
      if (!await verify(part, asset)) {
        await part.delete();
        throw const FormatException('Размер или SHA-256 обновления не совпал');
      }
      if (await file.exists()) await file.delete();
      return await part.rename(file.path);
    } catch (_) {
      if (_cancelled) throw DownloadCancelled();
      rethrow;
    } finally {
      _client = null;
      client.close(force: true);
    }
  }

  bool _validRange(HttpClientResponse response, int offset, int total) {
    final match = RegExp(
      r'^bytes (\d+)-(\d+)/(\d+)$',
    ).firstMatch(response.headers.value(HttpHeaders.contentRangeHeader) ?? '');
    return match != null &&
        int.parse(match[1]!) == offset &&
        int.parse(match[2]!) == total - 1 &&
        int.parse(match[3]!) == total;
  }

  Future<void> _write(
    HttpClientResponse response,
    File part,
    int total,
    int offset,
    void Function(double) onProgress,
  ) async {
    final sink = part.openWrite(
      mode: offset > 0 ? FileMode.append : FileMode.write,
    );
    var received = offset;
    try {
      await for (final chunk in response.timeout(const Duration(seconds: 45))) {
        if (_cancelled) throw DownloadCancelled();
        received += chunk.length;
        if (received > total)
          throw const HttpException('Пакет больше ожидаемого размера');
        sink.add(chunk);
        onProgress(received / total);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }
}
