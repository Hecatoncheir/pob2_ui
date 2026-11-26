import 'build_report.dart';

enum BuildCardIcon { gem, sword, shield, bow, fire, frost, lightning, minion }

enum BuildCardColor { none, gold, red, green, blue, purple, teal }

final class BuildCardAppearance {
  const BuildCardAppearance({
    this.icon = BuildCardIcon.gem,
    this.color = BuildCardColor.none,
  });

  factory BuildCardAppearance.fromJson(JsonMap json) => BuildCardAppearance(
    icon: _icons[json['icon']] ?? BuildCardIcon.gem,
    color: _colors[json['color']] ?? BuildCardColor.none,
  );

  static final _icons = BuildCardIcon.values.asNameMap();
  static final _colors = BuildCardColor.values.asNameMap();

  final BuildCardIcon icon;
  final BuildCardColor color;

  bool get isDefault => this == const BuildCardAppearance();

  Map<String, String> toJson() => {'icon': icon.name, 'color': color.name};

  @override
  bool operator ==(Object other) =>
      other is BuildCardAppearance &&
      other.icon == icon &&
      other.color == color;

  @override
  int get hashCode => Object.hash(icon, color);
}
