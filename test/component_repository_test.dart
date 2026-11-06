import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/domain/component.dart';

import 'support/temporary_directory.dart';

const oldPob = Installation(tag: 'v1', commit: 'old-pob', directory: 'old-pob');
const oldMcp = Installation(tag: 'v1', commit: 'old-mcp', directory: 'old-mcp');

class FailingProcesses extends ProcessService {
  @override
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) async => throw ProcessException(executable, arguments, 'Нет сети', 1);

  @override
  Future<String> python() async => 'python';
}

void main() {
  late Directory temporary;
  late InstallationStore store;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('pob2-ui-test-');
    store = InstallationStore(temporary);
  });
  tearDown(() => removeTemporaryDirectory(temporary));

  test(
    'Повторное сохранение заменяет активную пару и сохраняет предыдущую',
    () async {
      const nextPob = Installation(
        tag: 'v2',
        commit: 'next',
        directory: 'next',
      );
      final old = {Component.pob: oldPob, Component.mcp: oldMcp};
      await store.save(old, {});
      await store.save({...old, Component.pob: nextPob}, old);
      final reopened = InstallationStore(temporary);
      final current = await reopened.load();
      expect(current[Component.pob]!.commit, 'next');
      expect(reopened.previous[Component.pob]!.commit, 'old-pob');
      expect(current[Component.mcp]!.commit, 'old-mcp');
    },
  );

  test('Сбой загрузки сохраняет рабочую пару на диске', () async {
    await store.save({Component.pob: oldPob, Component.mcp: oldMcp}, {});
    final repository = ComponentRepository(
      store: store,
      processes: FailingProcesses(),
    );
    await repository.load();
    await expectLater(
      repository.install(
        Component.pob,
        Release('v2', '', DateTime.utc(2026)),
        (_) {},
      ),
      throwsA(isA<ProcessException>()),
    );
    final current = await store.load();
    expect(current[Component.pob]!.commit, 'old-pob');
    expect(repository.active[Component.pob]!.commit, 'old-pob');
  }, skip: !Platform.isWindows);

  test('Неудачная проверка отката сохраняет активную пару', () async {
    await store.save(
      {Component.pob: oldPob, Component.mcp: oldMcp},
      {Component.pob: oldPob, Component.mcp: oldMcp},
    );
    final repository = ComponentRepository(
      store: store,
      processes: FailingProcesses(),
    );
    await repository.load();
    await expectLater(repository.rollback(), throwsA(isA<ProcessException>()));
    expect((await store.load())[Component.pob]!.commit, 'old-pob');
  });
}
