import '../domain/component.dart';
import 'installation_store.dart';
import 'profile_cleanup.dart';
import 'profile_use.dart';

enum ComponentInstallStage { pob, mcp, compatibility }

abstract interface class ComponentSource {
  InstallationStore get store;
  ProfileUse? get profileUse;
  ProfileCleanup get profileCleanup;
  Installations get active;
  String? get engineExecutable;
  List<Component> get requiredComponents;

  Map<Component, Release> availableReleases();
  bool needsInstall(Component component, Release release);
  Future<void> load();
  Future<List<Installations>> installedPairs();
  Future<void> installPair(
    Map<Component, Release> releases,
    void Function(String) log, {
    Future<void> Function(Installations)? validate,
    void Function(ComponentInstallStage)? onStage,
  });
  Future<void> rollback({Future<void> Function(Installations)? validate});
  Future<void> selectInstalled(
    Component component,
    String commit, {
    Future<void> Function(Installations)? validate,
  });
  Future<Map<String, dynamic>> doctor([Installations? installations]);
  Future<CleanupResult> cleanProfile(Set<CleanupEntry> selected);
}
