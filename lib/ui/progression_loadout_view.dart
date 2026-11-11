import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';
import '../domain/progression_comparison.dart';
import '../domain/progression_loadout_change.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'equipment_presentation.dart';
import 'gem_tooltip.dart';
import 'item_description.dart';
import 'progression_comparison_bloc.dart';

class ProgressionLoadoutView extends StatelessWidget {
  const ProgressionLoadoutView(this.comparison, {super.key});
  final ProgressionComparison comparison;

  @override
  Widget build(BuildContext context) {
    final gems = comparison.gems;
    final items = comparison.equipment;
    return Column(
      children: [
        _section(context, 'Изменения умений', Icons.diamond_outlined, [
          for (final change in gems) _gemChange(context, change),
        ]),
        _section(context, 'Изменения экипировки', Icons.shield_outlined, [
          if (_weaponSetChange() case final change?) change,
          for (final change in items) _itemChange(context, change),
        ]),
      ],
    );
  }

  Widget? _weaponSetChange() {
    final before = comparison.before.raw['weaponSet'];
    final after = comparison.after.raw['weaponSet'];
    if (before is! int || after is! int || before == after) return null;
    return _ChangeRow(
      label: 'Набор оружия',
      before: AppText(before == 1 ? 'Оружие I' : 'Оружие II'),
      after: AppText(after == 1 ? 'Оружие I' : 'Оружие II'),
    );
  }

  Widget _section(
    BuildContext context,
    String label,
    IconData icon,
    List<Widget> rows,
  ) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      leading: Icon(icon),
      title: Text('${translateUi(context, label)} · ${rows.length}'),
      children: rows,
    );
  }

  Widget _gemChange(BuildContext context, ProgressionGemChange change) {
    final gem = (change.after ?? change.before)!;
    return _ChangeRow(
      label: gem.group == gem.name ? null : gem.group,
      gameLabel: true,
      before: _gemSide(context, change.before),
      after: _gemSide(context, change.after),
    );
  }

  Widget? _gemSide(BuildContext context, ProgressionGem? gem) {
    if (gem == null) return null;
    final describe = context.read<ProgressionComparisonBloc>().describeGem;
    final id = gem.id;
    return _DescriptionButton(
      name: gem.name,
      details: Wrap(
        spacing: 6,
        runSpacing: 3,
        children: [
          AppText('Уровень ${gem.level}'),
          Text('${gem.quality} %'),
          if (!gem.enabled) const AppText('Отключено'),
          if (gem.main) const AppText('Основное умение'),
        ],
      ),
      open: id == null || describe == null
          ? null
          : () => _showDescription(
              context,
              gem.name,
              describe(
                id,
                gem.level,
                gem.quality,
              ).then(GemDescriptionLines.new),
            ),
    );
  }

  Widget _itemChange(BuildContext context, ProgressionItemChange change) =>
      _ChangeRow(
        label: change.nodeId == null
            ? equipmentLabel(change.slot)
            : '${translateUi(context, 'Самоцветы')} · #${change.nodeId}',
        before: _itemSide(context, change.before),
        after: _itemSide(context, change.after),
      );

  Widget? _itemSide(BuildContext context, ProgressionItem? item) {
    if (item == null) return null;
    final describe = context.read<ProgressionComparisonBloc>().describeItem;
    return _DescriptionButton(
      name: item.name,
      open: describe == null
          ? null
          : () => _showDescription(
              context,
              item.name,
              describe(item.raw).then(ItemDescription.new),
            ),
    );
  }
}

class ProgressionWarnings extends StatelessWidget {
  const ProgressionWarnings(this.comparison, {super.key});
  final ProgressionComparison comparison;

  @override
  Widget build(BuildContext context) {
    final warnings = comparison.after.warnings;
    if (warnings.isEmpty) return const SizedBox.shrink();
    final existing = comparison.before.warnings.toSet();
    final color = Theme.of(context).colorScheme.error;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      initiallyExpanded: warnings.any((warning) => !existing.contains(warning)),
      leading: Icon(Icons.warning_amber_rounded, color: color),
      title: AppText('Предупреждения · ${warnings.length}'),
      children: [
        for (final warning in warnings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppText(
              warning,
              game: true,
              style: TextStyle(
                color: existing.contains(warning) ? null : color,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({
    required this.before,
    required this.after,
    this.label,
    this.gameLabel = false,
  });
  final Widget? before;
  final Widget? after;
  final String? label;
  final bool gameLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label case final String text when text.isNotEmpty)
          AppText(
            text,
            game: gameLabel,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                label: translateUi(context, 'Было'),
                child: before ?? const Text('—'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(Icons.arrow_forward, size: 16),
            ),
            Expanded(
              child: Semantics(
                label: translateUi(context, 'Стало'),
                child: after ?? const Text('—'),
              ),
            ),
          ],
        ),
        const Divider(height: 8),
      ],
    ),
  );
}

class _DescriptionButton extends StatelessWidget {
  const _DescriptionButton({required this.name, this.details, this.open});
  final String name;
  final Widget? details;
  final VoidCallback? open;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (open == null)
        AppText(name, game: true)
      else
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: const Size(0, 32),
            alignment: AlignmentDirectional.centerStart,
          ),
          onPressed: open,
          child: AppText(name, game: true),
        ),
      if (details case final value?)
        DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodySmall,
          child: value,
        ),
    ],
  );
}

Future<void> _showDescription(
  BuildContext context,
  String title,
  Future<Widget> description,
) => sparkDialog<void>(
  context,
  Dialog(
    child: SizedBox(
      width: 480,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              title,
              game: true,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: FutureBuilder<Widget>(
                  future: description,
                  builder: (context, snapshot) => switch (snapshot) {
                    AsyncSnapshot(:final Widget data) => data,
                    AsyncSnapshot(:final Object error) => AppText(
                      mcpErrorMessage(error),
                    ),
                    _ => const LinearProgressIndicator(),
                  },
                ),
              ),
            ),
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DialogCloseButton(label: 'Закрыть'),
            ),
          ],
        ),
      ),
    ),
  ),
);
