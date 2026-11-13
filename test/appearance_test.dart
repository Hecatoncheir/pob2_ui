import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/appearance_repository.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/appearance.dart';
import 'package:pob2_ui/domain/node_preview.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/appearance_bloc.dart';
import 'package:pob2_ui/ui/appearance_picker.dart';
import 'package:pob2_ui/ui/core/panels.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/core/frosted_surface.dart';
import 'package:pob2_ui/ui/tree_hover_card.dart';

import 'package:pob2_ui/ui/workshop_cubit.dart';

import 'support/temporary_directory.dart';
import 'support/dispose_widget_bloc.dart';

class DelayedPreferences extends AppearanceRepository {
  DelayedPreferences(super.root);
  final first = Completer<void>();
  final writes = <AppTheme>[];
  @override
  Future<void> save(AppTheme theme) async {
    writes.add(theme);
    if (writes.length == 1) await first.future;
    return super.save(theme);
  }
}

class MemoryPreferences extends AppearanceRepository {
  MemoryPreferences(super.root);
  AppTheme theme = AppTheme.light;
  @override
  Future<AppTheme> load() async => theme;
  @override
  Future<void> save(AppTheme value) async {
    theme = value;
  }
}

void main() {
  test(
    'Выбранная тема восстанавливается новым экземпляром приложения',
    () async {
      final root = await Directory.systemTemp.createTemp('pob2-appearance-');
      addTearDown(() => removeTemporaryDirectory(root));
      final appearance = AppearanceBloc(AppearanceRepository(root));
      appearance.add(const ThemeSelected(AppTheme.dark));
      await appearance.close();
      final repository = AppearanceRepository(root);
      final restored = AppearanceBloc(
        repository,
        initialTheme: await repository.load(),
      );
      expect(restored.state.theme, AppTheme.dark);
      restored.add(const ThemeSelected(AppTheme.light));
      await restored.close();
      expect(await AppearanceRepository(root).load(), AppTheme.light);
    },
  );

  test('Быстрое переключение сохраняет последний выбор, повреждённый файл безопасен', () async {
    final root = await Directory.systemTemp.createTemp('pob2-appearance-');
    addTearDown(() => removeTemporaryDirectory(root));
    final repository = DelayedPreferences(root);
    final appearance = AppearanceBloc(repository);
    appearance
      ..add(const ThemeSelected(AppTheme.dark))
      ..add(const ThemeSelected(AppTheme.light));
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, [AppTheme.dark]);
    repository.first.complete();
    await appearance.close();
    expect(await repository.load(), AppTheme.light);
    await repository.file.writeAsString('{broken');
    expect(await repository.load(), AppTheme.light);
  });

  for (final width in [360.0, 1366.0]) {
    testWidgets(
      'Переключение через настройки и восстановление без светлого кадра: $width',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 850));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final root = Directory('unused-theme-widget');
        final model = WorkshopCubit(
          ComponentRepository(store: InstallationStore(root)),
          McpClient(),
        );
        addTearDown(model.close);
        final preferences = MemoryPreferences(root);
        final appearance = AppearanceBloc(preferences);
        await tester.pumpWidget(PobApp(model: model, appearance: appearance));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('appearance-settings')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Тёмная'));
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(find.byType(AppearancePicker))).brightness,
          Brightness.dark,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Готово'));
        await tester.pumpAndSettle();
        final background = Theme.of(tester.element(find.byType(Scaffold)))
            .scaffoldBackgroundColor;
        expect(
          background,
          Spark.theme(brightness: Brightness.dark).scaffoldBackgroundColor,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await disposeWidgetBloc(tester, appearance);
        final restored = await preferences.load();
        final next = AppearanceBloc(preferences, initialTheme: restored);
        await tester.pumpWidget(PobApp(model: model, appearance: next));
        await tester.pump();
        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
          ThemeMode.dark,
        );
        expect(
          Theme.of(tester.element(find.byType(Scaffold))).brightness,
          Brightness.dark,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await disposeWidgetBloc(tester, next);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets('Подсказка и панели читаемы в теме $brightness', (
      tester,
    ) async {
      final theme = Spark.theme(brightness: brightness);
      final preview = NodePreview(
        tooltip: {
          'lines': [
            {'text': '^x00FF00+10 Energy Shield'},
            {'text': '^x8888FF15% increased Damage'},
          ],
          'path': [],
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 480,
                height: 500,
                child: SurfacePanel(
                  child: TreeHoverCard(
                    title: 'Узел',
                    state: (
                      id: 1,
                      preview: preview,
                      error: null,
                      loading: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final lines = tester
          .widgetList<Text>(find.byType(Text))
          .where((text) => text.textSpan != null);
      for (final text in lines) {
        expect(text.style!.fontSize, 14);
        for (final span
            in (text.textSpan! as TextSpan).children!.cast<TextSpan>()) {
          final foreground = span.style!.color!.computeLuminance();
          final background = FrostedSurface.contrastBackground(
            theme.colorScheme,
          ).computeLuminance();
          final contrast =
              ((foreground > background ? foreground : background) + .05) /
              ((foreground < background ? foreground : background) + .05);
          final minimum = text.textSpan!.toPlainText().contains('Energy Shield')
              ? 4.5
              : 7;
          expect(contrast, greaterThanOrEqualTo(minimum));
        }
      }
      expect(tester.takeException(), isNull);
    });
  }
}
