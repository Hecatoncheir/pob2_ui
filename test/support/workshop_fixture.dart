import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/tree_geometry.dart';

final fixture = BuildReport.fromJson({
  'source': 'original-lua',
  'snapshot': {
    'buildInfo': {
      'name': 'Проверка отображения',
      'class': 'Witch',
      'level': 90,
      'groups': {'entries': [], 'selected': 1},
      'skills': {'entries': [], 'selected': 1},
    },
  },
  'stats': {
    'Life': 1187,
    'Mana': 441,
    'EnergyShield': 0,
    'Spirit': 100,
    'TotalDPS': 124.83,
  },
  'groups': [
    {
      'id': 1,
      'label': 'Огненный шар',
      'enabled': true,
      'gems': [
        {'name': 'Fireball', 'level': 20, 'quality': 0},
      ],
    },
  ],
  'items': [
    {
      'id': 1,
      'name': 'Withered Wand',
      'raw': 'Rarity: Normal\nWithered Wand',
      'unsupported': [],
    },
  ],
  'slots': [
    {'name': 'Weapon 1', 'itemId': 1, 'active': true},
  ],
  'config': {'enemyIsBoss': 'Pinnacle'},
  'warnings': ['Недостаточно интеллекта'],
});
final tree = TreeGeometry.fromJson({
  'version': '0_5',
  'nodes': [
    {
      'id': 1,
      'x': 0,
      'y': 0,
      'name': 'Начало',
      'type': 'ClassStart',
      'allocated': true,
    },
    {
      'id': 2,
      'x': 100,
      'y': 100,
      'name': 'Узел',
      'type': 'Normal',
      'allocated': false,
    },
  ],
  'edges': [
    [1, 2],
  ],
});
