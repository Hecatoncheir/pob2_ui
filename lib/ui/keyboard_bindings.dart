import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/workspace_preferences.dart';

const commandLabels = {
  AppCommand.undo: 'Отменить действие',
  AppCommand.newBuild: 'Новая сборка',
  AppCommand.importXml: 'Открыть XML',
  AppCommand.exportXml: 'Экспорт XML',
  AppCommand.zoomIn: 'Увеличить интерфейс',
  AppCommand.zoomOut: 'Уменьшить интерфейс',
  AppCommand.resetZoom: 'Масштаб 100%',
};

KeyBinding defaultBinding(AppCommand command) => (
  key: switch (command) {
    AppCommand.undo => LogicalKeyboardKey.keyZ.keyId,
    AppCommand.newBuild => LogicalKeyboardKey.keyN.keyId,
    AppCommand.importXml => LogicalKeyboardKey.keyO.keyId,
    AppCommand.exportXml => LogicalKeyboardKey.keyS.keyId,
    AppCommand.zoomIn => LogicalKeyboardKey.equal.keyId,
    AppCommand.zoomOut => LogicalKeyboardKey.minus.keyId,
    AppCommand.resetZoom => LogicalKeyboardKey.digit0.keyId,
  },
  control: true,
  alt: false,
  shift: false,
  meta: false,
);

KeyBinding? commandBinding(
  WorkspacePreferences preferences,
  AppCommand command,
) => preferences.shortcuts.containsKey(command)
    ? preferences.shortcuts[command]
    : defaultBinding(command);

Map<ShortcutActivator, VoidCallback> commandCallbacks(
  WorkspacePreferences preferences,
  Map<AppCommand, VoidCallback> actions,
) => {
  for (final entry in actions.entries)
    for (final candidate in commandBindings(preferences, entry.key))
      _activator(candidate): entry.value,
};

Iterable<KeyBinding> commandBindings(
  WorkspacePreferences preferences,
  AppCommand command,
) sync* {
  final binding = commandBinding(preferences, command);
  if (binding == null) return;
  yield binding;
  if (preferences.shortcuts.containsKey(command)) return;
  yield (
    key: binding.key,
    control: false,
    alt: false,
    shift: false,
    meta: true,
  );
  if (command == AppCommand.zoomIn) {
    yield _control(LogicalKeyboardKey.equal, shift: true);
    yield _control(LogicalKeyboardKey.add);
    yield _control(LogicalKeyboardKey.add, shift: true);
    yield _control(LogicalKeyboardKey.numpadAdd);
  }
  if (command == AppCommand.zoomOut) {
    yield _control(LogicalKeyboardKey.numpadSubtract);
  }
}

KeyBinding _control(LogicalKeyboardKey key, {bool shift = false}) =>
    (key: key.keyId, control: true, alt: false, shift: shift, meta: false);

SingleActivator _activator(KeyBinding binding) => SingleActivator(
  LogicalKeyboardKey(binding.key),
  control: binding.control,
  alt: binding.alt,
  shift: binding.shift,
  meta: binding.meta,
);

List<String> bindingLabels(KeyBinding binding) => [
  if (binding.control) 'Ctrl',
  if (binding.alt) 'Alt',
  if (binding.shift) 'Shift',
  if (binding.meta) 'Cmd',
  LogicalKeyboardKey(binding.key).keyLabel.toUpperCase(),
];
