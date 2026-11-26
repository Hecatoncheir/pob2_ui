import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pob2_ui/data/build_library.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/workbench_client.dart';
import 'package:pob2_ui/domain/build_card_appearance.dart';
import 'package:pob2_ui/domain/library_entry.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/core/spark_art.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

import 'support/legacy/component_repository.dart';
import 'support/temporary_directory.dart';
import 'support/workshop_fixture.dart';

class _WidgetLibrary extends BuildLibrary {
  _WidgetLibrary(super.data);

  LibraryState? saved;

  @override
  Future<void> writeIndex(LibraryState state, {bool backup = true}) async {
    saved = state;
  }
}

void main() {
  late Directory root;
  late LibraryState initial;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-library-appearance-');
    addTearDown(() => removeTemporaryDirectory(root));
    final builds = BuildLibrary(root);
    final first = await builds.save(
      LibraryState(),
      fixture,
      '<build value="1"/>',
      title: 'Огненная ведьма',
    );
    initial = await builds.save(
      LibraryState(entries: first.entries),
      fixture,
      '<build value="2"/>',
      title: 'Ледяная ведьма',
    );
  });

  testWidgets('Оформление применяется к одной карточке и сбрасывается', (
    tester,
  ) async {
    final library = _WidgetLibrary(root);
    final model = WorkshopCubit(
      ComponentRepository(store: InstallationStore(root)),
      WorkbenchClient(),
      library: library,
      initialState: WorkshopState(library: initial),
    );
    addTearDown(model.close);
    final selected = initial.entries.first.id;
    final other = initial.entries.last.id;
    const defaults = (BuildCardIcon.gem, BuildCardColor.none);
    const custom = (BuildCardIcon.sword, BuildCardColor.purple);

    await tester.pumpWidget(PobApp(model: model));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('page-library')));
    final initialColor = _surfaceColor(tester, selected);
    final otherColor = _surfaceColor(tester, other);
    final edit = find.byKey(ValueKey('build-appearance-$selected'));
    final gem = _art(edit, 'illustrations/gem');
    expect(gem, findsOneWidget);

    await _tap(tester, edit);
    await _tap(tester, find.byKey(const ValueKey('build-icon-sword')));
    await _tap(tester, find.byKey(const ValueKey('build-color-purple')));
    expect(_appearance(model.state.library, selected), defaults);
    await _tap(tester, find.text('Сохранить'));

    expect(_appearance(model.state.library, selected), custom);
    expect(_appearance(library.saved!, selected), custom);
    expect(_appearance(model.state.library, other), defaults);
    expect(_art(edit, 'icons/sword'), findsOneWidget);
    expect(_surfaceColor(tester, selected), isNot(initialColor));
    expect(_surfaceColor(tester, other), otherColor);

    await _tap(tester, edit);
    await _tap(tester, find.byKey(const ValueKey('build-icon-frost')));
    await _tap(tester, find.byKey(const ValueKey('build-color-blue')));
    await _tap(tester, find.text('Отмена'));
    expect(_appearance(model.state.library, selected), custom);

    await _tap(tester, edit);
    await _tap(tester, find.byKey(const ValueKey('build-icon-gem')));
    await _tap(tester, find.byKey(const ValueKey('build-color-none')));
    await _tap(tester, find.text('Сохранить'));
    expect(_appearance(library.saved!, selected), defaults);
    expect(_surfaceColor(tester, selected), initialColor);
    expect(gem, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Finder _art(Finder ancestor, String name) => find.descendant(
  of: ancestor,
  matching: find.byWidgetPredicate(
    (widget) => widget is SparkArt && widget.name == name,
  ),
);

(BuildCardIcon, BuildCardColor) _appearance(LibraryState library, String id) {
  final style = library.entries
      .firstWhere((entry) => entry.id == id)
      .appearance;
  return (style.icon, style.color);
}

Color? _surfaceColor(WidgetTester tester, String id) => tester
    .widget<Material>(
      find
          .descendant(
            of: find.byKey(ValueKey('build-card-$id')),
            matching: find.byType(Material),
          )
          .first,
    )
    .color;
