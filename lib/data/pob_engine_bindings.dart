import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'atomic_text_file.dart';

typedef EngineBindingKey = ({String folder, String id});
typedef SavedEngineBinding = ({
  String sessionId,
  String? fileHash,
  String? engineHash,
});

class PobEngineBindings {
  PobEngineBindings(this.root);

  final Directory root;
  final _files = AtomicTextFile();

  static String hash(String value) =>
      sha256.convert(utf8.encode(value)).toString();

  String initialSessionId(
    EngineBindingKey key,
    String source,
    DateTime updated,
  ) =>
      'build-${hash(jsonEncode([key.folder, key.id, hash(source), updated.toUtc().toIso8601String()])).substring(0, 32)}';

  File _file(EngineBindingKey key) {
    final name = hash(jsonEncode([key.folder, key.id]));
    return File.fromUri(root.uri.resolve('engine-bindings/$name.json'));
  }

  Future<SavedEngineBinding?> read(EngineBindingKey key) async {
    final raw = jsonDecode(await _files.read(_file(key), missing: 'null'));
    if (raw == null) return null;
    if (raw case {
      'session': final String session,
      'fileHash': final String? file,
      'engineHash': final String? engine,
    }) {
      return (sessionId: session, fileHash: file, engineHash: engine);
    }
    throw const FormatException('Повреждена привязка сборки к движку');
  }

  Future<void> move(EngineBindingKey previous, EngineBindingKey next) async {
    final value = await read(previous);
    if (value == null) return;
    await write(next, value);
    await forget(previous);
  }

  Future<void> forget(EngineBindingKey key) async {
    if (await read(key) != null) {
      await _files.write(_file(key), 'null', backup: true);
    }
  }

  Future<void> write(EngineBindingKey key, SavedEngineBinding value) =>
      _files.write(
        _file(key),
        jsonEncode({
          'session': value.sessionId,
          'fileHash': value.fileHash,
          'engineHash': value.engineHash,
        }),
        backup: true,
      );
}
