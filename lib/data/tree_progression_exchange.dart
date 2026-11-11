import 'dart:convert';

import '../domain/tree_progression.dart';

const _marker = '<!-- PoB II progression: ';
final _trailer = RegExp(r'\r?\n<!-- PoB II progression: ([^<>]*) -->\s*$');
const _invalidPlan = FormatException('Некорректный план прокачки');

String attachTreeProgression(String xml, TreeProgressionTransfer? plan) {
  if (plan == null || plan.steps.isEmpty) return xml;
  final payload = jsonEncode({
    'schema': 1,
    'tree': plan.version,
    'class': plan.characterClass,
    'steps': encodeProgressionSteps(plan.steps),
  });
  return '$xml\n$_marker${base64.encode(utf8.encode(payload))} -->';
}

({String xml, TreeProgressionTransfer? progression}) splitTreeProgression(
  String xml,
) {
  final match = _trailer.firstMatch(xml);
  if (match == null) return (xml: xml, progression: null);
  return (
    xml: xml.substring(0, match.start),
    progression: _decodePlan(match[1]!),
  );
}

TreeProgressionTransfer _decodePlan(String encoded) {
  try {
    final data = jsonDecode(utf8.decode(base64.decode(encoded)));
    return switch (data) {
      {
        'schema': 1,
        'tree': final String version,
        'class': final String characterClass,
        'steps': final List<Object?> steps,
      }
          when version.isNotEmpty && characterClass.isNotEmpty =>
        (
          version: version,
          characterClass: characterClass,
          steps: decodeProgressionSteps(steps),
        ),
      _ => throw _invalidPlan,
    };
  } on FormatException {
    throw _invalidPlan;
  }
}

List<Map<String, Object>> encodeProgressionSteps(
  List<TreeProgressionStep> steps,
) => [
  for (final step in steps)
    {
      'level': step.level,
      'nodes': step.nodes.toList(),
      if (step.title.isNotEmpty) 'title': step.title,
      if (step.note.isNotEmpty) 'note': step.note,
      if (step.allocation case final allocation?) 'allocation': allocation,
      if (step.skills case final skills?) 'skills': skills,
      if (step.equipment case final equipment?) 'equipment': equipment,
    },
];

List<TreeProgressionStep> decodeProgressionSteps(List<Object?> entries) =>
    List.unmodifiable(entries.map(_decodeStep));

TreeProgressionStep _decodeStep(Object? entry) {
  if (entry is! Map<String, Object?>) throw _invalidPlan;
  final fields = (
    entry['level'],
    entry['nodes'],
    entry['title'] ?? '',
    entry['note'] ?? '',
  );
  if (fields
      case (
        final int level,
        final List<Object?> nodes,
        final String title,
        final String note,
      )
      when level >= 1 && level <= 100 && nodes.every((node) => node is int)) {
    return TreeProgressionStep(
      level,
      nodes.cast<int>(),
      title: title,
      note: note,
      allocation: _optionalXml(entry['allocation']),
      skills: _optionalXml(entry['skills']),
      equipment: _optionalXml(entry['equipment']),
    );
  }
  throw _invalidPlan;
}

String? _optionalXml(Object? value) => switch (value) {
  null => null,
  String() => value,
  _ => throw _invalidPlan,
};
