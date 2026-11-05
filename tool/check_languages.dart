// Проверка закреплённых игровых словарей: SHA-256, изолят и числовые подстановки.
import 'dart:io';

import 'package:pob2_ui/data/game_dictionary_repository.dart';
import 'package:pob2_ui/domain/app_language.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory(arguments.firstOrNull ?? 'build/language-check');
  final repository = GameDictionaryRepository(root);
  for (final language in AppLanguage.values) {
    final dictionary = await repository.load(language);
    final name = dictionary.translate('Intelligence');
    if (language != AppLanguage.english &&
        dictionary.translate('+5 to Intelligence') == '+5 to Intelligence') {
      throw StateError('Нет описания характеристики: ${language.code}');
    }
    for (final number in ['+5', '-10', '12.5']) {
      final translated = dictionary.translate('$number to Intelligence');
      if (!translated.contains(number)) {
        throw StateError('Перевод изменил число: ${language.code}');
      }
    }
    if (dictionary.translate('Unknown PoB text') != 'Unknown PoB text') {
      throw StateError('Изменена неизвестная строка');
    }
    stdout.writeln('${language.code}: $name · числа сохранены');
  }
}
