import 'build_report.dart';

class SkillGem {
  const SkillGem({
    required this.id,
    required this.name,
    this.naturalMaxLevel,
    this.support = false,
  });
  factory SkillGem.fromJson(JsonMap json) => switch (json) {
    {'id': final String id, 'name': final String name} => SkillGem(
      id: id,
      name: name,
      support: json['support'] == true,
      naturalMaxLevel: (json['naturalMaxLevel'] as num?)?.toInt(),
    ),
    _ => throw const FormatException('Lua не вернул описание камня'),
  };
  final String id, name;
  final bool support;
  final int? naturalMaxLevel;
}

typedef GemDraft = ({
  int key,
  SkillGem gem,
  String level,
  String quality,
  bool enabled,
  int? sourceIndex,
});

JsonMap gemRequest(GemDraft draft) {
  final level = int.tryParse(draft.level.trim());
  final quality = int.tryParse(draft.quality.trim());
  if (level == null || quality == null) {
    throw const FormatException(
      'Уровень и качество должны быть целыми числами',
    );
  }
  return {
    'id': draft.gem.id,
    'level': level,
    'quality': quality,
    'enabled': draft.enabled,
    if (draft.sourceIndex != null) 'sourceIndex': draft.sourceIndex,
  };
}

List<GemDraft> groupGemDrafts(JsonMap group) {
  final gems = jsonRows(group['gems']);
  final result = gems.indexed
      .map(
        (entry) => (
          key: entry.$1,
          gem: SkillGem.fromJson(entry.$2),
          level: '${entry.$2['level']}',
          quality: '${entry.$2['quality']}',
          enabled: entry.$2['enabled'] == true,
          sourceIndex: entry.$2['sourceIndex'] as int? ?? entry.$1 + 1,
        ),
      )
      .toList();
  final active = result.where((gem) => !gem.gem.support).toList();
  if (active.length != 1)
    throw const FormatException(
      'Редактор поддерживает одно активное умение в группе',
    );
  return List.unmodifiable([
    ...active,
    ...result.where((gem) => gem.gem.support),
  ]);
}
