import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grpc/grpc.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../data/component_source.dart';
import '../data/engine_session_client.dart';
import '../data/equipment_repository.dart';
import '../data/workbench_client.dart';
import '../data/mcp_editor_gateway.dart';
import '../data/mcp_error_message.dart';
import '../data/pob_window_repository.dart';
import '../data/pob_build_document.dart';
import '../data/pob_share_code.dart';
import '../data/pob_share_links.dart';
import '../data/profile_cleanup.dart';
import '../data/progression_comparison_session.dart';
import '../data/pob_build_library.dart';
import '../data/pob_engine_bindings.dart';
import '../data/pob_build_locations.dart';
import '../data/session_repository.dart';
import '../data/build_library.dart';
import '../data/tree_icon_repository.dart';
import '../data/tree_progression_exchange.dart';
import '../data/tree_progression_repository.dart';
import '../data/tree_path_comparison.dart' as paths;
import '../domain/build_report.dart';
import '../domain/equipment_item.dart';
import '../domain/tree_geometry.dart';
import '../domain/tree_progression.dart';
import '../domain/tree_path_comparison.dart';
import '../domain/original_tree_scene.dart';
import '../domain/node_power.dart';
import '../domain/node_preview.dart';
import '../domain/library_entry.dart';
import '../domain/component.dart';
import 'workshop_state.dart';
import 'mcp_editor_cubit.dart';
import '../domain/tree_allocation_mode.dart';
import '../data/xml_file_service.dart';
import '../data/game_catalog_repository.dart';
import '../data/saved_build_comparison.dart';
import '../domain/build_comparison.dart';
import '../domain/build_edit_result.dart';
import '../domain/engine_session.dart';
import 'engine_session_cubit.dart';

typedef _BuildSnapshot = ({String xml, String title});
typedef _ComponentValidation = Future<void> Function(Installations);
typedef _EngineXmlBinding = ({
  int inputRevision,
  String libraryRevision,
  String? fileXml,
});
typedef _SharedEditSource = ({
  EngineSnapshot snapshot,
  _EngineXmlBinding binding,
  int epoch,
});
typedef WorkshopTreeOffer = ({
  EngineTreeOffer offer,
  int inputRevision,
  int bindingEpoch,
});

typedef WorkshopJewelOffer = ({
  EngineJewelOffer offer,
  int inputRevision,
  int bindingEpoch,
});

const _missingEngineXml = 'В общей сессии нет XML сборки';
const _staleTree = 'Выполните предпросмотр для текущей ревизии';
const _staleBuild =
    'Сборка изменилась. Дождитесь новой ревизии и повторите действие';
const _staleCondition = 'Сборка изменилась. Откройте условие заново.';
const _divergedBuild =
    'Файл сборки изменился. Проверьте версии перед переподключением.';

class WorkshopCubit extends Cubit<WorkshopState> {
  WorkshopCubit(
    this.components,
    WorkbenchClient engine, {
    WorkshopState? initialState,
    SessionRepository? session,
    BuildStorage? library,
    XmlFileService? files,
    PobWindowRepository? pobWindow,
    PobBuildLocations? buildLocations,
    PobShareLinks? shareLinks,
    WorkbenchClient Function()? createEngine,
    Future<EngineConnection> Function(EngineOptions)? openEngineSession,
    EngineOptions? primaryEngine,
  }) : _engine = engine,
       _createEngine = createEngine ?? WorkbenchClient.new,
       session = session ?? SessionRepository(components.store.root),
       library = library ?? BuildLibrary(components.store.root),
       files = files ?? XmlFileService(),
       pobWindow = pobWindow ?? PobWindowRepository(),
       buildLocations = buildLocations ?? PobBuildLocations(),
       _shareLinks = shareLinks ?? PobShareLinks(),
       _openEngineSession = openEngineSession,
       _primaryEngine = primaryEngine,
       super(initialState ?? WorkshopState());
  final ComponentSource components;
  final Future<EngineConnection> Function(EngineOptions)? _openEngineSession;
  late final engineSession = EngineSessionCubit(
    open: _openEngineSession,
    onSnapshot: _applyEngineSnapshot,
  );
  final EngineOptions? _primaryEngine;
  Future<void>? _initialization;
  Future<void>? _primaryOpening;
  EngineBindingKey? _primaryAttempt;
  bool _managedEngine = false;
  int? _primaryDiskRevision;
  EngineBindingKey? _engineBinding;
  int _engineBindingEpoch = 0;
  _EngineXmlBinding? _engineXmlBinding;
  EngineBindingKey? get _currentEngineBinding {
    final id = state.library.activeId;
    return id == null ? null : (folder: sharedLibrary?.directory ?? '', id: id);
  }

  Future<void> connectEngine(
    EngineOptions options, {
    String? createName,
    bool bindCurrentBuild = false,
    bool importOpenBuild = false,
    bool useSessionXml = false,
  }) async {
    final opened = _currentEngineBinding;
    _primaryAttempt = opened;
    _managedEngine = false;
    final xml = importOpenBuild ? await _exportEngineXml(createName) : null;
    final syncXml = bindCurrentBuild && (importOpenBuild || useSessionXml);
    final input = syncXml ? _startEngineXmlBinding(opened) : null;
    final epoch = ++_engineBindingEpoch;
    _engineBinding = bindCurrentBuild ? _currentEngineBinding : null;
    _engineXmlBinding = input;
    try {
      await engineSession.connect(
        options,
        createName: createName,
        createXml: xml,
      );
      if (syncXml) await _confirmEngineXmlBinding(epoch);
    } catch (_) {
      if (epoch == _engineBindingEpoch) _clearEngineBinding();
      rethrow;
    }
  }

  Future<String> _exportEngineXml(String? createName) async {
    final xml = createName == null ? null : await exportXml();
    if (xml == null) {
      throw StateError('Откройте сборку для импорта в общую сессию');
    }
    return xml;
  }

  Future<void> _confirmEngineXmlBinding(int epoch) async {
    await engineSession.waitForSnapshot();
    if (epoch != _engineBindingEpoch) return;
    if (_engineXmlBinding!.inputRevision == 0) {
      throw StateError(state.error ?? _missingEngineXml);
    }
  }

  _EngineXmlBinding _startEngineXmlBinding(
    ({String folder, String id})? opened,
  ) {
    final revision = state.library.active?.revision;
    if (opened == null ||
        opened != _currentEngineBinding ||
        revision == null ||
        state.document == null ||
        sharedLibrary == null) {
      throw StateError('Откройте сборку для импорта в общую сессию');
    }
    return (inputRevision: 0, libraryRevision: revision, fileXml: null);
  }

  void _clearEngineBinding() {
    _managedEngine = false;
    _primaryDiskRevision = null;
    _engineBindingEpoch++;
    _engineBinding = null;
    _engineXmlBinding = null;
  }

  Future<void> disconnectEngine() async {
    _primaryAttempt = _currentEngineBinding;
    _clearEngineBinding();
    await engineSession.disconnect();
  }

  Future<void> _applyEngineSnapshot(EngineSnapshot snapshot) async {
    final binding = _engineBinding;
    final epoch = _engineBindingEpoch;
    if (binding == null) return;
    if (state.busy) await stream.firstWhere((value) => !value.busy);
    if (isClosed ||
        _closing ||
        _engineBinding != binding ||
        _currentEngineBinding != binding ||
        epoch != _engineBindingEpoch)
      return;
    if (_engineXmlBinding != null) {
      await _acceptEngineXml(snapshot);
      return;
    }
    await _renameLocalBuild(snapshot.buildName);
    if (state.error case final error?) throw StateError(error);
    addLog(
      'Общая сессия ${snapshot.sessionId}, ревизия ${snapshot.revision}: название «${snapshot.buildName}»',
    );
  }

  bool get usesPrimaryEngine => _primaryEngine != null;

  Future<void> waitForPrimarySession() async {
    var opening = _primaryOpening;
    while (opening != null) {
      await opening;
      opening = _primaryOpening;
    }
  }

  void _schedulePrimarySession() {
    final key = _currentEngineBinding;
    final shared = sharedLibrary;
    if (_primaryEngine == null ||
        _primaryOpening != null ||
        key == null ||
        key == _primaryAttempt ||
        shared == null ||
        state.report == null)
      return;
    if (_closing || isClosed || _engineBinding != null || state.busy) return;
    _primaryAttempt = key;
    _primaryOpening = _openPrimarySession(shared, key).whenComplete(() {
      _primaryOpening = null;
      _schedulePrimarySession();
    });
    unawaited(_primaryOpening!);
  }

  Future<void> _openPrimarySession(
    PobBuildLibrary shared,
    EngineBindingKey key,
  ) async {
    final startingEpoch = _engineBindingEpoch;
    int? bindingEpoch;
    try {
      final disk = await shared.open(key.id);
      final saved = await _ensurePrimaryBinding(shared, key, disk);
      if (_primarySourceChanged(key, startingEpoch)) {
        if (state.busy &&
            key == _currentEngineBinding &&
            startingEpoch == _engineBindingEpoch) {
          _primaryAttempt = null;
        }
        return;
      }
      final epoch = ++_engineBindingEpoch;
      bindingEpoch = epoch;
      _managedEngine = true;
      _engineBinding = key;
      _engineXmlBinding = (
        inputRevision: 0,
        libraryRevision: disk.entry.revision!,
        fileXml: disk.xml,
      );
      final options = _primaryOptions(saved.sessionId);
      await engineSession.connect(
        options,
        initialSnapshot: (connection) =>
            _restorePrimarySession(connection, saved, disk, epoch),
      );
      await _confirmEngineXmlBinding(epoch);
    } catch (error) {
      if (isClosed ||
          _closing ||
          (bindingEpoch ?? startingEpoch) != _engineBindingEpoch)
        return;
      _clearEngineBinding();
      _update(
        state.copyWith(
          operation: (busy: state.busy, error: engineError(error)),
        ),
      );
      addLog(engineError(error));
    }
  }

  bool _primarySourceChanged(EngineBindingKey key, int epoch) =>
      isClosed ||
      _closing ||
      state.busy ||
      key != _currentEngineBinding ||
      epoch != _engineBindingEpoch ||
      _engineBinding != null;

  Future<SavedEngineBinding> _ensurePrimaryBinding(
    PobBuildLibrary shared,
    EngineBindingKey key,
    PobBuildVersion disk,
  ) async {
    final existing = await shared.engineBindings.read(key);
    if (existing != null) return existing;
    final binding = (
      sessionId: shared.engineBindings.initialSessionId(
        key,
        disk.xml,
        disk.entry.updated,
      ),
      fileHash: PobEngineBindings.hash(disk.xml),
      engineHash: null,
    );
    await shared.engineBindings.write(key, binding);
    return binding;
  }

  EngineOptions _primaryOptions(String sessionId) {
    final pair = components.active;
    final pob = pair[Component.pob];
    final native = pob?.nativeDirectory;
    return _primaryEngine!.forBuild(
      sessionId,
      pob: pob?.directory,
      native: native,
    );
  }

  Future<EngineSnapshot> _restorePrimarySession(
    EngineConnection connection,
    SavedEngineBinding saved,
    PobBuildVersion disk,
    int epoch,
  ) async {
    final session = await _existingPrimarySession(connection, saved.sessionId);
    if (epoch != _engineBindingEpoch) throw StateError(_staleBuild);

    if (session == null)
      return _createPrimarySession(connection, saved, disk, epoch);
    final engineXml = session.build?.xml;
    if (engineXml == null) throw StateError(_missingEngineXml);
    final sameEngine = saved.engineHash == PobEngineBindings.hash(engineXml);
    final sameFile = saved.fileHash == PobEngineBindings.hash(disk.xml);
    if (engineXml == disk.xml || (sameFile && sameEngine)) {
      return _loadedFromDisk(session, epoch);
    }
    if (sameFile) return session;
    if (!sameEngine) throw StateError(_divergedBuild);
    await _checkEngineFile(_engineXmlBinding!);
    if (epoch != _engineBindingEpoch) throw StateError(_staleBuild);
    final replaced = await connection.replaceBuild(
      session,
      disk.xml,
      engineRequestId(),
    );
    return _loadedFromDisk(replaced, epoch);
  }

