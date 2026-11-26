import 'build_card_appearance.dart';
import 'build_report.dart';

class LibraryEntry {
  const LibraryEntry({
    required this.id,
    required this.title,
    required this.characterClass,
    required this.level,
    required this.updated,
    this.revision,
    this.appearance = const BuildCardAppearance(),
  });
  factory LibraryEntry.fromJson(JsonMap json) => LibraryEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    characterClass: json['class'] as String,
    level: json['level'] as int,
    updated: DateTime.parse(json['updated'] as String),
    revision: json['revision'] as String?,
    appearance: BuildCardAppearance.fromJson(jsonMap(json['appearance'])),
  );
  final String id, title, characterClass;
  final int level;
  final DateTime updated;
  final String? revision;
  final BuildCardAppearance appearance;

  LibraryEntry copyWith({String? revision, BuildCardAppearance? appearance}) =>
      LibraryEntry(
        id: id,
        title: title,
        characterClass: characterClass,
        level: level,
        updated: updated,
        revision: revision ?? this.revision,
        appearance: appearance ?? this.appearance,
      );
  JsonMap toJson() => {
    'id': id,
    'title': title,
    'class': characterClass,
    'level': level,
    'updated': updated.toUtc().toIso8601String(),
    if (revision != null) 'revision': revision,
    if (!appearance.isDefault) 'appearance': appearance.toJson(),
  };
}

class LibraryState {
  LibraryState({
    List<LibraryEntry> entries = const [],
    this.activeId,
    this.skipSessionRecovery = false,
  }) : entries = List.unmodifiable(entries);
  final List<LibraryEntry> entries;
  final String? activeId;
  final bool skipSessionRecovery;
  LibraryEntry? get active =>
      entries.where((entry) => entry.id == activeId).firstOrNull;

  LibraryState withAppearance(String id, BuildCardAppearance appearance) {
    if (!entries.any((entry) => entry.id == id)) {
      throw const FormatException('Сборка не найдена');
    }
    return LibraryState(
      entries: [
        for (final entry in entries)
          entry.id == id ? entry.copyWith(appearance: appearance) : entry,
      ],
      activeId: activeId,
      skipSessionRecovery: skipSessionRecovery,
    );
  }
}
