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
    String requestId,
  ) async => current;
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
