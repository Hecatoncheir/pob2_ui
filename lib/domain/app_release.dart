import 'app_info.dart';

class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);
  final int major;
  final int minor;
  final int patch;

  static AppVersion parse(String value) {
    final match = RegExp(
      r'^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:\+[0-9A-Za-z.-]+)?$',
    ).firstMatch(value);
    if (match == null)
      throw const FormatException('Нужна стабильная версия вида 0.2.0');
    return AppVersion(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
    );
  }

  @override
  int compareTo(AppVersion other) {
    final left = [major, minor, patch];
    final right = [other.major, other.minor, other.patch];
    for (var index = 0; index < left.length; index++) {
      final comparison = left[index].compareTo(right[index]);
      if (comparison != 0) return comparison;
    }
    return 0;
  }

  @override
  String toString() => '$major.$minor.$patch';
}

String installerName(String version, String target) => switch (target) {
  'windows-x64' => 'pob2-ui-$version-windows-x64-setup.exe',
  'macos-arm64' => 'pob2-ui-$version-macos-arm64.dmg',
  'linux-x64' => 'pob2-ui-$version-linux-x64.run',
  _ => throw const FormatException('Для этой платформы нет пакета обновления'),
};

class AppAsset {
  const AppAsset({
    required this.name,
    required this.url,
    required this.size,
    this.sha256,
  });
  final String name;
  final Uri url;
  final int size;
  final String? sha256;

  AppAsset withDigest(String digest) =>
      AppAsset(name: name, url: url, size: size, sha256: digest);
}

class AppRelease {
  const AppRelease({
    required this.version,
    required this.notes,
    this.installer,
  });
  final AppVersion version;
  final String notes;
  final AppAsset? installer;
  Uri get page => Uri.parse('$appReleasesUrl/tag/v$version');

  AppRelease withInstaller(AppAsset? value) =>
      AppRelease(version: version, notes: notes, installer: value);

  static AppRelease? parse(Map<String, dynamic> json, String target) {
    if (json['draft'] == true || json['prerelease'] == true) return null;
    final version = AppVersion.parse(json['tag_name'] as String);
    final name = installerName('$version', target);
    final rawAssets = json['assets'] as List<dynamic>? ?? [];
    AppAsset? installer;
    for (final raw in rawAssets) {
      if (raw is! Map<String, dynamic> || raw['name'] != name) continue;
      installer = parseAsset(raw, version);
      break;
    }
    return AppRelease(
      version: version,
      notes: json['body'] as String? ?? '',
      installer: installer,
    );
  }

  static AppAsset parseAsset(Map<String, dynamic> json, AppVersion version) {
    final name = json['name'] as String;
    final url = Uri.parse(json['browser_download_url'] as String);
    final expected = Uri.parse('$appReleasesUrl/download/v$version/$name');
    if (url != expected)
      throw const FormatException('Неверный источник файла выпуска');
    final size = json['size'] as int;
    if (size <= 0 || size > 1024 * 1024 * 1024)
      throw const FormatException('Некорректный размер файла');
    final digest = json['digest'];
    final match = digest is String
        ? RegExp(r'^sha256:([a-fA-F0-9]{64})$').firstMatch(digest)
        : null;
    return AppAsset(
      name: name,
      url: url,
      size: size,
      sha256: match?[1]?.toLowerCase(),
    );
  }
}
