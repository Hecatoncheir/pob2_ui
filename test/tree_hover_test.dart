import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/domain/node_preview.dart';
import 'package:pob2_ui/ui/tree_hover_cubit.dart';

NodePreview preview(int id) => NodePreview(
  tooltip: {
    'lines': [
      {'text': 'Свойства $id'},
      {'text': 'Tip: Hold Shift'},
    ],
    'path': [id],
  },
);

void main() {
  test('Пустые блоки не оставляют повторные или крайние разделители', () {
    final value = NodePreview(
      tooltip: {
        'lines': [
          {'separator': true},
          {'text': ''},
          {'text': 'Первый блок'},
          {'separator': true},
          {'text': '   '},
          {'separator': true},
          {'text': 'Tip: Hold Ctrl'},
          {'separator': true},
          {'text': 'Второй блок'},
          {'separator': true},
        ],
      },
    );
    expect(value.lines, [
      {'text': 'Первый блок'},
      {'separator': true},
      {'text': 'Второй блок'},
    ]);
  });
  test('Запоздавший ответ не подменяет подсказку нового узла', () async {
    final first = Completer<NodePreview>(), second = Completer<NodePreview>();
    final cubit = TreeHoverCubit(
      (id) => id == 1 ? first.future : second.future,
      delay: Duration.zero,
    );
    addTearDown(cubit.close);
    cubit.hover(1);
    await Future<void>.delayed(Duration.zero);
    cubit.hover(2);
    await Future<void>.delayed(Duration.zero);
    second.complete(preview(2));
    await Future<void>.delayed(Duration.zero);
    first.complete(preview(1));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.id, 2);
    expect(cubit.state.preview!.path, [2]);
    expect(cubit.state.preview!.lines, hasLength(1));
    cubit.clear();
    expect(cubit.state.preview, isNull);
  });
  test('Уход с узла отменяет запрос до задержки', () async {
    var calls = 0;
    final cubit = TreeHoverCubit((id) async {
      calls++;
      return preview(id);
    });
    cubit.hover(1);
    cubit.clear();
    await cubit.close();
    expect(calls, 0);
  });
}
