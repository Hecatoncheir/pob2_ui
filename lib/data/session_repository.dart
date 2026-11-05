import 'dart:io';

class SessionRepository {
  SessionRepository(this.root);
  final Directory root;
  File get _file => File.fromUri(root.uri.resolve('session.xml'));
  Future<bool> exists() => _file.exists();
  Future<String> read() => _file.readAsString();

  Future<void> save(String xml) async {
    await root.create(recursive: true);
    final temporary = File.fromUri(root.uri.resolve('session.xml.tmp'));
    await temporary.writeAsString(xml, flush: true);
    await temporary.rename(_file.path);
  }
}
