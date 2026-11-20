class EngineOptions {
  const EngineOptions({
    this.executable = 'pob2-engine',
    this.profile = 'default',
    this.sessionId = 'main',
    this.runtimeDirectory = '',
    this.dataDirectory = '',
  });
  final String executable;
  final String profile;
  final String sessionId;
  final String runtimeDirectory;
  final String dataDirectory;
}

class EngineSnapshot {
  const EngineSnapshot(this.sessionId, this.buildName, this.revision);
  final String sessionId;
  final String buildName;
  final int revision;
}

class EngineChange {
  const EngineChange({
    required this.snapshot,
    required this.kind,
    this.requestId = '',
    this.previousName = '',
    this.fields = const [],
  });
  final EngineSnapshot snapshot;
  final String kind;
  final String requestId;
  final String previousName;
  final List<String> fields;

  String get description => kind == 'snapshot'
      ? 'Получен снимок сессии'
      : 'Название: «$previousName» → «${snapshot.buildName}»';
}
