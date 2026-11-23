import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/engine_session.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'engine_build_comparison.dart';
import 'engine_session_cubit.dart';
import 'equipment_presentation.dart';

const _equipmentSlots = [
  'Helmet',
  'Body Armour',
  'Gloves',
  'Boots',
  'Belt',
  'Amulet',
  'Ring 1',
  'Ring 2',
];

class EngineEquipmentPanel extends StatelessWidget {
  const EngineEquipmentPanel(this.session, this.document, {super.key});

  final EngineSessionCubit session;
  final EngineBuild document;

  @override
  Widget build(BuildContext context) {
    final slots = session.supportsEquipmentPreview
        ? _equipmentSlots
        : _equipmentSlots.where(document.equipment.containsKey);
    if (slots.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      key: const Key('engine-equipment'),
      title: const AppText('Экипировка'),
      tilePadding: EdgeInsets.zero,
      children: [
        for (final slot in slots)
          ListTile(
            key: ValueKey('engine-equipment-slot-$slot'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: AppText(equipmentLabel(slot)),
            subtitle: AppText(
              _itemName(document.equipment[slot] ?? ''),
              game: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: session.supportsEquipmentPreview
                ? () => sparkDialog<void>(
                    context,
                    _EngineEquipmentDialog(session, slot),
                  )
                : null,
          ),
      ],
    );
  }
}

String _itemName(String raw) => const LineSplitter()
    .convert(raw)
    .map((line) => line.trim())
    .firstWhere(
      (line) =>
          line.isNotEmpty &&
          !line.startsWith('Rarity:') &&
          !line.startsWith('Item Class:') &&
          !line.startsWith('---'),
      orElse: () => '—',
    );

class _EngineEquipmentDialog extends StatefulWidget {
  const _EngineEquipmentDialog(this.session, this.slot);
  final EngineSessionCubit session;
  final String slot;

  @override
  State<_EngineEquipmentDialog> createState() => _EngineEquipmentDialogState();
}

class _EngineEquipmentDialogState extends State<_EngineEquipmentDialog> {
  final _text = TextEditingController();
  bool _remove = false;
  bool _busy = false;
  String? _error;
  EngineEquipmentOffer? _offer;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _edited() => setState(() {
    _offer = null;
    _error = null;
  });

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
    } catch (error) {
      if (mounted) setState(() => _error = engineError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _preview(EngineSnapshot snapshot, EngineEquipmentEdit edit) =>
      _run(() async {
        setState(() => _offer = null);
        final offer = await widget.session.previewEquipment(snapshot, edit);
        if (mounted) setState(() => _offer = offer);
      });

  Future<void> _apply(EngineEquipmentOffer offer) => _run(() async {
    await widget.session.editEquipment(offer);
    if (mounted) Navigator.pop(context);
  });

  EngineEquipmentEdit? _edit(String? equipped) {
    if (equipped == null) return null;
    final raw = _remove ? '' : _text.text.trim();
    if (raw == equipped.trim()) return null;
    if (!_remove && raw.isEmpty) return null;
    return (slot: widget.slot, raw: raw);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EngineSessionCubit, EngineSessionState>(
        bloc: widget.session,
        builder: (_, state) => _dialog(state.snapshot),
      );

  Widget _dialog(EngineSnapshot? snapshot) {
    final build = snapshot?.build;
    final equipped = build == null ? null : build.equipment[widget.slot] ?? '';
    final enabled =
        equipped != null && widget.session.supportsEquipmentPreview && !_busy;
    final edit = _edit(equipped);
    final offer = _offer;
    final fresh =
        offer != null && widget.session.isCurrentEquipmentOffer(offer);
    return AlertDialog(
      title: AppText(equipmentLabel(widget.slot)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(child: _content(equipped, enabled, fresh)),
      ),
      actions: [
        const DialogCloseButton(
          key: Key('engine-equipment-cancel'),
          label: 'Отмена',
        ),
        TextButton(
          key: const Key('engine-equipment-preview'),
          onPressed: enabled && edit != null && snapshot != null
              ? () => _preview(snapshot, edit)
              : null,
          child: const AppText('Предпросмотр'),
        ),
        FilledButton(
          key: const Key('engine-equipment-apply'),
          onPressed: enabled && fresh ? () => _apply(offer) : null,
          child: const AppText('Применить'),
        ),
      ],
    );
  }

  Widget _content(String? equipped, bool enabled, bool fresh) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (equipped != null) AppText(_itemName(equipped), game: true),
      if (equipped?.isNotEmpty == true)
        CheckboxListTile(
          key: const Key('engine-equipment-remove'),
          title: const AppText('Снять'),
          value: _remove,
          dense: true,
          contentPadding: EdgeInsets.zero,
          onChanged: enabled ? _setRemove : null,
        ),
      if (!_remove)
        TextField(
          key: const Key('engine-equipment-text'),
          controller: _text,
          minLines: 4,
          maxLines: 8,
          enabled: enabled,
          decoration: const InputDecoration(label: AppText('Текст предмета')),
          onChanged: (_) => _edited(),
        ),
      if (_offer case final offer?)
        EngineBuildComparisonPanel(
          offer.preview,
          key: const Key('engine-equipment-result'),
          fresh: fresh,
        ),
      if (_error case final error?)
        AppText(
          error,
          key: const Key('engine-equipment-error'),
          localize: false,
        ),
      if (_busy) const LinearProgressIndicator(),
    ],
  );

  void _setRemove(bool? value) {
    _remove = value == true;
    _edited();
  }
}
