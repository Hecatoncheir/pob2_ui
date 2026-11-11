import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/appearance_repository.dart';
import 'package:pob2_ui/domain/appearance.dart';
import 'package:pob2_ui/ui/appearance_bloc.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/exit_protection.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/item_comparison_panel.dart';
import 'package:pob2_ui/data/trade_search_repository.dart';

const ring =
    'Item Class: Rings\nRarity: Rare\nTide Loop\nLazuli Ring\n--------\nItem Level: 80\n--------\n+50 to maximum Life\n+20% to Fire Resistance\n';
const wand = 'Rarity: Normal\nWithered Wand\n';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Экипировка: текст игры, отказ, снятие, наборы, Undo/Redo и XML',
    (tester) async {
      if (!Platform.environment.containsKey('POB2_UI_HOME'))
        throw StateError('Нужен отдельный профиль POB2_UI_HOME');
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(InstallationStore.defaultRoot()),
        ),
        McpClient(),
      );
      addTearDown(model.close);
      final appearance = AppearanceBloc(
        AppearanceRepository(model.components.store.root),
        initialTheme: AppTheme.dark,
      );
      addTearDown(appearance.close);
      await model.initialize();
      expect(model.state.error, isNull);
      final witch = model.state.classes.firstWhere(
        (entry) => entry['name'] == 'Witch',
      );
      await model.createBuild(
        witch['id'] as int,
        90,
        name: 'Проверка экипировки Lua',
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('equipment-review-image'),
          child: ExitProtection(
            model: model,
            child: PobApp(model: model, appearance: appearance),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tab-items')));
      await tester.pumpAndSettle();
      final before = model.state.report!.stats['Life'] as num;
      await _select(tester, 'Ring 1');
      await _edit(tester, 'not an item');
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('item-editor-save')))
            .onPressed,
        isNull,
      );
      expect(model.state.report!.items, isEmpty);
      await _check(tester, ring);
      await _save(tester, model);
      final added = model.state.report!.stats['Life'] as num;
      expect(added, greaterThan(before));
      expect(model.state.report!.items, hasLength(1));
      await _tradePreview(tester, model);
      await _edit(tester, wand);
      expect(find.text('Предмет не подходит для этого слота'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('item-editor-save')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('item-editor-cancel')));
      await tester.pumpAndSettle();
      expect(model.state.report!.stats['Life'], added);
      await _tap(tester, find.byKey(const Key('equipment-remove')));
      await _wait(tester, () => !model.state.busy);
      expect(model.state.report!.stats['Life'], before);
      expect(model.state.report!.items, hasLength(1));
      await model.undo();
      expect(model.state.report!.stats['Life'], added);
      await model.redo();
      expect(model.state.report!.stats['Life'], before);
      await model.undo();
      await tester.pumpAndSettle();
      await _select(tester, 'Weapon 1');
      await _edit(tester, wand);
      await _save(tester, model);
      await _tap(tester, find.byKey(const ValueKey('equipment-weapon-2')));
      await _wait(
        tester,
        () => !model.state.busy && model.state.report!.raw['weaponSet'] == 2,
      );
      await _select(tester, 'Weapon 1 Swap');
      await _edit(tester, wand);
      await _save(tester, model);
      final stats = model.state.report!.stats;
      final xml = await model.exportXml();
      await model.importXml(xml!);
      expect(model.state.error, isNull);
      expect(model.state.report!.stats, stats);
      expect(model.state.report!.raw['weaponSet'], 2);
      expect(model.state.report!.items, hasLength(3));
      await tester.pumpAndSettle();
      await _select(tester, 'Ring 1');
      await _wait(
        tester,
        () => find.textContaining('Tide Loop').evaluate().isNotEmpty,
      );
      await _capture(tester);
      expect(tester.takeException(), isNull);
      debugPrint(
        'Готово: предметы Lua, отказ, снятие, наборы оружия, история и XML',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.hitTestable().evaluate().isEmpty)
    await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tradePreview(WidgetTester tester, WorkshopCubit model) async {
  final before = await model.exportXml();
  final life = model.state.report!.stats['Life'] as num;
  final catalog = await TradeSearchRepository(model.engine).catalog('Ring 1');
  final stat = catalog.stats.firstWhere(
    (entry) => entry.type == 'explicit' && entry.label == '# to maximum Life',
  );
  await _tap(tester, find.byKey(const Key('equipment-trade')));
  await _wait(
    tester,
    () => find.byKey(const Key('trade-league')).evaluate().isNotEmpty,
  );
  await tester.enterText(find.byKey(const Key('trade-league')), 'Standard');
  await tester.enterText(find.byKey(const Key('trade-budget')), '5');
  await _tap(tester, find.byKey(const Key('trade-add-stat')));
  await tester.enterText(
    find.byKey(const Key('trade-choice-search')),
    'maximum Life',
  );
  await tester.pumpAndSettle();
  final choice = find.byKey(ValueKey('trade-choice-${stat.id}'));
  await tester.scrollUntilVisible(
    choice,
    120,
    scrollable: find.descendant(
      of: find.byKey(const Key('trade-choice-list')),
      matching: find.byType(Scrollable),
    ),
  );
  await _tap(tester, choice);
  final minimum = find.byKey(ValueKey('trade-${stat.id}-min'));
  await tester.ensureVisible(minimum);
  await tester.enterText(minimum, '80');
  await _tap(tester, find.byKey(const Key('trade-copy')));
  await _wait(
    tester,
    () =>
        tester
            .widget<FilledButton>(find.byKey(const Key('trade-open')))
            .onPressed !=
        null,
  );
  final link = await Clipboard.getData(Clipboard.kTextPlain);
  final uri = Uri.parse(link!.text!);
  expect(uri.host, 'www.pathofexile.com');
  final query = jsonDecode(uri.queryParameters['q']!) as Map<String, dynamic>;
  expect(query['query']['stats'][0]['filters'][0]['id'], stat.id);
  expect(query['query']['stats'][0]['filters'][0]['value']['min'], 80);
  expect(
    query['query']['filters']['trade_filters']['filters']['price']['max'],
    5,
  );
  expect(await model.exportXml(), before);
  await _capture(tester, '-market');
  await Clipboard.setData(ClipboardData(text: ring.replaceFirst('+50', '+80')));
  await _tap(tester, find.byKey(const Key('trade-import')));
  await _wait(
    tester,
    () => find.byType(ItemComparisonPanel).evaluate().isNotEmpty,
  );
  await tester.pumpAndSettle();
  final preview = tester
      .widget<ItemComparisonPanel>(find.byType(ItemComparisonPanel))
      .comparison;
  expect(preview.rows.firstWhere((row) => row.id == 'Life').change, isNotNull);
  expect(await model.exportXml(), before);
  await _capture(tester, '-comparison');
  await _save(tester, model);
  expect(model.state.report!.stats['Life'] as num, greaterThan(life));
  await model.undo();
  expect(model.state.report!.stats['Life'], life);
  await model.redo();
  expect(model.state.report!.stats['Life'] as num, greaterThan(life));
  await model.undo();
  await tester.pumpAndSettle();
  debugPrint(
    'Готово: торговая ссылка, возврат предмета, примерка, применение и Undo/Redo',
  );
}

