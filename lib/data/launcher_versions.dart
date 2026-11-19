import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/app_release.dart';

class LauncherVersions {
  LauncherVersions(this.root);
  final Directory root;

  File executable(String version) => File(
    p.join(
      root.path,
      'versions',
      version,
      Platform.isWindows ? 'pob2_ui.exe' : 'pob2_ui',
    ),
  );

  Future<List<String>> candidates({String? active, String? pending}) async {
    final rejected = await _readRejected();
    final versions = {...await _installed(), ?active, ?pending}
        .where((v) => !rejected.contains(v) || v == active || v == pending)
        .toList();
    versions.sort(
      (left, right) =>
          AppVersion.parse(right).compareTo(AppVersion.parse(left)),
    );
    return versions;
  }

  Future<List<String>> _installed() async {
    final directory = Directory(p.join(root.path, 'versions'));
    if (!await directory.exists()) return [];
    final versions = <String>[];
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is! Directory) continue;
      final name = p.basename(entry.path);
      if (!_canonical(name)) continue;
      if (await executable(name).exists()) versions.add(name);
    }
    return versions;
  }

  Future<void> reject(String version) async {
    final rejected = await _readRejected();
    rejected.add(version);
    await _writeRejected(rejected);
  }

  Future<void> allow(String version) async {
    final rejected = await _readRejected();
    if (rejected.remove(version)) await _writeRejected(rejected);
  }

  Future<Set<String>> _readRejected() async {
    final file = File(p.join(root.path, 'rejected-versions.json'));
    if (!await file.exists()) return {};
    try {
      if (jsonDecode(await file.readAsString()) case {
        'schema': 1,
        'versions': final List<dynamic> values,
      }) {
        return values.whereType<String>().where(_canonical).toSet();
      }
    } on FormatException {
      return {};
    }
    return {};
  }

  Future<void> _writeRejected(Set<String> versions) async {
    final file = File(p.join(root.path, 'rejected-versions.json.tmp'));
    await file.writeAsString(
      jsonEncode({'schema': 1, 'versions': versions.toList()..sort()}),
      flush: true,
    );
    await file.rename(p.join(root.path, 'rejected-versions.json'));
  }

  bool _canonical(String value) {
    try {
      return '${AppVersion.parse(value)}' == value;
    } on FormatException {
      return false;
    }
  }
}
