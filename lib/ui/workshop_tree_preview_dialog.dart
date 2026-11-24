import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mcp_error_message.dart';
import '../domain/engine_session.dart';
import '../domain/tree_geometry.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'engine_session_cubit.dart';
import 'engine_tree_dialog.dart' show EngineTreeComparison;
import 'workshop_cubit.dart';
import 'workshop_state.dart';

Future<bool?> showWorkshopTreePreview(
  BuildContext context,
  WorkshopCubit model,
  TreeNode node, {
  EngineTreeAction? action,
  EnginePassiveAttribute? attribute,
}) => sparkDialog<bool>(
  context,
  _WorkshopTreePreviewDialog(model, node, action, attribute),
  barrierDismissible: false,
);

class _WorkshopTreePreviewDialog extends StatefulWidget {
  const _WorkshopTreePreviewDialog(
    this.model,
    this.node,
    this.action,
    this.attribute,
  );
  final WorkshopCubit model;
  final TreeNode node;
  final EngineTreeAction? action;
  final EnginePassiveAttribute? attribute;

  @override
  State<_WorkshopTreePreviewDialog> createState() =>
      _WorkshopTreePreviewDialogState();
}

class _WorkshopTreePreviewDialogState
    extends State<_WorkshopTreePreviewDialog> {
  WorkshopTreeOffer? _offer;
  String? _error;
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _preview();
  }

  Future<void> _preview() async {
    setState(() {
      _loading = true;
      _offer = null;
      _error = null;
    });
    try {
      final offer = await widget.model.previewSharedTreeNode(
        widget.node.id,
        action: widget.action,
        attribute: widget.attribute,
      );
      if (mounted) setState(() => _offer = offer);
    } catch (error) {
      if (mounted) setState(() => _error = mcpErrorMessage(engineError(error)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply(WorkshopTreeOffer offer) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await widget.model.applySharedTreeNode(offer);
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
        builder: (_, state) =>
            BlocBuilder<EngineSessionCubit, EngineSessionState>(
              bloc: widget.model.engineSession,
              builder: (_, _) => _dialog(state.busy),
            ),
      );

  Widget _dialog(bool workshopBusy) {
    final offer = _offer;
    final fresh = offer != null && widget.model.isCurrentSharedTreeOffer(offer);
    final enabled = !_loading && !_saving && !workshopBusy;
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: AppText(widget.node.name, game: true),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(child: _content(fresh)),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const AppText('Закрыть'),
          ),
          if (!fresh)
            TextButton(
              onPressed: enabled ? _preview : null,
              child: const AppText('Предпросмотр'),
            ),
          FilledButton(
            key: const Key('workshop-tree-apply'),
            onPressed: enabled && fresh ? () => _apply(offer) : null,
            child: const AppText('Применить'),
          ),
        ],
      ),
    );
  }

  Widget _content(bool fresh) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_loading || _saving) const LinearProgressIndicator(),
      if (_offer case final view?)
        EngineTreeComparison(view.offer.preview, fresh: fresh),
      if (_error case final error?) AppText(error),
    ],
  );
}
