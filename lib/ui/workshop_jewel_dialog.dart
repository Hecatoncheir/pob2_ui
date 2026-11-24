import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mcp_error_message.dart';
import '../domain/build_report.dart';
import '../domain/engine_session.dart';
import '../domain/item_name.dart';
import '../domain/tree_geometry.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'engine_build_comparison.dart';
import 'engine_session_cubit.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';

Future<bool?> showWorkshopJewelDialog(
  BuildContext context,
  WorkshopCubit model,
  TreeNode node,
) => sparkDialog<bool>(
  context,
  _WorkshopJewelDialog(model, node),
  barrierDismissible: false,
);

class _WorkshopJewelDialog extends StatefulWidget {
  const _WorkshopJewelDialog(this.model, this.node);
  final WorkshopCubit model;
  final TreeNode node;

  @override
  State<_WorkshopJewelDialog> createState() => _WorkshopJewelDialogState();
}

class _WorkshopJewelDialogState extends State<_WorkshopJewelDialog> {
  final _text = TextEditingController();
  int _itemId = 0;
  bool _remove = false;
  bool _loading = false;
  bool _saving = false;
  WorkshopJewelOffer? _offer;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _filled =>
      widget.model.state.report?.socketedItems.containsKey(widget.node.id) ??
      false;

  bool get _removing => _remove && _filled;

  int get _selectedItem {
    final items = widget.model.state.report?.items ?? const [];
    return items.any((item) => item['id'] == _itemId) ? _itemId : 0;
  }

  EngineJewelEdit get _edit {
    final itemId = _removing ? 0 : _selectedItem;
    return (
      nodeId: widget.node.id,
      itemId: itemId,
      raw: _removing || itemId != 0 ? '' : _text.text.trim(),
    );
  }

  void _change(VoidCallback change) => setState(() {
    change();
    _offer = null;
    _error = null;
  });

  Future<void> _preview() async {
    final edit = _edit;
    _change(() => _loading = true);
    try {
      final offer = await widget.model.previewSharedJewel(edit);
      if (mounted) setState(() => _offer = offer);
    } catch (error) {
      if (mounted) setState(() => _error = mcpErrorMessage(engineError(error)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply(WorkshopJewelOffer offer) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await widget.model.applySharedJewel(offer);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = result.error;
    });
    if (result.committed) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkshopCubit, WorkshopState>(
        bloc: widget.model,
        builder: (_, workshop) =>
            BlocBuilder<EngineSessionCubit, EngineSessionState>(
              bloc: widget.model.engineSession,
              builder: (_, _) => _dialog(workshop),
            ),
      );

  Widget _dialog(WorkshopState workshop) {
    final offer = _offer;
    final fresh =
        offer != null && widget.model.isCurrentSharedJewelOffer(offer);
    final enabled = !_loading && !_saving && !workshop.busy;
    final canPreview =
        _removing || _selectedItem != 0 || _text.text.trim().isNotEmpty;
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: AppText(widget.node.name, game: true),
        scrollable: true,
        content: SizedBox(
          width: 500,
          child: _content(workshop.report, _filled, enabled, fresh),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const AppText('Закрыть'),
          ),
          TextButton(
            key: const Key('tree-jewel-preview'),
            onPressed: enabled && canPreview ? _preview : null,
            child: const AppText('Предпросмотр'),
          ),
          FilledButton(
            key: const Key('tree-jewel-apply'),
            onPressed: enabled && fresh ? () => _apply(offer) : null,
            child: const AppText('Применить'),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildReport? report, bool filled, bool enabled, bool fresh) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (report?.socketedItems[widget.node.id] case final jewel?)
            AppText(itemDisplayName(jewel), game: true),
          if (filled)
            CheckboxListTile(
              key: const Key('tree-jewel-remove'),
              contentPadding: EdgeInsets.zero,
              title: const AppText('Снять'),
              value: _remove,
              onChanged: enabled
                  ? (value) => _change(() => _remove = value ?? false)
                  : null,
            ),
          _inventory(report?.items ?? const [], enabled && !_removing),
          TextField(
            key: const Key('tree-jewel-raw'),
            controller: _text,
            decoration: const InputDecoration(label: AppText('Текст предмета')),
            minLines: 2,
            maxLines: 5,
            enabled: enabled && !_removing && _selectedItem == 0,
            onChanged: (_) => _change(() {}),
          ),
          if (_loading || _saving) const LinearProgressIndicator(),
          if (_offer case final comparison?)
            EngineBuildComparisonPanel(comparison.offer.preview, fresh: fresh),
          if (_error case final error?) AppText(error),
        ],
      );

  Widget _inventory(List<JsonMap> items, bool enabled) => DropdownButton<int>(
    key: const Key('tree-jewel-inventory'),
    isExpanded: true,
    value: _selectedItem,
    items: [
      const DropdownMenuItem(value: 0, child: AppText('Текст предмета')),
      for (final item in items)
        if (item['id'] case final int id)
          DropdownMenuItem(
            value: id,
            child: AppText(itemDisplayName(item), game: true, maxLines: 1),
          ),
    ],
    onChanged: enabled ? (id) => _change(() => _itemId = id ?? 0) : null,
  );
}
