import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/proxy_preferences.dart';
import 'package:pob2_ui/domain/proxy_settings.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/proxy_cubit.dart';
import 'package:pob2_ui/ui/proxy_settings_dialog.dart';

class _ProxyPreferences extends ProxyPreferences {
  _ProxyPreferences() : super(Directory('unused-proxy-dialog'));

  ProxySettings saved = const ProxySettings.automatic();
  bool fail = false;

  @override
  Future<ProxySettings> load() async => saved;

  @override
  Future<void> save(ProxySettings settings) async {
    if (fail) throw const FileSystemException('Нет доступа');
    saved = settings;
  }
}

void main() {
  testWidgets('Диалог проверяет адрес и восстанавливает сохранённый прокси', (
    tester,
  ) async {
    final preferences = _ProxyPreferences();
    final proxy = await _open(tester, preferences);
    await _tapText(tester, 'HTTP-прокси');
    final field = find.byType(TextField);
    await tester.enterText(field, 'proxy.example');
    await _tapText(tester, 'Сохранить');

    expect(
      find.text('Введите адрес HTTP-прокси в формате хост:порт.'),
      findsOneWidget,
    );
    expect(await preferences.load(), const ProxySettings.automatic());

    await tester.enterText(field, 'HTTP://Proxy.Example:08080');
    await _tapText(tester, 'Сохранить');
    final expected = ProxySettings.manual('proxy.example:8080');
    expect(find.byType(AlertDialog), findsNothing);
    expect(await preferences.load(), expected);
    expect(proxy.state, expected);

    final restored = await _open(tester, preferences);
    expect(restored.state, expected);
    expect(tester.widget<TextField>(field).controller?.text, expected.address);
  });

  testWidgets('Ошибка записи оставляет черновик и позволяет отменить', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = _ProxyPreferences()
      ..saved = ProxySettings.manual('proxy.example:8080')
      ..fail = true;
    final proxy = await _open(tester, preferences);
    final expected = proxy.state;
    final field = find.byType(TextField);
    await tester.enterText(field, 'proxy.example:8081');
    await _tapText(tester, 'Сохранить');

    expect(
      find.textContaining('Не удалось сохранить настройки прокси'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(field).controller?.text,
      'proxy.example:8081',
    );
    expect(proxy.state, expected);

    await _tapText(tester, 'Без прокси');
    await _tapText(tester, 'Отмена');
    expect(find.byType(AlertDialog), findsNothing);
    expect(await preferences.load(), expected);
  });
}

Future<ProxyCubit> _open(
  WidgetTester tester,
  _ProxyPreferences preferences,
) async {
  final proxy = ProxyCubit(preferences, initial: await preferences.load());
  addTearDown(proxy.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: Spark.theme(),
      home: Scaffold(
        body: Center(child: ProxySettingsButton(proxy: proxy)),
      ),
    ),
  );
  await tester.tap(find.byType(ProxySettingsButton));
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsOneWidget);
  return proxy;
}

Future<void> _tapText(WidgetTester tester, String label) async {
  final button = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text(label),
  );
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}
