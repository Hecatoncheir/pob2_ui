import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/equipment_item.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/item_comparison_panel.dart';
import 'package:pob2_ui/ui/item_editor_cubit.dart';

ItemInspection preview({int revision = 7}) => ItemInspection.fromJson({
  'source': 'original-lua',
  'item': {'name': 'Ring', 'raw': 'raw'},
  'compatible': true,
  'comparison': {
    'revision': revision,
    'rows': [
      {
        'id': 'Life',
        'label': 'Life',
        'beforeText': '^7100',
        'afterText': '^7150',
        'changeText': '^x33FF77+50 (+50%)',
      },
      {
        'id': 'FireResist',
        'label': 'Fire Resistance',
        'beforeText': '^775%',
        'afterText': '^750%',
        'changeText': '^xDD0022-25%',
      },
      {'id': 'EnergyShield', 'label': 'Energy Shield', 'afterText': '^740'},
    ],
  },
});

void main() {
  test('Применение использует ревизию примерки; отказ обновляет её и сохраняет ввод', () async {
    var revision = 7;
    final applied = <int?>[];
    final editor = ItemEditorCubit(
      ({raw, itemId}) async => preview(revision: revision++),
      ({raw, itemId, expectedRevision}) async {
        applied.add(expectedRevision);
        return (
          committed: applied.length > 1,
          error: applied.length == 1 ? 'Сборка изменилась' : null,
        );
      },
    );
    addTearDown(editor.close);
    editor.text('copied item');
    await editor.preview();
    expect(await editor.save(), isFalse);
    expect(editor.state.raw, 'copied item');
    expect(editor.state.error, 'Сборка изменилась');
    expect(editor.state.preview!.comparison!.revision, 8);
    expect(await editor.save(), isTrue);
    expect(applied, [7, 8]);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Было/Стало, отрицательные эффекты и отсутствующие значения: $brightness',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            theme: Spark.theme(brightness: brightness),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ItemComparisonPanel(preview().comparison!),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Было'), findsOneWidget);
        expect(find.text('Стало'), findsOneWidget);
        expect(find.text('+50 (+50%)', findRichText: true), findsOneWidget);
        expect(find.text('-25%', findRichText: true), findsOneWidget);
        expect(find.text('—', findRichText: true), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
