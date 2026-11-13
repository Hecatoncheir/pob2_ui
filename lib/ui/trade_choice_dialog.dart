import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/motion.dart';
import 'core/search_query_bloc.dart';

typedef TradePickerChoice = ({String id, String label, String? detail});

Future<String?> showTradeChoice(
  BuildContext context,
  String title,
  List<TradePickerChoice> choices,
) => sparkDialog<String>(
  context,
  BlocProvider(
    create: (_) => SearchQueryBloc(),
    child: _ChoiceDialog(title, choices),
  ),
);

class _ChoiceDialog extends StatelessWidget {
  const _ChoiceDialog(this.title, this.choices);
  final String title;
  final List<TradePickerChoice> choices;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: AppText(title),
    content: SizedBox(
      width: 540,
      height: (MediaQuery.sizeOf(context).height * .6).clamp(180, 520),
      child: Column(
        children: [
          TextField(
            key: const Key('trade-choice-search'),
            autofocus: true,
            decoration: const InputDecoration(
              label: AppText('Поиск'),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => context.read<SearchQueryBloc>().add(
              SearchQueryChanged(value.trim()),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SearchQueryBloc, String>(
              builder: (context, query) => _results(context, query),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const AppText('Отмена'),
      ),
    ],
  );

  Widget _results(BuildContext context, String query) {
    final rows = choices.where((row) => _matches(context, row, query)).toList();
    if (rows.isEmpty) return const Center(child: AppText('Ничего не найдено'));
    return ListView.builder(
      key: const Key('trade-choice-list'),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return ListTile(
          key: ValueKey('trade-choice-${row.id}'),
          title: AppText(row.label, game: true),
          subtitle: row.detail == null
              ? null
              : AppText(
                  row.detail!,
                  game: true,
                  style: const TextStyle(fontSize: 11),
                ),
          onTap: () => Navigator.pop(context, row.id),
        );
      },
    );
  }

  bool _matches(BuildContext context, TradePickerChoice row, String query) =>
      row.id.toLowerCase().contains(query) ||
      row.label.toLowerCase().contains(query) ||
      translateGame(context, row.label).toLowerCase().contains(query);
}
