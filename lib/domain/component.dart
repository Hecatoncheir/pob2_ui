enum Component {
  pob(
    'Path of Building',
    'PathOfBuildingCommunity/PathOfBuilding-PoE2',
    'Исходный Lua-движок и игровые данные',
  ),
  mcp(
    'PoB MCP',
    'Hecatoncheir/pob-poe2-mcp',
    'Локальная связь интерфейса с расчётами',
  );

  const Component(this.title, this.repository, this.description);
  final String title;
  final String repository;
  final String description;
  String get url => 'https://github.com/$repository';
}

class Release {
  const Release(this.tag, this.url, this.publishedAt);
  final String tag;
  final String url;
  final DateTime publishedAt;

  factory Release.fromJson(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String;
    if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{0,79}$').hasMatch(tag)) {
      throw const FormatException('Неподдерживаемый формат тега выпуска');
    }
    return Release(
      tag,
      json['html_url'] as String,
      DateTime.parse(json['published_at'] as String),
    );
  }
}

class Installation {
  const Installation({
    required this.tag,
    required this.commit,
    required this.directory,
  });
  final String tag;
  final String commit;
  final String directory;

  factory Installation.fromJson(Map<String, dynamic> json) => Installation(
    tag: json['tag'] as String,
    commit: json['commit'] as String,
    directory: json['directory'] as String,
  );

  Map<String, dynamic> toJson() => {
    'tag': tag,
    'commit': commit,
    'directory': directory,
  };
}

typedef Installations = Map<Component, Installation>;
