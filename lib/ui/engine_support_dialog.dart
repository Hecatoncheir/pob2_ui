import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/engine_session.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'engine_session_cubit.dart';

Future<void> showEngineSupport(
  BuildContext context,
  EngineSessionCubit session,
) => sparkDialog<void>(context, _EngineSupportDialog(session));

class _EngineSupportDialog extends StatefulWidget {
  const _EngineSupportDialog(this.session);
  final EngineSessionCubit session;

  @override
  State<_EngineSupportDialog> createState() => _EngineSupportDialogState();
}

class _EngineSupportDialogState extends State<_EngineSupportDialog> {
  final _query = TextEditingController();
  EngineSupportPage? _page;
  EngineSupportOption? _gem;
  int _level = 1;
  int _quality = 0;
  EngineSupportOffer? _offer;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

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

  Future<void> _search(EngineSnapshot snapshot, [int offset = 0]) => _run(
    () async {
      final query = _query.text.trim();
      final result = await widget.session.findSupports(snapshot, query, offset);
      if (!mounted) return;
      setState(() {
        _page = result;
        _selectGem(_exactMatch(result.entries, query));
      });
    },
  );

  EngineSupportOption? _exactMatch(
    List<EngineSupportOption> entries,
    String query,
  ) {
    if (entries.length == 1) return entries.single;
    final normalized = query.toLowerCase();
    final matches = entries
        .where(
          (gem) =>
              gem.id.toLowerCase() == normalized ||
              gem.name.toLowerCase() == normalized,
        )
        .take(2)
        .toList();
    return matches.length == 1 ? matches.single : null;
  }

  void _selectGem(EngineSupportOption? gem) {
    _gem = gem;
    _level = gem?.levels.firstOrNull ?? 1;
    _quality = gem?.qualities.firstOrNull ?? 0;
    _offer = null;
  }

  Future<void> _preview(EngineSnapshot snapshot, EngineSupportOption gem) =>
      _run(() async {
        setState(() => _offer = null);
        final offer = await widget.session.previewSupport(snapshot, (
          id: gem.id,
          level: _level,
          quality: _quality,
        ));
        if (mounted) setState(() => _offer = offer);
      });

  Future<void> _apply(EngineSupportOffer offer) => _run(() async {
    await widget.session.addSupport(offer);
    if (mounted) Navigator.pop(context);
  });

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EngineSessionCubit, EngineSessionState>(
        bloc: widget.session,
        builder: (_, state) => _dialog(state.snapshot),
      );

