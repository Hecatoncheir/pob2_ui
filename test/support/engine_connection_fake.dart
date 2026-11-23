import 'dart:async';

import 'package:pob2_ui/data/engine_session_client.dart';
import 'package:pob2_ui/domain/engine_session.dart';

class FakeEngineConnection implements EngineConnection {
  FakeEngineConnection([
    this.current = const EngineSnapshot('main', 'Начальная', 1),
  ]);
  EngineSnapshot current;
  final events = StreamController<EngineChange>.broadcast(sync: true);
  final history = <EngineChange>[];
  final watchedRevisions = <int>[];
  final renames = <({EngineSnapshot before, String name, String requestId})>[];
  bool closed = false;

  void change(String name, {String requestId = 'external'}) {
    final previous = current;
    current = EngineSnapshot(previous.sessionId, name, previous.revision + 1);
    final event = EngineChange(
      snapshot: current,
      kind: 'renamed',
      previousName: previous.buildName,
      requestId: requestId,
      fields: const ['build_name'],
    );
    history.add(event);
    events.add(event);
  }

  @override
  Future<EngineSnapshot> snapshot(String sessionId) async => current;
  @override
  Future<EngineSnapshot> create(
    String sessionId,
    String name,
    String requestId, {
    String? xml,
  }) async => current;
  @override
  Future<EngineSnapshot> rename(
    EngineSnapshot current,
    String name,
    String requestId,
  ) async {
    renames.add((before: current, name: name, requestId: requestId));
    change(name, requestId: requestId);
    return this.current;
  }

  @override
  Future<void> setLevel(EngineSnapshot current, int level, String requestId) =>
      throw UnimplementedError();

  @override
  Future<EngineSnapshot> setCondition(
    EngineSnapshot current,
    String name,
    Object? value,
    String requestId,
  ) => throw UnimplementedError();

  @override
  bool get supportsAddSupport => false;

  @override
  bool get supportsEquipmentPreview => false;

  @override
  Future<EngineEquipmentPreview> previewEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
  ) => throw UnimplementedError();

  @override
  Future<void> editEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
    String requestId,
  ) => throw UnimplementedError();

  @override
  bool get supportsTreePreview => false;

  @override
  bool get supportsTreeAttributes => false;

  @override
  bool get supportsTreeAllocationModes => false;

  @override
  Future<EnginePassivePage> findPassives(
    String version,
    String query,
    int offset,
  ) => throw UnimplementedError();

  @override
  Future<EngineTreePreview> previewTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
  ) => throw UnimplementedError();

  @override
  Future<EngineSnapshot> editTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
    String requestId,
  ) => throw UnimplementedError();

  @override
  Future<EngineSupportPage> findSupports(String query, int offset) =>
      throw UnimplementedError();

  @override
  Future<EngineSupportPreview> previewSupport(
    EngineSnapshot current,
    EngineSupportSelection selection,
  ) => throw UnimplementedError();

  @override
  Future<void> addSupport(
    EngineSnapshot current,
    EngineSupportSelection selection,
    String requestId,
  ) => throw UnimplementedError();

  @override
  Future<void> calculate(EngineSnapshot current, String requestId) =>
      throw UnimplementedError();

  @override
  Stream<EngineChange> watch(String sessionId, int afterRevision) {
    watchedRevisions.add(afterRevision);
    return Stream.multi((controller) {
      for (final event in history.where(
        (event) => event.snapshot.revision > afterRevision,
      )) {
        controller.add(event);
      }
      final subscription = events.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<void> close() async {
    closed = true;
  }
}
