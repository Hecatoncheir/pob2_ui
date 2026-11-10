import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/domain/library_entry.dart';

import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

String buildXml(int level) =>
    '<PathOfBuilding2><Build className="Witch" level="$level"/><Notes/></PathOfBuilding2>';

void main() {
  late Directory root, profile, builds;
  late PobBuildLibrary library;
  late File existing;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-shared-library-');
    profile = Directory(path.join(root.path, 'profile'));
    builds = await Directory(path.join(root.path, 'PoB', 'Builds'))
        .create(recursive: true);
    existing = File(path.join(builds.path, 'PoB.xml'));
    await existing.writeAsString(buildXml(40));
    library = PobBuildLibrary(profile);
  });
  tearDown(() => removeTemporaryDirectory(root));

  test('Отступы XML от PoB не попадают в текст заметок', () {
    final xml = buildXml(90).replaceFirst(
      '<Notes/>',
      '<Notes>\r\n\t\tПлан\r\n\tСвой отступ &amp; текст\r\n\t</Notes>',
    );
    expect(PobBuildDocument(xml).notes, 'План\n\tСвой отступ & текст');
  });

  test(
    'Читает вложенные сборки PoB и хранит выбор без локальной копии XML',
    () async {
      final folder = await Directory(path.join(builds.path, 'Лига')).create();
      final nested = File(path.join(folder.path, 'Ведьма.xml'));
      await nested.writeAsString(buildXml(70));
      await File(path.join(builds.path, 'bad.xml')).writeAsString('<broken>');
      await File(path.join(builds.path, 'comment.xml'))
          .writeAsString('<!-- comment -->');
      await File(path.join(builds.path, '~~temp~~.xml'))
          .writeAsString(buildXml(20));
      final listed = await library.configure(builds.path);
      expect(
        listed.entries.map((entry) => entry.title),
        unorderedEquals(['PoB', 'Ведьма']),
      );
      final id = listed.entries
          .firstWhere((entry) => entry.title == 'Ведьма')
          .id;
      await library.activate(id);
      expect((await PobBuildLibrary(profile).load()).active?.level, 70);
      expect(await nested.readAsString(), buildXml(70));
      expect(
        await File(path.join(profile.path, 'session.xml')).exists(),
        isFalse,
      );
      await expectLater(
        library.read(path.join('..', 'other.xml')),
        throwsFormatException,
      );
    },
  );

  test(
    'Миграция переносит заметки и сохраняет сборку PoB при совпадении имени',
    () async {
      final legacy = BuildLibrary(profile);
      final before = await legacy.save(
        LibraryState(),
        fixture,
        buildXml(90),
        title: 'PoB',
      );
      await SessionRepository(profile)
          .saveNotes(before.activeId!, 'План < & >\nВторая строка');
      final migrated = await library.configure(builds.path);
      expect(migrated.entries, hasLength(2));
      expect(migrated.active?.level, 90);
      expect(
        await library.readNotes(migrated.activeId!),
        'План < & >\nВторая строка',
      );
      expect(await existing.readAsString(), buildXml(40));
      expect(await legacy.read(before.activeId!), buildXml(90));
      expect((await library.configure(builds.path)).entries, hasLength(2));
    },
  );

  test(
    'Сохраняет в том же XML и защищает внешние изменения и заметки',
    () async {
      final scanned = await library.configure(builds.path);
      final id = scanned.entries.single.id;
      final working = LibraryState(entries: scanned.entries, activeId: id);
      expect(await library.readNotes(id), isEmpty);
      await library.saveNotes(id, 'Привет <PoB>');
      final saved = await library.save(working, fixture, buildXml(65));
      expect(saved.activeId, id);
      expect(saved.active?.level, 65);
      expect(await library.readNotes(id), 'Привет <PoB>');
      final backup = File('${existing.path}.bak');
      expect(PobBuildDocument(await backup.readAsString()).level, 40);
      await expectLater(library.checkExport(existing), throwsStateError);
      await existing.writeAsString(buildXml(75));
      await expectLater(
        library.save(saved, fixture, buildXml(90)),
        throwsStateError,
      );
      await expectLater(library.remove(saved, id), throwsStateError);
      expect(await existing.readAsString(), buildXml(75));
      expect((await library.open(id)).entry.level, 75);
    },
  );

  test(
    'Копия, переименование и удаление не перезаписывают одноимённые файлы PoB',
    () async {
      final scanned = await library.configure(builds.path);
      final copy = await library.save(
        scanned,
        fixture,
        buildXml(90),
        title: 'PoB',
      );
      expect(copy.active?.title, 'PoB (2)');
      await expectLater(
        library.save(copy, fixture, buildXml(90), title: 'PoB'),
        throwsStateError,
      );
      final renamed = await library.save(
        copy,
        fixture,
        buildXml(90),
        title: 'Другая',
      );
      expect(renamed.active?.title, 'Другая');
      expect((await library.scan()).entries, hasLength(2));
      final removed = await library.remove(renamed, renamed.activeId!);
      expect(removed.active, isNull);
      expect((await library.scan()).entries.single.title, 'PoB');
      expect(await existing.readAsString(), buildXml(40));
    },
  );
}
