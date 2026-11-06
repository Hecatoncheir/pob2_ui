export 'skills_view.dart';
export 'conditions_view.dart';

import 'core/dialog_close_button.dart';
import 'core/app_text.dart';

import 'package:flutter/material.dart';

import '../domain/build_report.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';

const slotLabels = {
  'Weapon 1': 'Оружие',
  'Weapon 2': 'Левая рука',
  'Helmet': 'Голова',
  'Body Armour': 'Нагрудник',
  'Gloves': 'Перчатки',
  'Boots': 'Обувь',
  'Amulet': 'Амулет',
  'Ring 1': 'Кольцо I',
  'Ring 2': 'Кольцо II',
  'Belt': 'Пояс',
};

class ItemsView extends StatelessWidget {
  const ItemsView({super.key, required this.report});
  final BuildReport report;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const SectionHeading(
        'Снаряжение',
        subtitle: 'Предметы и активные слоты из Lua',
      ),
      ...report.slots
          .where((slot) => slot['active'] != false)
          .map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ItemSlot(
                slot: slot,
                item: report.items
                    .where((item) => item['id'] == slot['itemId'])
                    .firstOrNull,
              ),
            ),
          ),
    ],
  );
}

class _ItemSlot extends StatelessWidget {
  const _ItemSlot({required this.slot, this.item});
  final JsonMap slot;
  final JsonMap? item;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.all(16),
    child: InkWell(
      onTap: item == null ? null : () => _details(context),
      child: Row(
        children: [
          const SparkArt('icons/sword', width: 25),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  slotLabels[slot['name']] ?? '${slot['name']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                AppText(
                  item == null ? 'Пусто' : '${item!['name']}',
                  game: true,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: item == null
                        ? Spark.of(context).muted
                        : Spark.of(context).ink,
                  ),
                ),
              ],
            ),
          ),
          if (item != null) const SparkArt('icons/chevron', width: 15),
        ],
      ),
    ),
  );
  void _details(BuildContext context) => sparkDialog<void>(
    context,
    AlertDialog(
      title: AppText('${item!['name']}', game: true),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                '${item!['raw']}',
                style: Spark.mono.copyWith(fontSize: 12),
              ),
              ...jsonRows(item!['unsupported']).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AppText(
                    'Не распознано: ${line['line']}',
                    style: TextStyle(color: Spark.of(context).danger),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [const DialogCloseButton(label: 'Закрыть')],
    ),
  );
}
