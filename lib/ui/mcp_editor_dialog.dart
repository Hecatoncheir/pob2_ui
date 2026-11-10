import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'mcp_editor_cubit.dart';
import 'workshop_cubit.dart';

class McpEditorButton extends StatelessWidget {
  const McpEditorButton(this.model, {super.key});
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<McpEditorCubit, McpEditorState>(
        bloc: model.mcpEditor,
        builder: (context, state) => IconButton(
          key: const Key('mcp-editor-settings'),
          tooltip: translateUi(context, 'Правки через MCP'),
          isSelected: state.command != null,
          onPressed: model.state.busy || !model.engine.connected
              ? null
              : () => _show(context),
          icon: const Icon(Icons.hub_outlined, size: 20),
          selectedIcon: Icon(
            Icons.hub,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

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
                'Доступ действует для текущей сборки. Правки можно отменить.',
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
