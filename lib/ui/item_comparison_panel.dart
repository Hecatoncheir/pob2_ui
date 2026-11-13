import 'package:material_ui/material_ui.dart';

import '../domain/item_comparison.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'core/pob_text.dart';

const _important = {
  'FullDPS',
  'TotalDPS',
  'Life',
  'Mana',
  'EnergyShield',
  'Armour',
  'Evasion',
  'FireResist',
  'ColdResist',
  'LightningResist',
  'ChaosResist',
};

class ItemComparisonPanel extends StatelessWidget {
  const ItemComparisonPanel(this.comparison, {super.key});
  final ItemComparison comparison;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppText(
          'Примерка',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        const SizedBox(height: 12),
        if (comparison.reason case final reason?)
          AppText(reason)
        else ...[
          const Row(
            children: [
              Expanded(
                flex: 3,
                child: AppText('Показатель', style: TextStyle(fontSize: 12)),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  'Было',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  'Стало',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          for (final row in comparison.rows.where(_visible)) _row(row),
          if (comparison.rows.every((row) => row.change == null))
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: AppText('Показатели не изменятся'),
            ),
          const SizedBox(height: 10),
          const AppText(
            'Сборка изменится после нажатия «Применить»',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ],
    ),
  );

  bool _visible(ItemComparisonRow row) =>
      row.change != null ||
      (row.actor == 'player' && _important.contains(row.id));

  Widget _row(ItemComparisonRow row) => Padding(
    key: ValueKey('comparison-${row.actor}-${row.id}'),
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppText(
                row.actor == 'minion' ? 'Приспешник · ${row.label}' : row.label,
                game: true,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: PoBText(
                row.before ?? '—',
                size: 12,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: PoBText(
                row.after ?? '—',
                size: 12,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        if (row.change case final change?)
          PoBText(change, size: 12, textAlign: TextAlign.end),
      ],
    ),
  );
}
