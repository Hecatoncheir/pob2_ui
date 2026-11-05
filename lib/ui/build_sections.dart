import 'package:flutter/material.dart';

import '../domain/build_report.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'report_views.dart';
import 'workshop_cubit.dart';

class SkillsView extends StatelessWidget {
  const SkillsView({super.key, required this.model});
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) {
    final report = model.state.report!;
    if (report.groups.isEmpty)
      return const EmptyPanel(
        title: 'Умения ещё не добавлены',
        message: 'Откройте XML с умениями, чтобы выбрать основной навык и увидеть его расчёт.',
        art: 'gem',
      );
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SectionHeading(
          'Умения',
          subtitle: 'Группы камней из вашей сборки',
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SkillSelectors(model: model),
        ),
        const SizedBox(height: 22),
        ...report.groups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SkillGroup(group),
          ),
        ),
      ],
    );
  }
}

class _SkillGroup extends StatelessWidget {
  const _SkillGroup(this.group);
  final JsonMap group;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SparkArt('icons/gem', width: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${group['label']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (group['enabled'] != true)
              const Text('Отключена', style: TextStyle(color: Spark.muted)),
          ],
        ),
        const SizedBox(height: 18),
        ...jsonRows(group['gems']).map((gem) => _GemRow(gem)),
      ],
    ),
  );
}

class _GemRow extends StatelessWidget {
  const _GemRow(this.gem);
  final JsonMap gem;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SparkArt('icons/spark', width: 17, color: Spark.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${gem['name']}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Уровень ${gem['level']} · качество ${gem['quality']} %',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (gem['error'] case final String error when error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(color: Spark.danger, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

const slotLabels = {
  'Weapon 1': 'Оружие',
  'Weapon 2': 'Левая рука',
  'Helmet': 'Голова',
  'Body Armour': 'Нагрудник',
  'Gloves': 'Перчатки',
  'Boots': 'Обувь',
  'Amulet': 'Амулет',
  'Ring 1': 'Кольцо I',
  'Ring 2': 'Кольцо II',
  'Belt': 'Пояс',
};

class ItemsView extends StatelessWidget {
  const ItemsView({super.key, required this.report});
  final BuildReport report;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const SectionHeading(
        'Снаряжение',
        subtitle: 'Предметы и активные слоты из Lua',
      ),
      ...report.slots
          .where((slot) => slot['active'] != false)
          .map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ItemSlot(
                slot: slot,
                item: report.items
                    .where((item) => item['id'] == slot['itemId'])
                    .firstOrNull,
              ),
            ),
          ),
    ],
  );
}

class _ItemSlot extends StatelessWidget {
  const _ItemSlot({required this.slot, this.item});
  final JsonMap slot;
  final JsonMap? item;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.all(16),
    child: InkWell(
      onTap: item == null ? null : () => _details(context),
      child: Row(
        children: [
          const SparkArt('icons/sword', width: 25),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slotLabels[slot['name']] ?? '${slot['name']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  item == null ? 'Пусто' : '${item!['name']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: item == null ? Spark.muted : Spark.ink,
                  ),
                ),
              ],
            ),
          ),
          if (item != null) const SparkArt('icons/chevron', width: 15),
        ],
      ),
    ),
  );
  void _details(BuildContext context) => sparkDialog<void>(
    context,
    AlertDialog(
      title: Text('${item!['name']}'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                '${item!['raw']}',
                style: Spark.mono.copyWith(fontSize: 12),
              ),
              ...jsonRows(item!['unsupported']).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Не распознано: ${line['line']}',
                    style: const TextStyle(color: Spark.danger),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}

class ConditionsView extends StatefulWidget {
  const ConditionsView({super.key, required this.model});
  final WorkshopCubit model;
  @override
  State<ConditionsView> createState() => _ConditionsViewState();
}

class _ConditionsViewState extends State<ConditionsView> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final entries =
        widget.model.state.report!.config.entries
            .where(
              (entry) => entry.key.toLowerCase().contains(query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SectionHeading(
          'Условия расчёта',
          subtitle: 'Эти настройки влияют на показатели сборки',
        ),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            hintText: 'Найти условие',
            prefixIcon: Padding(
              padding: EdgeInsets.all(13),
              child: SparkArt('icons/search', width: 18),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (query.isNotEmpty)
          ...entries.map(_entry)
        else ...[
          ...entries.where((entry) => _common.contains(entry.key)).map(_entry),
          const SizedBox(height: 16),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Дополнительные условия'),
            children: entries
                .where((entry) => !_common.contains(entry.key))
                .map(_entry)
                .toList(),
          ),
        ],
      ],
    );
  }

  static const _common = {
    'enemyIsBoss',
    'resistancePenalty',
    'enemySizePreset',
    'enemyLevel',
  };

  Widget _entry(MapEntry<String, dynamic> entry) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    title: Text(
      _conditionLabel(entry.key),
      style: const TextStyle(fontSize: 12),
    ),
    subtitle: Text(
      _conditionValue(entry.value),
      style: Spark.mono.copyWith(fontSize: 11, color: Spark.green),
    ),
    trailing: const SparkArt('icons/chevron', width: 14),
    onTap: widget.model.state.busy
        ? null
        : () => sparkDialog<void>(
            context,
            _ConditionDialog(widget.model, entry.key, entry.value),
          ),
  );
}

