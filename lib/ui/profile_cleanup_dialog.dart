import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mcp_error_message.dart';
import '../data/profile_cleanup.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'workshop_cubit.dart';

Future<void> showProfileCleanup(BuildContext context, WorkshopCubit model) =>
    sparkDialog<void>(
      context,
      BlocProvider(
        create: (_) => _CleanupCubit(model)..scan(),
        child: const _ProfileCleanupDialog(),
      ),
    );

sealed class _CleanupState {
  const _CleanupState();
}

class _Scanning extends _CleanupState {
  const _Scanning();
}

class _Selection extends _CleanupState {
  const _Selection(this.entries, this.selected);
  final List<CleanupEntry> entries;
  final Set<CleanupEntry> selected;
  int get bytes => selected.fold(0, (sum, entry) => sum + entry.bytes);
}

class _Cleaning extends _CleanupState {
  const _Cleaning();
}

class _Complete extends _CleanupState {
  const _Complete(this.result);
  final CleanupResult result;
}

class _Failed extends _CleanupState {
  const _Failed(this.message);
  final String message;
}

class _CleanupCubit extends Cubit<_CleanupState> {
  _CleanupCubit(this.model) : super(const _Scanning());
  final WorkshopCubit model;

  Future<void> scan() async {
    try {
      final entries = await model.components.profileCleanup.preview();
      if (!isClosed) emit(_Selection(entries, Set.unmodifiable(entries)));
    } catch (_) {
      if (!isClosed) emit(const _Failed('Не удалось проверить профиль.'));
    }
  }

  void select(CleanupEntry entry, bool enabled) {
    if (state case _Selection(:final entries, :final selected)) {
      final next = {...selected};
      if (enabled) {
        next.add(entry);
      } else {
        next.remove(entry);
      }
      emit(_Selection(entries, Set.unmodifiable(next)));
    }
  }

  Future<void> clean() async {
    if (state case _Selection(:final selected) when selected.isNotEmpty) {
      emit(const _Cleaning());
      try {
        final result = await model.cleanProfile(selected);
        if (!isClosed) emit(_Complete(result));
      } catch (error) {
        if (!isClosed) emit(_Failed(mcpErrorMessage(error)));
      }
    }
  }
}

class _ProfileCleanupDialog extends StatelessWidget {
  const _ProfileCleanupDialog();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<_CleanupCubit, _CleanupState>(
        builder: (context, state) {
          final cubit = context.read<_CleanupCubit>();
          return PopScope(
            canPop: state is! _Cleaning,
            child: AlertDialog(
              title: const AppText('Предпросмотр очистки профиля'),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(child: _content(state, cubit)),
              ),
              actions: _actions(context, state, cubit),
            ),
          );
        },
      );

  List<Widget> _actions(
    BuildContext context,
    _CleanupState state,
    _CleanupCubit cubit,
  ) => [
    if (state is! _Cleaning) const DialogCloseButton(),
    if (state is _Selection && state.entries.isNotEmpty)
      FilledButton(
        onPressed:
            state.selected.isEmpty || cubit.model.components.profileUse == null
            ? null
            : () => _confirm(context, cubit, state.bytes),
        child: const AppText('Очистить выбранное'),
      ),
  ];

  Widget _content(_CleanupState state, _CleanupCubit cubit) => switch (state) {
    _Scanning() => const AppText('Проверяем профиль…'),
    _Selection() => _entries(state, cubit),
    _Cleaning() => const AppText('Очищаем профиль…'),
    _Complete(:final result) => _summary(result),
    _Failed(:final message) => AppText(message),
  };

  Widget _entries(_Selection state, _CleanupCubit cubit) {
    if (state.entries.isEmpty) return const AppText('Нет данных для очистки.');
    final total = state.entries.fold(0, (sum, entry) => sum + entry.bytes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText('Доступно для очистки: $total байт'),
        const SizedBox(height: 12),
        for (final entry in state.entries)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(entry.relativePath),
            subtitle: AppText('${entry.bytes} байт'),
            value: state.selected.contains(entry),
            onChanged: (value) => cubit.select(entry, value == true),
          ),
      ],
    );
  }

  Widget _summary(CleanupResult result) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      AppText('Удалено: ${result.bytes} байт'),
      for (final MapEntry(:key, :value) in result.skipped.entries)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(key),
          subtitle: AppText(value),
        ),
    ],
  );

  Future<void> _confirm(
    BuildContext context,
    _CleanupCubit cubit,
    int bytes,
  ) async {
    final approved = await sparkDialog<bool>(
      context,
      AlertDialog(
        title: const AppText('Очистить профиль?'),
        content: AppText('Будут удалены выбранные файлы объёмом $bytes байт.'),
        actions: [
          const DialogCloseButton(label: 'Отмена'),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const AppText('Подтвердить очистку'),
          ),
        ],
      ),
    );
    if (context.mounted && approved == true) await cubit.clean();
  }
}
