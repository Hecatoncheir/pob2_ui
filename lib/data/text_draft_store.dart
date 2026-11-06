import 'dart:io';

import 'atomic_text_file.dart';

class TextDraftStore {
  TextDraftStore(this.root, {AtomicTextFile? files})
    : files = files ?? AtomicTextFile();
  final Directory root;
  final AtomicTextFile files;
  final Map<String, String> _unsaved = {};
  Future<void> _pending = Future.value();

  File _file(String name) {
    if (name == 'draft.xml') return File.fromUri(root.uri.resolve(name));
    if (!RegExp(r'^[a-f0-9]{32}\.md$').hasMatch(name)) {
      throw const FormatException('Некорректный идентификатор заметок');
    }
    return File.fromUri(root.uri.resolve('notes/$name'));
  }

  Future<String> read(String name) => _unsaved.containsKey(name)
      ? Future.value(_unsaved[name])
      : files.read(_file(name), missing: '');

  Future<void> save(String name, String text) {
    _file(name);
    _unsaved[name] = text;
    return flush();
  }

  Future<void> flush() {
    if (_unsaved.isEmpty) return Future.value();
    _pending = _pending.catchError((Object _) {}).then((_) => _drain());
    return _pending;
  }

  Future<void> _drain() async {
    while (_unsaved.isNotEmpty) {
      final entry = _unsaved.entries.first;
      await files.write(_file(entry.key), entry.value, backup: true);
      if (_unsaved[entry.key] == entry.value) _unsaved.remove(entry.key);
    }
  }
}
