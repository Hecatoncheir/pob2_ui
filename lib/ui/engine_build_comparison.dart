import 'package:material_ui/material_ui.dart';

import '../domain/build_report.dart';
import '../domain/engine_session.dart';
import '../domain/item_comparison.dart';
import 'core/app_text.dart';
import 'item_comparison_panel.dart';

final _statLabels = {
  for (final group in statGroups.values) ...group,
  'TotalDPS': 'DPS умения',
  'FullDPS': 'Суммарный DPS',
  'TotalEHP': 'Эффективное здоровье',
};

class EngineBuildComparisonPanel extends StatelessWidget {
  const EngineBuildComparisonPanel(
    this.preview, {
    required this.fresh,
    super.key,
  });
  final EngineBuildComparison preview;
  final bool fresh;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!fresh) const AppText('Выполните предпросмотр для текущей ревизии'),
        ItemComparisonPanel(
          ItemComparison(
            revision: preview.revision,
            rows: [
              for (final delta in preview.deltas)
                if (_statLabels[delta.name] case final label?)
                  _row(label, delta),
            ],
          ),
        ),
        _warnings('Было', preview.before.warnings),
        _warnings('Стало', preview.after.warnings),
      ],
    ),
  );

  ItemComparisonRow _row(String label, EngineStatDelta delta) {
    final percent = delta.name.endsWith('Resist') ? '%' : '';
    final changed = delta.difference.abs() >= .005;
    final sign = delta.difference > 0 ? '+' : '';
    return ItemComparisonRow(
      id: delta.name,
      label: label,
      before: formatStat(delta.before, suffix: percent, fractionDigits: 2),
      after: formatStat(delta.after, suffix: percent, fractionDigits: 2),
      change: changed
          ? '$sign${formatStat(delta.difference, suffix: percent, fractionDigits: 2)}'
          : null,
    );
  }

  Widget _warnings(String label, List<String> warnings) => warnings.isEmpty
      ? const SizedBox.shrink()
      : Wrap(
          spacing: 8,
          children: [
            AppText(label),
            for (final warning in warnings) AppText(warning, localize: false),
          ],
        );
}
