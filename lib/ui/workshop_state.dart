import '../domain/component.dart';
import '../domain/build_report.dart';
import '../domain/tree_geometry.dart';
import '../domain/library_entry.dart';
import '../domain/tree_allocation_mode.dart';

typedef WorkshopOperation = ({bool busy, String? error});
typedef XmlDraft = ({String xml, bool edited});
typedef HistoryCounts = ({int undo, int redo});
typedef WorkshopDocument = ({
  BuildReport report,
  TreeGeometry? tree,
  bool stale,
  String? treeError,
});

class WorkshopState {
  WorkshopState({
    this.operation = (busy: false, error: null),
    this.status = 'Установите компоненты и подключите Lua',
    this.document,
    this.treeMode = TreeAllocationMode.common,
    this.history = (undo: 0, redo: 0),
    LibraryState? library,
    this.sessionSaved = false,
    this.draft = (xml: '', edited: false),
    Map<Component, Release> releases = const {},
    List<String> log = const [],
    List<Map<String, dynamic>> classes = const [],
  }) : library = library ?? LibraryState(),
       releases = Map.unmodifiable(releases),
       log = List.unmodifiable(log),
       classes = List.unmodifiable(classes);

  final WorkshopOperation operation;
  bool get busy => operation.busy;
  String? get error => operation.error;
  final String status;
  final WorkshopDocument? document;
  final TreeAllocationMode treeMode;
  final HistoryCounts history;
  int get undoCount => history.undo;
  int get redoCount => history.redo;
  BuildReport? get report => document?.report;
  final LibraryState library;
  final bool sessionSaved;
  final XmlDraft draft;
  String get draftXml => draft.xml;
  bool get draftEdited => draft.edited;
  final Map<Component, Release> releases;
  final List<String> log;
  final List<Map<String, dynamic>> classes;

  WorkshopState copyWith({
    WorkshopOperation? operation,
    String? status,
    WorkshopDocument? document,
    TreeAllocationMode? treeMode,
    HistoryCounts? history,
    LibraryState? library,
    bool clearReport = false,
    bool? sessionSaved,
    XmlDraft? draft,
    Map<Component, Release>? releases,
    List<String>? log,
    List<Map<String, dynamic>>? classes,
  }) => WorkshopState(
    operation: operation ?? this.operation,
    status: status ?? this.status,
    document: _nextDocument(document, clearReport),
    treeMode: treeMode ?? this.treeMode,
    history: history ?? this.history,
    library: library ?? this.library,
    sessionSaved: sessionSaved ?? this.sessionSaved,
    draft: draft ?? this.draft,
    releases: releases ?? this.releases,
    log: log ?? this.log,
    classes: classes ?? this.classes,
  );

  WorkshopDocument? _nextDocument(WorkshopDocument? next, bool clear) =>
      clear ? null : next ?? document;
}
