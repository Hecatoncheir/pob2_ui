import '../domain/component.dart';

typedef WorkshopOperation = ({bool busy, String? error});
typedef XmlDraft = ({String xml, bool edited});

class WorkshopState {
  WorkshopState({
    this.operation = (busy: false, error: null),
    this.status = 'Установите компоненты и подключите Lua',
    this.report,
    this.sessionSaved = false,
    this.draft = (xml: '', edited: false),
    Map<Component, Release> releases = const {},
    List<String> log = const [],
    List<Map<String, dynamic>> classes = const [],
  }) : releases = Map.unmodifiable(releases),
       log = List.unmodifiable(log),
       classes = List.unmodifiable(classes);

  final WorkshopOperation operation;
  bool get busy => operation.busy;
  String? get error => operation.error;
  final String status;
  final Map<String, dynamic>? report;
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
    Map<String, dynamic>? report,
    bool clearReport = false,
    bool? sessionSaved,
    XmlDraft? draft,
    Map<Component, Release>? releases,
    List<String>? log,
    List<Map<String, dynamic>>? classes,
  }) => WorkshopState(
    operation: operation ?? this.operation,
    status: status ?? this.status,
    report: clearReport ? null : report ?? this.report,
    sessionSaved: sessionSaved ?? this.sessionSaved,
    draft: draft ?? this.draft,
    releases: releases ?? this.releases,
    log: log ?? this.log,
    classes: classes ?? this.classes,
  );
}
