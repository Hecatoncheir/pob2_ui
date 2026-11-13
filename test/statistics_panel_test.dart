import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/report_views.dart';
import 'package:pob2_ui/ui/shell_bloc.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/workshop_fixture.dart';
import 'support/dispose_widget_bloc.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Заголовок закреплён над списком, группы имеют округлую рамку: $brightness',
      (tester) async {
        final model = WorkshopCubit(
          ComponentRepository(
            store: InstallationStore(Directory('unused-panel-test')),
          ),
          McpClient(),
          initialState: WorkshopState(
            document: (
              report: fixture,
              tree: tree,
              stale: false,
              treeError: null,
            ),
          ),
        );
        final shell = ShellBloc();
        await tester.pumpWidget(
          MaterialApp(
            theme: Spark.theme(brightness: brightness),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 330,
                  height: 480,
                  child: StatisticsPanel(model: model, shell: shell),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final header = find.byKey(const Key('statistics-header'));
        final before = tester.getRect(header);
        final viewport = tester.getRect(
          find.byKey(const Key('statistics-scroll')),
        );
        expect(viewport.top, greaterThan(before.top));
        expect(viewport.top, lessThan(before.bottom));
        expect(
          find.descendant(of: header, matching: find.byType(BackdropFilter)),
          findsOneWidget,
        );
        await tester.drag(
          find.byKey(const Key('statistics-scroll')),
          const Offset(0, -150),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(header), before);
        final group = find.byKey(const PageStorageKey('stat-group-Урон'));
        await Scrollable.ensureVisible(tester.element(group), alignment: .25);
        await tester.pumpAndSettle();
        await tester.tap(group);
        await tester.pumpAndSettle();
        final tile = tester.widget<ExpansionTile>(group);
        expect(
          (tile.shape! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(14),
        );
        expect(tile.clipBehavior, Clip.antiAlias);
        expect(find.text('Средний урон'), findsOneWidget);
        for (final title in ['Сопротивления', 'Характеристики']) {
          final target = await _scrollToGroup(tester, title);
          await tester.tap(target);
          await tester.pumpAndSettle();
        }
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await tester.pumpAndSettle();
        await _scrollToGroup(tester, 'Характеристики');
        expect(find.text('Ловкость'), findsOneWidget);
        expect(tester.getRect(header), before);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await disposeWidgetBloc(tester, shell);
        await model.close();
      },
    );
  }
}

Future<Finder> _scrollToGroup(WidgetTester tester, String title) async {
  final target = find.byKey(PageStorageKey('stat-group-$title'));
  await tester.scrollUntilVisible(
    target,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await Scrollable.ensureVisible(tester.element(target), alignment: .25);
  await tester.pumpAndSettle();
  return target;
}
