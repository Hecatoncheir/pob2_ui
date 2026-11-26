import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/build_card_appearance.dart';
import '../domain/library_entry.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'core/ui_translation.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';

Future<BuildCardAppearance?> showBuildCardAppearance(
  BuildContext context,
  WorkshopCubit model,
  LibraryEntry entry,
) => sparkDialog<BuildCardAppearance>(
  context,
  _BuildCardAppearanceDialog(model: model, entry: entry),
);

class _BuildCardAppearanceDialog extends StatefulWidget {
  const _BuildCardAppearanceDialog({required this.model, required this.entry});

  final WorkshopCubit model;
  final LibraryEntry entry;

  @override
  State<_BuildCardAppearanceDialog> createState() =>
      _BuildCardAppearanceDialogState();
}

class _BuildCardAppearanceDialogState
    extends State<_BuildCardAppearanceDialog> {
  late BuildCardAppearance _appearance = widget.entry.appearance;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const AppText('Оформление карточки'),
    scrollable: true,
    content: SizedBox(
      width: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _preview(),
          const SizedBox(height: 20),
          const AppText('Иконка'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: BuildCardIcon.values.map(_iconChoice).toList(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              const AppText('Цвет подсветки'),
              AppText(
                _appearance.color._label,
                style: TextStyle(color: Spark.of(context).muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: BuildCardColor.values.map(_colorChoice).toList(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const AppText('Отмена'),
      ),
      BlocSelector<WorkshopCubit, WorkshopState, bool>(
        bloc: widget.model,
        selector: (state) => state.busy,
        builder: (context, busy) => FilledButton(
          onPressed: busy || _appearance == widget.entry.appearance
              ? null
              : () => Navigator.of(context).pop(_appearance),
          child: const AppText('Сохранить'),
        ),
      ),
    ],
  );

  Widget _preview() => SurfacePanel(
    accent: _appearance.color.accent,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    child: Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Center(child: BuildCardIconArt(_appearance, size: 36)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            widget.entry.title,
            localize: false,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _iconChoice(BuildCardIcon icon) => ChoiceChip(
    key: ValueKey('build-icon-${icon.name}'),
    avatar: BuildCardIconArt(BuildCardAppearance(icon: icon), size: 18),
    label: AppText(icon._label),
    selected: _appearance.icon == icon,
    onSelected: (_) => setState(() {
      _appearance = BuildCardAppearance(icon: icon, color: _appearance.color);
    }),
  );

  Widget _colorChoice(BuildCardColor color) {
    final selected = _appearance.color == color;
    final label = translateUi(context, color._label);
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: ChoiceChip(
        key: ValueKey('build-color-${color.name}'),
        label: Semantics(label: label, child: _swatch(color.accent, selected)),
        labelPadding: EdgeInsets.zero,
        showCheckmark: false,
        selected: selected,
        onSelected: (_) => setState(() {
          _appearance = BuildCardAppearance(
            icon: _appearance.icon,
            color: color,
          );
        }),
      ),
    );
  }

  Widget _swatch(Color? color, bool selected) {
    final symbol = selected ? Icons.check_rounded : Icons.block_outlined;
    final foreground = color == null ? Spark.of(context).muted : Colors.black87;
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 24,
        child: Icon(
          selected || color == null ? symbol : null,
          size: 16,
          color: foreground,
        ),
      ),
    );
  }
}

class BuildCardIconArt extends StatelessWidget {
  const BuildCardIconArt(this.appearance, {super.key, required this.size});

  final BuildCardAppearance appearance;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ink = Spark.of(context).ink;
    final accent = appearance.color.accent;
    final color = accent == null
        ? ink
        : Color.alphaBlend(accent.withValues(alpha: .65), ink);
    return switch (appearance.icon) {
      BuildCardIcon.gem => SparkArt(
        size > 24 ? 'illustrations/gem' : 'icons/gem',
        width: size,
        color: color,
      ),
      BuildCardIcon.sword => SparkArt('icons/sword', width: size, color: color),
      BuildCardIcon.shield => SparkArt(
        'icons/shield',
        width: size,
        color: color,
      ),
      BuildCardIcon.bow => Icon(
        Icons.gps_fixed_rounded,
        size: size,
        color: color,
      ),
      BuildCardIcon.fire => Icon(
        Icons.local_fire_department_outlined,
        size: size,
        color: color,
      ),
      BuildCardIcon.frost => Icon(
        Icons.ac_unit_rounded,
        size: size,
        color: color,
      ),
      BuildCardIcon.lightning => Icon(
        Icons.bolt_rounded,
        size: size,
        color: color,
      ),
      BuildCardIcon.minion => Icon(
        Icons.pets_outlined,
        size: size,
        color: color,
      ),
    };
  }
}

extension on BuildCardIcon {
  String get _label => switch (this) {
    BuildCardIcon.gem => 'Самоцвет',
    BuildCardIcon.sword => 'Меч',
    BuildCardIcon.shield => 'Щит',
    BuildCardIcon.bow => 'Стрельба',
    BuildCardIcon.fire => 'Огонь',
    BuildCardIcon.frost => 'Холод',
    BuildCardIcon.lightning => 'Молния',
    BuildCardIcon.minion => 'Приспешник',
  };
}

extension BuildCardAccent on BuildCardColor {
  Color? get accent => switch (this) {
    BuildCardColor.none => null,
    BuildCardColor.gold => const Color(0xFFCF9D37),
    BuildCardColor.red => const Color(0xFFD86C64),
    BuildCardColor.green => const Color(0xFF6AAA61),
    BuildCardColor.blue => const Color(0xFF699CD9),
    BuildCardColor.purple => const Color(0xFFAA83D5),
    BuildCardColor.teal => const Color(0xFF47A89D),
  };

  String get _label => switch (this) {
    BuildCardColor.none => 'Без подсветки',
    BuildCardColor.gold => 'Золотой',
    BuildCardColor.red => 'Красный',
    BuildCardColor.green => 'Зелёный',
    BuildCardColor.blue => 'Синий',
    BuildCardColor.purple => 'Фиолетовый',
    BuildCardColor.teal => 'Бирюзовый',
  };
}
