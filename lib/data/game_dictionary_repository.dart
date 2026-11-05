import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '../domain/app_language.dart';
import '../domain/game_dictionary.dart';
import 'app_http.dart';
import 'file_digest.dart';
import 'game_locale_catalog.dart';

class GameDictionaryRepository {
  GameDictionaryRepository(this.root, {HttpClientFactory? clientFactory})
    : _clientFactory = clientFactory ?? HttpClient.new;
  final Directory root;
  final HttpClientFactory _clientFactory;
  GameDictionary? _last;
  final _pending = <AppLanguage, Future<GameDictionary>>{};
  final _packs = <String, Future<File>>{};

  Future<GameDictionary> load(AppLanguage language) async {
    if (language == AppLanguage.english) return GameDictionary.english();
    if (_last?.language == language.code) return _last!;
    final existing = _pending[language];
    if (existing != null) return existing;
    final future = _load(language);
    _pending[language] = future;
    try {
      return await future;
    } finally {
      _pending.remove(language);
    }
  }

  Future<GameDictionary> _load(AppLanguage language) async {
    final english = await _pack('en');
    final selected = await _pack(language.code);
    final result = await Isolate.run(
      () => GameDictionary(
        language.code,
        Map<String, String>.from(jsonDecode(english.readAsStringSync()) as Map),
        Map<String, String>.from(
          jsonDecode(selected.readAsStringSync()) as Map,
        ),
      ),
    );
    _last = result;
    return result;
  }

  Future<File> _pack(String code) async {
    final existing = _packs[code];
    if (existing != null) return existing;
    final future = _ensurePack(code);
    _packs[code] = future;
    try {
      return await future;
    } finally {
      _packs.remove(code);
    }
  }

  Future<File> _ensurePack(String code) async {
    final metadata = gameLocaleAssets[code]!;
    final folder = Directory.fromUri(
      root.uri.resolve('translations/$gameLocaleCommit/'),
    );
    final file = File.fromUri(folder.uri.resolve('$code.json'));
    if (await _valid(file, metadata)) return file;
    await folder.create(recursive: true);
    await _download(file, code, metadata.size);
    if (!await _valid(file, metadata)) {
      await file.delete();
      throw const FormatException('Контрольная сумма перевода не совпала');
    }
    return file;
  }

  Future<bool> _valid(File file, ({int size, String sha256}) metadata) async =>
      await file.exists() &&
      await file.length() == metadata.size &&
      await fileSha256(file) == metadata.sha256;

  Future<void> _download(File file, String code, int size) async {
    final client = _clientFactory()
      ..connectionTimeout = const Duration(seconds: 20);
    final temporary = File(
      '${file.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      final uri = Uri.https(
        'raw.githubusercontent.com',
        '/gw1108/PathOfExile_Translated/$gameLocaleCommit/dist/poe2/full/$code.json',
      );
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 25));
      request.followRedirects = false;
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != 200)
        throw HttpException('Перевод: HTTP ${response.statusCode}');
      await _write(response, temporary, size);
      await temporary.rename(file.path);
    } finally {
      client.close(force: true);
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<void> _write(HttpClientResponse response, File file, int limit) async {
    final sink = file.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.timeout(const Duration(seconds: 45))) {
        received += chunk.length;
        if (received > limit)
          throw const FormatException('Перевод больше ожидаемого размера');
        sink.add(chunk);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }
}
