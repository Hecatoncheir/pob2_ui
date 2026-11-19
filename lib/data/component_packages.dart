import '../domain/app_release.dart';
import '../domain/component.dart';
import 'managed_installation.dart';

const componentPackageTag = 'components-0.23.1-0.22.0-2';
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
      'c5d0bdd472ee853f74ae4a7c1a06577efa857b0405d8b948bcade0ea5d3098dd',
    ),
    'macos-arm64' => (
      44499002,
      'f08245c9fcc77b0356c16a0416ce7e038e21a03f87378b8afb6f28182c67c30d',
    ),
    'linux-x64' => (
      74345549,
      '1a4a0a1ff58e467045e7b7ea9c738a003e0a6521ba24d8057f6f58282d4a3b1f',
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
