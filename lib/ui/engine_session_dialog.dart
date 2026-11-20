import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/engine_session.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'engine_session_cubit.dart';
import 'engine_session_view.dart';
import 'workshop_cubit.dart';

Future<void> showEngineSession(
  BuildContext context,
  WorkshopCubit model,
) async {
  await sparkDialog<void>(context, _EngineSessionDialog(model));
}

class _EngineSessionDialog extends StatefulWidget {
  const _EngineSessionDialog(this.model);
  final WorkshopCubit model;
  @override
  State<_EngineSessionDialog> createState() => _EngineSessionDialogState();
}

class _EngineSessionDialogState extends State<_EngineSessionDialog> {
  final executable = TextEditingController();
  final profile = TextEditingController();
  final session = TextEditingController();
  final name = TextEditingController();
  bool create = false;
  bool bind = false;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final options = widget.model.engineSession.state.options;
    executable.text =
        Platform.environment['POB2_ENGINE_EXECUTABLE'] ?? options.executable;
    profile.text = options.profile;
    session.text = options.sessionId;
    name.text = widget.model.state.library.active?.title ?? 'Новая сборка';
    bind = widget.model.state.library.activeId != null;
  }

  @override
  void dispose() {
    for (final controller in [executable, profile, session, name]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _choose() async {
    final file = await openFile(confirmButtonText: 'Выбрать движок');
    if (file != null && mounted) setState(() => executable.text = file.path);
  }

  Future<void> _connect() async {
    setState(() {
      busy = true;
      error = null;
    });
    final previous = widget.model.engineSession.state.options;
    try {
      await widget.model.connectEngine(
        EngineOptions(
          executable: executable.text.trim(),
          profile: profile.text.trim(),
          sessionId: session.text.trim(),
          runtimeDirectory: previous.runtimeDirectory,
          dataDirectory: previous.dataDirectory,
        ),
        createName: create ? name.text.trim() : null,
        bindCurrentBuild: bind,
      );
      if (mounted) Navigator.pop(context);
    } catch (failure) {
      if (mounted) setState(() => error = engineError(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const AppText('Общая сессия Go'),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'CLI, MCP и приложение видят одну сессию. Сейчас синхронизируется название; игровые расчёты выполняет Lua.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _field(
                    executable,
                    'Программа pob2-engine',
                    'engine-executable',
                  ),
                ),
                IconButton(
                  onPressed: busy ? null : _choose,
                  tooltip: 'Выбрать программу',
                  icon: const Icon(Icons.folder_open),
                ),
              ],
            ),
            _field(profile, 'Профиль сервера', 'engine-profile'),
            _field(session, 'Идентификатор сессии', 'engine-session-id'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const AppText('Создать новую сессию'),
              value: create,
              onChanged: busy
                  ? null
                  : (value) => setState(() => create = value ?? false),
            ),
            if (create) _field(name, 'Название сборки', 'engine-create-name'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const AppText('Связать с открытой сборкой'),
              subtitle: const AppText(
                'Имя общей сессии будет сохранено в открытой сборке. При смене сборки привязка отключится.',
              ),
              value: bind,
              onChanged: _bindCallback(),
            ),
            if (error case final message?)
              AppText(
                message,
                localize: false,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 12),
            EngineSessionHistory(cubit: widget.model.engineSession),
          ],
        ),
      ),
    ),
    actions: _actions(context),
  );

  ValueChanged<bool?>? _bindCallback() {
    if (busy || widget.model.state.library.activeId == null) return null;
    return (value) => setState(() => bind = value ?? false);
  }

  Widget _field(TextEditingController controller, String label, String key) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          key: Key(key),
          controller: controller,
          enabled: !busy,
          decoration: InputDecoration(labelText: label),
        ),
      );

  List<Widget> _actions(BuildContext context) => [
    if (widget.model.engineSession.state.snapshot != null)
      TextButton(
        onPressed: busy
            ? null
            : () async {
                await widget.model.disconnectEngine();
                if (context.mounted) Navigator.pop(context);
              },
        child: const AppText('Отключить'),
      ),
    const DialogCloseButton(),
    FilledButton(
      key: const Key('engine-connect'),
      onPressed: busy ? null : _connect,
      child: AppText(busy ? 'Подключение…' : 'Подключить'),
    ),
  ];
}
