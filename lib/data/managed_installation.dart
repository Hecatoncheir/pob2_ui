import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import '../domain/app_info.dart';

String? currentAppTarget() => switch (Abi.current()) {
  Abi.windowsX64 => 'windows-x64',
  Abi.macosArm64 => 'macos-arm64',
  Abi.linuxX64 => 'linux-x64',
  _ => null,
};

class ManagedInstallation {
  const ManagedInstallation({required this.root, required this.kind});
  final Directory root;
  final String kind;

  static Future<ManagedInstallation?> detect({String? executable}) async {
    final file = File(executable ?? Platform.resolvedExecutable);
    final path = File(await file.resolveSymbolicLinks());
    return Platform.isMacOS ? _detectMac(path) : _detectVersioned(path);
  }

  static Future<ManagedInstallation?> _detectMac(File path) async {
    final bundle = path.parent.parent.parent;
    if (!bundle.path.endsWith('.app')) return null;
    final marker = File.fromUri(
      bundle.uri.resolve('Contents/Resources/pob2-install.json'),
    );
    if (!await validMarker(marker, 'macos-dmg')) return null;
    final writable = await Process.run('/bin/test', ['-w', bundle.parent.path]);
    return writable.exitCode == 0
        ? ManagedInstallation(root: bundle, kind: 'macos-dmg')
        : null;
  }

  static Future<ManagedInstallation?> _detectVersioned(File path) async {
    final root = path.parent.parent.parent;
    final marker = File.fromUri(root.uri.resolve('pob2-install.json'));
    final kind = Platform.isWindows ? 'windows-inno' : 'linux-run';
    if (!await validMarker(marker, kind)) return null;
    final expected = Directory.fromUri(root.uri.resolve('versions/'));
    if (path.parent.parent.uri != expected.uri) return null;
    return ManagedInstallation(root: root, kind: kind);
  }

  static Future<bool> validMarker(File file, String kind) async {
    try {
      final value =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return value['schema'] == 1 &&
          value['id'] == appId &&
          value['kind'] == kind;
    } on Object {
      return false;
    }
  }
}
