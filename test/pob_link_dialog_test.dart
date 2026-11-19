import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/domain/build_import_link.dart';
import 'package:pob2_ui/ui/pob_link_dialog.dart';

const _profile =
    'https://poe.ninja/poe2/profile/Example-1234/standard/character/ExampleCharacter';
const _shared = 'https://poe.ninja/poe2/pob/150d6';

Future<void> _open(
  WidgetTester tester, {
  required void Function(PobImportChoice?) result,
  Future<String?> Function()? clipboard,
  Future<void> Function(Uri)? browser,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result(
              await showDialog<PobImportChoice>(
                context: context,
                builder: (_) =>
                    PobLinkDialog(readClipboard: clipboard, openPage: browser),
              ),
            ),
            child: const Text('Импорт'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Импорт'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Профиль открывается на сайте, затем импортируется вставленный код',
    (tester) async {
      PobImportChoice? choice;
      Uri? opened;
      await _open(
        tester,
        result: (value) => choice = value,
        clipboard: () async => ' TEST_CODE ',
        browser: (uri) async => opened = uri,
      );
      await tester.enterText(find.byKey(const Key('pob-link-input')), _profile);
      await tester.pumpAndSettle();
      expect(find.text(poeNinjaExportHint), findsOneWidget);
      expect(find.byKey(const Key('pob-link-submit')), findsNothing);
      await tester.tap(find.byKey(const Key('poe-ninja-open')));
      await tester.pumpAndSettle();
      expect(opened, Uri.parse(_profile));
      expect(choice, isNull);
      await tester.tap(find.byKey(const Key('pob-link-paste-code')));
      await tester.pumpAndSettle();
      expect(choice, (text: 'TEST_CODE', code: true));
      expect(find.byType(PobLinkDialog), findsNothing);
    },
  );

  testWidgets('Ссылка экспорта передаётся на непосредственный импорт', (
    tester,
  ) async {
    PobImportChoice? choice;
    await _open(tester, result: (value) => choice = value);
    await tester.enterText(find.byKey(const Key('pob-link-input')), _shared);
    await tester.tap(find.byKey(const Key('pob-link-submit')));
    await tester.pumpAndSettle();
    expect(choice, (text: _shared, code: false));
  });

  testWidgets('Скопированный код можно вставить прямо в поле ввода', (
    tester,
  ) async {
    final code = File('integration_test/fixtures/witch_fireball.pobcode')
        .readAsStringSync();
    PobImportChoice? choice;
    await _open(tester, result: (value) => choice = value);
    await tester.enterText(find.byKey(const Key('pob-link-input')), _profile);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pob-link-input')), code);
    await tester.pumpAndSettle();
    expect(find.text(poeNinjaExportHint), findsNothing);
    await tester.tap(find.byKey(const Key('pob-link-submit')));
    await tester.pumpAndSettle();
    expect(choice, (text: code.trim(), code: true));
  });

  testWidgets('Пустой буфер оставляет диалог открытым, отмена не импортирует', (
    tester,
  ) async {
    PobImportChoice? choice;
    await _open(
      tester,
      result: (value) => choice = value,
      clipboard: () async => ' ',
    );
    await tester.enterText(find.byKey(const Key('pob-link-input')), _profile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pob-link-paste-code')));
    await tester.pumpAndSettle();
    expect(find.text('В буфере обмена нет кода PoB.'), findsOneWidget);
    expect(find.byType(PobLinkDialog), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(choice, isNull);
    expect(find.byType(PobLinkDialog), findsNothing);
  });

  testWidgets('Помощь для профиля помещается в узком окне', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _open(tester, result: (_) {});
    await tester.enterText(find.byKey(const Key('pob-link-input')), _profile);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
  });
}
