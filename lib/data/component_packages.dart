import '../domain/app_release.dart';
import '../domain/component.dart';
import 'managed_installation.dart';

const componentPackageTag = 'components-0.23.1-0.21.0-1';
const _base =
    'https://github.com/Hecatoncheir/pob2_ui/releases/download/'
    '$componentPackageTag';

// Архивы собраны командой tool/package_components.py из components-lock.json.
Map<Component, Release> componentReleases() => {
  Component.pob: _release(
    Component.pob,
    'v0.23.1',
    '7d6f530cbdab20389ff8bc6ba97a37ac27f74e41',
    'pob.zip',
    382859677,
    'de52b2c30a30057b02f4c4286af40be8ebc5e1d542482c910c0e3108d7578c55',
  ),
  Component.mcp: _mcpRelease(currentAppTarget()),
};

Release _mcpRelease(String? target) {
  final (size, digest) = switch (target) {
    'windows-x64' => (
      12501300,
      '4e94fd31f0c7f7da3b9f5eb281270593a8b522b9c57346483a3c18e1b28e1405',
    ),
    'macos-arm64' => (
      44495669,
      'df13a098dc19d67f87ade228061e566401fa632f03d8970e0d70f84e09a19356',
    ),
    'linux-x64' => (
      74342217,
      '689dd30a68610c8ab6a0ffb40324bac9d39b7cdd7df658c05f18363c4ff518bd',
    ),
    _ => throw UnsupportedError(
      'Поддерживаются Windows x64, Linux x64 и macOS arm64',
    ),
  };
  return _release(
    Component.mcp,
    'v0.21.0',
    'd932e4b6b05934c906607c6558e841cc64580967',
    'mcp-$target.zip',
    size,
    digest,
  );
}

Release _release(
  Component component,
  String tag,
  String commit,
  String name,
  int size,
  String digest,
) => Release(
  tag,
  '${component.url}/releases/tag/$tag',
  DateTime.utc(2026, 11, 17),
  expectedCommit: commit,
  package: AppAsset(
    name: name,
    url: Uri.parse('$_base/$name'),
    size: size,
    sha256: digest,
  ),
);
