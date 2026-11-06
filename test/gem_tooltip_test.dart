import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/game_catalog_repository.dart';
import 'package:pob2_ui/domain/build_report.dart';
import 'package:pob2_ui/ui/core/frosted_surface.dart';
import 'package:pob2_ui/ui/core/spark_theme.dart';
import 'package:pob2_ui/ui/gem_medallion.dart';

import 'support/editor_fakes.dart';

class TooltipEngine extends EditorCatalogEngine {
  TooltipEngine() {
    tools = {...tools, 'pob_gem_tooltip'};
  }
  final descriptions = <JsonMap>[];
  Completer<JsonMap>? pending;
  @override
  Future<JsonMap> call(String name, [JsonMap arguments = const {}]) async {
    if (name != 'pob_gem_tooltip') return super.call(name, arguments);
    descriptions.add(arguments);
    if (pending case final value?) return value.future;
    return response;
  }

  static const response = {
    'source': 'original-lua',
    'lines': [
      {'size': 20, 'text': '^x33FF77Fireball'},
      {'separator': true},
      {'size': 16, 'text': 'Fires a ball of flame.'},
    ],
  };
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Описание по наведению, скрытие и повторное чтение: $brightness',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(340, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final engine = TooltipEngine();
        await tester.pumpWidget(
          MaterialApp(
            theme: Spark.theme(brightness: brightness),
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomRight,
                child: GemMedallion(
                  id: 'fireball',
                  level: 5,
                  quality: 20,
                  repository: GameCatalogRepository(engine),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(engine.descriptions, isEmpty);
        final pointer = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await pointer.addPointer(location: Offset.zero);
        await pointer.moveTo(tester.getCenter(find.byType(GemMedallion)));
        await tester.pump(const Duration(milliseconds: 450));
        await tester.pumpAndSettle();
        expect(engine.descriptions.single, {
          'id': 'fireball',
          'level': 5,
          'quality': 20,
        });
        expect(find.byType(FrostedSurface), findsOneWidget);
        expect(
          find.text('Fires a ball of flame.', findRichText: true),
          findsOneWidget,
        );
        final card = tester.getRect(find.byType(FrostedSurface));
        expect(card.left, greaterThanOrEqualTo(0));
        expect(card.right, lessThanOrEqualTo(340));
        await pointer.moveTo(Offset.zero);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        expect(find.byType(FrostedSurface), findsNothing);
        await pointer.moveTo(tester.getCenter(find.byType(GemMedallion)));
        await tester.pump(const Duration(milliseconds: 450));
        await tester.pumpAndSettle();
        expect(engine.descriptions, hasLength(2));
        await pointer.removePointer();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Установленный камень передаёт группу, поздний ответ закрытой подсказки игнорируется',
    (tester) async {
      final engine = TooltipEngine()..pending = Completer<JsonMap>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GemMedallion(
                id: 'support',
                groupId: 2,
                sourceIndex: 3,
                level: 8,
                quality: 15,
                repository: GameCatalogRepository(engine),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      await pointer.moveTo(tester.getCenter(find.byType(GemMedallion)));
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump();
      expect(engine.descriptions.single, {'groupId': 2, 'sourceIndex': 3});
      await tester.pumpWidget(const SizedBox.shrink());
      engine.pending!.complete(TooltipEngine.response);
      await tester.pumpAndSettle();
      await pointer.removePointer();
      expect(tester.takeException(), isNull);
    },
  );
}
