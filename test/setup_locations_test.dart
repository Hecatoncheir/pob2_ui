import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/pob_build_locations.dart';
import 'package:pob2_ui/data/pob_window_repository.dart';
import 'package:pob2_ui/data/setup_preferences.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';

class _WindowWithoutBridge extends PobWindowRepository {
  int checks = 0;

  @override
  bool get supported => true;

  @override
  Future<String> buildDirectory(Installations components) async {
    checks++;
    throw StateError('Нет связи с окном PoB');
  }
}

void main() {
  late Directory profile;

  setUp(
    () async => profile = await Directory.systemTemp.createTemp('pob2-setup-'),
  );
  tearDown(() => removeTemporaryDirectory(profile));

  Future<String> makeBuilds(String parent) async {
    final folder = Directory(
      path.join(parent, 'Path of Building (PoE2)', 'Builds'),
    );
    await folder.create(recursive: true);
    return folder.resolveSymbolicLinks();
  }

  test(
    'При недоступном мосте подключаются системные Документы Windows',
    () async {
      final documents = path.join(profile.path, 'Другие документы');
      final expected = await makeBuilds(documents);
      final components = ComponentRepository(store: InstallationStore(profile));
      components.active = {
        for (final component in Component.values)
          component: Installation(
            tag: 'test',
            commit: 'test',
            directory: profile.path,
          ),
      };
      final window = _WindowWithoutBridge();
      final model = WorkshopCubit(
        components,
        McpClient(),
        library: PobBuildLibrary(profile),
        pobWindow: window,
        buildLocations: PobBuildLocations(
          system: 'windows',
          windowsDocuments: () async => documents,
        ),
      );
      addTearDown(model.close);

      await model.detectPobBuildFolder();
      expect(window.checks, 1);
      expect(model.sharedLibrary?.directory, expected);
      expect(model.state.error, isNull);
    },
  );

  test(
    'На Linux учитывается Wine, при второй библиотеке нужен выбор',
    () async {
      final home = profile.path;
      final prefix = path.join(home, 'custom-prefix');
      final finder = PobBuildLocations(
        system: 'linux',
        environment: {'HOME': home, 'WINEPREFIX': prefix},
      );
      expect(await finder.find(), isNull);
      final expected = await makeBuilds(
        path.join(prefix, 'drive_c', 'users', 'user', 'Documents'),
      );
      expect(await finder.find(), expected);
      await makeBuilds(
        path.join(home, '.local', 'share', 'RustyPathOfBuilding2', 'userdata'),
      );
      await expectLater(finder.find(), throwsStateError);
    },
  );

  test('На macOS находится библиотека в Application Support', () async {
    final expected = await makeBuilds(
      path.join(profile.path, 'Library', 'Application Support'),
    );
    final finder = PobBuildLocations(
      system: 'macos',
      environment: {'HOME': profile.path},
    );
    expect(await finder.find(), expected);
  });

  test('Отметка показа мастера переживает перезапуск', () async {
    final preferences = SetupPreferences(profile);
    expect(await preferences.wasShown(), isFalse);
    await preferences.markShown();
    expect(await SetupPreferences(profile).wasShown(), isTrue);
  });
}
