import 'dart:io';

import 'package:material_ui/material_ui.dart';
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
import 'package:pob2_ui/ui/workspace_preferences_bloc.dart';

import 'support/temporary_directory.dart';
import 'support/dispose_widget_bloc.dart';

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
  int redoCalls = 0;
  @override
  Future<void> undo() async => undoCalls++;
  @override
  Future<void> redo() async => redoCalls++;
}

void main() {
  test('Новый Redo не перехватывает старые пользовательские Ctrl+Shift+Z и Cmd+Shift+Z', () {
    final primary = defaultBinding(AppCommand.redo);
    final legacy = WorkspacePreferences(shortcuts: {AppCommand.undo: primary});
    expect(commandBinding(legacy, AppCommand.redo), isNull);
    expect(commandBindings(legacy, AppCommand.undo), [primary]);
    final meta = (
      key: primary.key,
      control: false,
      alt: false,
      shift: true,
      meta: true,
    );
    final metaLegacy = WorkspacePreferences(
      shortcuts: {AppCommand.newBuild: meta},
    );
    expect(commandBinding(metaLegacy, AppCommand.redo), primary);
    expect(commandBindings(metaLegacy, AppCommand.redo), [primary]);
  });
  test('Старые настройки получают Ctrl+Shift+Z; новое сочетание Redo сохраняется и проверяется на конфликты', () async {
    final root = await Directory.systemTemp.createTemp('pob2-redo-keys-');
    addTearDown(() => removeTemporaryDirectory(root));
    final repository = WorkspacePreferencesRepository(root);
    final preferences = WorkspacePreferencesBloc(repository);
    final defaultRedo = defaultBinding(AppCommand.redo);
    expect(defaultRedo.key, LogicalKeyboardKey.keyZ.keyId);
    expect(defaultRedo.control, isTrue);
    expect(defaultRedo.shift, isTrue);
    expect(
      commandBindings(preferences.state.preferences, AppCommand.redo).last.meta,
      isTrue,
    );
    expect(
      commandBindings(
        preferences.state.preferences,
        AppCommand.redo,
      ).last.shift,
      isTrue,
    );
    await _apply(preferences, ShortcutChanged(AppCommand.undo, defaultRedo));
    expect(preferences.state.error, isNotNull);
    final custom = (
      key: LogicalKeyboardKey.keyR.keyId,
      control: true,
      alt: true,
      shift: false,
      meta: false,
    );
    preferences.add(ShortcutChanged(AppCommand.redo, custom));
    await preferences.close();
    expect(commandBinding(await repository.load(), AppCommand.redo), custom);
  });

  testWidgets(
    'Ctrl+Shift+Z повторяет действие; сочетание Redo меняется в настройках',
    (tester) async {
      final root = Directory('unused-redo-shortcuts-test');
      final repository = MemoryWorkspacePreferences(root);
      final preferences = WorkspacePreferencesBloc(repository);
      final model = ShortcutWorkshop(root);
      await tester.pumpWidget(
        PobApp(model: model, workspacePreferences: preferences),
      );
      await tester.pumpAndSettle();
      await _redoKeys(tester, LogicalKeyboardKey.keyZ, shift: true);
      expect(model.redoCalls, 1);
      expect(model.undoCalls, 0);
      await tester.tap(find.byKey(const Key('appearance-settings')));
      await tester.pumpAndSettle();
      final row = find.byKey(const Key('shortcut-redo'));
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      await _redoKeys(tester, LogicalKeyboardKey.keyR, alt: true);
      expect(model.redoCalls, 1);
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();
      await _redoKeys(tester, LogicalKeyboardKey.keyZ, shift: true);
      expect(model.redoCalls, 1);
      await _redoKeys(tester, LogicalKeyboardKey.keyR, alt: true);
      expect(model.redoCalls, 2);
      expect(model.undoCalls, 0);
      expect(commandBinding(repository.saved, AppCommand.redo)!.alt, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      await disposeWidgetBloc(tester, preferences);
      await model.close();
    },
  );
  test('Ширина и сочетания сохраняются; конфликты, включая Cmd и дополнительные клавиши масштаба, отклоняются', () async {
    final root = await Directory.systemTemp.createTemp('pob2-preferences-');
    addTearDown(() => removeTemporaryDirectory(root));
    final repository = WorkspacePreferencesRepository(root);
    final preferences = WorkspacePreferencesBloc(repository);
    preferences
      ..add(const SidebarDragged(32))
      ..add(const SidebarDragged(30))
      ..add(const SidebarDragEnded())
      ..add(const SidebarToggled());
    final custom = (
      key: LogicalKeyboardKey.keyK.keyId,
      control: true,
      alt: false,
      shift: true,
      meta: false,
    );
    preferences
      ..add(ShortcutChanged(AppCommand.undo, custom))
      ..add(const ShortcutChanged(AppCommand.exportXml, null));
    await preferences.close();
    final saved = await repository.load();
    expect(saved.sidebarWidth, 78);
    expect(saved.expandedWidth, 260);
    expect(commandBinding(saved, AppCommand.undo), custom);
    expect(commandBinding(saved, AppCommand.exportXml), isNull);
    final next = WorkspacePreferencesBloc(repository, initial: saved);
    await _apply(next, const SidebarToggled());
    expect(next.state.preferences.sidebarWidth, 260);
    await _apply(
      next,
      ShortcutChanged(AppCommand.undo, defaultBinding(AppCommand.zoomIn)),
    );
    expect(next.state.error, isNotNull);
    expect(commandBinding(next.state.preferences, AppCommand.undo), custom);
    await _apply(
      next,
      ShortcutChanged(AppCommand.undo, (
        key: LogicalKeyboardKey.keyN.keyId,
        control: false,
        alt: false,
        shift: false,
        meta: true,
      )),
    );
    expect(next.state.error, isNotNull);
    await _apply(next, const ShortcutsReset());
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
      final preferences = WorkspacePreferencesBloc(
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
      await disposeWidgetBloc(tester, preferences);
      await model.close();
    },
  );

  testWidgets(
    'Запись сочетания в настройках не запускает команду; новое сочетание сохраняется',
    (tester) async {
      final root = Directory('unused-shortcuts-test');
      final repository = MemoryWorkspacePreferences(root);
      final preferences = WorkspacePreferencesBloc(repository);
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
      await disposeWidgetBloc(tester, preferences);
      await model.close();
      expect(commandBinding(repository.saved, AppCommand.undo)!.shift, isTrue);
    },
  );
}

Future<void> _apply(
  WorkspacePreferencesBloc bloc,
  WorkspacePreferencesEvent event,
) async {
  final changed = bloc.stream.first;
  bloc.add(event);
  await changed;
}

Future<void> _redoKeys(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
  bool alt = false,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  if (alt) await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(key);
  if (alt) await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}
