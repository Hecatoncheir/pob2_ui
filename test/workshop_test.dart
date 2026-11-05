import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/mcp_client.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/domain/tree_geometry.dart';
import 'package:pob2_ui/ui/app.dart';
import 'package:pob2_ui/ui/workshop_cubit.dart';
import 'package:pob2_ui/ui/workshop_state.dart';

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

void main() {
  for (final size in const [
    Size(360, 800),
    Size(768, 850),
    Size(1366, 768),
    Size(1920, 1080),
  ]) {
    testWidgets('Новая навигация без переполнения: ${size.width}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(Directory('test-components')),
        ),
        McpClient(),
      );
      addTearDown(model.close);
      await tester.pumpWidget(PobApp(model: model));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ваша следующая сборка'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('page-components')));
      await tester.pumpAndSettle();
      expect(find.text('Проверить обновления'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('page-library')));
      await tester.pumpAndSettle();
      expect(find.text('Здесь будут ваши сборки'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Отчёт, предупреждения и пять разделов: ${size.width}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = WorkshopCubit(
        ComponentRepository(
          store: InstallationStore(Directory('test-components')),
        ),
        McpClient(),
        initialState: WorkshopState(
          document: (
            report: fixture,
            tree: tree,
            stale: false,
            treeError: null,
          ),
        ),
      );
      addTearDown(model.close);
      await tester.pumpWidget(PobApp(model: model));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Предупреждения: 1'), findsOneWidget);
      await tester.tap(find.text('Предупреждения: 1'));
      await tester.pumpAndSettle();
      expect(find.text('Недостаточно интеллекта'), findsOneWidget);
      await tester.tap(find.text('Закрыть'));
      await tester.pumpAndSettle();
      for (final tab in [
        'Предметы',
        'Умения',
        'Условия',
        'Расчёты',
        'Дерево',
      ]) {
        final finder = find.text(tab).first;
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