  Future<EngineSnapshot> _createPrimarySession(
    EngineConnection connection,
    SavedEngineBinding saved,
    PobBuildVersion disk,
    int epoch,
  ) async {
    try {
      final created = await connection.create(
        saved.sessionId,
        disk.entry.title,
        engineRequestId(),
        xml: disk.xml,
      );
      return _loadedFromDisk(created, epoch);
    } on GrpcError catch (error) {
      if (error.code != StatusCode.alreadyExists) rethrow;
      return _restorePrimarySession(connection, saved, disk, epoch);
    }
  }

  EngineSnapshot _loadedFromDisk(EngineSnapshot snapshot, int epoch) {
    if (epoch != _engineBindingEpoch) throw StateError(_staleBuild);
    _primaryDiskRevision = snapshot.revision;
    return snapshot;
  }

  Future<EngineSnapshot?> _existingPrimarySession(
    EngineConnection connection,
    String id,
  ) async {
    try {
      return await connection.snapshot(id);
    } on GrpcError catch (error) {
      if (error.code == StatusCode.notFound) return null;
      rethrow;
    }
  }

  Future<void> _checkpointPrimarySession(
    EngineSnapshot snapshot,
    String diskXml,
  ) async {
    final key = _engineBinding;
    if (!_managedEngine || key == null) return;
    try {
      await sharedLibrary!.engineBindings.write(key, (
        sessionId: snapshot.sessionId,
        fileHash: PobEngineBindings.hash(diskXml),
        engineHash: PobEngineBindings.hash(snapshot.build!.xml),
      ));
    } on FileSystemException catch (error) {
      addLog(error.toString());
    }
  }

  Future<void> _acceptEngineXml(EngineSnapshot snapshot) async {
    final binding = _engineXmlBinding!;
    if (binding.inputRevision != 0 &&
        snapshot.revision != engineSession.state.snapshot?.revision) {
      return;
    }
    final incoming = snapshot.build;
    if (incoming == null) return;
    if (incoming.inputRevision > binding.inputRevision) {
      await _run(() async {
        await _mirrorEngineBuild(snapshot, binding);
        _clearHistory();
      });
      if (state.error case final error?) throw StateError(error);
      return;
    }
    if (state.library.active?.title != snapshot.buildName) {
      await _renameLocalBuild(snapshot.buildName, binding: binding);
      if (state.error case final error?) throw StateError(error);
    }
  }

  Future<String> _checkEngineFile(_EngineXmlBinding binding) async {
    final entry = state.library.active;
    if (entry == null || entry.revision != binding.libraryRevision) {
      throw StateError(_divergedBuild);
    }
    final file = await sharedLibrary!.changed(entry.id, null);
    if (file == null ||
        file.entry.revision != binding.libraryRevision ||
        (binding.fileXml != null && file.xml != binding.fileXml)) {
      throw StateError(_divergedBuild);
    }
    return file.xml;
  }

  Future<void> _mirrorEngineBuild(
    EngineSnapshot snapshot,
    _EngineXmlBinding binding,
  ) async {
    final epoch = _engineBindingEpoch;
    final diskXml = await _checkEngineFile(binding);
    await _flushText();
    if (epoch != _engineBindingEpoch || binding != _engineXmlBinding) {
      throw StateError(_staleBuild);
    }
    final document = state.document!;
    final target = state.library;
    final before = await _currentXml();
    final incoming = snapshot.build!;
    final keepDisk =
        _managedEngine &&
        binding.inputRevision == 0 &&
        snapshot.revision == _primaryDiskRevision;
    final fileXml = keepDisk ? diskXml : incoming.xml;
    final (:xml, :progression) = splitTreeProgression(incoming.xml);
    _markStale();
    try {
      await _loadXml(xml);
      await _readReport(
        target: target,
        title: snapshot.buildName,
        progression: progression,
        progressionSource: _storedProgressionKey,
        persist: !keepDisk,
        savedXml: fileXml,
        expectedXml: diskXml,
        snapshot: snapshot,
      );
      if (progression == null) await _clearMissingProgression(diskXml);
      _engineXmlBinding = (
        inputRevision: incoming.inputRevision,
        libraryRevision: state.library.active!.revision!,
        fileXml: fileXml,
      );
    } catch (_) {
      await _restoreWorking(before, document, target);
      rethrow;
    }
    _seenBuildXml = fileXml;
    await _checkpointPrimarySession(snapshot, fileXml);
  }

  Future<void> _clearMissingProgression(String previousXml) async {
    final plan = splitTreeProgression(previousXml).progression;
    final id = state.library.activeId;
    if (plan == null || id == null) return;
    final key = _progressionKey(id, plan.version, plan.characterClass);
    await progressionRepository(key).restoreFromSnapshot([]);
  }

  final PobShareLinks _shareLinks;
  WorkbenchClient _engine;
  WorkbenchClient get engine => _engine;
  final WorkbenchClient Function() _createEngine;
  final SessionRepository session;
  final BuildStorage library;
  PobBuildLibrary? get sharedLibrary =>
      library is PobBuildLibrary ? library as PobBuildLibrary : null;
  BuildNotesStorage get buildNotes =>
      sharedLibrary ?? session as BuildNotesStorage;
  bool get buildFolderReady =>
      sharedLibrary == null || sharedLibrary?.directory != null;
  final XmlFileService files;
  TreeProgressionKey? get progressionKey {
    final id = state.library.activeId;
    final document = state.document;
    final tree = document?.tree;
    if (id == null || tree == null) return null;
    return _progressionKey(id, tree.version, document!.report.characterClass);
  }

  TreeProgressionKey? get _storedProgressionKey {
    if (progressionKey case final key?) return key;
    final id = state.library.activeId;
    final report = state.report;
    final version = report?.treeVersion;
    if (id == null || version == null || version.isEmpty || version == '—') {
      return null;
    }
    return _progressionKey(id, version, report!.characterClass);
  }

  TreeProgressionKey _progressionKey(
    String id,
    String version,
    String characterClass,
  ) => (
    folder: sharedLibrary?.directory ?? '',
    build: id,
    version: version,
    characterClass: characterClass,
  );

  TreeProgressionRepository progressionRepository(TreeProgressionKey key) =>
      TreeProgressionRepository(
        components.store.root,
        key,
        saveShared: _sharedProgressionEditor(key),
      );

  Future<void> Function(List<TreeProgressionStep>)? _sharedProgressionEditor(
    TreeProgressionKey key,
  ) {
    if (!hasSharedTree || key != progressionKey) return null;
    final epoch = _engineBindingEpoch;
    final source = engineSession.state.snapshot?.build?.xml;
    if (source == null) return null;
    var previous = _progressionValue(source);
    return (steps) async {
      final plan = (
        version: key.version,
        characterClass: key.characterClass,
        steps: steps,
      );
      final result = await _applyEngineEdit(
        expectedInput: _engineXmlBinding?.inputRevision ?? 0,
        epoch: epoch,
        staleMessage: _staleBuild,
        apply: (current) {
          if (_progressionValue(current.build!.xml) != previous) {
            throw StateError('План прокачки изменился. Откройте его заново.');
          }
          final base = splitTreeProgression(current.build!.xml).xml;
          return engineSession.replaceBuild(
            current,
            attachTreeProgression(base, plan),
          );
        },
      );
      if (!result.committed) throw StateError(result.error!);
      previous = attachTreeProgression('', plan);
    };
  }

  String _progressionValue(String xml) =>
      attachTreeProgression('', splitTreeProgression(xml).progression);

  Set<int> get _progressionStarts => {
    for (final node in state.document!.tree!.nodes)
      if (!isProgressionNode(node.kind)) node.id,
  };

  Future<TreeProgressionStep?> captureProgression(
    TreeProgressionKey key,
  ) async {
    if (key != progressionKey || state.document!.stale) return null;
    TreeProgressionStep? step;
    await _run(() async {
      final build = PobBuildDocument(await _currentXml());
      step = TreeProgressionStep(
        build.level,
        build.allocatedNodes.difference(_progressionStarts),
        allocation: build.progressionAllocation,
        skills: build.progressionSkills,
        equipment: build.progressionEquipment,
      );
    });
    return step;
  }

  Future<void> applyProgression(
    TreeProgressionKey key,
    TreeProgressionStep step, {
    Set<ProgressionPart> parts = const {ProgressionPart.tree},
  }) async {
    if (key != progressionKey || state.document!.stale) return;
    if (parts.isEmpty || !step.parts.containsAll(parts)) return;
    final starts = _progressionStarts;
    await _changeBuild(
      () async {
        final build = PobBuildDocument(await _currentXml());
        await _loadXml(build.withProgression(step, parts: parts));
      },
      validate: parts.contains(ProgressionPart.tree)
          ? (xml) => _verifyAppliedProgression(xml, step, starts)
          : null,
    );
  }

  ProgressionComparisonSession progressionComparison(TreeProgressionKey key) =>
      ProgressionComparisonSession(() async {
        final report = state.report;
        if (report == null || !_canCompareProgression(key)) {
          throw StateError('Сборка изменилась. Откройте этап снова.');
        }
        final xml = await _currentXml();
        if (!_canCompareProgression(key) || state.report != report) {
          throw StateError('Сборка изменилась. Откройте этап снова.');
        }
        return (
          components: Map<Component, Installation>.unmodifiable(
            components.active,
          ),
          report: report,
          xml: xml,
          starts: _progressionStarts,
        );
      }, engine: _createEngine());

  bool _canCompareProgression(TreeProgressionKey key) =>
      key == progressionKey && !state.busy && state.document?.stale == false;

  void _verifyAppliedProgression(
    String xml,
    TreeProgressionStep step,
    Set<int> starts,
  ) {
    final actual = PobBuildDocument(xml);
    verifyProgressionTree(
      step,
      actual.level,
      actual.allocatedNodes.difference(starts),
    );
  }

  final PobWindowRepository pobWindow;
  final PobBuildLocations buildLocations;
  McpEditorCubit? _mcpEditor;
  McpEditorCubit get mcpEditor => _mcpEditor ??= McpEditorCubit(this);
  late GameCatalogRepository _catalogs = GameCatalogRepository(engine);
  GameCatalogRepository get catalogs => _catalogs;
  late final treeIcons = TreeIconRepository(
    root: Directory.fromUri(components.store.root.uri.resolve('tree-cache/')),
    readShared: _readSharedTexture,
  );
  TreeGeometry? _pendingTreeArtwork;
  Future<void>? _treeArtworkLoad;
  Timer? _buildChangeDelay;
  StreamSubscription<FileSystemEvent>? _buildChanges;
  ({String directory, String id})? _watchedBuild;
  bool _closing = false;
  String? _seenBuildXml;
  Completer<void>? _buildSync;
  Future<void>? _componentChange;
  bool _buildSyncPending = false;
  bool Function()? modalOpen;
  final List<_BuildSnapshot> _undoHistory = [];
  final List<_BuildSnapshot> _redoHistory = [];

  bool get ready =>
      components.requiredComponents.every(components.active.containsKey);
  bool get luaReady => engine.connected && state.classes.isNotEmpty;

  Future<BuildComparison> compareSavedBuilds(
    String baselineXml,
    String candidateXml,
  ) async {
    if (!ready || _closing || isClosed) {
      throw StateError('Для сравнения подготовьте PoB и MCP');
    }
    final pair = Map<Component, Installation>.unmodifiable(components.active);
    return compareSavedXml(_createEngine(), pair, baselineXml, candidateXml);
  }

  bool get canCompareTreePaths =>
      ready &&
      engine.connected &&
      !state.busy &&
      state.document?.stale == false &&
      (_canCompareSharedPaths ||
          engine.tools.containsAll({
            'pob_node_tooltip',
            'pob_tree_action',
            'pob_tree_options',
          }));

  bool get _canCompareSharedPaths =>
      hasSharedTree && engineSession.supportsTreeAllocationModes;

