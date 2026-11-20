import '../domain/app_release.dart';
import '../domain/component.dart';
import 'managed_installation.dart';

const componentPackageTag = 'components-0.23.1-0.24.1';
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
      12509343,
      'a2d15bcf483b907380cf8343fabed1f9b1eca14a40baecf6d2e878b1c6e173c7',
    ),
    'macos-arm64' => (
      44502514,
      'dcc4e0eaf46e17ffe014cc8dd48d6acc1da39d4b592c5c362cd8c151f47364a7',
    ),
    'linux-x64' => (
      74349064,
      '20c180bfc1017a89dd39f68954b5a24a684d18dd3ff401e9fd5ca68383093cc9',
    ),
    _ => throw UnsupportedError(
      'Поддерживаются Windows x64, Linux x64 и macOS arm64',
    ),
  };
  return _release(
    Component.mcp,
    'v0.24.1',
    '312b337fa4a24f5ef55ebd38c8fd7bd46c7de78a',
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
