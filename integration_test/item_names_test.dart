import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/game_dictionary_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/language_preferences.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/app_language.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/language_bloc.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';

const _damagedHelmet =
    'Rarity: RARE\n???? ????\nImperial Greathelm\n'
    'Item Level: 80\n+50 to maximum Life';
const _namedArmour =
    'Rarity: RARE\nTide Song\nSacramental Robe\n'
    'Item Level: 80\n+30 to maximum Mana';
const _imageKey = Key('item-names-image');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Названия предметов: Lua, десять языков и сохранность XML', (
    tester,
  ) async {
    if (!Platform.environment.containsKey('POB2_UI_HOME')) {
      throw StateError('Нужен отдельный профиль POB2_UI_HOME');
    }
    final root = InstallationStore.defaultRoot();
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(root)),
      McpClient(),
    );
    final language = LanguageBloc(
      LanguagePreferences(root),
      GameDictionaryRepository(root),
    );
    addTearDown(model.close);
    addTearDown(language.close);
    await model.initialize();
    expect(model.state.error, isNull);
    final witch = model.state.classes.firstWhere((c) => c['name'] == 'Witch');
    await model.createBuild(witch['id'] as int, 90, name: 'Названия предметов');
    await model.equipItem('Helmet', raw: _damagedHelmet);
    await model.equipItem('Body Armour', raw: _namedArmour);
    expect(model.state.error, isNull);
    final xml = await model.exportXml();
    final stats = model.state.report!.stats;
    await tester.pumpWidget(
      RepaintBoundary(
        key: _imageKey,
        child: PobApp(model: model, language: language),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-items')));
    for (final value in AppLanguage.values) {
      language.add(LanguageSelected(value));
      await _waitLanguage(tester, language, value);
      debugPrint(
        '${value.code}: ${model.state.report!.items.map((i) => i['name']).toList()}',
      );
      await _capture(tester, value.code);
      expect(find.textContaining('????'), findsNothing);
      expect(find.text('Tide Song'), findsOneWidget);
      expect(
        find.text(language.state.dictionary!.translate('Imperial Greathelm')),
        findsOneWidget,
      );
      expect(await model.exportXml(), xml);
      expect(model.state.report!.stats, stats);
    }
    await model.importXml(xml!);
    expect(model.state.error, isNull);
    expect(model.state.report!.stats, stats);
    expect(model.state.report!.items.first['name'], '???? ????');
    expect(model.state.report!.items.last['name'], 'Tide Song');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 8)));
}

Future<void> _waitLanguage(
  WidgetTester tester,
  LanguageBloc bloc,
  AppLanguage language,
) async {
  for (var attempt = 0; attempt < 600; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    if (bloc.state.language == language &&
        !bloc.state.loading &&
        bloc.state.dictionary != null) {
      expect(bloc.state.error, isNull);
      await tester.pumpAndSettle();
      return;
    }
    if (bloc.state.error != null) fail(bloc.state.error!);
  }
  fail('Не загрузился язык ${language.code}');
}

Future<void> _capture(WidgetTester tester, String language) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_imageKey),
    );
    final picture = await boundary.toImage();
    final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
    final file = File(
      'build/review/item-names-$language-${Platform.operatingSystem}.png',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    picture.dispose();
  });
}