  Future<TreePathComparison> compareTreePaths(int first, int second) async {
    final report = state.report;
    if (report == null || !canCompareTreePaths)
      throw StateError(staleTreePaths);
    final buildId = state.library.activeId;
    final mode = state.treeMode;
    final componentSource = _componentSource;
    final shared = _canCompareSharedPaths
        ? await _compareSharedPaths(first, second)
        : null;
    final xml = shared == null
        ? await _currentXml()
        : engineSession.state.snapshot!.build!.xml;
    final reports = shared == null
        ? await _compareLegacyPaths(xml, first, second, mode)
        : _enginePathReports(shared);
    final comparison = TreePathComparison(
      source: report,
      sourceRevision: PobBuildDocument(xml).revision,
      buildId: buildId,
      reports: reports,
      mode: mode,
      weaponSet: report.weaponSet,
      componentSource: componentSource,
      enginePaths: shared,
    );
    if (!canCompareTreePaths || !isTreePathCurrent(comparison)) {
      throw StateError(staleTreePaths);
    }
    return comparison;
  }

  Future<TreePathReports> _compareLegacyPaths(
    String xml,
    int first,
    int second,
    TreeAllocationMode mode,
  ) => paths.compareTreePaths(
    _createEngine(),
    Map<Component, Installation>.unmodifiable(components.active),
    xml,
    first,
    second,
    mode: mode,
  );

  Future<EngineTreePaths?> _compareSharedPaths(int first, int second) async {
    if (first == second)
      throw const FormatException('Выберите два разных узла.');
    try {
      final left = await previewSharedTreeNode(
        first,
        action: EngineTreeAction.allocate,
      );
      final right = await previewSharedTreeNode(
        second,
        action: EngineTreeAction.allocate,
      );
      if (!isCurrentSharedTreeOffer(left) || !isCurrentSharedTreeOffer(right)) {
        throw StateError(staleTreePaths);
      }
      return (
        first: left.offer,
        second: right.offer,
        inputRevision: left.inputRevision,
        bindingEpoch: left.bindingEpoch,
      );
    } on GrpcError catch (error) {
      if (error.code == StatusCode.invalidArgument) return null;
      rethrow;
    }
  }

  static TreePathReports _enginePathReports(EngineTreePaths source) => (
    baseline: _enginePathStats(source.first.preview.comparison.before),
    first: _enginePathOption(source.first),
    second: _enginePathOption(source.second),
  );

  static TreePathStats _enginePathStats(EngineCalculation result) =>
      (dps: result.dps, life: result.life);

  static TreePathOption _enginePathOption(EngineTreeOffer offer) {
    final preview = offer.preview;
    final points = preview.points!;
    final mode = offer.edit.allocationMode;
    return (
      target: offer.edit.nodeId,
      points:
          _pathPointCount(points.after, mode) -
          _pathPointCount(points.before, mode),
      nodes: preview.added,
      stats: _enginePathStats(preview.comparison.after),
      xml: null,
    );
  }

  static int _pathPointCount(
    EnginePassivePoints points,
    TreeAllocationMode? mode,
  ) => switch (mode) {
    TreeAllocationMode.weaponOne => points.weaponOne,
    TreeAllocationMode.weaponTwo => points.weaponTwo,
    _ => points.passives,
  };

  bool isTreePathCurrent(TreePathComparison comparison) =>
      ready &&
      state.document?.stale == false &&
      state.treeMode == comparison.mode &&
      state.report?.weaponSet == comparison.weaponSet &&
      _componentSource == comparison.componentSource &&
      identical(state.report, comparison.source) &&
      state.library.activeId == comparison.buildId &&
      _isCurrentPathPreview(comparison.enginePaths);

  bool _isCurrentPathPreview(EngineTreePaths? paths) =>
      paths == null ||
      (_isCurrentEngineInput(paths.bindingEpoch, paths.inputRevision) &&
          engineSession.isCurrentTreeOffer(paths.first) &&
          engineSession.isCurrentTreeOffer(paths.second));

  Future<BuildEditResult> applyTreePath(
    TreePathComparison comparison, {
    required bool first,
  }) {
    if (comparison.enginePaths case final shared?) {
      if (!isTreePathCurrent(comparison)) {
        return Future.value((committed: false, error: staleTreePaths));
      }
      return applySharedTreeNode((
        offer: first ? shared.first : shared.second,
        inputRevision: shared.inputRevision,
        bindingEpoch: shared.bindingEpoch,
      ));
    }
    final option = first ? comparison.reports.first : comparison.reports.second;
    late String updated;
    return _changeBuild(
      () => _loadXml(updated),
      guard: (before) {
        final current = PobBuildDocument(before);
        if (!isTreePathCurrent(comparison) ||
            current.revision != comparison.sourceRevision) {
          throw StateError(staleTreePaths);
        }
        updated = current.withTreeAllocation(PobBuildDocument(option.xml!));
      },
      validate: (after) => paths.checkAppliedTreePath(after, option),
    );
  }

  String get _componentSource => _pairSource(components.active);

  String _pairSource(Installations pair) =>
      components.requiredComponents.map((key) => pair[key]!.commit).join('-');

  Future<NodePreview> previewNode(int id) async {
    final hovered = await _sharedNodeTooltip(
      id,
      compare: true,
      includeScene: true,
    );
    if (hovered?['engineScene'] case final OriginalTreeScene scene) {
      final images = await loadTreeSceneImages(scene);
      return NodePreview(tooltip: hovered!, scene: scene, images: images);
    }
    return _legacyNodePreview(id);
  }

  Future<NodePreview> _legacyNodePreview(int id) async {
    final tip = await _sharedNodeTooltip(id, compare: true);
    if (!engine.tools.contains('pob_tree_hover')) {
      return NodePreview(
        tooltip:
            tip ??
            await engine.call('pob_node_tooltip', {'id': id, 'compare': true}),
      );
    }
    final result = await engine.call('pob_tree_hover', {
      'id': id,
      'compare': true,
    });
    final scene = OriginalTreeScene.fromJson(jsonMap(result['scene']));
    final images = await loadTreeSceneImages(scene);
    return NodePreview(
      tooltip: tip ?? jsonMap(result['tooltip']),
      scene: scene,
      images: images,
    );
  }

  Future<JsonMap?> _sharedNodeTooltip(
    int id, {
    required bool compare,
    bool includeScene = false,
  }) async {
    final snapshot = _engineXmlBinding == null
        ? null
        : engineSession.state.snapshot;
    if (snapshot == null) return null;
    return engineSession.workshopReader?.readNodeTooltip(
      snapshot,
      id,
      compare,
      includeScene: includeScene,
    );
  }

  Future<List<int>> progressionPath(int id) async {
    final report = state.report;
    final result =
        await _sharedNodeTooltip(id, compare: false) ??
        await engine.call('pob_node_tooltip', {'id': id, 'compare': false});
    if (state.report != report || state.busy) return const [];
    final path = NodePreview(tooltip: result).path;
    return path.firstOrNull == id ? List.unmodifiable(path.reversed) : const [];
  }

  ({EngineTreePowerReader reader, EngineSnapshot snapshot})? get _sharedPower {
    if (_engineXmlBinding == null) return null;
    final Object? reader = engineSession.workshopReader;
    final snapshot = engineSession.state.snapshot;
    if (reader is EngineTreePowerReader &&
        reader.supportsTreePower &&
        snapshot != null) {
      return (reader: reader, snapshot: snapshot);
    }
    return null;
  }

  Future<List<JsonMap>>? readSharedPowerMetrics() {
    final power = _sharedPower;
    return power?.reader.readPowerMetrics(power.snapshot);
  }

  Stream<NodePowerUpdate>? watchSharedPower(NodePowerOptions options) {
    final power = _sharedPower;
    return power?.reader.watchTreePower(power.snapshot, options);
  }

  Future<Uint8List?> _readSharedTexture(TreeTextureReference reference) async =>
      engineSession.workshopReader?.readTreeTexture(reference);

  Future<Map<String, Uint8List>> loadTreeSceneImages(OriginalTreeScene scene) =>
      treeIcons.overlay(
        state.document!.tree!.withScene(scene),
        engine,
        _componentSource,
      );

  bool get canRollback => components.requiredComponents.every(
    components.store.previous.containsKey,
  );

  void _update(WorkshopState next) {
    if (isClosed) return;
    final wasBusy = state.busy;
    emit(next);
    if (_engineBinding != null && _engineBinding != _currentEngineBinding) {
      final release = _managedEngine && _currentEngineBinding == null;
      _clearEngineBinding();
      if (release) unawaited(engineSession.disconnect());
    }
    _mcpEditor?.checkBuild();
    _watchOpenBuild();
    if (wasBusy && !next.busy) resumeBuildSync();
    if (!next.busy) _startTreeArtwork();
  }

