import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/report_views.dart';
import 'package:pob2_ui/ui/shell_cubit.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/workshop_fixture.dart';

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
        final shell = ShellCubit();
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
        final group = find.byKey(const ValueKey('stat-group-Урон'));
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
        expect(tester.getRect(header), before);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await shell.close();
        await model.close();
      },
    );
  }
}
