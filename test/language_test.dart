import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/game_dictionary_repository.dart';
import 'package:pob2_ui/data/language_preferences.dart';
import 'package:pob2_ui/domain/app_language.dart';
import 'package:pob2_ui/domain/game_dictionary.dart';
import 'package:pob2_ui/domain/node_preview.dart';
import 'package:pob2_ui/l10n/generated/app_localizations.dart';
import 'package:pob2_ui/ui/core/app_text.dart';
import 'package:pob2_ui/ui/core/language_scope.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/language_bloc.dart';
import 'package:pob2_ui/ui/language_picker.dart';
import 'package:pob2_ui/ui/tree_hover_card.dart';

import 'support/temporary_directory.dart';
import 'support/dispose_widget_bloc.dart';

class MemoryLanguages extends LanguagePreferences {
  MemoryLanguages() : super(Directory('unused-language-test'));
  AppLanguage language = AppLanguage.russian;
  @override
  Future<void> save(AppLanguage value) async => language = value;
}

class DelayedDictionaries extends GameDictionaryRepository {
  DelayedDictionaries() : super(Directory('unused-dictionary-test'));
  final pending = <AppLanguage, Completer<GameDictionary>>{};
  @override
  Future<GameDictionary> load(AppLanguage language) =>
      pending.putIfAbsent(language, Completer<GameDictionary>.new).future;
}

GameDictionary russianDictionary() => GameDictionary(
  'ru',
  {'name': 'Intelligence', 'stat': '# to Intelligence'},
  {'name': 'Интеллект', 'stat': '# к интеллекту'},
);

void main() {
  test(
    'Язык сохраняется после перезапуска, повреждённый файл безопасен',
    () async {
      final root = await Directory.systemTemp.createTemp('pob2-language-');
      addTearDown(() => removeTemporaryDirectory(root));
      for (final language in AppLanguage.values) {
        await LanguagePreferences(root).save(language);
        expect(await LanguagePreferences(root).load(), language);
      }
      await LanguagePreferences(root).file.writeAsString('{broken');
      expect(await LanguagePreferences(root).load(), AppLanguage.russian);
    },
  );

  test('Запоздавшая загрузка не возвращает предыдущий язык; ошибка допускает повтор', () async {
    final preferences = MemoryLanguages();
    final dictionaries = DelayedDictionaries();
    final bloc = LanguageBloc(preferences, dictionaries);
    addTearDown(bloc.close);
    final loaded = bloc.stream.firstWhere((state) => !state.loading);
    bloc
      ..add(const LanguageSelected(AppLanguage.russian))
      ..add(const LanguageSelected(AppLanguage.english));
    await Future<void>.delayed(Duration.zero);
    dictionaries.pending[AppLanguage.english]!.complete(
      GameDictionary.english(),
    );
    await loaded;
    dictionaries.pending[AppLanguage.russian]!.complete(russianDictionary());
    await bloc.pendingSave;
    expect(bloc.state.language, AppLanguage.english);
    expect(bloc.state.dictionary!.language, 'en');
    expect(preferences.language, AppLanguage.english);
    final failure = bloc.stream.firstWhere((state) => state.error != null);
    bloc.add(const LanguageSelected(AppLanguage.japanese));
    await Future<void>.delayed(Duration.zero);
    dictionaries.pending[AppLanguage.japanese]!.completeError(
      const FormatException('offline'),
    );
    final failed = await failure;
    expect(failed.loading, isFalse);
    expect(failed.dictionary, isNull);
    expect(failed.error, contains('offline'));
    dictionaries.pending.remove(AppLanguage.japanese);
    final retry = bloc.stream.firstWhere((state) => !state.loading);
    bloc.add(const LanguageLoadRequested());
    await Future<void>.delayed(Duration.zero);
    dictionaries.pending[AppLanguage.japanese]!.complete(
      GameDictionary('ja', {}, {}),
    );
    expect((await retry).error, isNull);
  });

  for (final language in AppLanguage.values) {
    testWidgets('Каталог и настройки без переполнения: ${language.code}', (
      tester,
    ) async {
      final bloc = LanguageBloc(
        MemoryLanguages(),
        DelayedDictionaries(),
        initialLanguage: language,
      );

      await tester.binding.setSurfaceSize(const Size(360, 650));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            locale: languageLocale(language),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: Spark.theme(),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    LanguagePicker(),
                    AppText('Новая сборка'),
                    AppText('Найти узел'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(language.label), findsOneWidget);
      if (language != AppLanguage.russian) {
        expect(find.text('Новая сборка'), findsNothing);
        expect(find.text('Найти узел'), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await disposeWidgetBloc(tester, bloc);
    });
  }

  testWidgets('Подсказка переводится без изменения исходных чисел Lua', (
    tester,
  ) async {
    final preview = NodePreview(
      tooltip: {
        'lines': [
          {'text': '^x0000FF+5 to Intelligence'},
          {'text': 'Unallocating this node will give you:'},
          {'text': '^xFF0000-10 Total Mana (-2.0%)'},
          {'text': '+3 Strength [+0 per point]'},
        ],
      },
    );
    await tester.pumpWidget(
      LanguageScope(
        dictionary: russianDictionary(),
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: Spark.theme(),
          home: Scaffold(
            body: TreeHoverCard(
              title: 'Intelligence',
              state: (id: 123, loading: false, preview: preview, error: null),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Интеллект'), findsOneWidget);
    expect(find.text('+5 к интеллекту', findRichText: true), findsOneWidget);
    expect(
      find.text('-10 Всего маны (-2.0%)', findRichText: true),
      findsOneWidget,
    );
    expect(preview.lines.first['text'], '^x0000FF+5 to Intelligence');
    expect(
      find.text('+3 Сила [+0 На очко]', findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
