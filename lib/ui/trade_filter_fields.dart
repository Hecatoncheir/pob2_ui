import 'package:flutter/material.dart';

import '../domain/trade_search.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'trade_search_cubit.dart';

class TradeFilterFields extends StatelessWidget {
  const TradeFilterFields({
    super.key,
    required this.filter,
    required this.editor,
    required this.busy,
  });
  final TradeFilterDraft filter;
  final TradeSearchCubit editor;
  final bool busy;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                filter.stat.label,
                game: true,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            IconButton(
              tooltip: 'Убрать',
              onPressed: busy ? null : () => editor.remove(filter.stat.id),
              icon: const Icon(Icons.close, size: 17),
            ),
          ],
        ),
        if (filter.stat.options.isNotEmpty)
          _options()
        else if (filter.stat.numeric)
          Row(
            children: [
              Expanded(child: _number('min', 'Минимум', filter.min)),
              const SizedBox(width: 12),
              Expanded(child: _number('max', 'Максимум', filter.max)),
            ],
          ),
      ],
    ),
  );

  Widget _options() => DropdownButtonFormField<String>(
    initialValue: filter.option,
    isExpanded: true,
    decoration: const InputDecoration(label: AppText('Вариант')),
    items: filter.stat.options
        .map(
          (entry) => DropdownMenuItem(
            value: entry.id,
            child: AppText(entry.label, game: true),
          ),
        )
        .toList(),
    onChanged: busy
        ? null
        : (value) => editor.edit(filter.stat.id, option: value),
  );

  Widget _number(String kind, String label, String value) => TextFormField(
    key: ValueKey('trade-${filter.stat.id}-$kind'),
    initialValue: value,
    enabled: !busy,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    decoration: InputDecoration(label: AppText(label)),
    onChanged: (text) => kind == 'min'
        ? editor.edit(filter.stat.id, min: text)
        : editor.edit(filter.stat.id, max: text),
  );
}
