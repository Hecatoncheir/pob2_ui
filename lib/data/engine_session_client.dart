import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:pob2_engine_api/pob2/v1/build.pb.dart' as builds;
import 'package:pob2_engine_api/pob2/v1/catalog.pb.dart' as catalog;
import 'package:pob2_engine_api/pob2/v1/session.pbgrpc.dart' as pb;

import '../domain/engine_session.dart';
import 'pob_build_document.dart';

abstract interface class EngineConnection {
  Future<EngineSnapshot> snapshot(String sessionId);
  Future<EngineSnapshot> create(
    String sessionId,
    String name,
    String requestId,
  );
  Future<EngineSnapshot> rename(
    EngineSnapshot current,
    String name,
    String requestId,
  );
  Future<void> setLevel(EngineSnapshot current, int level, String requestId);
  bool get supportsAddSupport;
  bool get supportsEquipmentPreview;
  Future<EngineEquipmentPreview> previewEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
  );
  Future<void> editEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
    String requestId,
  );
  bool get supportsTreePreview;
  Future<EnginePassivePage> findPassives(
    String version,
    String query,
    int offset,
  );
  Future<EngineTreePreview> previewTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
  );
  Future<void> editTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
    String requestId,
  );
  Future<EngineSupportPage> findSupports(String query, int offset);
  Future<EngineSupportPreview> previewSupport(
    EngineSnapshot current,
    EngineSupportSelection selection,
  );
  Future<void> addSupport(
    EngineSnapshot current,
    EngineSupportSelection selection,
    String requestId,
  );
  Future<void> calculate(EngineSnapshot current, String requestId);
  Stream<EngineChange> watch(String sessionId, int afterRevision);
  Future<void> close();
}

String engineRequestId() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

// Дочерний connect владеет обнаружением и одной арендой приложения.
class EngineSessionClient implements EngineConnection {
  EngineSessionClient._(
    this._helper,
    this._output,
    this._errors,
    this._channel,
    this._rpc,
    this.supportsAddSupport,
    this.supportsEquipmentPreview,
    this.supportsTreePreview,
  );
  final Process _helper;
  final StreamSubscription<String> _output;
  final StreamSubscription<List<int>> _errors;
  final ClientChannel _channel;
  final pb.SessionServiceClient _rpc;
  @override
  final bool supportsAddSupport;
  @override
  final bool supportsEquipmentPreview;
  @override
  final bool supportsTreePreview;
  bool _closed = false;

