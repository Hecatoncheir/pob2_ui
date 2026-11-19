import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/build_import_link.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'pob_link_cubit.dart';

typedef PobImportChoice = ({String text, bool code});

class PobLinkDialog extends StatefulWidget {
  const PobLinkDialog({super.key, this.readClipboard, this.openPage});
  final Future<String?> Function()? readClipboard;
  final Future<void> Function(Uri)? openPage;

  @override
  State<PobLinkDialog> createState() => _PobLinkDialogState();
}

class _PobLinkDialogState extends State<PobLinkDialog> {
  final _link = TextEditingController();
  late final PobLinkCubit _model;

  @override
  void initState() {
    super.initState();
    _model = PobLinkCubit(
      readClipboard: widget.readClipboard,
      openPage: widget.openPage,
    );
  }

  @override
  void dispose() {
    _link.dispose();
    unawaited(_model.close());
    super.dispose();
  }

  void _submit() {
    if (_model.state.profile != null) {
      unawaited(_model.openProfile());
      return;
    }
    final text = _link.text.trim();
    final code = !(Uri.tryParse(text)?.hasScheme ?? false);
    Navigator.pop(context, (text: text, code: code));
  }

  Future<void> _paste() async {
    final code = await _model.pasteCode();
    if (mounted && code != null)
      Navigator.pop(context, (text: code, code: true));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PobLinkCubit, PobLinkState>(
    bloc: _model,
    builder: (context, state) => AlertDialog(
      scrollable: true,
      title: const AppText('Импортировать по ссылке'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('pob-link-input'),
              controller: _link,
              autofocus: true,
              enabled: !state.busy,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                label: AppText('Ссылка или код PoB'),
                hintText: 'https://poe.ninja/poe2/pob/…',
              ),
              onChanged: _model.changed,
              onSubmitted: (_) => _submit(),
            ),
            if (state.profile != null)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: AppText(poeNinjaExportHint),
              ),
            if (state.error case final error?)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: AppText(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        const DialogCloseButton(label: 'Отмена'),
        TextButton(
          key: const Key('pob-link-paste-code'),
          onPressed: state.busy ? null : _paste,
          child: const AppText('Вставить код PoB'),
        ),
        FilledButton(
          key: Key(
            state.profile == null ? 'pob-link-submit' : 'poe-ninja-open',
          ),
          onPressed: state.busy ? null : _submit,
          child: AppText(
            state.profile == null
                ? 'Открыть и рассчитать'
                : 'Открыть poe.ninja',
          ),
        ),
      ],
    ),
  );
}
