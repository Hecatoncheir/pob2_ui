import 'dart:io';

class SessionRepository {
  SessionRepository(this.root);
  final Directory root;
  File get _file => File.fromUri(root.uri.resolve('session.xml'));
  Future<bool> exists() => _file.exists();
  Future<String> read() => _file.readAsString();
  File get _draft => File.fromUri(root.uri.resolve('draft.xml'));
  Future<String> readDraft() async =>
      await _draft.exists() ? _draft.readAsString() : '';
  Future<void> saveDraft(String xml) => _save('draft.xml', xml);

  Future<void> save(String xml) => _save('session.xml', xml);

  Future<void> _save(String name, String xml) async {
    await root.create(recursive: true);
    final temporary = File.fromUri(root.uri.resolve('$name.tmp'));
    await temporary.writeAsString(xml, flush: true);
    await temporary.rename(File.fromUri(root.uri.resolve(name)).path);
  }
}
