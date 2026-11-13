import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/workspace_preferences.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'core/ui_translation.dart';
import 'keyboard_bindings.dart';
import 'workspace_preferences_bloc.dart';

class ShortcutSettings extends StatelessWidget {
  const ShortcutSettings({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<WorkspacePreferencesBloc, WorkspacePreferencesState>(
    builder: (context, state) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Spark.of(context).line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Горячие клавиши',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const AppText(
            'Работают в окне приложения. Нажмите на сочетание, чтобы изменить его.',
          ),
          const SizedBox(height: 12),
          for (final command in AppCommand.values)
            _ShortcutRow(command, commandBinding(state.preferences, command)),
          if (state.error case final error?)
            AppText(error, style: TextStyle(color: Spark.of(context).danger)),
          TextButton(
            onPressed: () => context.read<WorkspacePreferencesBloc>().add(
              const ShortcutsReset(),
            ),
            child: const AppText('Сбросить сочетания'),
          ),
        ],
      ),
    ),
  );
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow(this.command, this.binding);
  final AppCommand command;
  final KeyBinding? binding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(flex: 4, child: AppText(commandLabels[command]!)),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: OutlinedButton(
            key: ValueKey('shortcut-${command.name}'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _capture(context),
            child: binding == null
                ? const AppText('Не назначено')
                : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: bindingLabels(binding!)
                        .map((label) => _KeyCap(label))
                        .toList(),
                  ),
          ),
        ),
        IconButton(
          key: ValueKey('clear-shortcut-${command.name}'),
          tooltip: translateUi(context, 'Убрать сочетание'),
          onPressed: () => context.read<WorkspacePreferencesBloc>().add(
            ShortcutChanged(command, null),
          ),
          icon: const Icon(Icons.backspace_outlined, size: 18),
        ),
      ],
    ),
  );

  Future<void> _capture(BuildContext context) async {
    final preferences = context.read<WorkspacePreferencesBloc>();
    final next = await sparkDialog<KeyBinding>(
      context,
      const _CaptureShortcut(),
    );
    if (next != null && !preferences.isClosed) {
      preferences.add(ShortcutChanged(command, next));
    }
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      border: Border.all(color: Spark.of(context).line),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label, style: Spark.mono.copyWith(fontSize: 11)),
  );
}

class _CaptureShortcut extends StatelessWidget {
  const _CaptureShortcut();
  @override
  Widget build(BuildContext context) => Focus(
    autofocus: true,
    onKeyEvent: (_, event) => _key(context, event),
    child: const AlertDialog(
      title: AppText('Новое сочетание'),
      content: AppText('Нажмите сочетание с Ctrl, Alt или Cmd. Esc — отмена.'),
      actions: [DialogCloseButton(label: 'Отмена')],
    ),
  );

  KeyEventResult _key(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    final keyboard = HardwareKeyboard.instance;
    if (_modifier(event.logicalKey)) return KeyEventResult.handled;
    if (keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed) {
      Navigator.of(context).pop((
        key: event.logicalKey.keyId,
        control: keyboard.isControlPressed,
        alt: keyboard.isAltPressed,
        shift: keyboard.isShiftPressed,
        meta: keyboard.isMetaPressed,
      ));
    }
    return KeyEventResult.handled;
  }

  bool _modifier(LogicalKeyboardKey key) => const [
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  ].contains(key);
}
