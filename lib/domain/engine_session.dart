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
  const EngineSnapshot(
    this.sessionId,
    this.buildName,
    this.revision, {
    this.build,
  });
  final String sessionId;
  final String buildName;
  final int revision;
  final EngineBuild? build;
}

class EngineBuild {
  const EngineBuild({required this.xml, required this.level, this.calculation});

  final String xml;
  final int level;
  final EngineCalculation? calculation;
}

class EngineCalculation {
  const EngineCalculation({
    required this.status,
    this.life,
    required this.warnings,
  });

  final String status;
  final double? life;
  final List<String> warnings;
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

  String get description => switch (kind) {
    'snapshot' => 'Получен снимок сессии',
    'created' => 'Сессия создана',
    'renamed' => 'Название: «$previousName» → «${snapshot.buildName}»',
    'calculated' => 'Расчёт сохранён',
    'imported' || 'edited' => 'XML сборки обновлён',
    _ => 'Сборка обновлена',
  };
}
