// Проверка закреплённых игровых словарей: SHA-256, изолят и числовые подстановки.
import 'dart:io';

import 'package:pob2_ui/data/game_dictionary_repository.dart';
import 'package:pob2_ui/domain/app_language.dart';
import 'package:pob2_ui/domain/game_dictionary.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory(arguments.firstOrNull ?? 'build/language-check');
  final repository = GameDictionaryRepository(root);
  for (final language in AppLanguage.values) {
    final dictionary = await repository.load(language);
    _checkDictionary(dictionary, language);
    final name = dictionary.translate('Intelligence');
    final range = dictionary.translate('Adds 3 to 17 Fire Damage');
    stdout.writeln('${language.code}: $name · числа сохранены · $range');
  }
}

void _checkDictionary(GameDictionary dictionary, AppLanguage language) {
  if (language != AppLanguage.english &&
      dictionary.translate('+5 to Intelligence') == '+5 to Intelligence') {
    throw StateError('Нет описания характеристики: ${language.code}');
  }
  for (final number in ['+5', '-10', '12.5']) {
    if (!dictionary.translate('$number to Intelligence').contains(number)) {
      throw StateError('Перевод изменил число: ${language.code}');
    }
  }
  if (dictionary.translate('Unknown PoB text') != 'Unknown PoB text') {
    throw StateError('Изменена неизвестная строка');
  }
  _checkRange(dictionary, language);
}

void _checkRange(GameDictionary dictionary, AppLanguage language) {
  const source = 'Adds -3.5 to +17,25 Fire Damage';
  final translated = dictionary.translate(source);
  final first = translated.indexOf('-3.5');
  final second = translated.indexOf('+17,25');
  if (first < 0 || second <= first) {
    throw StateError('Изменён порядок или формат чисел: ${language.code}');
  }
}
