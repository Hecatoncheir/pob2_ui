import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/condition_definition.dart';
import 'catalog_cubit.dart';
import 'condition_dialog.dart';
import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/panels.dart';
import 'core/spark_theme.dart';
import 'workshop_cubit.dart';

class ConditionsView extends StatefulWidget {
  const ConditionsView({super.key, required this.model});
  final WorkshopCubit model;
  @override
  State<ConditionsView> createState() => _ConditionsViewState();
}

class _ConditionsViewState extends State<ConditionsView> {
  late final catalog = CatalogCubit(widget.model.catalogs.conditions);
  @override
  void initState() {
    super.initState();
    catalog.load();
  }

  @override
  void dispose() {
    catalog.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<
        CatalogCubit<ConditionDefinition>,
        CatalogState<ConditionDefinition>
      >(
        bloc: catalog,
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(
                'Условия расчёта',
                subtitle: 'Эти настройки влияют на показатели сборки',
              ),
              TextField(
                key: const Key('condition-search'),
                onChanged: catalog.search,
                decoration: const InputDecoration(
                  hint: AppText('Найти условие'),
                  prefixIcon: Icon(Icons.search, size: 19),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const AppText('Все'),
                    selected: !state.configuredOnly,
                    onSelected: (_) => catalog.configured(false),
                  ),
                  ChoiceChip(
                    label: const AppText('Заданные'),
                    selected: state.configuredOnly,
                    onSelected: (_) => catalog.configured(true),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(child: _results(context, state)),
            ],
          ),
        ),
      );

  Widget _results(
    BuildContext context,
    CatalogState<ConditionDefinition> state,
  ) {
    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.error != null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText('Не удалось прочитать каталог: ${state.error}'),
            TextButton(
              onPressed: catalog.load,
              child: const AppText('Повторить загрузку'),
            ),
          ],
        ),
      );
    final entries = _entries(context, state);
    if (entries.isEmpty)
      return const Center(child: AppText('Условия не найдены'));
    return ListView.builder(
      key: const Key('condition-catalog'),
      itemCount: entries.length,
      itemBuilder: (context, index) => _entry(context, entries[index]),
    );
  }

  List<ConditionDefinition> _entries(
    BuildContext context,
    CatalogState<ConditionDefinition> state,
  ) {
    final query = state.query.trim().toLowerCase();
    final configured = widget.model.state.report!.config;
    final entries = state.entries.where((entry) {
      if (state.configuredOnly && !configured.containsKey(entry.id))
        return false;
      return '${entry.id} ${entry.name} ${translateGame(context, entry.label)}'
          .toLowerCase()
          .contains(query);
    }).toList();
    entries.sort((a, b) => _order(a).compareTo(_order(b)));
    return entries;
  }

  String _order(ConditionDefinition entry) =>
      '${const {'enemyIsBoss', 'resistancePenalty', 'enemySizePreset', 'enemyLevel'}.contains(entry.id) ? '0' : '1'}${entry.name.toLowerCase()}';

  Widget _entry(BuildContext context, ConditionDefinition entry) {
    final config = widget.model.state.report!.config;
    return ListTile(
      key: ValueKey('condition-${entry.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: AppText(
        entry.label,
        game: true,
        style: const TextStyle(fontSize: 13),
      ),
      subtitle: AppText(
        config.containsKey(entry.id)
            ? _value(entry, config[entry.id])
            : 'По умолчанию',
        game: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: config.containsKey(entry.id)
              ? Spark.of(context).green
              : Spark.of(context).muted,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: widget.model.state.busy || !entry.editable
          ? null
          : () => showConditionEditor(context, widget.model, entry),
    );
  }

  String _value(ConditionDefinition entry, dynamic value) {
    if (value is bool) return value ? 'Включено' : 'Выключено';
    final choice = entry.choices
        .where((choice) => choice['value'] == value)
        .firstOrNull;
    return choice == null ? '$value' : '${choice['label']}';
  }
}
