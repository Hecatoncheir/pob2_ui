import 'dart:io';

import 'package:path/path.dart' as path;

import 'process_service.dart';

class PobBuildLocations {
  PobBuildLocations({
    String? system,
    Map<String, String>? environment,
    Future<String> Function()? windowsDocuments,
  }) : _system = system ?? Platform.operatingSystem,
       _environment = environment ?? Platform.environment,
       _windowsDocuments = windowsDocuments ?? _knownWindowsDocuments;

  final String _system;
  final Map<String, String> _environment;
  final Future<String> Function() _windowsDocuments;

  static const _pob = 'Path of Building (PoE2)';

  Future<String?> find() async {
    final found = <String>{};
    for (final candidate in await _candidates()) {
      final directory = Directory(candidate);
      if (await directory.exists()) {
        found.add(await directory.resolveSymbolicLinks());
      }
    }
    if (found.length > 1) {
      throw StateError('Найдено несколько папок PoB. Выберите нужную вручную.');
    }
    return found.singleOrNull;
  }

  Future<List<String>> _candidates() async {
    if (_system == 'windows') {
      final documents = await _windowsDocuments();
      return path.isAbsolute(documents) ? [_builds(documents)] : [];
    }
    final home = _environment['HOME'];
    if (home == null || !path.isAbsolute(home)) return [];
    return switch (_system) {
      'macos' => [
        _builds(path.join(home, 'Library', 'Application Support')),
        _builds(path.join(home, 'Documents')),
      ],
      'linux' => _linuxCandidates(home),
      _ => [],
    };
  }

  Future<List<String>> _linuxCandidates(String home) async {
    final data = _environment['XDG_DATA_HOME'];
    final native = data != null && path.isAbsolute(data)
        ? data
        : path.join(home, '.local', 'share');
    final flatpak = path.join(
      home,
      '.var',
      'app',
      'community.pathofbuilding.PathOfBuilding',
      'data',
    );
    return [
      for (final root in [native, flatpak])
        _builds(path.join(root, 'RustyPathOfBuilding2', 'userdata')),
      ...await _wineCandidates(home),
    ];
  }

  Future<List<String>> _wineCandidates(String home) async {
    final prefix = _environment['WINEPREFIX'];
    final root = prefix != null && path.isAbsolute(prefix)
        ? prefix
        : path.join(home, '.wine');
    final users = Directory(path.join(root, 'drive_c', 'users'));
    if (!await users.exists()) return [];
    return [
      await for (final user in users.list(followLinks: false))
        if (user is Directory) ...[
          _builds(path.join(user.path, 'Documents')),
          _builds(path.join(user.path, 'My Documents')),
        ],
    ];
  }

  static String _builds(String parent) => path.join(parent, _pob, 'Builds');

  static Future<String> _knownWindowsDocuments() async {
    try {
      return await ProcessService().run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'[Console]::OutputEncoding = [Text.Encoding]::UTF8; [Environment]::GetFolderPath("MyDocuments")',
      ], timeout: const Duration(seconds: 8));
    } on ProcessException {
      return '';
    }
  }
}
