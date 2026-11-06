import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/equipment_repository.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'equipment_presentation.dart';
import 'item_description.dart';
import 'item_comparison_panel.dart';
import 'item_editor_cubit.dart';
import 'workshop_cubit.dart';

Future<void> showItemEditor(
  BuildContext context,
  WorkshopCubit model,
  String slot, {
  String initial = '',
}) => sparkDialog<void>(
  context,
  _ItemEditorDialog(model, slot, initial),
  barrierDismissible: false,
);

class _ItemEditorDialog extends StatefulWidget {
  const _ItemEditorDialog(this.model, this.slot, this.initial);
  final WorkshopCubit model;
  final String slot;
  final String initial;
  @override
  State<_ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<_ItemEditorDialog> {
  late final repository = EquipmentRepository(widget.model.engine);
  late final editor = ItemEditorCubit(
    ({raw, itemId}) => repository.inspect(
      widget.slot,
      raw: raw,
      itemId: itemId,
      compare: true,
    ),
    ({raw, itemId, expectedRevision}) => widget.model.equipItem(
      widget.slot,
      raw: raw,
      itemId: itemId,
      expectedRevision: expectedRevision,
    ),
  );
  late final text = TextEditingController(text: widget.initial);
  late final AppLifecycleListener exitListener;
  @override
  void initState() {
    super.initState();
    if (widget.initial.isNotEmpty) {
      editor.text(widget.initial);
      editor.preview();
    }
    exitListener = AppLifecycleListener(
      onExitRequested: () async =>
          editor.mayExit() ? AppExitResponse.exit : AppExitResponse.cancel,
    );
  }

  @override
  void dispose() {
    exitListener.dispose();
    text.dispose();
    editor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ItemEditorCubit, ItemEditorState>(
        bloc: editor,
        builder: (context, state) => PopScope(
          canPop: !state.saving,
          child: AlertDialog(
            title: AppText(equipmentLabel(widget.slot)),
            insetPadding: const EdgeInsets.all(18),
            content: SizedBox(
              width: 1000,
              height: (MediaQuery.sizeOf(context).height * .65).clamp(220, 600),
              child: _content(state),
            ),
            actions: [
              TextButton(
                key: const Key('item-editor-cancel'),
                onPressed: state.saving ? null : () => Navigator.pop(context),
                child: const AppText('Отмена'),
              ),
              FilledButton(
                key: const Key('item-editor-save'),
                onPressed: editor.canSave ? _save : null,
                child: AppText(state.saving ? 'Расчёт…' : 'Применить'),
              ),
            ],
          ),
        ),
      );

  Widget _content(ItemEditorState state) => LayoutBuilder(
    builder: (context, constraints) {
      final input = _input(state);
      final preview = _preview(state);
      if (constraints.maxWidth >= 640)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: input),
            const SizedBox(width: 18),
            Expanded(child: SingleChildScrollView(child: preview)),
          ],
        );
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 300, child: input),
            const SizedBox(height: 16),
            preview,
          ],
        ),
      );
    },
  );

  Widget _input(ItemEditorState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Expanded(child: AppText('Текст предмета')),
          TextButton.icon(
            onPressed: state.saving ? null : _paste,
            icon: const Icon(Icons.content_paste, size: 18),
            label: const AppText('Вставить'),
          ),
        ],
      ),
      Expanded(
        child: TextField(
          key: const Key('item-raw'),
          controller: text,
          enabled: !state.saving,
          expands: true,
          minLines: null,
          maxLines: null,
          textAlignVertical: TextAlignVertical.top,
          onChanged: editor.text,
          style: Spark.mono.copyWith(fontSize: 12),
          decoration: const InputDecoration(
            hintText: 'Скопируйте предмет из игры или PoB',
          ),
        ),
      ),
      const SizedBox(height: 10),
      OutlinedButton(
        key: const Key('item-preview'),
        onPressed: state.saving || state.loading
            ? null
            : () => editor.preview(),
        child: const AppText('Проверить предмет'),
      ),
      _savedItems(state),
    ],
  );

  Widget _savedItems(ItemEditorState state) {
    final items = widget.model.state.report!.items;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DropdownButtonFormField<int>(
        key: const Key('stored-item'),
        initialValue: state.itemId,
        isExpanded: true,
        decoration: const InputDecoration(label: AppText('Предмет из сборки')),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item['id'] as int,
                child: AppText(
                  '${item['name']}',
                  game: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: state.saving
            ? null
            : (id) {
                if (id != null) editor.preview(itemId: id);
              },
      ),
    );
  }

  Widget _preview(ItemEditorState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (state.loading) const LinearProgressIndicator(),
      if (state.error case final error?)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppText(
            error,
            style: TextStyle(color: Spark.of(context).danger),
          ),
        ),
      if (state.preview case final preview?) ...[
        if (preview.comparison case final comparison?) ...[
          ItemComparisonPanel(comparison),
          const SizedBox(height: 14),
        ],
        if (!repository.canCompare)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: AppText('Обновите MCP для сравнения предметов'),
          ),
        ItemDescription(preview),
      ] else if (!state.loading)
        const Padding(
          padding: EdgeInsets.all(20),
          child: AppText(
            'Проверьте текст, чтобы увидеть описание и совместимость',
          ),
        ),
    ],
  );

  Future<void> _paste() async {
    final value = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted || value?.text == null) return;
    text.text = value!.text!;
    editor.text(text.text);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (await editor.save() && mounted) Navigator.pop(context);
  }
}
