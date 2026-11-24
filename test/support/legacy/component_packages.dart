import 'package:pob2_ui/domain/app_release.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/data/managed_installation.dart';

const componentPackageTag = 'components-0.23.1-0.23.0';
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
      12507376,
      'badf3807a7df98601621ed59a42bd20be2d2acd32393071e6335f99e874268fd',
    ),
    'macos-arm64' => (
      44500952,
      '494e00ce810094e5e202b3d13c1886382500409a4e44726996ae680c220330af',
    ),
    'linux-x64' => (
      74347500,
      'f65d2fb537a849c01c96d3277320a0ec368188a1f69396f5badd22d1519761e3',
    ),
    _ => throw UnsupportedError(
      'Поддерживаются Windows x64, Linux x64 и macOS arm64',
    ),
  };
  return _release(
    Component.mcp,
    'v0.23.0',
    '1b3f61dc00016fe3bc86d889d6f4992302231d75',
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
  DateTime.utc(2026, 11, 20),
  expectedCommit: commit,
  package: AppAsset(
    name: name,
    url: Uri.parse('$_base/$name'),
    size: size,
    sha256: digest,
  ),
);
