import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:pob2_ui/ui/language_cubit.dart';
import 'package:pob2_ui/ui/language_picker.dart';
import 'package:pob2_ui/ui/tree_hover_card.dart';

import 'support/temporary_directory.dart';

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
    final cubit = LanguageCubit(preferences, dictionaries);
    addTearDown(cubit.close);
    final first = cubit.selectLanguage(AppLanguage.russian);
    final last = cubit.selectLanguage(AppLanguage.english);
    dictionaries.pending[AppLanguage.english]!.complete(
      GameDictionary.english(),
    );
    await last;
    dictionaries.pending[AppLanguage.russian]!.complete(russianDictionary());
    await first;
    expect(cubit.state.language, AppLanguage.english);
    expect(cubit.state.dictionary!.language, 'en');
    expect(preferences.language, AppLanguage.english);
    final failure = cubit.selectLanguage(AppLanguage.japanese);
    dictionaries.pending[AppLanguage.japanese]!.completeError(
      const FormatException('offline'),
    );
    await failure;
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.dictionary, isNull);
    expect(cubit.state.error, contains('offline'));
    dictionaries.pending.remove(AppLanguage.japanese);
    final retry = cubit.load();
    dictionaries.pending[AppLanguage.japanese]!.complete(
      GameDictionary('ja', {}, {}),
    );
    await retry;
    expect(cubit.state.error, isNull);
  });

  for (final language in AppLanguage.values) {
    testWidgets('Каталог и настройки без переполнения: ${language.code}', (
      tester,
    ) async {
      final cubit = LanguageCubit(
        MemoryLanguages(),
        DelayedDictionaries(),
        initialLanguage: language,
      );

      await tester.binding.setSurfaceSize(const Size(360, 650));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            locale: languageLocale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
      await cubit.close();
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
