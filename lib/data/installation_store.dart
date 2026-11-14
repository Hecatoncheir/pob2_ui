import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'atomic_text_file.dart';

class InstallationStore {
  InstallationStore(this.root);
  final Directory root;
  final _files = AtomicTextFile();
  Installations previous = {};
  File get _manifest => File.fromUri(root.uri.resolve('components.json'));

  static Directory defaultRoot({
    String? system,
    Map<String, String>? environment,
  }) {
    final variables = environment ?? Platform.environment;
    final explicit = variables['POB2_UI_HOME'];
    if (explicit != null) return Directory(explicit).absolute;
    final operatingSystem = system ?? Platform.operatingSystem;
    if (operatingSystem == 'windows') {
      final base = variables['LOCALAPPDATA'];
      if (base == null) throw StateError('Не найден LOCALAPPDATA');
      return Directory.fromUri(Directory(base).uri.resolve('pob2_ui/'));
    }
    final home = variables['HOME'];
    if (home == null) throw StateError('Не найден домашний каталог');
    if (operatingSystem == 'macos')
      return Directory.fromUri(
        Directory(home).uri.resolve('Library/Application%20Support/pob2_ui/'),
      );
    final data = variables['XDG_DATA_HOME'];
    final base = data == null
        ? Directory.fromUri(Directory(home).uri.resolve('.local/share/'))
        : Directory(data);
    return Directory.fromUri(base.uri.resolve('pob2_ui/'));
  }

  Future<Installations> load() async {
    final saved = await read();
    previous = saved.previous;
    return saved.active;
  }

  Future<({Installations active, Installations previous})> read() async {
    if (!await _manifest.exists()) {
      return (
        active: <Component, Installation>{},
        previous: <Component, Installation>{},
      );
    }
    final data =
        jsonDecode(await _manifest.readAsString()) as Map<String, dynamic>;
    if (data['schema'] != 1)
      throw const FormatException('Неизвестная версия настроек');
    return (
      active: _decode(data['active'] as Map<String, dynamic>),
      previous: _decode(data['previous'] as Map<String, dynamic>),
    );
  }

  Installations _decode(Map<String, dynamic> data) => {
    for (final component in Component.values)
      if (data[component.name] != null)
        component: Installation.fromJson(
          data[component.name] as Map<String, dynamic>,
        ),
  };

  Future<void> save(Installations active, Installations old) async {
    await _files.write(
      _manifest,
      const JsonEncoder.withIndent('  ').convert({
        'schema': 1,
        'active': _encode(active),
        'previous': _encode(old),
      }),
    );
    previous = Map.of(old);
  }

  Map<String, dynamic> _encode(Installations items) => {
    for (final entry in items.entries) entry.key.name: entry.value.toJson(),
  };
}
