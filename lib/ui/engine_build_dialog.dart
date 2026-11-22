import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/engine_session.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'engine_session_cubit.dart';
import 'workshop_cubit.dart';

Future<void> showEngineBuild(BuildContext context, WorkshopCubit model) =>
    sparkDialog<void>(context, _EngineBuildDialog(model));

class _EngineBuildDialog extends StatefulWidget {
  const _EngineBuildDialog(this.model);
  final WorkshopCubit model;

  @override
  State<_EngineBuildDialog> createState() => _EngineBuildDialogState();
}

class _EngineBuildDialogState extends State<_EngineBuildDialog> {
  EngineSessionCubit get _session => widget.model.engineSession;
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
    } catch (error) {
      if (mounted) setState(() => _error = engineError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editLevel(EngineSnapshot snapshot, int current) async {
    final selected = await sparkDialog<int>(
      context,
      _EngineLevelDialog(current),
    );
    if (!mounted || selected == null || selected == current) return;
    await _run(() => _session.setLevel(snapshot, selected));
  }

  Future<void> _export(EngineSnapshot snapshot, EngineBuild build) =>
      _run(() async {
        await widget.model.files.save(
          build.xml,
          snapshot.buildName,
          beforeSave: widget.model.sharedLibrary?.checkExport,
        );
      });

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EngineSessionCubit, EngineSessionState>(
        bloc: _session,
        builder: (context, state) {
          final snapshot = state.snapshot;
          final build = snapshot?.build;
          if (snapshot == null || build == null) {
            return const AlertDialog(
              content: AppText('В общей сессии нет XML сборки'),
              actions: [DialogCloseButton()],
            );
          }
          return _dialog(snapshot, build, state);
        },
      );

  Widget _dialog(
    EngineSnapshot snapshot,
    EngineBuild build,
    EngineSessionState state,
  ) {
    final canChange = state.connected && !_busy;
    return AlertDialog(
      title: AppText(snapshot.buildName, localize: false),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText('Ревизия ${snapshot.revision}'),
              AppText(
                'Уровень персонажа: ${build.level}',
                key: const Key('engine-build-level'),
              ),
              const SizedBox(height: 12),
              _EngineBuildResult(build.calculation),
              if (!state.connected) AppText(state.message, localize: false),
              if (_error case final message?)
                AppText(message, key: const Key('engine-build-error')),
              if (_busy) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
      actions: [
        const DialogCloseButton(),
        TextButton(
          onPressed: _busy ? null : () => _export(snapshot, build),
          child: const AppText('Сохранить XML'),
        ),
        TextButton(
          key: const Key('engine-edit-level'),
          onPressed: canChange ? () => _editLevel(snapshot, build.level) : null,
          child: const AppText('Изменить уровень'),
        ),
        FilledButton(
          key: const Key('engine-calculate'),
          onPressed: canChange
              ? () => _run(() => _session.calculate(snapshot))
              : null,
          child: const AppText('Рассчитать'),
        ),
      ],
    );
  }
}

class _EngineBuildResult extends StatelessWidget {
  const _EngineBuildResult(this.result);
  final EngineCalculation? result;

  @override
  Widget build(BuildContext context) {
    final calculation = result;
    if (calculation == null) {
      return const AppText('Для этой ревизии расчёта ещё нет');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(calculation.status),
        if (calculation.life case final life?)
          AppText(
            'Жизнь: ${life.toStringAsFixed(0)}',
            key: const Key('engine-build-life'),
          ),
        for (final warning in calculation.warnings)
          AppText(warning, localize: false),
      ],
    );
  }
}

class _EngineLevelDialog extends StatefulWidget {
  const _EngineLevelDialog(this.current);
  final int current;

  @override
  State<_EngineLevelDialog> createState() => _EngineLevelDialogState();
}

class _EngineLevelDialogState extends State<_EngineLevelDialog> {
  late int? _level = widget.current;
  bool get _valid => _level != null && _level! >= 1 && _level! <= 100;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const AppText('Уровень персонажа'),
    content: TextFormField(
      key: const Key('engine-level-input'),
      initialValue: '${widget.current}',
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(helperText: '1–100'),
      onChanged: (value) => setState(() => _level = int.tryParse(value.trim())),
      onFieldSubmitted: (_) {
        if (_valid) Navigator.pop(context, _level);
      },
    ),
    actions: [
      const DialogCloseButton(label: 'Отмена'),
      FilledButton(
        key: const Key('engine-save-level'),
        onPressed: _valid ? () => Navigator.pop(context, _level) : null,
        child: const AppText('Сохранить'),
      ),
    ],
  );
}
