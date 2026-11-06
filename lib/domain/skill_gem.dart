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
  };
}
