import '../domain/app_release.dart';
import '../domain/component.dart';
import 'managed_installation.dart';

const componentPackageTag = 'components-0.23.1-0.22.0-1';
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
      12504986,
      '10854a8c8d4a5d53c90519ee9067425f3bf12cdd25fbf50612db02775dfc6af5',
    ),
    'macos-arm64' => (
      44499002,
      'eb777d78620aa8d3af725395864403325a8d432e9bd272c8f351f6433dbe24ae',
    ),
    'linux-x64' => (
      74345549,
      '5921029ca188214ba0706ba5b41adbd5ca0bc7a0f9345915e94b6f6cb91cbb2c',
    ),
    _ => throw UnsupportedError(
      'Поддерживаются Windows x64, Linux x64 и macOS arm64',
    ),
  };
  return _release(
    Component.mcp,
    'v0.22.0',
    'c56f1b0ded6c732a7adf23a81a627318768a748a',
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
  DateTime.utc(2026, 11, 19),
  expectedCommit: commit,
  package: AppAsset(
    name: name,
    url: Uri.parse('$_base/$name'),
    size: size,
    sha256: digest,
  ),
);
