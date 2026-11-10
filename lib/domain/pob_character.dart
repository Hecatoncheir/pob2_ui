typedef PobCharacter = ({
  String name,
  String characterClass,
  int level,
  String? league,
});

PobCharacter readPobCharacter(Object? value) => switch (value) {
  {
    'name': final String name,
    'class': final String characterClass,
    'level': final int level,
  } =>
    (
      name: name,
      characterClass: characterClass,
      level: level,
      league: switch (value) {
        {'league': final String league} => league,
        _ => null,
      },
    ),
  _ => throw const FormatException('PoB вернул неверные данные персонажа.'),
};