Future<void> _select(WidgetTester tester, String slot) =>
    _tap(tester, find.byKey(ValueKey('equipment-slot-$slot')));
Future<void> _edit(WidgetTester tester, String raw) async {
  await _tap(tester, find.byKey(const Key('equipment-edit')));
  await _check(tester, raw);
}

Future<void> _check(WidgetTester tester, String raw) async {
  final input = find.byKey(const Key('item-raw'));
  await tester.tap(input);
  await tester.pumpAndSettle();
  await tester.enterText(input, raw);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('item-preview')));
  await _wait(
    tester,
    () => find.byType(LinearProgressIndicator).evaluate().isEmpty,
  );
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester, WorkshopCubit model) async {
  final save = find.byKey(const Key('item-editor-save'));
  await _wait(
    tester,
    () => tester.widget<FilledButton>(save).onPressed != null,
  );
  await tester.tap(save);
  await _wait(tester, () => !model.state.busy && save.evaluate().isEmpty);
  await tester.pumpAndSettle();
}

Future<void> _wait(WidgetTester tester, bool Function() done) async {
  for (var attempt = 0; attempt < 900; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (done()) return;
  }
  fail('Операция экипировки не завершилась');
}

Future<void> _capture(WidgetTester tester, [String suffix = '']) async {
  final path = Platform.environment['POB2_UI_SCREENSHOT'];
  if (path == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('equipment-review-image')),
  );
  final image = await boundary.toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path.replaceFirst('.png', '$suffix.png'));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data!.buffer.asUint8List());
  image.dispose();
}