  void addLog(String value) {
    final lines = [...state.log, value.trim()];
    _update(
      state.copyWith(
        log: lines.length > 120 ? lines.sublist(lines.length - 120) : lines,
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isClosed || state.busy) return;
    _update(
      state.copyWith(
        operation: (busy: true, error: null),
        clearSetupStage: true,
      ),
    );
    try {
      await action();
    } catch (failure) {
      if (failure is PobBuildSaveConflict) {
        _update(state.copyWith(library: _withEntry(failure.copy)));
      }
      final message = mcpErrorMessage(failure);
      _update(state.copyWith(operation: (busy: true, error: message)));
      addLog('Ошибка: $failure');
    } finally {
      _update(
        state.copyWith(
          operation: (busy: false, error: state.error),
          clearSetupStage: state.error == null,
        ),
      );
      _schedulePrimarySession();
    }
  }

  Future<void> initialize() async {
    if (_initialization != null) return;
    final loading = _run(_loadWorkspace);
    _initialization = loading;
    try {
      await loading;
    } finally {
      _initialization = null;
    }
  }

  Future<void> _loadWorkspace() async {
    await components.load();
    final builds = await _loadLibrary();
    final saved = !builds.skipSessionRecovery && await session.exists();
    final draft = await session.readDraft();
    _update(
      state.copyWith(
        sessionSaved: saved,
        library: builds,
        draft: state.draftEdited ? state.draft : (xml: draft, edited: false),
        status: ready
            ? 'Компоненты установлены. Можно подключить Lua.'
            : state.status,
      ),
    );
    await _resume();
  }

  Future<LibraryState> _loadLibrary() async {
    try {
      final builds = await library.load();
      final shared = sharedLibrary;
      if (shared == null || shared.directory != null) return builds;
      final folder = await buildLocations.defaultWithoutWine();
      if (folder == null) return builds;
      await folder.create(recursive: true);
      return await shared.configure(folder.path);
    } on FileSystemException catch (error) {
      if (sharedLibrary == null) rethrow;
      addLog('Папка сборок PoB недоступна: $error');
      return LibraryState(skipSessionRecovery: true);
    }
  }

  Future<void> selectPobBuildFolder(String folder) =>
      _run(() => _usePobBuildFolder(folder));

  Future<void> detectPobBuildFolder() => _run(() async {
    final live = await _liveBuildDirectory();
    if (live != null) {
      await _usePobBuildFolder(live);
      return;
    }
    if (sharedLibrary?.directory != null) return;
    final directory = await buildLocations.find();
    if (directory == null) {
      throw StateError(
        'Стандартная папка PoB не найдена. Выберите папку вручную.',
      );
    }
    await _usePobBuildFolder(directory);
    _update(state.copyWith(status: 'Подключена стандартная папка PoB'));
  });

  Future<String?> _liveBuildDirectory() async {
    if (!pobWindow.supported || !ready) return null;
    try {
      final directory = await pobWindow.buildDirectory(components.active);
      if (await Directory(directory).exists()) return directory;
      throw StateError('Папка сборок из настроек PoB недоступна.');
    } catch (error) {
      if (buildFolderReady) rethrow;
      addLog('Не удалось получить папку через мост PoB: $error');
      return null;
    }
  }

  Future<void> _usePobBuildFolder(String folder) async {
    final shared = sharedLibrary;
    if (shared == null) return;
    await buildNotes.flushText();
    final previous = shared.directory;
    final builds = await shared.configure(folder);
    final changed = previous != shared.directory;
    _setSharedLibrary(builds, changingFolder: changed);
    if (changed && engine.connected) await _resumeLibrary();
  }

  Future<void> refreshPobBuilds() => _run(() async {
    final shared = sharedLibrary;
    if (shared != null) {
      _setSharedLibrary(await shared.scan());
      requestBuildSync();
    }
  });

  void _setSharedLibrary(LibraryState scanned, {bool changingFolder = false}) {
    final opened = changingFolder || state.report == null
        ? null
        : state.library.active;
    final builds = opened == null
        ? scanned
        : LibraryState(
            entries: [
              opened,
              ...scanned.entries.where((entry) => entry.id != opened.id),
            ],
            activeId: opened.id,
            skipSessionRecovery: true,
          );
    _update(
      state.copyWith(
        library: builds,
        clearReport: changingFolder,
        sessionSaved: builds.active != null,
      ),
    );
    if (changingFolder) _clearHistory();
  }

  Future<void> prepareComponents() => _run(() async {
    if (!ready) {
      await _installFirstPair();
    } else if (components.engineExecutable == null &&
        !luaReady &&
        components.active.values.any((item) => item.archiveSha256 == null)) {
      await _migrateLegacyPair();
    }
    if (!luaReady) {
      _showSetupStage(WorkshopSetupStage.lua);
      await _resume();
      if (!luaReady) {
        throw const FormatException('Lua не вернул каталог классов');
      }
    }
  });

  Future<void> _installFirstPair() async {
    _showSetupStage(WorkshopSetupStage.releases);
    await _checkComponentReleases();
    await _installSelectedPair();
  }

  Future<void> _migrateLegacyPair() async {
    _showSetupStage(WorkshopSetupStage.releases);
    await _checkComponentReleases();
    if (!hasComponentUpdates) return;
    await _changeComponentPair(
      (validate) => _installSelectedPair(validate: validate),
      'Пара компонентов обновлена',
    );
  }

  Future<void> _installSelectedPair({_ComponentValidation? validate}) =>
      components.installPair(
        state.releases,
        addLog,
        validate: validate,
        onStage: (stage) => _showSetupStage(switch (stage) {
          ComponentInstallStage.pob => WorkshopSetupStage.pob,
          ComponentInstallStage.mcp => WorkshopSetupStage.mcp,
          ComponentInstallStage.compatibility =>
            WorkshopSetupStage.compatibility,
        }),
      );

  void _showSetupStage(WorkshopSetupStage stage) =>
      _update(state.copyWith(setupStage: stage));

  bool get hasComponentUpdates => state.releases.entries.any(
    (entry) => components.needsInstall(entry.key, entry.value),
  );

  Future<void> checkUpdates() => _run(_checkComponentReleases);

  Future<void> _checkComponentReleases() async {
    final releases = components.availableReleases();
    _update(
      state.copyWith(releases: releases, status: 'Проверка выпусков завершена'),
    );
    addLog(state.status);
  }

  Future<void> updateComponents() => _runComponentChange(() async {
    if (!components.requiredComponents.every(state.releases.containsKey)) {
      await _checkComponentReleases();
    }
    await _changeComponentPair(
      (validate) =>
          components.installPair(state.releases, addLog, validate: validate),
      'Пара компонентов обновлена',
    );
  });

  Future<void> updatePobData(String tag) => _runComponentChange(() async {
    final release = Release(
      tag,
      '${Component.pob.url}/releases/tag/$tag',
      DateTime.now().toUtc(),
    );
    await _changeComponentPair(
      (validate) => components.installPair(
        {Component.pob: release},
        addLog,
        validate: validate,
      ),
      'Данные PoB обновлены',
    );
  });

  Future<void> rollback() => _runComponentChange(
    () => _changeComponentPair(
      (validate) => components.rollback(validate: validate),
      'Предыдущая пара восстановлена и проверена через Lua',
    ),
  );

  Future<void> selectMcpComponent(Component component, String commit) =>
      _runComponentChange(
        () => _changeComponentPair(
          (validate) =>
              components.selectInstalled(component, commit, validate: validate),
          'Установленная пара компонентов проверена и подключена',
        ),
      );

  Future<void> disconnectMcpEngine() async {
    await checkpoint();
    engine.onDisconnected = null;
    await engine.close();
    _update(
      state.copyWith(
        status: 'Lua отключён',
        operation: (busy: false, error: null),
      ),
    );
  }

  Future<void> Function(String text)? sharedNotesEditor(String id) {
    if (!hasSharedTree || state.library.activeId != id) return null;
    final epoch = _engineBindingEpoch;
    final source = engineSession.state.snapshot?.build?.xml;
    if (source == null) return null;
    var previous = PobBuildDocument(splitTreeProgression(source).xml).notes;
    return (text) async {
      final result = await _editSharedXml(epoch, (document) {
        if (document.notes != previous) {
          throw StateError('Заметки изменились. Откройте их заново.');
        }
        return document.withNotes(text);
      });
      if (!result.committed) throw StateError(result.error!);
      previous = text.replaceAll('\r\n', '\n');
    };
  }

  Future<BuildEditResult> _editSharedXml(
    int epoch,
    String Function(PobBuildDocument) change,
  ) => _applyEngineEdit(
    expectedInput: _engineXmlBinding?.inputRevision ?? 0,
    epoch: epoch,
    staleMessage: _staleBuild,
    apply: (current) {
      final (:xml, :progression) = splitTreeProgression(current.build!.xml);
      final changed = change(PobBuildDocument(xml));
      return engineSession.replaceBuild(
        current,
        attachTreeProgression(changed, progression),
      );
    },
  );

  Future<void> writeMcpNotes(String id, String text) async {
    if (sharedNotesEditor(id) case final save?) {
      await save(text);
      return;
    }
    await _run(() async {
      await buildNotes.flushText();
      await buildNotes.readNotes(id);
      await buildNotes.saveNotes(id, text);
      await buildNotes.flushText();
      if (sharedLibrary case final shared?) {
        final disk = await shared.open(id);
        _seenBuildXml = disk.xml;
        _update(state.copyWith(library: _withEntry(disk.entry)));
      }
    });
  }

  Future<void> _runComponentChange(Future<void> Function() action) async {
    if (_closing || isClosed || state.busy) return;
    final pending = _run(action);
    _componentChange = pending;
    try {
      await pending;
    } finally {
      _componentChange = null;
    }
  }

  Future<void> _changeComponentPair(
    Future<void> Function(_ComponentValidation) change,
    String status,
  ) async {
    await _flushText();
    final xml = await _componentBuildXml();
    final candidate = _createEngine();
    var classes = <JsonMap>[];
    WorkshopDocument? document;
    try {
      await change((pair) async {
        await candidate.connect(pair);
        classes = await _readClasses(candidate);
        if (classes.isEmpty) {
          throw const FormatException('Lua не вернул каталог классов');
        }
        if (xml != null) {
          document = await _checkComponentBuild(candidate, xml);
        }
        if (!candidate.connected) throw StateError('Соединение с Lua прервано');
      });
    } catch (_) {
      await _closeComponentEngine(candidate);
      rethrow;
    }
    if (classes.isEmpty) {
      await _closeComponentEngine(candidate);
      _update(state.copyWith(status: 'Пара компонентов уже актуальна'));
      return;
    }
    await _activateComponentEngine(candidate, classes, document, status);
  }

  Future<String?> _componentBuildXml() async {
    if (engine.connected && state.document?.stale == false) return _savedXml();
    if (state.library.activeId case final id?) {
      return splitTreeProgression(await library.read(id)).xml;
    }
    if (state.document == null) return null;
    return session.read();
  }

  Future<WorkshopDocument> _checkComponentBuild(
    WorkbenchClient candidate,
    String xml,
  ) async {
    await candidate.call('pob_import_xml', {'xml': xml});
    await _restoreTreeMode(candidate);
    final result = await candidate.call('pob_check_build');
    final report = parseBuildReport(result);
    final exported = PobBuildDocument(await candidate.exportBuildXml());
    if (exported.characterClass != PobBuildDocument(xml).characterClass) {
      throw StateError('Новая пара изменила класс открытой сборки');
    }
    final (:tree, :error) = await _readTree(candidate, includeScene: false);
    if (tree == null && state.document?.tree != null) throw StateError(error!);
    return (report: report, tree: tree, stale: false, treeError: error);
  }

  Future<void> _activateComponentEngine(
    WorkbenchClient candidate,
    List<JsonMap> classes,
    WorkshopDocument? document,
    String status,
  ) async {
    final previous = engine;
    previous.onDisconnected = null;
    _engine = candidate;
    candidate.onDisconnected = _lostConnection;
    _catalogs = GameCatalogRepository(candidate);
    treeIcons.clear();
    _undoHistory.clear();
    _redoHistory.clear();
    _update(
      state.copyWith(
        classes: classes,
        document: document,
        history: (undo: 0, redo: 0),
        status: status,
      ),
    );
    if (!candidate.connected) _lostConnection(StateError('Lua завершился'));
    addLog(status);
    try {
      if (_mcpEditor?.remoteChanging != true) await _mcpEditor?.disable();
    } catch (error) {
      addLog('Не удалось отключить прежний редактор MCP: $error');
    }
    await _closeComponentEngine(previous);
    if (document != null && candidate.connected) {
      await _loadUpdatedTree(candidate, document, status);
    }
  }

  Future<void> _loadUpdatedTree(
    WorkbenchClient candidate,
    WorkshopDocument document,
    String status,
  ) async {
    final (:tree, :error) = await _readTree(candidate);
    if (!candidate.connected) return;
    _pendingTreeArtwork = tree;
    _update(
      state.copyWith(
        document: (
          report: document.report,
          tree: tree ?? document.tree,
          stale: false,
          treeError: error,
        ),
        status: status,
      ),
    );
  }

  Future<void> _closeComponentEngine(WorkbenchClient client) async {
    try {
      await client.close();
    } catch (error) {
      addLog('Не удалось закрыть сессию Lua: $error');
    }
  }

  Future<void> connect() => _run(_resume);

  Future<void> _resume() async {
    if (!ready) return;
    if (state.document != null) _markStale();
    await _connect();
    if (await _resumeLibrary(keepWorking: false)) return;
    if (sharedLibrary != null || state.library.skipSessionRecovery) return;
    if (await session.exists()) {
      await _loadXml(await session.read());
      await _readReport(
        target: LibraryState(entries: state.library.entries),
        title: 'Восстановленная сборка',
      );
      _clearHistory();
    }
  }

  Future<bool> _resumeLibrary({bool keepWorking = true}) async {
    final active = state.library.active;
    if (active == null) return false;
    try {
      await _openBuild(active.id, keepWorking: keepWorking);
      return true;
    } catch (error) {
      addLog(
        'Не удалось открыть последнюю сборку, проверяем копию восстановления: $error',
      );
      return false;
    }
  }

  Future<void> _connect() async {
    _update(state.copyWith(classes: []));
    engine.onDisconnected = _lostConnection;
    await engine.connect(components.active);
    catalogs.clear();
    final classes = await _readClasses(engine);
    _update(state.copyWith(classes: classes, status: 'Подключён PoB2Engine'));
    addLog(state.status);
  }

  Future<List<JsonMap>> _readClasses(WorkbenchClient client) async {
    final result = await client.call('pob_catalog', {'kind': 'classes'});
    return switch (result) {
      {'entries': final List<dynamic> entries} =>
        entries.map(_classEntry).toList(),
      _ => throw const FormatException('Lua не вернул каталог классов'),
    };
  }

  void _lostConnection(Object error) {
    if (isClosed) return;
    _markStale();
    _update(
      state.copyWith(
        classes: [],
        status: 'Соединение с Lua прервано',
        operation: (busy: state.busy, error: '$error'),
      ),
    );
  }

  Map<String, dynamic> _classEntry(dynamic value) => switch (value) {
    final Map<String, dynamic> entry => Map.unmodifiable(entry),
    _ => throw const FormatException('Неверная запись каталога Lua'),
  };

  Future<void> doctor() => _run(() async {
    final result = await components.doctor();
    _update(
      state.copyWith(
        status:
            'Lua отвечает · ${result['classes']} классов · совместимость проверена',
      ),
    );
    addLog(state.status);
  });

  Future<void> importXml(String xml) => _run(() => _importCopy(xml));

  Future<void> importShareCode(String code) =>
      _run(() async => _importCopy(await decodePobShareCode(code)));

  Future<void> importShareLink(String link) => _run(() async {
    final code = await _shareLinks.download(link);
    await _importCopy(await decodePobShareCode(code));
  });

  Future<void> copyShareCode(Future<void> Function(String) write) =>
      _run(() async {
        if (state.report == null) return;
        await _flushText();
        await write(await encodePobShareCode(await _savedXml()));
        _update(state.copyWith(status: 'Код PoB скопирован'));
      });

  Future<void> importFromPob() => _run(() async {
    final xml = await pobWindow.readXml(components.active);
    await _importCopy(xml);
  });

  Future<void> importPobCharacter(String name) => _run(() async {
    if (!engine.tools.contains('pob_import_character')) {
      throw StateError('Обновите MCP в разделе «Компоненты».');
    }
    final character = await pobWindow.readCharacter(components.active, name);
    await _switchBuild(
      () async {
        await engine.call('pob_import_character', {'character': character});
        await _restoreTreeMode();
      },
      target: LibraryState(entries: state.library.entries),
      title: name,
    );
  });

  Future<void> _importCopy(
    String xml, {
    String title = 'Импортированная сборка',
  }) => _switchXml(
    xml,
    target: LibraryState(entries: state.library.entries),
    title: title,
  );

  Future<void> openXmlFile() => _run(() async {
    final selected = await files.open();
    if (selected == null) return;
    if (sharedLibrary?.idForPath(selected.path) case final id?) {
      await _openBuild(id);
      return;
    }
    await _importCopy(selected.xml, title: selected.title);
  });

  Future<void> saveXmlFile() => _run(() async {
    if (state.report == null) return;
    await _flushText();
    final path = await files.save(
      await _exportedXml(),
      state.library.active?.title ?? state.report!.name,
      beforeSave: sharedLibrary?.checkExport,
    );
    if (path != null) _update(state.copyWith(status: 'XML сохранён'));
  });

  Future<void> createBuild(
    int classId,
    int level, {
    String name = 'Новая сборка',
  }) => _run(
    () => _createBuild({'name': name, 'classId': classId, 'level': level}),
  );

  Future<void> _createBuild(JsonMap arguments) => _switchBuild(
    () async {
      await engine.call('pob_create_build', arguments);
      await _restoreTreeMode();
    },
    target: LibraryState(entries: state.library.entries),
    title: arguments['name'] as String?,
  );

  Future<void> refreshReport() => _run(() async {
    if (state.report == null) return;
    _markStale();
    await _readReport(persist: sharedLibrary == null);
  });

  Future<void> restoreSession() => _run(() async {
    if (sharedLibrary != null) {
      await _resumeLibrary();
      return;
    }
    if (state.library.skipSessionRecovery) return;
    await _switchBuild(
      () async => _loadXml(await session.read()),
      target: state.library,
    );
  });

  Future<({BuildReport report, String xml})> _readResult([
    EngineSnapshot? snapshot,
  ]) async {
    if (snapshot != null && snapshot.build != null) {
      final report = await engineSession.workshopReader?.readReport(snapshot);
      if (report != null) return (report: report, xml: snapshot.build!.xml);
    }
    final result = await engine.call('pob_check_build');
    final report = parseBuildReport(result);
    return (report: report, xml: await _currentXml());
  }

  Future<void> _readReport({
    LibraryState? target,
    String? title,
    bool persist = true,
    String? savedXml,
    String? expectedXml,
    TreeProgressionTransfer? progression,
    TreeProgressionKey? progressionSource,
    EngineSnapshot? snapshot,
  }) async {
    final (:report, :xml) = await _readResult(snapshot);
    final (:tree, :error) = await _readWorkshopTree(snapshot);
    if (progression != null && expectedXml == null) {
      _checkProgression(progression, report, tree);
    }
    final builds = persist
        ? await _saveBuild(
            target ?? state.library,
            report,
            savedXml ?? attachTreeProgression(xml, progression),
            title: title,
            progressionSource: progressionSource,
            expectedXml: expectedXml,
          )
        : target ?? state.library;
    if ((progression, builds.activeId) case (final plan?, final id?)) {
      await _restoreProgression(plan, id, fromEngine: expectedXml != null);
    }
    final saved = sharedLibrary != null
        ? builds.active != null
        : await _saveRecovery(xml);
    _pendingTreeArtwork = tree;
    _update(
      state.copyWith(
        document: (report: report, tree: tree, stale: false, treeError: error),
        library: builds,
        sessionSaved: saved,
        status: 'Сборка рассчитана исходным Lua',
      ),
    );
    addLog(state.status);
  }

  Future<LibraryState> _saveBuild(
    LibraryState target,
    BuildReport report,
    String xml, {
    String? title,
    TreeProgressionKey? progressionSource,
    String? expectedXml,
  }) async {
    final epoch = _engineBindingEpoch;
    final builds = await switch (sharedLibrary) {
      final shared? => shared.save(
        target,
        report,
        xml,
        title: title,
        progressionSource: progressionSource,
        expectedXml: expectedXml,
      ),
      null => library.save(target, report, xml, title: title),
    };
    if (sharedLibrary != null && target.activeId == null) _seenBuildXml = xml;
    if (title != null) _followEngineRename(target, builds, epoch);
    return builds;
  }

  void _followEngineRename(LibraryState before, LibraryState after, int epoch) {
    final binding = _engineBinding;
    if (binding == null ||
        epoch != _engineBindingEpoch ||
        binding != _currentEngineBinding ||
        before.activeId != binding.id ||
        after.activeId == null)
      return;
    _engineBinding = (folder: binding.folder, id: after.activeId!);
    if (_managedEngine) _primaryAttempt = _engineBinding;
    _followEngineFileRevision(before, after);
  }

  void _followEngineFileRevision(LibraryState before, LibraryState after) {
    final binding = _engineXmlBinding;
    final revision = after.active?.revision;
    if (binding == null ||
        revision == null ||
        before.active?.revision != binding.libraryRevision) {
      return;
    }
    _engineXmlBinding = (
      inputRevision: binding.inputRevision,
      libraryRevision: revision,
      fileXml: binding.fileXml,
    );
  }

  Future<void> _restoreProgression(
    TreeProgressionTransfer plan,
    String id, {
    required bool fromEngine,
  }) {
    final key = _progressionKey(id, plan.version, plan.characterClass);
    final repository = progressionRepository(key);
    return fromEngine
        ? repository.restoreFromSnapshot(plan.steps)
        : repository.restoreIfMissing(plan.steps);
  }

  void _checkProgression(
    TreeProgressionTransfer plan,
    BuildReport report,
    TreeGeometry? tree,
  ) {
    if (plan.characterClass != report.characterClass ||
        (tree != null && tree.version != plan.version)) {
      throw const FormatException('Некорректный план прокачки');
    }
  }

  Future<bool> _saveRecovery(String xml) async {
    try {
      await session.save(xml);
      return true;
    } catch (error) {
      reportPersistenceError(
        'Сборка сохранена в библиотеке, но копия восстановления недоступна: $error',
      );
      return false;
    }
  }

  Future<({TreeGeometry? tree, String? error})> _readWorkshopTree(
    EngineSnapshot? snapshot,
  ) async {
    final geometry = snapshot == null
        ? null
        : await engineSession.workshopReader?.readTree(snapshot);
    if (geometry?.original != null) return (tree: geometry, error: null);
    final artwork = await _readTree(engine);
    if (geometry == null) return artwork;
    final scene = artwork.tree?.version == geometry.version
        ? artwork.tree?.original
        : null;
    return (
      tree: scene == null ? geometry : geometry.withScene(scene),
      error: null,
    );
  }

  Future<({TreeGeometry? tree, String? error})> _readTree(
    WorkbenchClient client, {
    bool includeScene = true,
  }) async {
    if (!client.tools.contains('pob_get_tree'))
      return (
        tree: null,
        error: 'Для дерева нужен MCP 0.5.0. Обновите компонент MCP.',
      );
    try {
      final tree = TreeGeometry.fromJson(
        await client.call('pob_get_tree', {
          if (includeScene && client.tools.contains('pob_tree_textures'))
            'includeScene': true,
        }),
      );
      return (tree: tree, error: null);
    } catch (error) {
      return (tree: null, error: 'Дерево недоступно: $error');
    }
  }

  bool _canLoadTreeArtwork(TreeGeometry tree, WorkbenchClient client) =>
      !_closing &&
      !isClosed &&
      !state.busy &&
      ready &&
      client.connected &&
      identical(client, engine) &&
      state.document?.stale == false &&
      identical(state.document?.tree, tree);

  void _startTreeArtwork() {
    // Запрашиваем оформление после сохранения расчёта и завершения операции.
    final tree = _pendingTreeArtwork;
    final client = engine;
    if (tree == null ||
        _treeArtworkLoad != null ||
        !_canLoadTreeArtwork(tree, client)) {
      return;
    }
    final source = _componentSource;
    _treeArtworkLoad = Future<void>(() async {
      try {
        await _loadTreeArtwork(tree, client, source);
      } finally {
        _treeArtworkLoad = null;
        _startTreeArtwork();
      }
    });
  }

  // Проверки оформления ждут и загрузку, и её паузы на операции редактора.
  Future<void> waitForTreeArtwork() async {
    while (!_closing && !isClosed) {
      if (state.busy) {
        await stream.firstWhere((state) => !state.busy, orElse: () => state);
        continue;
      }
      _startTreeArtwork();
      final pending = _treeArtworkLoad;
      if (pending == null) return;
      await pending;
    }
  }

  Future<void> _loadTreeArtwork(
    TreeGeometry tree,
    WorkbenchClient client,
    String source,
  ) async {
    bool current() => _canLoadTreeArtwork(tree, client);
    if (!current()) return;
    final loaded = await treeIcons.load(
      tree,
      client,
      source,
      canContinue: current,
    );
    if (!current() || identical(loaded, tree)) return;
    final document = state.document!;
    _pendingTreeArtwork = null;
    _update(
      state.copyWith(
        document: (
          report: document.report,
          tree: loaded,
          stale: document.stale,
          treeError: document.treeError,
        ),
      ),
    );
  }

  void _markStale() {
    if (state.document case final document?) {
      _update(
        state.copyWith(
          document: (
            report: document.report,
            tree: document.tree,
            stale: true,
            treeError: document.treeError,
          ),
        ),
      );
    }
  }

  Future<void> openBuild(String id) => _run(() => _openBuild(id));

  Future<void> _openBuild(String id, {bool keepWorking = true}) async {
    final shared = sharedLibrary;
    if (shared != null) {
      await _openShared(
        shared,
        await shared.open(id),
        keepWorking: keepWorking,
      );
      return;
    }
    final xml = await library.read(id);
    await _switchXml(
      xml,
      target: LibraryState(entries: state.library.entries, activeId: id),
      keepWorking: keepWorking,
    );
  }

  LibraryState _withEntry(LibraryEntry entry, {String? activeId}) =>
      LibraryState(
        entries: [
          entry,
          ...state.library.entries.where((item) => item.id != entry.id),
        ],
        activeId: activeId ?? state.library.activeId,
        skipSessionRecovery: true,
      );

  Future<void> _openShared(
    PobBuildLibrary shared,
    PobBuildVersion disk, {
    bool automatic = false,
    bool keepWorking = true,
  }) async {
    final copy = await shared.preserveLocal(disk);
    disk = await shared.open(disk.entry.id);
    if (copy != null) _update(state.copyWith(library: _withEntry(copy)));
    _seenBuildXml = disk.xml;
    final entry = disk.entry;
    if (automatic && _managedEngine) {
      _primaryAttempt = null;
      _clearEngineBinding();
      await engineSession.disconnect();
    }
    if (!automatic || entry.revision != state.library.active?.revision) {
      await _switchXml(
        disk.xml,
        target: _withEntry(entry, activeId: entry.id),
        persist: false,
        keepWorking: keepWorking,
      );
      await shared.activate(entry.id);
      if (automatic) {
        _update(state.copyWith(status: 'Сборка обновлена из Path of Building'));
      }
    }
    if (copy != null) {
      final message = 'Правки PoB II сохранены отдельно: ${copy.title}';
      _update(state.copyWith(status: message));
      addLog(message);
    }
  }

  void _watchOpenBuild() {
    if (_closing) return;
    final shared = sharedLibrary;
    final directory = shared?.directory;
    final id = state.library.activeId;
    final target = state.report == null || directory == null || id == null
        ? null
        : (directory: directory, id: id);
    if (target == _watchedBuild) return;
    unawaited(_buildChanges?.cancel());
    _buildChangeDelay?.cancel();
    _watchedBuild = target;
    _buildChanges = target == null
        ? null
        : shared!
              .watchBuild(target.id)
              .listen((_) => requestBuildSync(), onError: (Object _) {});
    if (target != null) requestBuildSync();
  }

  void requestBuildSync() {
    if (_watchedBuild == null) return;
    _buildSyncPending = true;
    resumeBuildSync();
  }

  void resumeBuildSync() {
    if (!_buildSyncPending || _buildSync != null || !_canSyncBuild) return;
    _buildChangeDelay?.cancel();
    _buildChangeDelay = Timer(
      const Duration(milliseconds: 120),
      () => unawaited(syncOpenBuild()),
    );
  }

  bool get _canSyncBuild =>
      !_closing &&
      !isClosed &&
      !state.busy &&
      engine.connected &&
      state.report != null &&
      modalOpen?.call() != true;

  Future<void> syncOpenBuild() async {
    final shared = sharedLibrary;
    final active = state.library.active;
    if (shared == null || active == null) return;
    _buildSyncPending = true;
    if (_buildSync != null || !_canSyncBuild) return;
    _buildSyncPending = false;
    _buildChangeDelay?.cancel();
    final sync = _buildSync = Completer<void>();
    try {
      final disk = await shared.changed(active.id, _seenBuildXml);
      if (disk == null) return;
      if (!_canSyncBuild || state.library.active != active) {
        _buildSyncPending = true;
        return;
      }
      await _run(() => _openShared(shared, disk, automatic: true));
    } finally {
      _buildSync = null;
      sync.complete();
      resumeBuildSync();
    }
  }

  Future<void> deleteBuild(String id) => _run(() async {
    await _flushText();
    final removedActive = state.library.activeId == id;
    final builds = await library.remove(state.library, id);
    _update(
      state.copyWith(
        library: builds,
        clearReport: removedActive,
        sessionSaved: removedActive ? false : null,
        status: 'Сборка удалена',
      ),
    );
    if (removedActive) _clearHistory();
  });

  Future<void> _switchXml(
    String source, {
    required LibraryState target,
    String? title,
    bool persist = true,
    bool keepWorking = true,
  }) {
    final (:xml, :progression) = splitTreeProgression(source);
    return _switchBuild(
      () => _loadXml(xml),
      target: target,
      title: title,
      persist: persist,
      keepWorking: keepWorking,
      progression: progression,
    );
  }

  Future<void> _switchBuild(
    Future<void> Function() action, {
    required LibraryState target,
    String? title,
    bool persist = true,
    bool keepWorking = true,
    TreeProgressionTransfer? progression,
    TreeProgressionKey? progressionSource,
  }) async {
    await _flushText();
    final previous = keepWorking ? state.document : null;
    final previousLibrary = state.library;
    final xml = previous == null ? null : await _currentXml();
    _markStale();
    try {
      await action();
      await _readReport(
        target: target,
        title: title,
        persist: persist,
        progression: progression,
        progressionSource: progressionSource,
      );
      _clearHistory();
    } catch (_) {
      if (xml != null && previous != null) {
        await _restoreWorking(xml, previous, previousLibrary);
      }
      rethrow;
    }
  }

  Future<void> _restoreWorking(
    String xml,
    WorkshopDocument document,
    LibraryState builds,
  ) async {
    try {
      await _loadXml(xml);
      final restored = await _readResult();
      _update(
        state.copyWith(
          library: builds,
          document: (
            report: restored.report,
            tree: document.tree,
            stale: false,
            treeError: document.treeError,
          ),
        ),
      );
    } catch (error) {
      _markStale();
      addLog('Рабочая сборка сохранена; не удалось восстановить Lua: $error');
    }
  }

  Future<void> copyBuild() => _run(() async {
    if (state.report == null) return;
    await _flushText();
    final source = _storedProgressionKey;
    final title =
        '${state.library.active?.title ?? state.report!.name} · копия';
    if (sharedLibrary != null) {
      final xml = await _savedXml();
      await _switchBuild(
        () => _loadXml(xml),
        target: LibraryState(entries: state.library.entries),
        title: title,
        progressionSource: source,
      );
      return;
    }
    final xml = await _currentXml();
    final id = library.newId();
    if (state.library.activeId case final sourceId?) {
      await session.saveNotes(id, await session.readNotes(sourceId));
    }
    Future<LibraryState> saveCopy() => library.save(
      LibraryState(entries: state.library.entries, activeId: id),
      state.report!,
      xml,
      title: title,
    );
    final builds = source == null
        ? await saveCopy()
        : await progressionRepository(source).transferTo(
            progressionRepository((
              folder: source.folder,
              build: id,
              version: source.version,
              characterClass: source.characterClass,
            )),
            saveCopy,
          );
    _update(state.copyWith(library: builds));
    _clearHistory();
  });

  Future<void> renameBuild(String title) {
    if (_engineBinding != null) return _run(() => engineSession.rename(title));
    return _renameLocalBuild(title);
  }

  Future<void> _renameLocalBuild(String title, {_EngineXmlBinding? binding}) =>
      _run(() async {
        if (state.report == null || title.trim().isEmpty) return;
        final previousTitle = state.library.active?.title ?? state.report!.name;
        if (previousTitle == title.trim()) return;
        await _persistRename(title.trim(), previousTitle, binding);
      });

  Future<void> _persistRename(
    String title,
    String previousTitle,
    _EngineXmlBinding? binding,
  ) async {
    final diskXml = binding == null ? null : await _checkEngineFile(binding);
    await _flushText();
    final xml = diskXml == null
        ? await _currentXml()
        : engineSession.state.snapshot!.build!.xml;
    final builds = await _saveBuild(
      state.library,
      state.report!,
      xml,
      title: title,
      progressionSource: _storedProgressionKey,
      expectedXml: diskXml,
    );
    _update(state.copyWith(library: builds));
    _recordRename(binding, xml, previousTitle);
    if (binding != null) {
      _seenBuildXml = xml;
      await _checkpointPrimarySession(engineSession.state.snapshot!, xml);
    }
  }

  void _recordRename(
    _EngineXmlBinding? binding,
    String xml,
    String previousTitle,
  ) {
    if (binding == null) {
      _pushUndo(xml, title: previousTitle);
      return;
    }
    _updateEngineFileRevision(binding);
    _pushUndo(engineSession.state.snapshot!.build!.xml, title: previousTitle);
  }

  void _updateEngineFileRevision(_EngineXmlBinding binding) {
    _engineXmlBinding = (
      inputRevision: binding.inputRevision,
      libraryRevision: state.library.active!.revision!,
      fileXml: engineSession.state.snapshot!.build!.xml,
    );
  }

  Future<JsonMap> readTreeNode(int id) async {
    final catalog = await engine.call('pob_catalog', {
      'kind': 'nodes',
      'query': '$id',
      'limit': 200,
    });
    final node = jsonRows(catalog['entries'])
        .where((entry) => entry['id'] == id)
        .firstOrNull;
    if (node == null)
      throw const FormatException('Lua не вернул сведения об узле');
    return node;
  }

  Future<bool> isAttributeNode(int id) async =>
      jsonRows((await readTreeNode(id))['attributeOptions']).isNotEmpty;

  Future<TreeMastery> readTreeMastery(int id) async {
    final node = await readTreeNode(id);
    final document = PobBuildDocument(await _currentXml());
    return (
      effects: {
        for (final entry in jsonRows(node['masteryEffects']))
          if (entry['effect'] case final int effectId)
            effectId: jsonStrings(entry['stats']),
      },
      activeEffect: document.masteryEffects[id],
    );
  }

  Future<BuildEditResult> selectMastery(int nodeId, int effectId) =>
      _changeBuild(
        () async {
          await engine.call('pob_tree_action', {
            'id': nodeId,
            'action': 'allocate',
            'mastery': effectId,
          });
        },
        validate: (xml) {
          final document = PobBuildDocument(xml);
          if (document.masteryEffects[nodeId] != effectId ||
              !document.allocatedNodes.contains(nodeId)) {
            throw const FormatException('Эффект мастерства не сохранён');
          }
        },
      );

  Future<BuildEditResult> treeAction(
    int id,
    bool allocated, {
    int? attribute,
  }) => _changeBuild(() async {
    await engine.call('pob_tree_action', {
      'id': id,
      'action': allocated && attribute == null ? 'refund' : 'allocate',
      if (attribute != null) 'attribute': attribute,
    });
  });

  bool get hasSharedTree => _engineXmlBinding != null;

  Future<WorkshopTreeOffer> previewSharedTreeNode(
    int nodeId, {
    EngineTreeAction? action,
    EnginePassiveAttribute? attribute,
  }) async {
    final epoch = _engineBindingEpoch;
    final (:snapshot, :binding) = _engineEditSource(
      _engineXmlBinding?.inputRevision,
      epoch,
      _staleTree,
    );
    final tree = snapshot.build!.tree;
    if (tree == null || !engineSession.supportsTreeAllocationModes) {
      throw StateError('Дерево пока недоступно');
    }
    if (attribute != null && !engineSession.supportsTreeAttributes) {
      throw StateError('Для выбора атрибута обновите движок.');
    }
    await _checkEngineFile(binding);
    final allocated = tree.nodes.contains(nodeId);
    final offer = await engineSession.previewTree(snapshot, (
      nodeId: nodeId,
      action:
          action ??
          (allocated ? EngineTreeAction.refund : EngineTreeAction.allocate),
      attribute: attribute,
      allocationMode: _sharedTreeMode(tree, nodeId, allocated),
    ));
    return (
      offer: offer,
      inputRevision: binding.inputRevision,
      bindingEpoch: epoch,
    );
  }

  TreeAllocationMode _sharedTreeMode(
    EngineTree tree,
    int nodeId,
    bool allocated,
  ) {
    final node = state.document?.tree?.nodes
        .where((node) => node.id == nodeId)
        .firstOrNull;
    if (node?.kind == 'Socket') {
      if (!engineSession.supportsTreeSockets) {
        throw StateError('Для правки гнёзд самоцветов обновите движок.');
      }
      return TreeAllocationMode.common;
    }
    return allocated
        ? tree.allocations[nodeId] ?? TreeAllocationMode.common
        : state.treeMode;
  }

  bool _isCurrentEngineInput(int epoch, int inputRevision) {
    final binding = _engineXmlBinding;
    return epoch == _engineBindingEpoch &&
        inputRevision == binding?.inputRevision &&
        state.library.active?.revision == binding?.libraryRevision;
  }

  bool isCurrentSharedTreeOffer(WorkshopTreeOffer preview) =>
      _isCurrentEngineInput(preview.bindingEpoch, preview.inputRevision) &&
      engineSession.isCurrentTreeOffer(preview.offer);

  bool get canEditSharedJewel =>
      hasSharedTree && engineSession.supportsTreeJewels;

  Future<WorkshopJewelOffer> previewSharedJewel(EngineJewelEdit edit) async {
    final epoch = _engineBindingEpoch;
    final (:snapshot, :binding) = _engineEditSource(
      _engineXmlBinding?.inputRevision,
      epoch,
      _staleTree,
    );
    await _checkEngineFile(binding);
    final offer = await engineSession.previewJewel(snapshot, edit);
    return (
      offer: offer,
      inputRevision: binding.inputRevision,
      bindingEpoch: epoch,
    );
  }

  bool isCurrentSharedJewelOffer(WorkshopJewelOffer preview) =>
      _isCurrentEngineInput(preview.bindingEpoch, preview.inputRevision) &&
      engineSession.isCurrentJewelOffer(preview.offer);

  Future<BuildEditResult> applySharedJewel(WorkshopJewelOffer preview) =>
      _applyEngineEdit(
        expectedInput: preview.inputRevision,
        epoch: preview.bindingEpoch,
        staleMessage: _staleTree,
        apply: (_) => engineSession.editJewel(preview.offer),
      );

  Future<BuildEditResult> applySharedTreeNode(WorkshopTreeOffer preview) =>
      _applyEngineEdit(
        expectedInput: preview.inputRevision,
        epoch: preview.bindingEpoch,
        staleMessage: _staleTree,
        apply: (_) => engineSession.editTree(preview.offer),
      );

  Future<void> selectTreeMode(TreeAllocationMode mode) => _run(() async {
    if (state.report == null) return;
    if (mode == state.treeMode && state.document?.stale == false) return;
    _markStale();
    await engine.call('pob_tree_options', {'mode': mode.luaValue});
    _update(state.copyWith(treeMode: mode));
    await _readReport(persist: !hasSharedTree);
  });

  Future<BuildEditResult> Function(int) treeSpecSelection() {
    final binding = _engineXmlBinding;
    if (binding == null) return _selectLocalTreeSpec;
    final epoch = _engineBindingEpoch;
    return (id) => _applyEngineEdit(
      expectedInput: binding.inputRevision,
      epoch: epoch,
      staleMessage: _staleBuild,
      apply: (current) => engineSession.selectTreeSpec(current, id),
    );
  }

  Future<BuildEditResult> selectTreeSpec(int id) => treeSpecSelection()(id);

  Future<BuildEditResult> _selectLocalTreeSpec(int id) => _changeBuild(
    () async {
      await engine.call('pob_tree_options', {'spec': id});
      // MCP применяет mode к текущему набору до обработки spec.
      await engine.call('pob_tree_options', {'mode': state.treeMode.luaValue});
    },
  );

  Future<BuildEditResult> selectTreeClass({
    required int classId,
    required int ascendancyId,
    bool connect = false,
    bool reset = false,
  }) => treeClassSelection()((
    classId: classId,
    ascendancyId: ascendancyId,
    mode: reset ? 'reset' : (connect ? 'connect' : ''),
  ));

  Future<BuildEditResult> Function(EngineTreeClassEdit) treeClassSelection() {
    final binding = _engineXmlBinding;
    if (binding == null) return _selectLocalTreeClass;
    final epoch = _engineBindingEpoch;
    final revision = binding.inputRevision;
    return (edit) => _applyEngineEdit(
      expectedInput: revision,
      epoch: epoch,
      staleMessage: _staleTree,
      apply: (current) => engineSession.selectTreeClass(current, edit),
    );
  }

  Future<BuildEditResult> _selectLocalTreeClass(EngineTreeClassEdit edit) =>
      _changeBuild(() async {
        final sameClass = state.classes.any(
          (entry) =>
              entry['id'] == edit.classId &&
              entry['name'] == state.report!.characterClass,
        );
        await engine.call('pob_tree_options', {
          if (!sameClass) 'class': edit.classId,
          'ascendancy': edit.ascendancyId,
          if (edit.mode == 'connect') 'connect': true,
          if (edit.mode == 'reset') 'reset': true,
        });
      });

  Future<void> _restoreTreeMode([WorkbenchClient? client]) async {
    if (state.treeMode == TreeAllocationMode.common) return;
    await (client ?? engine).call('pob_tree_options', {
      'mode': state.treeMode.luaValue,
    });
  }

  Future<void> _loadXml(String xml) async {
    await engine.call('pob_import_xml', {'xml': xml});
    await _restoreTreeMode();
  }

  Future<void> Function(String, int) mainSkillEditor() {
    final revision = _engineXmlBinding?.inputRevision;
    final epoch = _engineBindingEpoch;
    return (control, id) {
      if (epoch != _engineBindingEpoch ||
          revision != _engineXmlBinding?.inputRevision) {
        return _run(() async => throw StateError(_staleBuild));
      }
      return selectMain(control, id);
    };
  }

  Future<void> selectMain(String control, int id) async {
    final revision = _engineXmlBinding?.inputRevision;
    final epoch = _engineBindingEpoch;
    if (revision != null &&
        engineSession.supportsSkillChoice &&
        _hasPersistentSkill(control)) {
      await _applyEngineEdit(
        expectedInput: revision,
        epoch: epoch,
        staleMessage: _staleBuild,
        apply: (current) => engineSession.chooseSkill(current, control, id),
      );
      return;
    }
    await _changeBuild(() async {
      await engine.call('pob_select_main_skill', {
        'control': control,
        'id': id,
      });
    });
  }

  bool _hasPersistentSkill(String control) {
    if (control == 'groups') return true;
    final report = state.report!;
    final id = report.groupSelector['selected'];
    final group = report.groups.where((group) => group['id'] == id).firstOrNull;
    return group != null && (group['source'] as String? ?? '').isEmpty;
  }

  bool get hasSharedSkillGroups =>
      _engineXmlBinding != null && engineSession.supportsSkillGroups;

  Future<BuildEditResult> Function(String, List<JsonMap>) skillGroupEditor(
    int? id,
  ) {
    final revision = _engineXmlBinding?.inputRevision;
    final epoch = _engineBindingEpoch;
    return (label, gems) {
      if (epoch != _engineBindingEpoch ||
          revision != _engineXmlBinding?.inputRevision) {
        return Future.value((committed: false, error: _staleBuild));
      }
      return id == null
          ? addSkillGroup(label, gems)
          : updateSkillGroup(id, label, gems);
    };
  }

  Future<BuildEditResult> addSkillGroup(String label, List<JsonMap> gems) =>
      _writeSkillGroup((id: null, label: label, delete: false, gems: gems));

  Future<BuildEditResult> updateSkillGroup(
    int id,
    String label,
    List<JsonMap> gems,
  ) => _writeSkillGroup((id: id, label: label, delete: false, gems: gems));

  Future<BuildEditResult> deleteSkillGroup(int id) =>
      _writeSkillGroup((id: id, label: null, delete: true, gems: const []));

  Future<BuildEditResult> _writeSkillGroup(EngineSkillGroupEdit edit) {
    final revision = _engineXmlBinding?.inputRevision;
    final epoch = _engineBindingEpoch;
    if (revision != null && engineSession.supportsSkillGroups) {
      return _applyEngineEdit(
        expectedInput: revision,
        epoch: epoch,
        staleMessage: _staleBuild,
        apply: (current) => engineSession.editSkillGroup(current, edit),
        calculate: true,
      );
    }
    return _legacySkillGroup(edit);
  }

  Future<BuildEditResult> _legacySkillGroup(EngineSkillGroupEdit edit) =>
      _changeBuild(() async {
        final method = switch (edit) {
          (delete: true, id: _, label: _, gems: _) => 'pob_delete_skill_group',
          (id: null, label: _, delete: _, gems: _) => 'pob_add_skill_group',
          _ => 'pob_update_skill_group',
        };
        await engine.call(method, {
          if (edit.id != null) 'groupId': edit.id,
          if (!edit.delete) 'label': edit.label,
          if (!edit.delete) 'gems': edit.gems,
        });
      });

  EquipmentRepository equipmentRepository() =>
      EquipmentRepository(engine, readShared: _readSharedEquipment);

  Future<ItemInspection?> _readSharedEquipment({
    String? slot,
    String? raw,
    int? itemId,
    required bool compare,
  }) async {
    if (_engineXmlBinding == null) return null;
    final snapshot = engineSession.state.snapshot;
    if (snapshot == null) return null;
    return engineSession.workshopReader?.readEquipmentDetails(
      snapshot,
      slot: slot,
      raw: raw,
      itemId: itemId,
      compare: compare,
    );
  }

  Future<int> previewSharedEquipment(EngineEquipmentEdit edit) async {
    final epoch = _engineBindingEpoch;
    final (:snapshot, :binding) = _engineEditSource(
      _engineXmlBinding?.inputRevision,
      epoch,
      _staleBuild,
    );
    await _checkEngineFile(binding);
    final offer = await engineSession.previewEquipment(snapshot, edit);
    if (!_isCurrentEngineInput(epoch, binding.inputRevision) ||
        !engineSession.isCurrentEquipmentOffer(offer)) {
      throw StateError(_staleBuild);
    }
    return offer.preview.revision;
  }

  Future<BuildEditResult> equipItem(
    String slot, {
    String? raw,
    int? itemId,
    int? expectedRevision,
  }) {
    final binding = _engineXmlBinding;
    if (binding == null) {
      return _changeBuild(() async {
        await engine.call('pob_equip_item', {
          'slot': slot,
          if (raw != null) 'raw': raw,
          if (itemId != null) 'itemId': itemId,
          if (expectedRevision != null) 'expectedRevision': expectedRevision,
        });
      });
    }
    return _applyEngineEdit(
      expectedInput: binding.inputRevision,
      epoch: _engineBindingEpoch,
      staleMessage: _staleBuild,
      apply: (current) {
        if (expectedRevision != null && expectedRevision != current.revision) {
          throw StateError(_staleBuild);
        }
        return engineSession.writeEquipment(current, (
          slot: slot,
          raw: raw ?? '',
          itemId: itemId ?? 0,
        ));
      },
    );
  }

  Future<BuildEditResult> selectWeaponSet(int index) {
    final binding = _engineXmlBinding;
    if (binding == null) {
      return _changeBuild(() async {
        await engine.call('pob_select_weapon_set', {'index': index});
      });
    }
    return _applyEngineEdit(
      expectedInput: binding.inputRevision,
      epoch: _engineBindingEpoch,
      staleMessage: _staleBuild,
      apply: (current) => engineSession.selectWeaponSet(current, index),
    );
  }

  Future<BuildEditResult> Function(String, Object) conditionEditorCommit() {
    final binding = _engineXmlBinding;
    if (binding == null) return setCondition;
    final epoch = _engineBindingEpoch;
    return (key, value) =>
        _setEngineCondition(key, value, binding.inputRevision, epoch);
  }

  Future<BuildEditResult> setCondition(String key, dynamic value) {
    final binding = _engineXmlBinding;
    if (binding != null) {
      return _setEngineCondition(
        key,
        value,
        binding.inputRevision,
        _engineBindingEpoch,
      );
    }
    return _changeBuild(() async {
      await engine.call('pob_set_config', {
        'values': {key: value},
      });
    });
  }

  Future<BuildEditResult> _setEngineCondition(
    String key,
    Object? value,
    int expectedInput,
    int epoch,
  ) => _applyEngineEdit(
    expectedInput: expectedInput,
    epoch: epoch,
    staleMessage: _staleCondition,
    apply: (current) => engineSession.setCondition(current, key, value),
    calculate: true,
  );

  ({EngineSnapshot snapshot, _EngineXmlBinding binding}) _engineEditSource(
    int? expectedInput,
    int epoch,
    String staleMessage,
  ) {
    final binding = _engineXmlBinding;
    final snapshot = engineSession.state.snapshot;
    if (binding == null ||
        expectedInput == null ||
        expectedInput == 0 ||
        snapshot?.build?.inputRevision != expectedInput ||
        binding.inputRevision != expectedInput ||
        epoch != _engineBindingEpoch) {
      throw StateError(staleMessage);
    }
    return (snapshot: snapshot!, binding: binding);
  }

  Future<BuildEditResult> _applyEngineEdit({
    required int expectedInput,
    required int epoch,
    required String staleMessage,
    required Future<EngineSnapshot> Function(EngineSnapshot) apply,
    bool calculate = false,
    bool recordUndo = true,
  }) async {
    var committed = false;
    await _run(() async {
      final (:snapshot, :binding) = _engineEditSource(
        expectedInput,
        epoch,
        staleMessage,
      );
      await _checkEngineFile(binding);
      if (epoch != _engineBindingEpoch) throw StateError(staleMessage);
      final updated = await apply(snapshot);
      if (epoch != _engineBindingEpoch) throw StateError(staleMessage);
      await _acceptEngineEdit(snapshot, updated, binding, recordUndo);
      committed = true;
      if (calculate) unawaited(_calculateEngineCondition(updated));
    });
    return (
      committed: committed,
      error: committed ? null : state.error ?? 'Действие недоступно',
    );
  }

  Future<void> _acceptEngineEdit(
    EngineSnapshot before,
    EngineSnapshot after,
    _EngineXmlBinding binding,
    bool recordUndo,
  ) async {
    if (after.build!.inputRevision <= binding.inputRevision) return;
    await _mirrorEngineBuild(after, binding);
    if (recordUndo) _pushUndo(before.build!.xml, title: before.buildName);
  }

  Future<void> _calculateEngineCondition(EngineSnapshot snapshot) async {
    try {
      await engineSession.calculate(snapshot);
    } catch (error) {
      if (!isClosed && !_closing) addLog(error.toString());
    }
  }

  Future<JsonMap> createMcpBuild(JsonMap arguments) async {
    JsonMap? result;
    await _run(() async {
      await _createBuild(arguments);
      result = {'id': state.library.activeId, 'report': state.report!.raw};
    });
    return result ??
        (throw McpEditorFault(
          'EDITOR_EDIT_FAILED',
          state.error ?? 'Действие недоступно',
        ));
  }

  Future<JsonMap> executeMcpEditorTool(
    String tool,
    JsonMap arguments, {
    required bool edit,
  }) async {
    JsonMap? response;
    Future<void> execute() async =>
        response = await engine.call(tool, arguments);
    if (edit) {
      final result = await _changeBuild(execute);
      if (!result.committed)
        throw McpEditorFault('EDITOR_EDIT_FAILED', result.error!);
      if (tool == 'pob_tree_options') _syncMcpTreeMode(arguments);
    } else {
      await _run(execute);
    }
    return response ??
        (throw McpEditorFault(
          'EDITOR_FAILED',
          state.error ?? 'Действие недоступно',
        ));
  }

  void _syncMcpTreeMode(JsonMap arguments) {
    if (arguments['mode'] case final int mode) {
      _update(
        state.copyWith(
          treeMode: TreeAllocationMode.values.firstWhere(
            (e) => e.luaValue == mode,
          ),
        ),
      );
    }
  }

  Future<({JsonMap result, List<dynamic> content})> executeMcpEditorRead(
    String tool,
    JsonMap arguments,
  ) async {
    ({JsonMap result, List<dynamic> content})? response;
    await _run(() async {
      response = await engine.callWithContent(tool, arguments);
    });
    return response ??
        (throw McpEditorFault(
          'EDITOR_FAILED',
          state.error ?? 'Нет ответа Lua',
        ));
  }

  Future<BuildEditResult> _changeBuild(
    Future<void> Function() action, {
    void Function(String xml)? guard,
    void Function(String xml)? validate,
  }) async {
    var committed = false;
    await _run(() async {
      final document = state.document;
      if (document == null) return;
      final builds = state.library;
      final shared = await _captureSharedEdit();
      final before = await _currentXml();
      guard?.call(before);
      _markStale();
      try {
        await action();
        final after = await _currentXml();
        validate?.call(after);
        await _finishWorkshopEdit(before, after, shared);
        committed = true;
      } catch (_) {
        await _restoreWorking(before, document, builds);
        rethrow;
      }
    });
    return (
      committed: committed,
      error: committed ? null : state.error ?? 'Действие недоступно',
    );
  }

  Future<_SharedEditSource?> _captureSharedEdit() async {
    final binding = _engineXmlBinding;
    if (binding == null) return null;
    final epoch = _engineBindingEpoch;
    final source = _engineEditSource(binding.inputRevision, epoch, _staleBuild);
    await _checkEngineFile(binding);
    return (snapshot: source.snapshot, binding: binding, epoch: epoch);
  }

  Future<void> _finishWorkshopEdit(
    String before,
    String after,
    _SharedEditSource? shared,
  ) async {
    if (shared == null) {
      await _readReport();
      if (after != before) _pushUndo(before);
      return;
    }
    if (after == before) {
      await _readReport(persist: false);
      return;
    }
    final plan = splitTreeProgression(shared.snapshot.build!.xml).progression;
    await _checkEngineFile(shared.binding);
    if (shared.epoch != _engineBindingEpoch) throw StateError(_staleBuild);
    final updated = await engineSession.replaceBuild(
      shared.snapshot,
      attachTreeProgression(after, plan),
    );
    if (shared.epoch != _engineBindingEpoch) throw StateError(_staleBuild);
    await _acceptEngineEdit(shared.snapshot, updated, shared.binding, true);
  }

  void _pushUndo(String xml, {String? title}) {
    _appendSnapshot(_undoHistory, (
      xml: xml,
      title: title ?? state.library.active?.title ?? state.report!.name,
    ));
    _redoHistory.clear();
    _publishHistory();
  }

  void _appendSnapshot(List<_BuildSnapshot> history, _BuildSnapshot snapshot) {
    history.add(snapshot);
    if (history.length > 50) history.removeAt(0);
  }

  void _publishHistory() => _update(
    state.copyWith(
      history: (undo: _undoHistory.length, redo: _redoHistory.length),
    ),
  );

  void _clearHistory() {
    _undoHistory.clear();
    _redoHistory.clear();
    _publishHistory();
  }

  Future<void> undo() => _moveHistory(_undoHistory, _redoHistory);

  Future<void> redo() => _moveHistory(_redoHistory, _undoHistory);

  Future<void> _moveHistory(
    List<_BuildSnapshot> source,
    List<_BuildSnapshot> destination,
  ) {
    if (source.isEmpty) return Future.value();
    return hasSharedTree
        ? _moveSharedHistory(source, destination)
        : _moveLocalHistory(source, destination);
  }

  Future<void> _moveSharedHistory(
    List<_BuildSnapshot> source,
    List<_BuildSnapshot> destination,
  ) async {
    final from = engineSession.state.snapshot;
    final target = source.last;
    if (from?.build == null) return;
    if (from!.buildName != target.title) {
      await _moveSharedTitle(source, destination, from, target);
      return;
    }
    final restored = await _applyEngineEdit(
      expectedInput: from.build!.inputRevision,
      epoch: _engineBindingEpoch,
      staleMessage: _staleBuild,
      recordUndo: false,
      apply: (current) => engineSession.replaceBuild(current, target.xml),
    );
    if (restored.committed)
      _advanceSharedHistory(source, destination, from, target);
  }

  void _advanceSharedHistory(
    List<_BuildSnapshot> source,
    List<_BuildSnapshot> destination,
    EngineSnapshot from,
    _BuildSnapshot target,
  ) {
    if (source.lastOrNull != target) return;
    source.removeLast();
    _appendSnapshot(destination, (xml: from.build!.xml, title: from.buildName));
    _publishHistory();
  }

  Future<void> _moveSharedTitle(
    List<_BuildSnapshot> source,
    List<_BuildSnapshot> destination,
    EngineSnapshot from,
    _BuildSnapshot target,
  ) => _run(() async {
    final binding = _engineXmlBinding!;
    final diskXml = await _checkEngineFile(binding);
    if (target.xml != from.build!.xml) throw StateError(_staleBuild);
    final renamed = await engineSession.renameShared(from, target.title);
    final builds = await _saveBuild(
      state.library,
      state.report!,
      renamed.build!.xml,
      title: renamed.buildName,
      progressionSource: _storedProgressionKey,
      expectedXml: diskXml,
    );
    _update(state.copyWith(library: builds));
    _updateEngineFileRevision(binding);
    _advanceSharedHistory(source, destination, from, target);
  });

  Future<void> _moveLocalHistory(
    List<_BuildSnapshot> source,
    List<_BuildSnapshot> destination,
  ) => _run(() async {
    if (source.isEmpty) return;
    final before = (
      xml: await _currentXml(),
      title: state.library.active?.title ?? state.report!.name,
    );
    if (_engineBinding != null && source.last.title != before.title) {
      await engineSession.rename(source.last.title);
    }
    try {
      await _restoreSnapshot(source.last);
    } catch (_) {
      await _recoverSnapshot(before);
      rethrow;
    }
    source.removeLast();
    _appendSnapshot(destination, before);
    _publishHistory();
  });

  Future<void> _restoreSnapshot(_BuildSnapshot snapshot) async {
    _markStale();
    await _flushText();
    await _loadXml(snapshot.xml);
    await _readReport(
      title: snapshot.title,
      progressionSource: _storedProgressionKey,
    );
  }

  Future<void> _recoverSnapshot(_BuildSnapshot snapshot) async {
    try {
      if (sharedLibrary != null) {
        await _loadXml(snapshot.xml);
        await _readReport(persist: false);
      } else {
        await _restoreSnapshot(snapshot);
      }
    } catch (error) {
      _markStale();
      addLog('Не удалось восстановить состояние после ошибки: $error');
    }
  }

  Future<String> _currentXml() => engine.exportBuildXml();

  Future<String> _savedXml() async {
    final xml = await _currentXml();
    final id = state.library.activeId;
    if (sharedLibrary case final shared? when id != null)
      return shared.withCurrentNotes(id, xml);
    return xml;
  }

  Future<String?> exportXml() async {
    String? xml;
    await _run(() async {
      if (state.report == null) return;
      xml = await _exportedXml();
    });
    return xml;
  }

  Future<String> _exportedXml() async {
    final xml = await _savedXml();
    final key = progressionKey;
    if (key == null) return xml;
    return attachTreeProgression(xml, (
      version: key.version,
      characterClass: key.characterClass,
      steps: await progressionRepository(key).load(),
    ));
  }

  void editDraft(String value) {
    _update(state.copyWith(draft: (xml: value, edited: true)));
    _saveDraft(value);
  }

  Future<void> _saveDraft(String value) async {
    try {
      await session.saveDraft(value);
    } catch (error) {
      reportPersistenceError('Не удалось сохранить черновик XML: $error');
    }
  }

  void reportPersistenceError(Object error) {
    _update(state.copyWith(operation: (busy: state.busy, error: '$error')));
    addLog('$error');
  }

  Future<void> checkpointBeforeExit() async {
    if (_initialization case final initialization?) {
      await initialization;
      if (state.error case final error?) throw StateError(error);
    }
    await checkpoint();
  }

  Future<void> finishScheduledExit() async {
    while (!isClosed && state.busy) {
      await stream.firstWhere((value) => !value.busy, orElse: () => state);
    }
    if (!isClosed) await checkpoint(closePob: true);
  }

  Future<void> checkpoint({bool closePob = false}) => _protectExit(() async {
    await session.saveDraft(state.draftXml);
    await _flushText();
    await _checkpointBuild();
    if (closePob) await pobWindow.closeLaunchedWindows();
  });

  Future<List<CleanupEntry>> previewProfileCleanup() async {
    // Загрузка текстур меняет состав и размер кеша, пока строится список.
    await waitForTreeArtwork();
    return components.profileCleanup.preview();
  }

  Future<CleanupResult> cleanProfile(Set<CleanupEntry> selected) async {
    late CleanupResult result;
    await _protectExit(() async {
      await _treeArtworkLoad;
      result = await components.cleanProfile(selected);
      treeIcons.clear();
    });
    return result;
  }

  Future<void> closeLaunchedPob() =>
      _protectExit(pobWindow.closeLaunchedWindows);

  Future<void> _protectExit(Future<void> Function() action) async {
    if (state.busy) throw StateError('Дождитесь завершения текущей операции');
    _update(state.copyWith(operation: (busy: true, error: state.error)));
    try {
      await action();
    } finally {
      _update(state.copyWith(operation: (busy: false, error: state.error)));
    }
  }

  Future<void> _checkpointBuild() async {
    if (sharedLibrary != null) return;
    if (!engine.connected || state.report == null) return;
    if (state.document?.stale == true) {
      await _readReport();
    }
    await session.save(await _currentXml());
  }

  Future<void> _flushText() async {
    await session.flushText();
    if (sharedLibrary case final shared?) await shared.flushText();
  }

  @override
  Future<void> close() async {
    _closing = true;
    await engineSession.close();
    await _primaryOpening;
    _buildChangeDelay?.cancel();
    await _buildChanges?.cancel();
    await _buildSync?.future;
    await _componentChange;
    await _mcpEditor?.close();
    await _flushText();
    await engine.close();
    await _treeArtworkLoad;
    await components.profileUse?.close();
    await super.close();
  }
}
