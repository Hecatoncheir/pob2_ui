import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/build_import_link.dart';

void main() {
  group('Ссылки экспорта PoB', () {
    test('pobb.in сохраняет прежний путь скачивания', () {
      final link = BuildImportLink.parse(
        ' https://pobb.in/Ab_12/?view=tree#x ',
      );
      expect(link.download, Uri.parse('https://pobb.in/pob/Ab_12'));
      expect(link.needsExport, isFalse);
    });

    test('Обычная, raw и прежняя ссылка poe2.ninja ведут к одному коду', () {
      for (final value in [
        'https://poe.ninja/poe2/pob/150d6',
        'https://poe.ninja/poe2/pob/150d6/?view=tree#skills',
        'https://poe.ninja/poe2/pob/raw/150d6',
        'https://poe2.ninja/pob/150d6',
        'https://poe2.ninja/poe2/pob/150d6',
      ]) {
        final link = BuildImportLink.parse(value);
        expect(
          link.download,
          Uri.parse('https://poe.ninja/poe2/pob/raw/150d6'),
        );
        expect(link.needsExport, isFalse);
      }
    });
  });

  group('Страницы персонажей', () {
    test('Профиль и страницы builds требуют явного экспорта кода', () {
      for (final value in [
        'https://poe.ninja/poe2/profile/Example-1234/standard/character/ExampleCharacter',
        'https://poe.ninja/poe2/builds/vaalssf/character/account-1234/character?i=1',
        'https://poe.ninja/poe2/builds/vaalssf',
        'https://poe2.ninja/profile/account-1234/standard/character/character',
      ]) {
        final link = BuildImportLink.parse(value);
        expect(link.needsExport, isTrue);
        expect(link.download, isNull);
        expect(link.source, Uri.parse(value));
      }
    });
  });

  test('Другие игры, подменённые хосты и пути не принимаются', () {
    for (final value in [
      'http://poe.ninja/poe2/pob/150d6',
      'https://poe.ninja.example.com/poe2/pob/150d6',
      'https://user@poe.ninja/poe2/pob/150d6',
      'https://poe.ninja:8443/poe2/pob/150d6',
      'https://poe.ninja/poe1/pob/150d6',
      'https://poe.ninja/pob/150d6',
      'https://poe.ninja/poe2/pob/',
      'https://poe.ninja/poe2/pob/a%2Fb',
      'https://poe.ninja/poe2/api/builds/character',
      'https://poe.ninja/poe2/profile/account',
    ]) {
      expect(() => BuildImportLink.parse(value), throwsFormatException);
    }
  });
}
