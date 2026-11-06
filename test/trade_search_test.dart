import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/trade_search_repository.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/item_comparison_panel.dart';
import 'package:pob2_ui/ui/trade_search_cubit.dart';
import 'package:pob2_ui/ui/trade_search_dialog.dart';

import 'editor_widget_test.dart' show application;
import 'equipment_editor_test.dart' show EquipmentEngine, EquipmentWorkshop;

class TradeEngine extends EquipmentEngine {
  TradeEngine() {
    tools = {
      ...tools,
      'pob_trade_catalog',
      'pob_trade_search',
      'pob_compare_item',
    };
  }
  final searches = <JsonMap>[];
  String? invalidUrl;
  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    if (name == 'pob_trade_catalog')
      return {
        'source': 'original-lua',
        'bases': ['Lazuli Ring'],
        'currencies': [
          {'id': 'divine', 'label': 'Divine Orb'},
        ],
        'stats': [
          {
            'id': 'explicit.life',
            'label': '# to maximum Life',
            'type': 'explicit',
            'numeric': true,
          },
        ],
      };
    if (name == 'pob_trade_search') {
      searches.add(arguments);
      return {
        'source': 'original-lua',
        'url':
            invalidUrl ??
            Uri.https(
              'www.pathofexile.com',
              '/trade2/search/poe2/${arguments['league']}',
              {'q': jsonEncode(arguments)},
            ).toString(),
      };
    }
    if (name == 'pob_compare_item')
      return {
        ...await super.call('pob_inspect_item', arguments),
        'comparison': {
          'revision': 7,
          'rows': [
            {
              'id': 'Life',
              'label': 'Life',
              'beforeText': '100',
              'afterText': '150',
              'changeText': '^x33FF77+50',
            },
          ],
        },
      };
    return super.call(name, arguments);
  }
}

void main() {
  test('Бюджет, характеристики, новая ссылка после изменения и защита повторного открытия', () async {
    final engine = TradeEngine();
    var opened = 0;
    final pending = Completer<void>();
    final editor = TradeSearchCubit(TradeSearchRepository(engine), 'Ring 1', (
      _,
    ) {
      opened++;
      return pending.future;
    });
    addTearDown(editor.close);
    await editor.load();
    editor.update(league: 'Лига', price: '2,5');
    editor.add(editor.state.catalog!.stats.single);
    editor.edit('explicit.life', min: '80');
    final first = await editor.link();
    expect(engine.searches.single['maxPrice'], 2.5);
    expect(engine.searches.single['filters'], [
      {'id': 'explicit.life', 'min': 80},
    ]);
    editor.update(price: '3');
    expect(await editor.link(), isNot(first));
    final opening = editor.open();
    await Future<void>.delayed(Duration.zero);
    await editor.open();
    expect(opened, 1);
    pending.complete();
    await opening;
    editor.update(price: 'wrong');
    expect(await editor.link(), isNull);
    expect(editor.state.error, contains('бюджет'));
  });

  test('Ответ с посторонним адресом не открывается', () async {
    final engine = TradeEngine()..invalidUrl = 'https://example.com/?q=test';
    final editor = TradeSearchCubit(
      TradeSearchRepository(engine),
      'Ring 1',
      (_) async => fail('Посторонний адрес открыт'),
    );
    addTearDown(editor.close);
    await editor.load();
    await editor.open();
    expect(editor.state.error, contains('ссылку'));
  });

  for (final width in [360.0, 1280.0]) {
    testWidgets(
      'Каталог, ссылка и возврат скопированного предмета в примерку: $width',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        String clipboard = '';
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData')
              clipboard = (call.arguments as Map)['text'] as String;
            if (call.method == 'Clipboard.getData') return {'text': clipboard};
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final engine = TradeEngine();
        final model = EquipmentWorkshop(engine);
        addTearDown(model.close);
        Uri? opened;
        await tester.pumpWidget(
          application(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showTradeSearch(
                  context,
                  model,
                  'Ring 1',
                  openBrowser: (uri) async {
                    opened = uri;
                  },
                ),
                child: const Text('Торговля'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Торговля'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('trade-league')),
          'Test League',
        );
        await tester.enterText(find.byKey(const Key('trade-budget')), '5');
        await tester.pumpAndSettle();
        final scrollable = find
            .descendant(
              of: find.byType(TradeSearchDialog),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          find.byKey(const Key('trade-add-stat')),
          160,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('trade-add-stat')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('trade-choice-search')),
          'maximum Life',
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('trade-choice-explicit.life')),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('trade-explicit.life-min')),
          160,
          scrollable: scrollable,
        );
        await tester.enterText(
          find.byKey(const ValueKey('trade-explicit.life-min')),
          '80',
        );
        await tester.tap(find.byKey(const Key('trade-copy')));
        await tester.pumpAndSettle();
        expect(Uri.parse(clipboard).host, 'www.pathofexile.com');
        await tester.tap(find.byKey(const Key('trade-open')));
        await tester.pumpAndSettle();
        expect(opened?.queryParameters['q'], contains('Test League'));
        clipboard = 'Rarity: Rare\nTide Loop\nLazuli Ring';
        await tester.tap(find.byKey(const Key('trade-import')));
        await tester.pumpAndSettle();
        expect(find.byType(ItemComparisonPanel), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('item-raw')))
              .controller!
              .text,
          clipboard,
        );
        expect(model.equipped, isNull);
        await tester.tap(find.byKey(const Key('item-editor-cancel')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
