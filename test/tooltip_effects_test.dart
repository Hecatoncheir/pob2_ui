import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/game_dictionary.dart';
import 'package:pob2_ui/domain/node_preview.dart';
import 'package:pob2_ui/ui/core/frosted_surface.dart';
import 'package:pob2_ui/ui/core/language_scope.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/tree_hover_card.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Оценка Lua сохраняет зелёный и терракотовый после перевода: $brightness',
      (tester) async {
        final theme = Spark.theme(brightness: brightness);
        final dictionary = GameDictionary(
          'ru',
          {'stat': '# Taken Phys dmg'},
          {'stat': '# Получаемый физический урон'},
        );
        final preview = NodePreview(
          tooltip: {
            'lines': [
              {'text': '^x33FF77-10 Taken Phys dmg'},
              {'text': '^xDD0022+10 Taken Phys dmg'},
            ],
          },
        );
        await tester.pumpWidget(
          LanguageScope(
            dictionary: dictionary,
            child: MaterialApp(
              theme: theme,
              home: Scaffold(
                body: TreeHoverCard(
                  title: 'Узел',
                  state: (id: 1, loading: false, preview: preview, error: null),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .where((text) => text.textSpan != null)
            .toList();
        final colors = <Color>[];
        for (final text in texts) {
          final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
          colors.add(
            spans
                .firstWhere((span) => span.text?.isNotEmpty == true)
                .style!
                .color!,
          );
        }
        expect(HSVColor.fromColor(colors[0]).hue, inInclusiveRange(80, 170));
        expect(HSVColor.fromColor(colors[1]).hue, inInclusiveRange(0, 45));
        final background = FrostedSurface.contrastBackground(theme.colorScheme)
            .computeLuminance();
        for (final color in colors) {
          final foreground = color.computeLuminance();
          final contrast =
              ((foreground > background ? foreground : background) + .05) /
              ((foreground < background ? foreground : background) + .05);
          expect(contrast, greaterThanOrEqualTo(4.5));
        }
        expect(
          find.text('-10 Получаемый физический урон', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.text('+10 Получаемый физический урон', findRichText: true),
          findsOneWidget,
        );
        expect(preview.lines.first['text'], '^x33FF77-10 Taken Phys dmg');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
