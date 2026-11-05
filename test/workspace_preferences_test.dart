import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/data/workspace_preferences_repository.dart';
import 'package:pob2_ui/domain/workspace_preferences.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/keyboard_bindings.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workspace_preferences_cubit.dart';

import 'support/temporary_directory.dart';

class MemoryWorkspacePreferences extends WorkspacePreferencesRepository {
  MemoryWorkspacePreferences(super.root);
  WorkspacePreferences saved = WorkspacePreferences();
  @override
  Future<void> save(WorkspacePreferences preferences) async =>
      saved = preferences;
}

class ShortcutWorkshop extends WorkshopCubit {
  ShortcutWorkshop(Directory root)
    : super(ComponentRepository(store: InstallationStore(root)), McpClient());
  int undoCalls = 0;
  @override
  Future<void> undo() async => undoCalls++;
}

void main() {
  test('Ширина и сочетания сохраняются; конфликты, включая Cmd и дополнительные клавиши масштаба, отклоняются', () async {
    final root = await Directory.systemTemp.createTemp('pob2-preferences-');
    addTearDown(() => removeTemporaryDirectory(root));
    final repository = WorkspacePreferencesRepository(root);
    final preferences = WorkspacePreferencesCubit(repository);
    preferences.resizeSidebar(260);
    await preferences.settleSidebar();
    await preferences.toggleSidebar();
    final custom = (
      key: LogicalKeyboardKey.keyK.keyId,
      control: true,
      alt: false,
      shift: true,
      meta: false,
    );
    await preferences.setBinding(AppCommand.undo, custom);
    await preferences.setBinding(AppCommand.exportXml, null);
    await preferences.close();
    final saved = await repository.load();
    expect(saved.sidebarWidth, 78);
    expect(saved.expandedWidth, 260);
    expect(commandBinding(saved, AppCommand.undo), custom);
    expect(commandBinding(saved, AppCommand.exportXml), isNull);
    final next = WorkspacePreferencesCubit(repository, initial: saved);
    await next.toggleSidebar();
    expect(next.state.preferences.sidebarWidth, 260);
    await next.setBinding(AppCommand.undo, defaultBinding(AppCommand.zoomIn));
    expect(next.state.error, isNotNull);
    expect(commandBinding(next.state.preferences, AppCommand.undo), custom);
    await next.setBinding(AppCommand.undo, (
      key: LogicalKeyboardKey.keyN.keyId,
      control: false,
      alt: false,
      shift: false,
      meta: true,
    ));
    expect(next.state.error, isNotNull);
    await next.resetBindings();
    expect(
      commandBinding(next.state.preferences, AppCommand.undo),
      defaultBinding(AppCommand.undo),
    );
    await next.close();
    await repository.file.writeAsString('{broken');
    expect((await repository.load()).sidebarWidth, 198);
  });

  testWidgets(
    'Панель сворачивается и растягивается; узкий экран не меняет сохранённую ширину',
    (tester) async {
      final root = Directory('unused-sidebar-test');
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final preferences = WorkspacePreferencesCubit(
        MemoryWorkspacePreferences(root),
      );
      final model = WorkshopCubit(
        ComponentRepository(store: InstallationStore(root)),
        McpClient(),
      );
      await tester.pumpWidget(
        PobApp(model: model, workspacePreferences: preferences),
      );
      await tester.pumpAndSettle();
      final sidebar = find.byKey(const Key('sidebar-width'));
      expect(tester.getSize(sidebar).width, 198);
      await tester.tap(find.byKey(const Key('sidebar-toggle')));
      await tester.pumpAndSettle();
      expect(tester.getSize(sidebar).width, 78);
      expect(
        tester.getSize(find.byKey(const Key('appearance-settings'))),
        const Size(36, 36),
      );
      await tester.drag(
        find.byKey(const Key('sidebar-resize')),
        const Offset(170, 0),
      );
      await tester.pumpAndSettle();
      final expanded = tester.getSize(sidebar).width;
      expect(expanded, greaterThan(200));
      await tester.binding.setSurfaceSize(const Size(900, 800));
      await tester.pumpAndSettle();
      expect(tester.getSize(sidebar).width, 78);
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      await tester.pumpAndSettle();
      expect(tester.getSize(sidebar).width, expanded);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await preferences.close();
      await model.close();
    },
  );

  testWidgets(
    'Запись сочетания в настройках не запускает команду; новое сочетание сохраняется',
    (tester) async {
      final root = Directory('unused-shortcuts-test');
      final repository = MemoryWorkspacePreferences(root);
      final preferences = WorkspacePreferencesCubit(repository);
      final model = ShortcutWorkshop(root);
      await tester.pumpWidget(
        PobApp(model: model, workspacePreferences: preferences),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('appearance-settings')));
      await tester.pumpAndSettle();
      final shortcut = find.byKey(const Key('shortcut-undo'));
      await tester.ensureVisible(shortcut);
      await tester.tap(shortcut);
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(
        commandBinding(preferences.state.preferences, AppCommand.undo)!.key,
        LogicalKeyboardKey.keyK.keyId,
      );
      expect(find.text('Новое сочетание'), findsNothing);
      expect(model.undoCalls, 0);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(model.undoCalls, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await preferences.close();
      await model.close();
      expect(commandBinding(repository.saved, AppCommand.undo)!.shift, isTrue);
    },
  );
}
