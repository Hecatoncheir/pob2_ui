import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

class DelayedComponents extends ComponentRepository {
  DelayedComponents(InstallationStore store) : super(store: store);
  final gate = Completer<void>();
  int loads = 0;
  @override
  Future<void> load() async {
    loads++;
    await gate.future;
    await super.load();
  }
}

void main() {
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-cubit-test-');
  });
  tearDown(() => root.delete(recursive: true));

  test(
    'Снимок состояния неизменяем; загрузка не затирает новый черновик',
    () async {
      final components = DelayedComponents(InstallationStore(root));
      final cubit = WorkshopCubit(components, McpClient());
      addTearDown(cubit.close);
      await cubit.session.saveDraft('старый XML');
      final before = cubit.state;
      final initializing = cubit.initialize();
      expect(cubit.state.busy, isTrue);
      await cubit.initialize();
      expect(components.loads, 1);
      cubit.editDraft('новый XML');
      components.gate.complete();
      await initializing;
      expect(cubit.state.draftXml, 'новый XML');
      expect(before.draftXml, '');
      expect(cubit.state.busy, isFalse);
      expect(() => cubit.state.log.add('изменение'), throwsUnsupportedError);
      await cubit.checkpoint();
      expect(await cubit.session.readDraft(), 'новый XML');
    },
  );

  test('Обновление ждёт окончания операции; закрытый Cubit не получает новые состояния', () async {
    final components = DelayedComponents(InstallationStore(root));
    final cubit = WorkshopCubit(components, McpClient());
    final pending = cubit.initialize();
    await expectLater(cubit.checkpoint(), throwsStateError);
    await cubit.close();
    components.gate.complete();
    await pending;
    expect(cubit.isClosed, isTrue);
  });
}
