import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/condition_definition.dart';
import 'condition_editor_cubit.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'workshop_cubit.dart';

Future<void> showConditionEditor(
  BuildContext context,
  WorkshopCubit model,
  ConditionDefinition definition,
) => sparkDialog<void>(
  context,
  _ConditionDialog(model, definition),
  barrierDismissible: false,
);

class _ConditionDialog extends StatefulWidget {
  const _ConditionDialog(this.model, this.definition);
  final WorkshopCubit model;
  final ConditionDefinition definition;
  @override
  State<_ConditionDialog> createState() => _ConditionDialogState();
}

class _ConditionDialogState extends State<_ConditionDialog> {
  late final AppLifecycleListener exitListener;
  late final editor = ConditionEditorCubit(
    widget.definition,
    widget.model.state.report!.config[widget.definition.id],
    widget.model.setCondition,
  );
  late final text = TextEditingController(text: editor.state.text);
  @override
  void initState() {
    super.initState();
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
      BlocBuilder<ConditionEditorCubit, ConditionEditorState>(
        bloc: editor,
        builder: (context, state) => PopScope(
          canPop: !state.saving,
          child: AlertDialog(
            title: AppText(widget.definition.label, game: true),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(state),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: AppText(
                          state.error!,
                          style: TextStyle(color: Spark.of(context).danger),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: state.saving ? null : () => Navigator.pop(context),
                child: const AppText('Отмена'),
              ),
              FilledButton(
                key: const Key('condition-save'),
                onPressed: state.saving || !widget.definition.editable
                    ? null
                    : _save,
                child: AppText(
                  state.saving ? 'Расчёт…' : 'Применить и рассчитать',
                ),
              ),
            ],
          ),
        ),
      );
  Widget _field(ConditionEditorState state) => switch (widget.definition.type) {
    'check' => SwitchListTile(
      key: const Key('condition-toggle'),
      title: const AppText('Включено'),
      contentPadding: EdgeInsets.zero,
      value: state.selection == true,
      onChanged: state.saving ? null : editor.select,
    ),
    'list' => DropdownButtonFormField<Object>(
      key: const Key('condition-choice'),
      initialValue: state.selection,
      isExpanded: true,
      hint: const AppText('Выберите значение'),
      items: widget.definition.choices
          .map(
            (choice) => DropdownMenuItem<Object>(
              value: choice['value'],
              child: AppText(
                '${choice['label']}',
                game: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: state.saving ? null : editor.select,
    ),
    _ => _textField(state),
  };

  Widget _textField(ConditionEditorState state) => TextField(
    key: const Key('condition-value'),
    controller: text,
    enabled: !state.saving && widget.definition.editable,
    minLines: widget.definition.type == 'text' ? 4 : 1,
    maxLines: widget.definition.type == 'text' ? 8 : 1,
    onChanged: editor.text,
    keyboardType: widget.definition.type == 'text'
        ? TextInputType.multiline
        : const TextInputType.numberWithOptions(decimal: true, signed: true),
    decoration: const InputDecoration(label: AppText('Значение')),
  );
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (await editor.save() && mounted) Navigator.pop(context);
  }
}
