import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/pob_build_locations.dart';
import 'package:pob2_ui/data/pob_window_repository.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/data/setup_preferences.dart';
import 'package:pob2_ui/domain/component.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';

class _WineCommands extends ProcessService {
  _WineCommands([this.available]);

  final String? available;
  final checked = <String>[];

  @override
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) async {
    checked.add(executable);
    if (executable == available) return 'wine';
    throw ProcessException(executable, arguments);
  }
}

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

  for (final system in ['linux', 'macos']) {
    test(
      'Без Wine создаётся и сохраняется папка по умолчанию: $system',
      () async {
        final locations = PobBuildLocations(
          system: system,
          environment: {'HOME': profile.path},
          processes: _WineCommands(),
        );
        final model = WorkshopCubit(
          ComponentRepository(store: InstallationStore(profile)),
          McpClient(),
          library: PobBuildLibrary(profile),
          buildLocations: locations,
        );
        addTearDown(model.close);

        await model.initialize();

        final folder = Directory(path.join(profile.path, 'Documents', 'PoE2'));
        final expected = await folder.resolveSymbolicLinks();
        expect(model.state.error, isNull);
        expect(model.buildFolderReady, isTrue);
        expect(model.sharedLibrary?.directory, expected);
        final reopened = PobBuildLibrary(profile);
        await reopened.load();
        expect(reopened.directory, expected);
      },
    );
  }

  test('Ранее выбранная папка сохраняется при запуске без Wine', () async {
    final chosen = await Directory(path.join(profile.path, 'chosen')).create();
    final library = PobBuildLibrary(profile);
    await library.configure(chosen.path);
    final commands = _WineCommands();
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(profile)),
      McpClient(),
      library: PobBuildLibrary(profile),
      buildLocations: PobBuildLocations(
        system: 'linux',
        environment: {'HOME': profile.path},
        processes: commands,
      ),
    );
    addTearDown(model.close);

    await model.initialize();

    expect(model.sharedLibrary?.directory, await chosen.resolveSymbolicLinks());
    expect(commands.checked, isEmpty);
  });

  test('При доступном wine64 сохраняется прежний выбор папки', () async {
    final locations = PobBuildLocations(
      system: 'linux',
      environment: {'HOME': profile.path},
      processes: _WineCommands('wine64'),
    );
    expect(await locations.defaultWithoutWine(), isNull);
  });

  test('Отметка показа мастера переживает перезапуск', () async {
    final preferences = SetupPreferences(profile);
    expect(await preferences.wasShown(), isFalse);
    await preferences.markShown();
    expect(await SetupPreferences(profile).wasShown(), isTrue);
  });
}