  Widget _dialog(EngineSnapshot? snapshot) {
    final current = widget.session.supportsAddSupport && !_busy
        ? snapshot
        : null;
    final offer = _offer;
    final fresh = offer != null && widget.session.isCurrentSupportOffer(offer);
    return AlertDialog(
      title: const AppText('Добавить поддержку'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _searchField(current),
              if (_page case final page?) _results(current, page),
              if (_gem case final gem?) _parameters(gem, current != null),
              if (offer != null) _PreviewResult(offer.preview, fresh: fresh),
              if (_error case final error?) AppText(error, localize: false),
              if (_busy) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
      actions: [
        const DialogCloseButton(
          key: Key('engine-support-cancel'),
          label: 'Отмена',
        ),
        _previewButton(current),
        FilledButton(
          key: const Key('engine-support-apply'),
          onPressed:
              !_busy && offer != null && fresh && offer.preview.compatible
              ? () => _apply(offer)
              : null,
          child: const AppText('Применить'),
        ),
      ],
    );
  }

  Widget _previewButton(EngineSnapshot? current) {
    final gem = _gem;
    return TextButton(
      key: const Key('engine-support-preview'),
      onPressed: current != null && gem != null
          ? () => _preview(current, gem)
          : null,
      child: const AppText('Предпросмотр'),
    );
  }

  Widget _searchField(EngineSnapshot? current) => Row(
    children: [
      Expanded(
        child: TextField(
          key: const Key('engine-support-query'),
          controller: _query,
          autofocus: true,
          enabled: current != null,
          decoration: const InputDecoration(label: AppText('Название или ID')),
          onChanged: (_) => setState(() {
            _page = null;
            _selectGem(null);
          }),
          onSubmitted: current == null ? null : (_) => _search(current),
        ),
      ),
      TextButton(
        key: const Key('engine-support-search'),
        onPressed: current == null ? null : () => _search(current),
        child: const AppText('Найти'),
      ),
    ],
  );

  Widget _results(EngineSnapshot? current, EngineSupportPage page) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(child: _gemPicker(page.entries, current != null)),
        if (page.nextOffset case final offset?)
          TextButton(
            onPressed: current == null ? null : () => _search(current, offset),
            child: const AppText('Ещё'),
          ),
      ],
    ),
  );

  Widget _gemPicker(List<EngineSupportOption> entries, bool enabled) {
    if (entries.isEmpty) return const AppText('Поддержки не найдены');
    return DropdownButton<EngineSupportOption>(
      key: const Key('engine-support-gem'),
      hint: const AppText('Камень поддержки'),
      isExpanded: true,
      value: _gem,
      items: [
        for (final gem in entries)
          DropdownMenuItem(value: gem, child: AppText(gem.name, game: true)),
      ],
      onChanged: enabled ? (gem) => setState(() => _selectGem(gem)) : null,
    );
  }

  Widget _parameters(EngineSupportOption gem, bool enabled) => Wrap(
    spacing: 16,
    children: [
      _ParameterPicker(
        label: 'Уровень',
        value: _level,
        values: gem.levels,
        onChanged: enabled
            ? (value) => setState(() {
                _level = value;
                _offer = null;
              })
            : null,
      ),
      _ParameterPicker(
        label: 'Качество',
        value: _quality,
        values: gem.qualities,
        onChanged: enabled
            ? (value) => setState(() {
                _quality = value;
                _offer = null;
              })
            : null,
      ),
    ],
  );
}

class _ParameterPicker extends StatelessWidget {
  const _ParameterPicker({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String label;
  final int value;
  final List<int> values;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppText(label),
      const SizedBox(width: 8),
      DropdownButton<int>(
        value: value,
        items: [
          for (final option in values.isEmpty ? [value] : values)
            DropdownMenuItem(value: option, child: Text('$option')),
        ],
        onChanged: onChanged == null
            ? null
            : (value) {
                if (value != null) onChanged!(value);
              },
      ),
    ],
  );
}

class _PreviewResult extends StatelessWidget {
  const _PreviewResult(this.preview, {required this.fresh});
  final EngineSupportPreview preview;
  final bool fresh;

  static const _labels = {
    'TotalDPS': 'DPS умения',
    'FullDPS': 'Суммарный DPS',
    'Life': 'Жизнь',
    'ManaCost': 'Расход маны',
    'Speed': 'Действий в секунду',
    'AreaOfEffectRadiusMetres': 'Радиус, м',
  };

  @override
  Widget build(BuildContext context) => Padding(
    key: const Key('engine-support-result'),
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!fresh) const AppText('Выполните предпросмотр для текущей ревизии'),
        AppText(
          preview.compatible
              ? 'PoB подтвердил совместимость'
              : 'PoB не подтвердил совместимость поддержки',
        ),
        for (final delta in preview.deltas)
          if (_labels[delta.name] case final label?) _stat(label, delta),
        _warnings('До добавления', preview.before),
        _warnings('После добавления', preview.after),
      ],
    ),
  );

  Widget _stat(String label, EngineStatDelta delta) {
    final sign = delta.difference > 0 ? '+' : '';
    return Wrap(
      spacing: 8,
      children: [
        AppText(label),
        Text(
          '${delta.before.toStringAsFixed(2)} → ${delta.after.toStringAsFixed(2)} '
          '($sign${delta.difference.toStringAsFixed(2)})',
        ),
      ],
    );
  }

  Widget _warnings(String stage, EngineCalculation calculation) => Wrap(
    spacing: 8,
    children: [
      AppText(stage),
      AppText(calculation.status),
      for (final warning in calculation.warnings)
        AppText(warning, localize: false),
    ],
  );
}
