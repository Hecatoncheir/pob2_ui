import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/original_tree_scene.dart';
import 'package:pob2_ui/ui/attribute_picker.dart';
import 'package:pob2_ui/ui/original_tree_artwork.dart';

Future<ui.Image> _whiteImage() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(Colors.white, ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(1, 1);
  picture.dispose();
  return image;
}

Map<String, dynamic> _rectangle(double start, double end, List<double> color) =>
    {
      'texture': 'solid',
      'positions': [start, start, end, start, end, end, start, end],
      'uv': [0, 0, 1, 0, 1, 1, 0, 1],
      'color': color,
      'blend': 'ALPHA',
      'clamp': true,
    };

void main() {
  testWidgets('Фон сцены прозрачен, остальные команды PoB сохранены', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final image = await _whiteImage();
      final scene = OriginalTreeScene.fromJson({
        'width': 100,
        'height': 100,
        'scale': 1,
        'offsetX': 0,
        'offsetY': 0,
        'commands': [
          _rectangle(0, 100, [8 / 255, 12 / 255, 17 / 255, 1]),
          _rectangle(40, 60, [1, 0, 0, 1]),
        ],
      });
      final artwork = OriginalTreeArtwork(scene, {'solid': image});
      final output = await artwork.picture.toImage(100, 100);
      final pixels = (await output.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      expect(_pixel(pixels, 10, 10), [0, 0, 0, 0]);
      expect(_pixel(pixels, 50, 50), [255, 0, 0, 255]);
      output.dispose();
      artwork.dispose();
      image.dispose();
    });
  });

  testWidgets('Атрибуты идут горизонтально и передают Lua индексы 1–3', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: StatefulBuilder(
                builder: (context, setState) => AttributePicker(
                  options: [
                    for (final name in [
                      'Strength',
                      'Dexterity',
                      'Intelligence',
                    ])
                      {'id': 39037, 'name': name},
                  ],
                  value: selected,
                  onChanged: (value) => setState(() => selected = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final positions = [
      for (var index = 1; index <= 3; index++)
        tester.getCenter(find.byKey(ValueKey('attribute-$index'))),
    ];
    expect(positions.map((point) => point.dy).toSet(), hasLength(1));
    expect(positions[0].dx, lessThan(positions[1].dx));
    expect(positions[1].dx, lessThan(positions[2].dx));
    for (var index = 1; index <= 3; index++) {
      await tester.tap(find.byKey(ValueKey('attribute-$index')));
      await tester.pumpAndSettle();
      expect(selected, index);
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(DropdownButtonFormField<int>), findsNothing);
  });
}

List<int> _pixel(ByteData pixels, int x, int y) => [
  for (var channel = 0; channel < 4; channel++)
    pixels.getUint8((y * 100 + x) * 4 + channel),
];
