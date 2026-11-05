import 'build_report.dart';

class LibraryEntry {
  const LibraryEntry({
    required this.id,
    required this.title,
    required this.characterClass,
    required this.level,
    required this.updated,
  });
  factory LibraryEntry.fromJson(JsonMap json) => LibraryEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    characterClass: json['class'] as String,
    level: json['level'] as int,
    updated: DateTime.parse(json['updated'] as String),
  );
  final String id, title, characterClass;
  final int level;
  final DateTime updated;
  JsonMap toJson() => {
    'id': id,
    'title': title,
    'class': characterClass,
    'level': level,
    'updated': updated.toUtc().toIso8601String(),
  };
}

class LibraryState {
  LibraryState({List<LibraryEntry> entries = const [], this.activeId})
    : entries = List.unmodifiable(entries);
  final List<LibraryEntry> entries;
  final String? activeId;
  LibraryEntry? get active =>
      entries.where((entry) => entry.id == activeId).firstOrNull;
}
