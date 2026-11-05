import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';

class InstallationStore {
  InstallationStore(this.root);
  final Directory root;
  Installations previous = {};
  File get _manifest => File.fromUri(root.uri.resolve('components.json'));

  static Directory defaultRoot() {
    final explicit = Platform.environment['POB2_UI_HOME'];
    if (explicit != null) return Directory(explicit).absolute;
    final base = Platform.environment['LOCALAPPDATA'];
    if (base == null) throw StateError('Не найден LOCALAPPDATA');
    return Directory.fromUri(Directory(base).uri.resolve('pob2_ui/'));
  }

  Future<Installations> load() async {
    if (!await _manifest.exists()) return {};
    final data =
        jsonDecode(await _manifest.readAsString()) as Map<String, dynamic>;
    if (data['schema'] != 1)
      throw const FormatException('Неизвестная версия настроек');
    previous = _decode(data['previous'] as Map<String, dynamic>);
    return _decode(data['active'] as Map<String, dynamic>);
  }

  Installations _decode(Map<String, dynamic> data) => {
    for (final component in Component.values)
      if (data[component.name] != null)
        component: Installation.fromJson(
          data[component.name] as Map<String, dynamic>,
        ),
  };

  Future<void> save(Installations active, Installations old) async {
    await root.create(recursive: true);
    final temporary = File.fromUri(root.uri.resolve('components.json.tmp'));
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'schema': 1,
        'active': _encode(active),
        'previous': _encode(old),
      }),
      flush: true,
    );
    await temporary.rename(_manifest.path);
    previous = Map.of(old);
  }

  Map<String, dynamic> _encode(Installations items) => {
    for (final entry in items.entries) entry.key.name: entry.value.toJson(),
  };
}
