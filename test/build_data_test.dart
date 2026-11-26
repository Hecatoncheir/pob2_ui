import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/domain/build_card_appearance.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/library_entry.dart';

BuildReport report() => BuildReport.fromJson({
  'source': 'original-lua',
  'snapshot': {
    'buildInfo': {'name': 'Lua', 'level': 90, 'class': 'Witch'},
  },
  'stats': {'Life': 1187},
  'warnings': ['Общее'],
  'groups': [
    {
      'gems': [
        {'name': 'Камень', 'error': 'Ошибка'},
      ],
    },
  ],
  'items': [
    {
      'name': 'Предмет',
      'unsupported': [
        {'line': 'Строка'},
      ],
    },
  ],
  'customMods': [
    {
      'title': 'Модификаторы',
      'unparsed': [
        {'line': 'Не распознано'},
      ],
    },
  ],
});

void main() {
  test(
    'Принимается только отчёт Lua, отсутствие чисел не превращается в ноль',
    () {
      expect(
        () => BuildReport.fromJson({'source': 'demo'}),
        throwsFormatException,
      );
      expect(formatStat(null), '—');
      expect(formatStat(0), '0');
      expect(formatStat(1187), '1\u2009187');
      expect(report().warnings, hasLength(4));
    },
  );
  test(
    'Библиотека сохраняет XML, имя и активную сборку, копия не меняет оригинал',
    () async {
      final root = await Directory.systemTemp.createTemp('pob2-library-test-');
      addTearDown(() => root.delete(recursive: true));
      final library = BuildLibrary(root);
      final first = await library.save(
        LibraryState(),
        report(),
        '<first/>',
        title: 'Первая',
      );
      final second = await library.save(
        LibraryState(entries: first.entries),
        report(),
        '<second/>',
        title: 'Копия',
      );
      expect(await library.read(first.activeId!), '<first/>');
      final restored = await BuildLibrary(root).load();
      expect(restored.entries, hasLength(2));
      expect(restored.active!.title, 'Копия');
      expect(restored.activeId, second.activeId);
      expect(() => library.read('../outside'), throwsFormatException);
    },
  );

  test('Старая карточка и неизвестный цвет используют стандартный вид', () {
    final oldEntry = {
      'id': 'old',
      'title': 'Первая',
      'class': 'Witch',
      'level': 90,
      'updated': '2026-11-25T00:00:00Z',
    };
    expect(
      LibraryEntry.fromJson(oldEntry).appearance,
      const BuildCardAppearance(),
    );
    expect(
      LibraryEntry.fromJson({
        ...oldEntry,
        'appearance': {'icon': 'shield', 'color': 'future-color'},
      }).appearance,
      const BuildCardAppearance(icon: BuildCardIcon.shield),
    );
  });

  test(
    'Локальная карточка сохраняет вид отдельно от новой ревизии XML',
    () async {
      final root = await Directory.systemTemp.createTemp('pob2-card-');
      addTearDown(() => root.delete(recursive: true));
      final library = BuildLibrary(root);
      final first = await library.save(LibraryState(), report(), '<first/>');
      final second = await library.save(
        LibraryState(entries: first.entries),
        report(),
        '<second/>',
      );
      const appearance = BuildCardAppearance(
        icon: BuildCardIcon.shield,
        color: BuildCardColor.blue,
      );
      final id = first.activeId!;
      final edited = await library.updateAppearance(second, id, appearance);
      expect(edited.activeId, second.activeId);
      expect(edited.active?.appearance, const BuildCardAppearance());
      expect(edited.entries.last.revision, first.active?.revision);
      expect(await library.read(id), '<first/>');

      final saved = await library.save(
        LibraryState(entries: edited.entries, activeId: id),
        report(),
        '<recalculated/>',
      );
      expect(saved.active?.appearance, appearance);
      final reopened = BuildLibrary(root);
      final restored = await reopened.load();
      expect(restored.active?.appearance, appearance);
      await reopened.updateAppearance(
        restored,
        id,
        const BuildCardAppearance(),
      );
      expect(
        (await library.load()).active?.appearance,
        const BuildCardAppearance(),
      );
      expect(await library.read(id), '<recalculated/>');
    },
  );
}
