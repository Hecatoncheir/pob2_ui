import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pob2_ui/data/launcher_versions.dart';

import 'support/temporary_directory.dart';

void main() {
  late Directory root;
  late LauncherVersions versions;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-launcher-');
    versions = LauncherVersions(root);
  });
  tearDown(() => removeTemporaryDirectory(root));

  Future<void> install(String version) async {
    final file = versions.executable(version);
    await file.parent.create(recursive: true);
    await file.writeAsString('установленный исполняемый файл');
  }

  test('Новая установленная версия выбирается без pending-version', () async {
    await install('0.9.9');
    await install('0.10.3');
    expect(await versions.candidates(active: '0.9.9'), ['0.10.3', '0.9.9']);
  });

  test('Устаревший pending-version не понижает установленную версию', () async {
    await install('0.10.3');
    await install('0.11.0');
    expect(await versions.candidates(active: '0.10.3', pending: '0.9.0'), [
      '0.11.0',
      '0.10.3',
      '0.9.0',
    ]);
  });

  test('Версии находятся и при отсутствии обоих маркеров', () async {
    await install('0.9.0');
    await install('0.10.3');
    expect(await versions.candidates(), ['0.10.3', '0.9.0']);
  });

  test('Незавершённые каталоги и нестабильные номера исключаются', () async {
    for (final version in ['0.10.3', 'v0.12.0', '0.12.0-beta', '0.12.0+1']) {
      await install(version);
    }
    await Directory(p.join(root.path, 'versions', '0.11.0')).create();
    expect(await versions.candidates(), ['0.10.3']);
  });

  test('Неудачная версия исключается и после нового запуска', () async {
    await install('0.10.3');
    await install('0.11.0');
    await versions.reject('0.11.0');
    expect(await LauncherVersions(root).candidates(active: '0.10.3'), [
      '0.10.3',
    ]);
  });

  test(
    'Явная повторная установка разрешает проверку отклонённой версии',
    () async {
      await install('0.10.3');
      await install('0.11.0');
      await versions.reject('0.11.0');
      expect(await versions.candidates(active: '0.10.3', pending: '0.11.0'), [
        '0.11.0',
        '0.10.3',
      ]);
      await versions.allow('0.11.0');
      expect(await versions.candidates(), ['0.11.0', '0.10.3']);
    },
  );

  test(
    'Отсутствующий явный кандидат сохраняется для проверки и отката',
    () async {
      await install('0.10.3');
      expect(await versions.candidates(active: '0.10.3', pending: '0.11.0'), [
        '0.11.0',
        '0.10.3',
      ]);
    },
  );

  test('Повреждённый индекс отказов не закрывает рабочую установку', () async {
    await install('0.10.3');
    await File(p.join(root.path, 'rejected-versions.json')).writeAsString('{');
    expect(await versions.candidates(), ['0.10.3']);
  });
}
