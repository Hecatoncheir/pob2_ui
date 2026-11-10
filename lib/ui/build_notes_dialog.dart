import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'notes_cubit.dart';
import 'workshop_cubit.dart';

Future<void> showBuildNotes(
  BuildContext context,
  WorkshopCubit model,
  String id,
) => sparkDialog<void>(context, _BuildNotesDialog(model, id));

class _BuildNotesDialog extends StatefulWidget {
  const _BuildNotesDialog(this.model, this.id);
  final WorkshopCubit model;
  final String id;
  @override
  State<_BuildNotesDialog> createState() => _BuildNotesDialogState();
}

class _BuildNotesDialogState extends State<_BuildNotesDialog> {
  late final notes = NotesCubit(widget.model.buildNotes, widget.id);
  final controller = TextEditingController();
  bool _allowClose = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    notes.load().then((_) {
      if (mounted) controller.text = notes.state.text;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    notes.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _allowClose,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _finish();
    },
    child: BlocBuilder<NotesCubit, NotesState>(
      bloc: notes,
      builder: (context, state) => AlertDialog(
        title: const AppText('Заметки к сборке'),
        content: SizedBox(
          width: 580,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 280,
                child: TextField(
                  key: const Key('build-notes'),
                  controller: controller,
                  enabled: !state.loading && notes.canEdit,
                  onChanged: notes.edit,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hint: AppText('Планы, предметы, варианты развития…'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (state.error == null)
                AppText(
                  state.saving
                      ? 'Сохранение…'
                      : 'Заметки сохраняются автоматически',
                ),
              if (state.error != null)
                AppText(
                  'Не удалось открыть или сохранить заметки.\n${state.error}',
                  style: TextStyle(color: Spark.of(context).danger),
                ),
            ],
          ),
        ),
        actions: [
          if (state.error != null && widget.model.sharedLibrary != null)
            TextButton(
              onPressed: _discardAndClose,
              child: const AppText('Отмена'),
            ),
          TextButton(
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: controller.text)),
            child: const AppText('Скопировать'),
          ),
          FilledButton(
            onPressed: state.loading ? null : _retryOrFinish,
            child: AppText(
              state.error == null ? 'Готово' : 'Повторить сохранение',
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _retryOrFinish() async {
    if (!notes.canEdit) {
      await notes.load();
      if (mounted) controller.text = notes.state.text;
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    if (_closing) return;
    _closing = true;
    final saved = !notes.canEdit || await notes.flush();
    _closing = false;
    if (saved) _closeDialog();
  }

  Future<void> _discardAndClose() async {
    if (_closing) return;
    _closing = true;
    await widget.model.sharedLibrary!.discardNotes(widget.id);
    _closeDialog();
  }

  void _closeDialog() {
    if (!mounted) return;
    setState(() => _allowClose = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }
}