String _conditionValue(dynamic value) => switch (value) {
  true => 'Включено',
  false => 'Выключено',
  'Pinnacle' => 'Вершинный босс',
  'None' => 'Обычный противник',
  _ => '$value',
};

String _conditionLabel(String key) =>
    const {
      'enemyIsBoss': 'Тип противника',
      'resistancePenalty': 'Штраф сопротивлений',
      'enemySizePreset': 'Размер противника',
      'enemyLevel': 'Уровень противника',
    }[key] ??
    key;

class _ConditionDialog extends StatefulWidget {
  const _ConditionDialog(this.model, this.name, this.value);
  final WorkshopCubit model;
  final String name;
  final dynamic value;
  @override
  State<_ConditionDialog> createState() => _ConditionDialogState();
}

class _ConditionDialogState extends State<_ConditionDialog> {
  late dynamic value = widget.value;
  late final text = TextEditingController(text: '${widget.value}');
  late final definition = _load();
  String? error;
  Future<JsonMap?> _load() async {
    final result = await widget.model.engine.call('pob_catalog', {
      'kind': 'config',
      'query': widget.name,
      'limit': 200,
    });
    return jsonRows(result['entries'])
        .where((entry) => entry['id'] == widget.name)
        .firstOrNull;
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<JsonMap?>(
    future: definition,
    builder: (context, snapshot) => AlertDialog(
      title: Text(_conditionLabel(widget.name)),
      content: SizedBox(width: 400, child: _content(snapshot)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        if (snapshot.hasData)
          FilledButton(
            onPressed: () => _save(snapshot.data!),
            child: const Text('Применить и рассчитать'),
          ),
      ],
    ),
  );
  Widget _content(AsyncSnapshot<JsonMap?> snapshot) {
    if (snapshot.hasError)
      return Text('Не удалось прочитать каталог: ${snapshot.error}');
    if (snapshot.connectionState != ConnectionState.done)
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    final data = snapshot.data;
    if (data == null)
      return const Text('Описание условия недоступно в этой версии PoB.');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${data['name']}'),
        const SizedBox(height: 18),
        _field(data),
        if (error != null)
          Text(error!, style: const TextStyle(color: Spark.danger)),
      ],
    );
  }

  Widget _field(JsonMap data) => switch (data['type']) {
    'check' => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Включено'),
      value: value == true,
      onChanged: (next) => setState(() => value = next),
    ),
    'list' => DropdownButtonFormField<dynamic>(
      initialValue: value,
      isExpanded: true,
      items: jsonRows(data['choices'])
          .map(
            (choice) => DropdownMenuItem<dynamic>(
              value: choice['value'],
              child: Text(
                '${choice['label']}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (next) => value = next,
    ),
    _ => TextField(
      controller: text,
      decoration: const InputDecoration(labelText: 'Значение'),
    ),
  };
  void _save(JsonMap data) {
    if (!['check', 'list'].contains(data['type']))
      value = data['type'] == 'text'
          ? text.text
          : num.tryParse(text.text.replaceAll(',', '.'));
    if (value == null) {
      setState(() => error = 'Введите корректное значение');
      return;
    }
    widget.model.setCondition(widget.name, value);
    Navigator.pop(context);
  }
}
