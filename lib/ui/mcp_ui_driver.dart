import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mcp_editor_gateway.dart';
import '../domain/build_report.dart';
import 'mcp_ui_input.dart';

class McpUiDriver {
  McpUiDriver(this.navigator);
  final GlobalKey<NavigatorState> navigator;
  final surface = GlobalKey();
  late final input = McpUiInput(surface);
  SemanticsHandle? _handle;
  int _snapshot = 0;
  final _nodes = <int, SemanticsNode>{};
  final _owners = <int, SemanticsOwner>{};
  String? _fingerprint;

  void dispose() {
    _handle?.dispose();
    _handle = null;
    _nodes.clear();
    _owners.clear();
  }

  Future<JsonMap> snapshot() async {
    _handle ??= SemanticsBinding.instance.ensureSemantics();
    await _frame();
    return _read();
  }

  JsonMap _read() {
    _nodes.clear();
    _owners.clear();
    final rows = <JsonMap>[];
    for (final view in RendererBinding.instance.renderViews) {
      final owner = view.owner?.semanticsOwner;
      final root = owner?.rootSemanticsNode;
      if (owner != null && root != null) _collect(root, owner, rows, null);
    }
    final box = surface.currentContext?.findRenderObject() as RenderBox?;
    final viewport = box == null
        ? null
        : {'width': box.size.width, 'height': box.size.height};
    final fingerprint = jsonEncode([rows, viewport]);
    if (_fingerprint != fingerprint) {
      _fingerprint = fingerprint;
      _snapshot++;
    }
    return {
      'snapshotId': _snapshot,
      'dialogOpen': navigator.currentState?.canPop() ?? false,
      if (viewport != null) 'viewport': viewport,
      'nodes': rows,
    };
  }

  void _collect(
    SemanticsNode node,
    SemanticsOwner owner,
    List<JsonMap> rows,
    int? parent,
  ) {
    final data = node.getSemanticsData();
    if (data.flagsCollection.isHidden) return;
    _nodes[node.id] = node;
    _owners[node.id] = owner;
    rows.add({
      'id': node.id,
      'parent': parent,
      'label': data.label,
      'value': data.flagsCollection.isObscured ? '' : data.value,
      'hint': data.hint,
      'tooltip': data.tooltip,
      'textField': data.flagsCollection.isTextField,
      'readOnly': data.flagsCollection.isReadOnly,
      'enabled': data.flagsCollection.isEnabled.name,
      'checked': data.flagsCollection.isChecked.name,
      'selected': data.flagsCollection.isSelected.name,
      'expanded': data.flagsCollection.isExpanded.name,
      'customActions': [
        for (final id in data.customSemanticsActionIds ?? const <int>[])
          {'id': id, 'label': CustomSemanticsAction.getAction(id)?.label},
      ],
      'actions': [
        for (final action in SemanticsAction.values)
          if (data.hasAction(action)) action.name,
      ],
    });
    node.visitChildren((child) {
      _collect(child, owner, rows, node.id);
      return true;
    });
  }

  Future<JsonMap> perform(JsonMap args) async {
    await _checkSnapshot(args);
    final id = args['nodeId'];
    final node = _nodes[id];
    if (node == null) {
      throw const McpEditorFault(
        'UI_ELEMENT_GONE',
        'Элемент интерфейса больше недоступен.',
      );
    }
    final action = SemanticsAction.values
        .where((a) => a.name == args['operation'])
        .firstOrNull;
    if (action == null || !node.getSemanticsData().hasAction(action)) {
      throw const McpEditorFault(
        'ACTION_UNAVAILABLE',
        'Действие или его параметры недоступны.',
      );
    }
    _owners[id]!.performAction(node.id, action, _argument(action, args, node));
    await _frame();
    return snapshot();
  }

  Future<void> _checkSnapshot(JsonMap args) async {
    await snapshot();
    if (args['snapshotId'] != _snapshot) {
      throw const McpEditorFault(
        'STALE_UI',
        'Состояние интерфейса устарело. Запросите snapshot заново.',
      );
    }
  }

  Future<JsonMap> interact(JsonMap args) async {
    await _checkSnapshot(args);
    if (args['action'] == 'gesture') {
      await input.gesture(args);
    } else {
      input.key(args);
    }
    await _frame();
    return snapshot();
  }

  Future<JsonMap> screenshot() async {
    for (
      var i = 0;
      i < 30 && WidgetsBinding.instance.transientCallbackCount > 0;
      i++
    ) {
      await _frame();
    }
    final state = await snapshot();
    final boundary =
        surface.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null)
      throw const McpEditorFault('UNAVAILABLE', 'Интерфейс не подключён.');
    final image = await boundary.toImage();
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return {...state, '_image': base64Encode(data!.buffer.asUint8List())};
    } finally {
      image.dispose();
    }
  }

  Object? _argument(SemanticsAction action, JsonMap args, SemanticsNode node) {
    final value = args['value'];
    return switch (action) {
      SemanticsAction.setText => _textArgument(value),
      SemanticsAction.setSelection => _selection(
        value,
        node.getSemanticsData().value.length,
      ),
      SemanticsAction.scrollToOffset => _offset(value),
      SemanticsAction.customAction => _customArgument(value, node),
      _ when action.name.startsWith('moveCursor') => value == true,
      _ => value,
    };
  }

  String _textArgument(Object? value) => switch (value) {
    final String text => text,
    _ => throw const McpEditorFault(
      'INVALID_ARGUMENTS',
      'Действие или его параметры недоступны.',
    ),
  };

  Float64List _offset(Object? value) => switch (value) {
    {'x': final num x, 'y': final num y} when x.isFinite && y.isFinite =>
      Float64List.fromList([x.toDouble(), y.toDouble()]),
    _ => throw const McpEditorFault(
      'INVALID_ARGUMENTS',
      'Действие или его параметры недоступны.',
    ),
  };

  Object? _customArgument(Object? value, SemanticsNode node) {
    if ((node.getSemanticsData().customSemanticsActionIds ?? []).contains(
      value,
    )) {
      return value;
    }
    throw const McpEditorFault(
      'INVALID_ARGUMENTS',
      'Действие или его параметры недоступны.',
    );
  }

  JsonMap _selection(Object? value, int length) {
    if (value case {'base': final int base, 'extent': final int extent}
        when base >= 0 && extent >= 0 && base <= length && extent <= length) {
      return {'base': base, 'extent': extent};
    }
    throw const McpEditorFault(
      'INVALID_ARGUMENTS',
      'Действие или его параметры недоступны.',
    );
  }

  Future<JsonMap> closeDialog({bool discard = false}) async {
    final state = navigator.currentState;
    if (state == null || !state.canPop()) return {'closed': false};
    await snapshot();
    final input = _nodes.values.any((node) {
      final flags = node.getSemanticsData().flagsCollection;
      return flags.isTextField && !flags.isReadOnly;
    });
    if (input && !discard) {
      throw const McpEditorFault(
        'DIALOG_INPUT',
        'Укажите discard=true для отмены ввода или сохраните форму.',
      );
    }
    await state.maybePop();
    await _frame();
    return snapshot();
  }

  Future<void> _frame() async {
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame;
  }
}
