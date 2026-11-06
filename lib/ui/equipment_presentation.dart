import 'package:flutter/material.dart';

import '../domain/build_report.dart';
import 'core/spark_art.dart';

const equipmentLabels = {
  'Weapon 1': 'Оружие',
  'Weapon 2': 'Левая рука',
  'Weapon 1 Swap': 'Оружие II',
  'Weapon 2 Swap': 'Левая рука II',
  'Helmet': 'Шлем',
  'Body Armour': 'Нагрудник',
  'Gloves': 'Перчатки',
  'Boots': 'Обувь',
  'Amulet': 'Амулет',
  'Ring 1': 'Кольцо I',
  'Ring 2': 'Кольцо II',
  'Ring 3': 'Кольцо III',
  'Belt': 'Пояс',
  'Flask 1': 'Флакон здоровья',
  'Flask 2': 'Флакон маны',
  'Charm 1': 'Оберег I',
  'Charm 2': 'Оберег II',
  'Charm 3': 'Оберег III',
};

String equipmentLabel(String slot) => equipmentLabels[slot] ?? slot;

class EquipmentIcon extends StatelessWidget {
  const EquipmentIcon(
    this.slot, {
    super.key,
    required this.color,
    required this.size,
  });
  final String slot;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => switch (slot) {
    'Helmet' => SparkArt('icons/helmet', width: size, color: color),
    'Boots' => SparkArt('icons/boots', width: size, color: color),
    'Body Armour' => SparkArt('icons/chest-armour', width: size, color: color),
    _ => Icon(_equipmentIcon(slot), color: color, size: size),
  };
}

IconData _equipmentIcon(String slot) => switch (slot) {
  'Weapon 1' || 'Weapon 1 Swap' => Icons.gavel_outlined,
  'Weapon 2' || 'Weapon 2 Swap' => Icons.shield_outlined,
  'Gloves' => Icons.back_hand_outlined,
  'Amulet' => Icons.diamond_outlined,
  'Belt' => Icons.horizontal_split_outlined,
  'Flask 1' || 'Flask 2' => Icons.science_outlined,
  _ => Icons.trip_origin,
};

List<JsonMap> equipmentSlots(BuildReport report) => report.slots
    .where((slot) => slot['nodeId'] == null && slot['visible'] != false)
    .toList(growable: false);
