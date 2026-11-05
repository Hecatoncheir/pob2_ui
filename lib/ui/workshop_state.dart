import '../domain/component.dart';

class WorkshopState {
  WorkshopState({
    this.busy = false,
    this.error,
    this.status = 'Установите компоненты и подключите Lua',
    this.report,
    this.sessionSaved = false,
    this.draftXml = '',
    this.draftEdited = false,
    Map<Component, Release> releases = const {},
    List<String> log = const [],
    List<Map<String, dynamic>> classes = const [],
  }) : releases = Map.unmodifiable(releases),
       log = List.unmodifiable(log),
       classes = List.unmodifiable(classes);

  final bool busy;
  final String? error;
  final String status;
  final Map<String, dynamic>? report;
  final bool sessionSaved;
  final String draftXml;
  final bool draftEdited;
  final Map<Component, Release> releases;
  final List<String> log;
  final List<Map<String, dynamic>> classes;

  WorkshopState copyWith({
    bool? busy,
    String? error,
    bool clearError = false,
    String? status,
    Map<String, dynamic>? report,
    bool clearReport = false,
    bool? sessionSaved,
    String? draftXml,
    bool? draftEdited,
    Map<Component, Release>? releases,
    List<String>? log,
    List<Map<String, dynamic>>? classes,
  }) => WorkshopState(
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
    status: status ?? this.status,
    report: clearReport ? null : report ?? this.report,
    sessionSaved: sessionSaved ?? this.sessionSaved,
    draftXml: draftXml ?? this.draftXml,
    draftEdited: draftEdited ?? this.draftEdited,
    releases: releases ?? this.releases,
    log: log ?? this.log,
    classes: classes ?? this.classes,
  );
}
