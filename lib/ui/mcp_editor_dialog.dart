import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'mcp_editor_cubit.dart';
import 'workshop_cubit.dart';

class McpEditorButton extends StatelessWidget {
  const McpEditorButton(this.model, {this.outlined = false, super.key});
  final WorkshopCubit model;
  final bool outlined;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<McpEditorCubit, McpEditorState>(
        bloc: model.mcpEditor,
        builder: _button,
      );

  Widget _button(BuildContext context, McpEditorState state) {
    const key = Key('mcp-editor-settings');
    final tooltip = translateUi(context, 'Правки через MCP');
    final selected = state.command != null;
    final onPressed = model.state.busy || !model.mcpEditor.canEnable
        ? null
        : () => _show(context);
    const inactive = Icon(Icons.hub_outlined, size: 20);
    const active = Icon(Icons.hub, size: 20);
    if (outlined) {
      return OutlinedButton.icon(
        key: key,
        onPressed: onPressed,
        icon: selected ? active : inactive,
        label: Text(tooltip),
      );
    }
    return IconButton(
      key: key,
      tooltip: tooltip,
      isSelected: selected,
      onPressed: onPressed,
      icon: inactive,
      selectedIcon: Icon(
        Icons.hub,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _show(BuildContext context) =>
      sparkDialog<void>(context, _McpEditorDialog(model.mcpEditor));
}

class _McpEditorDialog extends StatelessWidget {
  const _McpEditorDialog(this.editor);
  final McpEditorCubit editor;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<McpEditorCubit, McpEditorState>(
    bloc: editor,
    builder: (context, state) => AlertDialog(
      title: const AppText('Правки через MCP'),
      content: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              key: const Key('mcp-editor-permission'),
              contentPadding: EdgeInsets.zero,
              title: const AppText('Разрешить правки через MCP'),
              subtitle: const AppText(
                'MCP может создавать сборки и править текущую. Если вы смените сборку вручную, доступ отключится.',
              ),
              value: state.command != null,
              onChanged: state.busy
                  ? null
                  : (value) => value ? editor.enable() : editor.disable(),
            ),
            if (state.busy) const LinearProgressIndicator(),
            if (state.error case final error?)
              AppText(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (state.command case final command?)
              OutlinedButton.icon(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: command)),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const AppText('Скопировать команду подключения Codex'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const AppText('Закрыть'),
        ),
      ],
    ),
  );
}
