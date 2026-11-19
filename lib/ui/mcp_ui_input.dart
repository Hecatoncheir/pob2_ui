import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../data/mcp_editor_gateway.dart';
import '../domain/build_report.dart';

class McpUiInput {
  McpUiInput(this.surface);
  final GlobalKey surface;
  int _pointer = 100000;

  Never _invalid() => throw const McpEditorFault(
    'INVALID_ARGUMENTS',
    'Действие или его параметры недоступны.',
  );

  Offset _point(Object? value) {
    final box = surface.currentContext?.findRenderObject() as RenderBox?;
    if (value case {'x': final num x, 'y': final num y}
        when x.isFinite && y.isFinite && box != null) {
      final point = Offset(x.toDouble(), y.toDouble());
      if ((Offset.zero & box.size).contains(point))
        return box.localToGlobal(point);
    }
    return _invalid();
  }

  void _send(PointerEvent event) =>
      GestureBinding.instance.handlePointerEvent(event);

  Future<void> gesture(JsonMap args) =>
      _withKeys(jsonStrings(args['modifiers']).map(_key), () => _gesture(args));

  Future<void> _gesture(JsonMap args) async {
    final from = _point(args['from']);
    final operation = args['operation'];
    if (operation == 'hover') {
      _send(PointerHoverEvent(position: from, kind: PointerDeviceKind.mouse));
      return;
    }
    if (operation == 'scroll') {
      final value = args['value'];
      if (value case {'x': final num x, 'y': final num y}
          when x.isFinite && y.isFinite) {
        _send(
          PointerScrollEvent(
            position: from,
            scrollDelta: Offset(x.toDouble(), y.toDouble()),
          ),
        );
        return;
      }
      _invalid();
    }
    if (!{'tap', 'doubleTap', 'longPress', 'drag'}.contains(operation))
      _invalid();
    final to = operation == 'drag' ? _point(args['to']) : from;
    final buttons = args['button'] == 'secondary'
        ? kSecondaryMouseButton
        : kPrimaryMouseButton;
    await _press(from, to, buttons, operation);
    if (operation == 'doubleTap') {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await _press(from, to, buttons, 'tap');
    }
  }

  Future<void> _press(
    Offset from,
    Offset to,
    int buttons,
    Object? operation,
  ) async {
    final pointer = _pointer++;
    _send(
      PointerDownEvent(
        pointer: pointer,
        position: from,
        buttons: buttons,
        kind: PointerDeviceKind.mouse,
      ),
    );
    try {
      if (operation == 'longPress')
        await Future<void>.delayed(const Duration(milliseconds: 650));
      if (operation == 'drag') await _drag(pointer, from, to, buttons);
    } finally {
      _send(
        PointerUpEvent(
          pointer: pointer,
          position: to,
          kind: PointerDeviceKind.mouse,
        ),
      );
    }
  }

  Future<void> _drag(int pointer, Offset from, Offset to, int buttons) async {
    var previous = from;
    for (var i = 1; i <= 20; i++) {
      final next = Offset.lerp(from, to, i / 20)!;
      _send(
        PointerMoveEvent(
          pointer: pointer,
          position: next,
          delta: next - previous,
          buttons: buttons,
          kind: PointerDeviceKind.mouse,
        ),
      );
      previous = next;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  LogicalKeyboardKey _key(Object? name) {
    const keys = {
      'tab': LogicalKeyboardKey.tab,
      'enter': LogicalKeyboardKey.enter,
      'escape': LogicalKeyboardKey.escape,
      'space': LogicalKeyboardKey.space,
      'backspace': LogicalKeyboardKey.backspace,
      'delete': LogicalKeyboardKey.delete,
      'arrowLeft': LogicalKeyboardKey.arrowLeft,
      'arrowRight': LogicalKeyboardKey.arrowRight,
      'arrowUp': LogicalKeyboardKey.arrowUp,
      'arrowDown': LogicalKeyboardKey.arrowDown,
      'home': LogicalKeyboardKey.home,
      'end': LogicalKeyboardKey.end,
      'pageUp': LogicalKeyboardKey.pageUp,
      'pageDown': LogicalKeyboardKey.pageDown,
      'control': LogicalKeyboardKey.controlLeft,
      'shift': LogicalKeyboardKey.shiftLeft,
      'alt': LogicalKeyboardKey.altLeft,
      'meta': LogicalKeyboardKey.metaLeft,
    };
    if (keys[name] case final key?) return key;
    if (name is String && RegExp(r'^[\x20-\x7e]$').hasMatch(name))
      return LogicalKeyboardKey(name.toLowerCase().codeUnitAt(0));
    if (name is String && RegExp(r'^f([1-9]|1\d|2[0-4])$').hasMatch(name))
      return LogicalKeyboardKey(
        LogicalKeyboardKey.f1.keyId + int.parse(name.substring(1)) - 1,
      );
    return _invalid();
  }

  Future<void> key(JsonMap args) => _withKeys([
    ...jsonStrings(args['modifiers']).map(_key),
    _key(args['key']),
  ], () {});

  Future<void> _withKeys(
    Iterable<LogicalKeyboardKey> keys,
    FutureOr<void> Function() action,
  ) async {
    final keyboard = HardwareKeyboard.instance;
    final pressed = <LogicalKeyboardKey>[];
    try {
      for (final key in keys.toSet()) {
        if (keyboard.logicalKeysPressed.contains(key)) continue;
        pressed.add(key);
        _keyEvent(
          KeyDownEvent(
            physicalKey: PhysicalKeyboardKey(key.keyId),
            logicalKey: key,
            timeStamp: Duration.zero,
          ),
        );
      }
      await action();
    } finally {
      for (final key in pressed.reversed) {
        _keyEvent(
          KeyUpEvent(
            physicalKey: PhysicalKeyboardKey(key.keyId),
            logicalKey: key,
            timeStamp: Duration.zero,
          ),
        );
      }
    }
  }

  void _keyEvent(KeyEvent event) {
    ServicesBinding.instance.platformDispatcher.onKeyData?.call(
      ui.KeyData(
        type: event is KeyDownEvent ? ui.KeyEventType.down : ui.KeyEventType.up,
        physical: event.physicalKey.usbHidUsage,
        logical: event.logicalKey.keyId,
        character: null,
        timeStamp: event.timeStamp,
        synthesized: true,
      ),
    );
  }
}
