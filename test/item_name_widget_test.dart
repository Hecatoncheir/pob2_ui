import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/game_dictionary.dart';
import 'package:pob2_ui/ui/core/language_scope.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/equipment_board.dart';

void main() {
  testWidgets('Карточка и подсказка показывают базу, язык не меняет отчёт', (
    tester,
  ) async {
    final report = BuildReport.fromJson({
      'source': 'original-lua',
      'items': [
        {'id': 1, 'name': '???? ????', 'base': 'Siphoning Wand'},
      ],
      'slots': [
        {'name': 'Weapon 1', 'itemId': 1},
      ],
    });
    final russian = GameDictionary(
      'ru',
      {'wand': 'Siphoning Wand'},
      {'wand': 'Поглощающий жезл'},
    );
    for (final dictionary in [russian, GameDictionary.english()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: Spark.theme(),
          home: LanguageScope(
            dictionary: dictionary,
            child: Scaffold(
              body: SizedBox(
                width: 420,
                child: EquipmentBoard(
                  report: report,
                  selected: null,
                  select: (_) {},
                  busy: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final expected = dictionary.translate('Siphoning Wand');
      expect(find.text(expected), findsOneWidget);
      expect(find.textContaining('????'), findsNothing);
      expect(
        tester.widget<Tooltip>(find.byType(Tooltip)).message,
        contains(expected),
      );
      expect(report.items.single['name'], '???? ????');
      expect(tester.takeException(), isNull);
    }
  });
}
