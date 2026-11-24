import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_ownership.dart';

import 'support/legacy/component_repository.dart';

import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/domain/component.dart';

import 'support/temporary_directory.dart';

class _Components extends ComponentRepository {
  _Components(InstallationStore store) : super(store: store);
  @override
  Future<Map<String, dynamic>> doctor([Installations? installations]) async => {
    'ok': true,
    'classes': 8,
  };
}

void main() {
  test(
    'Установленная версия сохраняет старую пару при отказе проверки сборки',
    () async {
      final root = await Directory.systemTemp.createTemp('pob-installed-test-');
      addTearDown(() => removeTemporaryDirectory(root));
      final store = InstallationStore(root);
      const old = {
        Component.pob: Installation(
          tag: 'old',
          commit: 'old',
          directory: 'old-pob',
        ),
        Component.mcp: Installation(
          tag: 'old',
          commit: 'old',
          directory: 'old-mcp',
        ),
      };
      await store.save(old, old);
      final candidate = await Directory.fromUri(
        root.uri.resolve('versions/pob-candidate/'),
      ).create(recursive: true);
      final next = Installation(
        tag: 'dev-test',
        commit: 'a' * 40,
        directory: candidate.path,
      );
      await recordComponent(candidate, Component.pob, next);
      await Directory.fromUri(root.uri.resolve('versions/unknown/')).create();
      final repository = _Components(store);
      await repository.load();
      expect(await repository.installedPairs(), hasLength(1));
      await expectLater(
        repository.selectInstalled(
          Component.pob,
          next.commit,
          validate: (_) async => throw StateError('Отказ Lua'),
        ),
        throwsStateError,
      );
      expect((await store.read()).active[Component.pob]!.directory, 'old-pob');
      expect(repository.active[Component.pob]!.directory, 'old-pob');
      await repository.selectInstalled(Component.pob, next.commit);
      final saved = await store.read();
      expect(saved.active[Component.pob]!.commit, next.commit);
      expect(saved.active[Component.mcp]!.directory, 'old-mcp');
      expect(saved.previous[Component.pob]!.directory, 'old-pob');
      await repository.selectInstalled(Component.pob, next.commit);
      expect(
        (await store.read()).previous[Component.pob]!.directory,
        'old-pob',
      );
      await expectLater(
        repository.selectInstalled(Component.pob, 'b' * 40),
        throwsStateError,
      );
      expect((await store.read()).active[Component.pob]!.commit, next.commit);
    },
  );
}
