import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/data/pob_build_library.dart';
import 'package:pob2_ui/data/pob_build_document.dart';
import 'package:pob2_ui/data/session_repository.dart';
import 'package:pob2_ui/domain/build_card_appearance.dart';
import 'package:pob2_ui/domain/library_entry.dart';

import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

String buildXml(int level) =>
    '<PathOfBuilding2><Build className="Witch" level="$level"/><Notes/></PathOfBuilding2>';

const cardAppearance = BuildCardAppearance(
  icon: BuildCardIcon.fire,
  color: BuildCardColor.red,
);

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

  test('Выбор папки восстанавливает повреждённые настройки', () async {
    await profile.create();
    await File(path.join(profile.path, 'pob-builds.json')).writeAsString('{');
    await expectLater(library.load(), throwsFormatException);
    final configured = await library.configure(builds.path);
    expect(configured.entries.single.appearance, const BuildCardAppearance());
    expect((await PobBuildLibrary(profile).load()).entries, hasLength(1));
    expect(await existing.readAsString(), buildXml(40));
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
      await legacy.updateAppearance(before, before.activeId!, cardAppearance);
      final migrated = await library.configure(builds.path);
      expect(migrated.entries, hasLength(2));
      expect(migrated.active?.level, 90);
      expect(migrated.active?.appearance, cardAppearance);
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

  test(
    'Оформление одинаковых имён в разных папках хранится раздельно',
    () async {
      final first = await library.configure(builds.path);
      final id = first.entries.single.id;
      final edited = await library.updateAppearance(first, id, cardAppearance);
      expect(edited.entries.single.appearance, cardAppearance);
      expect(edited.entries.single.revision, first.entries.single.revision);
      expect(edited.entries.single.updated, first.entries.single.updated);
      expect(await existing.readAsString(), buildXml(40));

      final alternate = await Directory(path.join(root.path, 'Other')).create();
      final secondFile = File(path.join(alternate.path, 'PoB.xml'));
      await secondFile.writeAsString(buildXml(50));
      final second = await library.configure(alternate.path);
      expect(second.entries.single.id, id);
      expect(second.entries.single.appearance, const BuildCardAppearance());
      const alternateAppearance = BuildCardAppearance(
        color: BuildCardColor.teal,
      );
      await library.updateAppearance(second, id, alternateAppearance);
      final reopened = PobBuildLibrary(profile);
      expect(
        (await reopened.load()).entries.single.appearance,
        alternateAppearance,
      );

      final restored = await reopened.configure(builds.path);
      expect(restored.entries.single.appearance, cardAppearance);
      await reopened.updateAppearance(
        restored,
        id,
        const BuildCardAppearance(),
      );
      expect(
        (await PobBuildLibrary(profile).load()).entries.single.appearance,
        const BuildCardAppearance(),
      );
      expect(await secondFile.readAsString(), buildXml(50));
    },
  );

  test(
    'Оформление общей сборки остаётся при сохранении и переименовании',
    () async {
      final scanned = await library.configure(builds.path);
      final id = scanned.entries.single.id;
      await library.activate(id);
      final styled = await library.updateAppearance(
        await library.scan(),
        id,
        cardAppearance,
      );
      final saved = await library.save(styled, fixture, buildXml(65));
      expect(saved.active?.appearance, cardAppearance);
      final renamed = await library.save(
        saved,
        fixture,
        buildXml(65),
        title: 'Переименованная',
      );
      expect(renamed.active?.appearance, cardAppearance);
      await existing.writeAsString(buildXml(70));
      final reopened = PobBuildLibrary(profile);
      final restored = await reopened.load();
      expect(restored.active?.appearance, cardAppearance);
      expect(
        (await reopened.open(id)).entry.appearance,
        const BuildCardAppearance(),
      );

      await reopened.remove(restored, renamed.activeId!);
      final reused = File(path.join(builds.path, renamed.activeId!));
      await reused.writeAsString(buildXml(75));
      expect(
        (await PobBuildLibrary(profile).load()).entries
            .singleWhere((entry) => entry.id == renamed.activeId)
            .appearance,
        const BuildCardAppearance(),
      );
    },
  );
}
