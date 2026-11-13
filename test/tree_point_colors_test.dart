import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/ui/core/app_text.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/tree_point_counters.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Оружие I красное, оружие II зелёное, значения Lua сохранены: $brightness',
      (tester) async {
        final theme = Spark.theme(brightness: brightness);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: TreePointCounters('42 / 123 0 / 24 0 / 24 0 / 8'),
            ),
          ),
        );
        final colors = <Color>[];
        final values = <String>[];
        for (var index = 0; index < 4; index++) {
          final text = tester.widget<AppText>(
            find.byKey(ValueKey('tree-counter-$index')),
          );
          colors.add(text.style!.color!);
          values.add(text.data);
        }
        expect(values, ['42 / 123', '0 / 24', '0 / 24', '0 / 8']);
        expect(colors.toSet(), hasLength(4));
        expect(HSVColor.fromColor(colors[1]).hue, inInclusiveRange(0, 30));
        expect(HSVColor.fromColor(colors[2]).hue, inInclusiveRange(80, 170));
        final background = theme.scaffoldBackgroundColor.computeLuminance();
        for (final color in colors) {
          final foreground = color.computeLuminance();
          final contrast =
              ((foreground > background ? foreground : background) + .05) /
              ((foreground < background ? foreground : background) + .05);
          expect(contrast, greaterThanOrEqualTo(4.5));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
