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
  const EngineBuild({
    required this.xml,
    required this.level,
    this.calculation,
    this.group,
  });

  final String xml;
  final int level;
  final EngineCalculation? calculation;
  final EngineSkillGroup? group;
}

typedef EngineGem = ({String name, int level, int quality, bool enabled});
typedef EngineSkillGroup = ({int id, String label, List<EngineGem> gems});
typedef EngineSupportSelection = ({String id, int level, int quality});
typedef EngineSupportOption = ({
  String id,
  String name,
  List<int> levels,
  List<int> qualities,
});
typedef EngineSupportPage = ({
  List<EngineSupportOption> entries,
  int? nextOffset,
});
typedef EngineStatDelta = ({
  String name,
  double before,
  double after,
  double difference,
});

class EngineSupportPreview {
  const EngineSupportPreview({
    required this.revision,
    required this.compatible,
    required this.before,
    required this.after,
    required this.deltas,
  });
  final int revision;
  final bool compatible;
  final EngineCalculation before;
  final EngineCalculation after;
  final List<EngineStatDelta> deltas;
}

class EngineCalculation {
  const EngineCalculation({
    required this.status,
    this.life,
    this.dps,
    required this.warnings,
  });

  final String status;
  final double? life;
  final double? dps;
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