  static Future<EngineConnection> open(EngineOptions options) async {
    final helper = await Process.start(options.executable, [
      'connect',
      '--kind',
      'ui',
      '--connection-json',
      '--start-server',
      '--profile',
      options.profile,
      if (options.runtimeDirectory.isNotEmpty) ...[
        '--runtime-dir',
        options.runtimeDirectory,
      ],
      if (options.dataDirectory.isNotEmpty) ...[
        '--data-dir',
        options.dataDirectory,
      ],
    ]);
    final first = Completer<String>();
    final output = helper.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (!first.isCompleted) first.complete(line);
          },
          onError: (Object error) {
            if (!first.isCompleted) first.completeError(error);
          },
          onDone: () {
            if (!first.isCompleted)
              first.completeError(
                StateError('Движок не сообщил параметры подключения'),
              );
          },
        );
    // Диагностика процесса может содержать локальные пути; токен не журналируется.
    final errors = helper.stderr.listen((_) {});
    ClientChannel? channel;
    try {
      final credentials = _decodeCredentials(
        await first.future.timeout(const Duration(seconds: 12)),
      );
      channel = ClientChannel(
        credentials.host,
        port: credentials.port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );
      final rpc = pb.SessionServiceClient(
        channel,
        options: CallOptions(
          metadata: {
            'authorization': 'Bearer ${credentials.token}',
            'pob2-lease': credentials.lease,
          },
        ),
      );
      final info = await rpc.getServerInfo(
        pb.GetServerInfoRequest(),
        options: CallOptions(timeout: const Duration(seconds: 5)),
      );
      _validateServer(info, credentials.instance);
      return EngineSessionClient._(
        helper,
        output,
        errors,
        channel,
        rpc,
        info.capabilities.contains('build.add_support'),
        info.capabilities.contains('build.equipment_preview'),
        info.capabilities.contains('build.tree_preview'),
      );
    } catch (_) {
      await channel?.terminate();
      helper.kill();
      await output.cancel();
      await errors.cancel();
      rethrow;
    }
  }

  static ({String host, int port, String token, String lease, String instance})
  _decodeCredentials(String line) {
    try {
      return _credentials(jsonDecode(line));
    } on FormatException {
      throw const FormatException(
        'Движок вернул некорректные параметры подключения',
      );
    }
  }

  static ({String host, int port, String token, String lease, String instance})
  _credentials(dynamic json) {
    if (json case {
      'address': final String address,
      'token': final String token,
      'lease_id': final String lease,
      'instance_id': final String instance,
      'protocol_version': 'pob2.v1',
    }) {
      final uri = Uri.tryParse('http://$address');
      if (uri != null &&
          uri.host == '127.0.0.1' &&
          uri.port > 0 &&
          token.isNotEmpty &&
          lease.isNotEmpty &&
          instance.isNotEmpty) {
        return (
          host: uri.host,
          port: uri.port,
          token: token,
          lease: lease,
          instance: instance,
        );
      }
    }
    throw const FormatException(
      'Движок вернул несовместимые параметры подключения',
    );
  }

  static void _validateServer(pb.GetServerInfoResponse info, String instance) {
    if (info.protocolVersion != 'pob2.v1' ||
        info.instanceId != instance ||
        info.state != 'ready' ||
        !info.capabilities.contains('session.events')) {
      throw const FormatException(
        'Сервер не поддерживает подписки общей сессии',
      );
    }
  }

  static EngineSnapshot _snapshot(pb.SessionSnapshot value) => EngineSnapshot(
    value.sessionId,
    value.buildName,
    value.revision.toInt(),
    build: value.hasBuild() ? _build(value.build) : null,
  );

  static EngineBuild _build(builds.BuildDocument value) {
    PobBuildDocument(value.xml);
    final calculation =
        value.hasCalculation() &&
            value.calculatedFromRevision == value.inputRevision
        ? _calculation(value.calculation)
        : null;
    return EngineBuild(
      xml: value.xml,
      level: value.model.level,
      calculation: calculation,
      group: _selectedGroup(value.model),
      equipment: _equipment(value.model),
      tree: _tree(value.model),
    );
  }

  static EngineTree? _tree(builds.BuildModel model) {
    if (model.treeVersion.isEmpty || model.activeSets.tree == 0) return null;
    return (
      spec: model.activeSets.tree,
      version: model.treeVersion,
      nodes: Set.unmodifiable(model.nodes),
    );
  }

  static Map<String, String> _equipment(builds.BuildModel model) {
    final items = {for (final item in model.items) item.id: item.raw};
    return Map.unmodifiable({
      for (final entry in model.slots.entries)
        entry.key: items[entry.value] ?? '',
    });
  }

  static EngineSkillGroup? _selectedGroup(builds.BuildModel model) {
    final group = model.groups
        .where((group) => group.id == model.mainGroup)
        .firstOrNull;
    if (group == null) return null;
    return (
      id: group.id,
      label: group.label,
      gems: List.unmodifiable(
        group.gems.map(
          (gem) => (
            name: gem.name.isEmpty ? gem.skillId : gem.name,
            level: gem.level,
            quality: gem.quality,
            enabled: gem.enabled,
          ),
        ),
      ),
    );
  }

  static EngineCalculation _calculation(builds.CalculationResult value) =>
      EngineCalculation(
        status: switch (value.status) {
          builds.CalculationStatus.CALCULATION_STATUS_COMPLETE => 'Готово',
          builds.CalculationStatus.CALCULATION_STATUS_PARTIAL =>
            'Частичный расчёт',
          builds.CalculationStatus.CALCULATION_STATUS_UNSUPPORTED =>
            'Расчёт не поддерживается',
          _ => 'Неизвестный статус',
        },
        life: value.stats['Life'],
        dps: value.stats['TotalDPS'],
        warnings: List.unmodifiable(value.issues.map((issue) => issue.message)),
      );
  CallOptions get _timeout => CallOptions(timeout: const Duration(seconds: 5));

  @override
  Future<EngineSnapshot> snapshot(String sessionId) async => _snapshot(
    (await _rpc.getSnapshot(
      pb.GetSnapshotRequest(sessionId: sessionId),
      options: _timeout,
    )).snapshot,
  );
  @override
  Future<EngineSnapshot> create(
    String sessionId,
    String name,
    String requestId,
  ) async => _snapshot(
    (await _rpc.createSession(
      pb.CreateSessionRequest(
        sessionId: sessionId,
        buildName: name,
        requestId: requestId,
      ),
      options: _timeout,
    )).snapshot,
  );
  @override
  Future<EngineSnapshot> rename(
    EngineSnapshot current,
    String name,
    String requestId,
  ) async => _snapshot(
    (await _rpc.renameBuild(
      pb.RenameBuildRequest(
        sessionId: current.sessionId,
        buildName: name,
        expectedRevision: Int64(current.revision),
        requestId: requestId,
      ),
      options: _timeout,
    )).snapshot,
  );

  @override
  Future<void> setLevel(EngineSnapshot current, int level, String requestId) =>
      _applyEdit(
        current,
        builds.BuildEdit(level: builds.LevelEdit(level: level)),
        requestId,
      );

  @override
  Future<EngineSupportPage> findSupports(String query, int offset) async {
    final page = await _rpc.getCatalog(
      catalog.GetCatalogRequest(
        kind: 'gems',
        query: query,
        limit: 40,
        offset: offset,
      ),
      options: _timeout,
    );
    final next = page.offset + page.limit;
    return (
      entries: List<EngineSupportOption>.unmodifiable(
        page.entries
            .where((entry) => entry.support)
            .map(
              (entry) => (
                id: entry.id,
                name: entry.name,
                levels: List<int>.unmodifiable(entry.levels),
                qualities: List<int>.unmodifiable(entry.qualities),
              ),
            ),
      ),
      nextOffset: next < page.total && next <= 10000 ? next : null,
    );
  }

  @override
  Future<EngineSupportPreview> previewSupport(
    EngineSnapshot current,
    EngineSupportSelection selection,
  ) async {
    final preview = await _rpc.previewSupport(
      catalog.PreviewSupportRequest(
        sessionId: current.sessionId,
        expectedRevision: Int64(current.revision),
        supportId: selection.id,
        level: selection.level,
        quality: selection.quality,
      ),
      options: _calculationTimeout,
    );
    return EngineSupportPreview(
      revision: preview.revision.toInt(),
      compatible: preview.compatible,
      before: _calculation(preview.comparison.before),
      after: _calculation(preview.comparison.after),
      deltas: _statDeltas(preview.comparison),
    );
  }

  static List<EngineStatDelta> _statDeltas(builds.BuildComparison comparison) =>
      List.unmodifiable(
        comparison.deltas.map(
          (delta) => (
            name: delta.stat,
            before: delta.before,
            after: delta.after,
            difference: delta.difference,
          ),
        ),
      );

  @override
  Future<EngineEquipmentPreview> previewEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
  ) async {
    final result = await _compareEdit(current, _equipmentChange(edit));
    return _buildComparison(result);
  }

  Future<pb.CompareBuildResponse> _compareEdit(
    EngineSnapshot current,
    builds.BuildEdit edit,
  ) => _rpc.compareBuild(
    pb.CompareBuildRequest(
      sessionId: current.sessionId,
      expectedRevision: Int64(current.revision),
      edit: edit,
    ),
    options: _calculationTimeout,
  );

  static EngineBuildComparison _buildComparison(
    pb.CompareBuildResponse result,
  ) => (
    revision: result.revision.toInt(),
    before: _calculation(result.comparison.before),
    after: _calculation(result.comparison.after),
    deltas: _statDeltas(result.comparison),
  );

  @override
  Future<void> editEquipment(
    EngineSnapshot current,
    EngineEquipmentEdit edit,
    String requestId,
  ) => _applyEdit(current, _equipmentChange(edit), requestId);

  static builds.BuildEdit _equipmentChange(EngineEquipmentEdit edit) =>
      builds.BuildEdit(
        equipment: builds.EquipmentEdit(slot: edit.slot, raw: edit.raw),
      );

  @override
  Future<EnginePassivePage> findPassives(
    String version,
    String query,
    int offset,
  ) async {
    final page = await _rpc.getCatalog(
      catalog.GetCatalogRequest(
        kind: 'passives',
        query: query,
        limit: 30,
        offset: offset,
      ),
      options: _calculationTimeout,
    );
    if (page.treeVersion != version) {
      throw StateError('Каталог PoB относится к другой версии дерева');
    }
    final matches = page.entries.map(
      (entry) => (id: int.parse(entry.id), name: entry.name),
    );
    final next = page.offset + page.limit;
    return (
      entries: List<EnginePassive>.unmodifiable(matches),
      nextOffset: next < page.total && next <= 10000 ? next : null,
    );
  }

  @override
  Future<EngineTreePreview> previewTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
  ) async {
    final result = await _compareEdit(current, _treeChange(edit));
    if (!result.hasPassiveChange()) {
      throw const FormatException('Движок не вернул изменённые узлы');
    }
    return (
      comparison: _buildComparison(result),
      added: List<int>.unmodifiable(result.passiveChange.added),
      removed: List<int>.unmodifiable(result.passiveChange.removed),
    );
  }

  @override
  Future<void> editTree(
    EngineSnapshot current,
    EngineTreeEdit edit,
    String requestId,
  ) => _applyEdit(current, _treeChange(edit), requestId);

  static builds.BuildEdit _treeChange(EngineTreeEdit edit) => builds.BuildEdit(
    treeNode: builds.TreeNodeEdit(
      nodeId: edit.nodeId,
      action: edit.refund ? 'refund' : 'allocate',
    ),
  );

  @override
  Future<void> addSupport(
    EngineSnapshot current,
    EngineSupportSelection selection,
    String requestId,
  ) => _applyEdit(
    current,
    builds.BuildEdit(
      addSupport: builds.AddSupportEdit(
        supportId: selection.id,
        level: selection.level,
        quality: selection.quality,
      ),
    ),
    requestId,
  );

  Future<void> _applyEdit(
    EngineSnapshot current,
    builds.BuildEdit edit,
    String requestId,
  ) async {
    await _rpc.applyBuild(
      pb.ApplyBuildRequest(
        sessionId: current.sessionId,
        expectedRevision: Int64(current.revision),
        requestId: requestId,
        edit: edit,
      ),
      options: edit.hasEquipment() || edit.hasTreeNode()
          ? _calculationTimeout
          : _timeout,
    );
  }

  CallOptions get _calculationTimeout =>
      CallOptions(timeout: const Duration(seconds: 90));

  @override
  Future<void> calculate(EngineSnapshot current, String requestId) async {
    await _rpc
        .calculateBuild(
          pb.CalculateBuildRequest(
            sessionId: current.sessionId,
            expectedRevision: Int64(current.revision),
            requestId: requestId,
          ),
          options: _calculationTimeout,
        )
        .where((answer) => answer.hasSnapshot())
        .single;
  }

  @override
  Stream<EngineChange> watch(String sessionId, int afterRevision) => _rpc
      .watchSession(
        pb.WatchSessionRequest(
          sessionId: sessionId,
          afterRevision: Int64(afterRevision),
        ),
      )
      .map(
        (event) => EngineChange(
          snapshot: _snapshot(event.snapshot),
          kind: event.kind,
          requestId: event.requestId,
          previousName: event.previousBuildName,
          fields: List.unmodifiable(event.changedFields),
        ),
      );

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _channel.terminate();
    try {
      await _helper.stdin.close();
    } on IOException {
      /* Процесс уже завершился. */
    }
    try {
      await _helper.exitCode.timeout(const Duration(seconds: 3));
    } on TimeoutException {
      _helper.kill();
    }
    await _output.cancel();
    await _errors.cancel();
  }
}
