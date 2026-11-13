import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/trade_browser.dart';
import '../data/trade_search_repository.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'equipment_presentation.dart';
import 'item_editor_dialog.dart';
import 'trade_choice_dialog.dart';
import 'trade_filter_fields.dart';
import 'trade_search_cubit.dart';
import 'workshop_cubit.dart';

Future<void> showTradeSearch(
  BuildContext context,
  WorkshopCubit model,
  String slot, {
  Future<void> Function(Uri)? openBrowser,
}) async {
  final import = await sparkDialog<bool>(
    context,
    TradeSearchDialog(
      repository: TradeSearchRepository(model.engine),
      slot: slot,
      openBrowser: openBrowser ?? TradeBrowser().open,
    ),
  );
  if (import != true) return;
  final value = await Clipboard.getData(Clipboard.kTextPlain);
  if (context.mounted)
    await showItemEditor(context, model, slot, initial: value?.text ?? '');
}

Future<void> showProgressionTrade(
  BuildContext context,
  WorkshopCubit model,
  String slot,
  String? base,
) => sparkDialog<void>(
  context,
  TradeSearchDialog(
    repository: TradeSearchRepository(model.engine),
    slot: slot,
    openBrowser: TradeBrowser().open,
    initialBase: base,
    searchOnly: true,
  ),
);

class TradeSearchDialog extends StatefulWidget {
  const TradeSearchDialog({
    super.key,
    required this.repository,
    required this.slot,
    required this.openBrowser,
    this.initialBase,
    this.searchOnly = false,
  });
  final TradeSearchRepository repository;
  final String slot;
  final Future<void> Function(Uri) openBrowser;
  final String? initialBase;
  final bool searchOnly;
  @override
  State<TradeSearchDialog> createState() => _TradeSearchDialogState();
}

class _TradeSearchDialogState extends State<TradeSearchDialog> {
  late final editor = TradeSearchCubit(
    widget.repository,
    widget.slot,
    widget.openBrowser,
    initialBase: widget.initialBase,
  )..load();
  @override
  void dispose() {
    editor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TradeSearchCubit, TradeSearchState>(
        bloc: editor,
        builder: (context, state) => AlertDialog(
          title: const AppText('Поиск на рынке'),
          insetPadding: const EdgeInsets.all(18),
          content: SizedBox(
            width: 720,
            height: (310.0 + state.form.filters.length * 130).clamp(
              220,
              (MediaQuery.sizeOf(context).height * .66).clamp(220, 620),
            ),
            child: _body(state),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText('Закрыть'),
            ),
            if (!widget.searchOnly)
              TextButton(
                key: const Key('trade-import'),
                onPressed: state.busy
                    ? null
                    : () => Navigator.pop(context, true),
                child: const AppText('Вставить найденный предмет'),
              ),
            OutlinedButton(
              key: const Key('trade-copy'),
              onPressed: _enabled(state) ? _copy : null,
              child: const AppText('Скопировать ссылку'),
            ),
            FilledButton(
              key: const Key('trade-open'),
              onPressed: _enabled(state) ? editor.open : null,
              child: const AppText('Открыть поиск'),
            ),
          ],
        ),
      );

  bool _enabled(TradeSearchState state) =>
      !state.loading && !state.busy && state.catalog != null;

  Widget _body(TradeSearchState state) {
    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.catalog == null)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(state.error ?? ''),
          TextButton(
            onPressed: editor.load,
            child: const AppText('Повторить загрузку'),
          ),
        ],
      );
    return ListView(
      children: [
        AppText(
          equipmentLabel(widget.slot),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _parameters(state),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('trade-base'),
          onPressed: state.busy ? null : _base,
          icon: const Icon(Icons.inventory_2_outlined, size: 17),
          label: AppText(
            state.form.base ?? 'Любая база',
            game: state.form.base != null,
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const AppText('Только в сети'),
          value: state.form.online,
          onChanged: state.busy
              ? null
              : (value) => editor.update(online: value),
        ),
        Row(
          children: [
            const Expanded(
              child: AppText(
                'Характеристики',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              key: const Key('trade-add-stat'),
              onPressed: state.busy || state.form.filters.length >= 12
                  ? null
                  : _stat,
              icon: const Icon(Icons.add),
              label: const AppText('Добавить'),
            ),
          ],
        ),
        for (final filter in state.form.filters)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TradeFilterFields(
              key: ValueKey(filter.stat.id),
              filter: filter,
              editor: editor,
              busy: state.busy,
            ),
          ),
        if (state.error case final error?)
          AppText(error, style: TextStyle(color: Spark.of(context).danger)),
        if (state.busy) const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 12),
        const AppText(
          'Поиск откроется на официальном сайте',
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _parameters(TradeSearchState state) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      SizedBox(
        width: 210,
        child: TextFormField(
          key: const Key('trade-league'),
          initialValue: state.form.league,
          enabled: !state.busy,
          decoration: const InputDecoration(label: AppText('Лига')),
          onChanged: (value) => editor.update(league: value),
        ),
      ),
      SizedBox(
        width: 140,
        child: TextFormField(
          key: const Key('trade-budget'),
          initialValue: state.form.price,
          enabled: !state.busy,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            label: AppText('Бюджет'),
            hintText: 'Без ограничения',
          ),
          onChanged: (value) => editor.update(price: value),
        ),
      ),
      SizedBox(
        width: 230,
        child: DropdownButtonFormField<String>(
          key: const Key('trade-currency'),
          initialValue: state.form.currency,
          isExpanded: true,
          decoration: const InputDecoration(label: AppText('Валюта')),
          items: state.catalog!.currencies
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.id,
                  child: AppText(entry.label, game: true),
                ),
              )
              .toList(),
          onChanged: state.busy
              ? null
              : (value) => editor.update(currency: value),
        ),
      ),
    ],
  );

  Future<void> _base() async {
    final value = await showTradeChoice(context, 'База предмета', [
      (id: '', label: 'Любая база', detail: null),
      for (final name in editor.state.catalog!.bases)
        (id: name, label: name, detail: null),
    ]);
    if (value != null) editor.update(base: value, clearBase: value.isEmpty);
  }

  Future<void> _stat() async {
    final selected = editor.state.form.filters
        .map((filter) => filter.stat.id)
        .toSet();
    final choices = editor.state.catalog!.stats
        .where((stat) => !selected.contains(stat.id))
        .toList();
    final id = await showTradeChoice(context, 'Характеристика', [
      for (final stat in choices)
        (id: stat.id, label: stat.label, detail: _typeLabel(stat.type)),
    ]);
    if (id != null) editor.add(choices.firstWhere((stat) => stat.id == id));
  }

  Future<void> _copy() async {
    final uri = await editor.link();
    if (uri != null)
      await Clipboard.setData(ClipboardData(text: uri.toString()));
  }

  String _typeLabel(String value) => switch (value) {
    'explicit' => 'Явные свойства',
    'implicit' => 'Собственные свойства',
    'pseudo' => 'Суммарные свойства',
    'enchant' => 'Зачарования',
    'rune' => 'Руны',
    'skill' => 'Умения',
    _ => value,
  };
}
