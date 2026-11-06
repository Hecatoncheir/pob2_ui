import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/data/xml_file_service.dart';
import 'package:pob2_ui/domain/library_entry.dart';

import 'support/temporary_directory.dart';
import 'support/file_fakes.dart';
import 'support/workshop_fixture.dart';

void main() {
  late Directory root;
  setUp(
    () async =>
        root = await Directory.systemTemp.createTemp('pob2-file-safety-'),
  );
  tearDown(() => removeTemporaryDirectory(root));

  test('Копия сессии читается при отсутствии основного файла', () async {
    final session = SessionRepository(root);
    await session.save('<first/>');
    await session.save('<second/>');
    await File.fromUri(root.uri.resolve('session.xml')).delete();
    expect(await SessionRepository(root).exists(), isTrue);
    expect(await SessionRepository(root).read(), '<first/>');
  });

  test('Отмена диалогов не читает и не пишет файл; XML с Unicode сохраняется атомарно', () async {
    final dialogs = SelectPaths();
    final files = XmlFileService(dialogs: dialogs);
    expect(await files.open(), isNull);
    expect(await files.save('<build/>', 'CON'), isNull);
    expect(dialogs.suggestion, 'build-CON.xml');
    final target = File.fromUri(root.uri.resolve('Сборка λ.xml'));
    dialogs.savePath = target.path;
    await files.save('<build>Привет</build>', 'Сборка λ');
    dialogs.openPath = target.path;
    expect(await files.open(), (
      xml: '<build>Привет</build>',
      title: 'Сборка λ',
    ));
    expect(
      await root.list().where((file) => file.path.endsWith('.tmp')).length,
      0,
    );
  });

  test('Неудачное сохранение оставляет старый XML; пустой и слишком большой XML отклоняются', () async {
    final target = File.fromUri(root.uri.resolve('build.xml'));
    await target.writeAsString('<old/>');
    final dialogs = SelectPaths()
      ..savePath = target.path
      ..openPath = target.path;
    final failing = FailingTextFiles()..failAll = true;
    await expectLater(
      XmlFileService(dialogs: dialogs, files: failing).save('<new/>', 'Новая'),
      throwsA(isA<FileSystemException>()),
    );
    expect(await target.readAsString(), '<old/>');
    await target.writeAsString('');
    await expectLater(
      XmlFileService(dialogs: dialogs).open(),
      throwsFormatException,
    );
    final large = await target.open(mode: FileMode.write);
    await large.truncate(16 * 1024 * 1024 + 1);
    await large.close();
    await expectLater(
      XmlFileService(dialogs: dialogs).open(),
      throwsFormatException,
    );
  });

  test('Сбой индекса не заменяет рабочую ревизию; библиотека восстанавливается по резервному индексу', () async {
    final files = FailingTextFiles();
    final library = BuildLibrary(root, files: files);
    final first = await library.save(
      LibraryState(),
      fixture,
      '<first/>',
      title: 'Первая',
    );
    files.failName = 'index.json';
    await expectLater(
      library.save(first, fixture, '<candidate/>'),
      throwsA(isA<FileSystemException>()),
    );
    expect(await library.read(first.activeId!), '<first/>');
    files.failName = null;
    await library.save(first, fixture, '<second/>');
    await File.fromUri(root.uri.resolve('builds/index.json'))
        .writeAsString('{broken');
    final restored = await library.load();
    expect(restored.active!.title, 'Первая');
    expect(await library.read(restored.activeId!), '<first/>');
  });

  test('Старый XML мигрирует без удаления и остаётся читаемым после сбоя новой записи', () async {
    final id = 'a' * 32;
    final directory = Directory.fromUri(root.uri.resolve('builds/'));
    await directory.create();
    await File.fromUri(directory.uri.resolve('$id.xml'))
        .writeAsString('<legacy/>');
    final entry = LibraryEntry(
      id: id,
      title: 'Старая',
      characterClass: 'Witch',
      level: 90,
      updated: DateTime.utc(2026),
    );
    await File.fromUri(directory.uri.resolve('index.json')).writeAsString(
      jsonEncode({
        'schema': 1,
        'activeId': id,
        'entries': [entry.toJson()],
      }),
    );
    final files = FailingTextFiles();
    final library = BuildLibrary(root, files: files);
    final migrated = await library.load();
    expect(migrated.active!.revision, isNotNull);
    files.failName = 'index.json';
    await expectLater(
      library.save(migrated, fixture, '<candidate/>'),
      throwsA(isA<FileSystemException>()),
    );
    expect(await library.read(id), '<legacy/>');
  });

  test(
    'Неверная структура индекса восстанавливается без потери записей',
    () async {
      final library = BuildLibrary(root);
      final first = await library.save(LibraryState(), fixture, '<first/>');
      await library.save(first, fixture, '<second/>');
      final entry = first.active!.toJson();
      final invalidEntries = [
        null,
        [null],
        [
          {...entry, 'level': '90'},
        ],
        [
          {...entry, 'revision': '../outside'},
        ],
        [entry, entry],
      ];
      for (final entries in invalidEntries) {
        await File.fromUri(root.uri.resolve('builds/index.json')).writeAsString(
          jsonEncode({
            'schema': 1,
            'activeId': first.activeId,
            'entries': entries,
          }),
        );
        final restored = await library.load();
        expect(restored.entries, hasLength(1));
        expect(await library.read(restored.activeId!), '<first/>');
      }
    },
  );

  test('Заметки и черновик сохраняют последний ввод; ошибка записи удерживает текст для повтора', () async {
    final files = FailingTextFiles()..gate = Completer<void>();
    final session = SessionRepository(root, files: files);
    final id = 'b' * 32;
    final first = session.saveNotes(id, 'Первый');
    final last = session.saveNotes(id, 'Последний');
    expect(await session.readNotes(id), 'Последний');
    files.gate!.complete();
    await Future.wait([first, last]);
    expect(await SessionRepository(root).readNotes(id), 'Последний');
    files.failAll = true;
    await expectLater(
      session.saveNotes(id, 'Новый'),
      throwsA(isA<FileSystemException>()),
    );
    expect(await session.readNotes(id), 'Новый');
    files.failAll = false;
    await session.flushText();
    await session.saveDraft('<draft/>');
    expect(await SessionRepository(root).readNotes(id), 'Новый');
    expect(await SessionRepository(root).readDraft(), '<draft/>');
  });
}
