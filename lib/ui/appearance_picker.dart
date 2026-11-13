import 'core/app_text.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/appearance.dart';
import 'appearance_bloc.dart';

class AppearancePicker extends StatelessWidget {
  const AppearancePicker({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AppearanceBloc, AppearanceState>(
    builder: (context, state) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppText('Тема', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) =>
              _selector(context, state, constraints.maxWidth >= 300),
        ),
        if (state.error != null) ...[
          const SizedBox(height: 8),
          AppText(
            'Не удалось сохранить тему.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(
            onPressed: () =>
                context.read<AppearanceBloc>().add(ThemeSelected(state.theme)),
            child: const AppText('Повторить'),
          ),
        ],
      ],
    ),
  );
  Widget _selector(
    BuildContext context,
    AppearanceState state,
    bool icons,
  ) => SegmentedButton<AppTheme>(
    style: SegmentedButton.styleFrom(
      textStyle: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 12),
    ),
    segments: [
      ButtonSegment(
        value: AppTheme.system,
        label: const AppText('Системная'),
        icon: icons ? const Icon(Icons.settings_brightness, size: 18) : null,
      ),
      ButtonSegment(
        value: AppTheme.light,
        label: const AppText('Светлая'),
        icon: icons ? const Icon(Icons.light_mode_outlined, size: 18) : null,
      ),
      ButtonSegment(
        value: AppTheme.dark,
        label: const AppText('Тёмная'),
        icon: icons ? const Icon(Icons.dark_mode_outlined, size: 18) : null,
      ),
    ],
    selected: {state.theme},
    showSelectedIcon: false,
    onSelectionChanged: (values) =>
        context.read<AppearanceBloc>().add(ThemeSelected(values.single)),
  );
}
