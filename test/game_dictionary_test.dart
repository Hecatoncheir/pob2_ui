import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/game_dictionary.dart';

void main() {
  test(
    'Проверенные диапазоны сохраняют порядок, знак и формат обоих чисел',
    () {
      const id =
          'stat_translations.local_minimum_added_fire_damage '
          'local_maximum_added_fire_damage[0]';
      final dictionary = GameDictionary(
        'ru',
        {id: 'Adds # to # Fire Damage'},
        {id: 'Добавляет от # до # урона от огня'},
      );
      expect(
        dictionary.translate('Adds 3 to 17 Fire Damage'),
        'Добавляет от 3 до 17 урона от огня',
      );
      expect(
        dictionary.translate('Adds -3.5 to +17,25 Fire Damage'),
        'Добавляет от -3.5 до +17,25 урона от огня',
      );
    },
  );

  test('Перевод текста сохраняет числа и пробелы; неоднозначность не подменяет данные', () {
    final dictionary = GameDictionary(
      'ru',
      {
        'passives.Int': 'Intelligence',
        'stats.Int': '+# to Intelligence',
        'stat_translations/passive_skill.base_intelligence[0]':
            '# to Intelligence',
        'stats.Range': 'Adds # to # Fire Damage',
        'one': 'Same name',
        'two': 'Same name',
      },
      {
        'passives.Int': 'Интеллект',
        'stats.Int': '+# к интеллекту',
        'stat_translations/passive_skill.base_intelligence[0]':
            '# к интеллекту',
        'stats.Range': 'Добавляет от # до # урона от огня',
        'one': 'Первый',
        'two': 'Второй',
      },
    );
    expect(dictionary.translate(' Intelligence '), ' Интеллект ');
    expect(dictionary.translate('+5 to Intelligence'), '+5 к интеллекту');
    expect(dictionary.translate('-10 to Intelligence'), '-10 к интеллекту');
    expect(
      dictionary.translate('Adds 3 to 7 Fire Damage'),
      'Adds 3 to 7 Fire Damage',
    );
    expect(dictionary.translate('Same name'), 'Same name');
    expect(dictionary.translate('Unknown'), 'Unknown');
  });
}
