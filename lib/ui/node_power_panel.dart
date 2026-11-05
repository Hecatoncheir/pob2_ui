import 'core/dialog_close_button.dart';
import 'core/app_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/build_report.dart';
import '../domain/node_power.dart';
import 'core/spark_theme.dart';
import 'node_power_cubit.dart';
import 'core/ui_translation.dart';

class NodePowerPanel extends StatelessWidget {
  const NodePowerPanel({
    super.key,
    required this.model,
    required this.onFocus,
    this.enabled = true,
  });
  final NodePowerCubit model;
  final ValueChanged<int> onFocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NodePowerCubit, NodePowerState>(
        bloc: model,
        builder: (context, state) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Spark.of(context).surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Spark.of(context).line),
          ),
          child: state.metrics.isEmpty
              ? _loading(context, state)
              : _content(context, state),
        ),
      );

  Widget _loading(BuildContext context, NodePowerState state) => Center(
    child: state.error == null
        ? const CircularProgressIndicator()
        : AppText(state.error!),
  );

  Widget _content(BuildContext context, NodePowerState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LayoutBuilder(
        builder: (context, size) =>
            _controls(context, state, size.maxWidth < 580),
      ),
      const SizedBox(height: 8),
      if (state.progress case final progress?) ...[
        LinearProgressIndicator(value: progress.clamp(0, 1)),
        const SizedBox(height: 8),
        AppText(
          'Расчёт Lua · ${(progress * 100).round()}%',
          style: const TextStyle(fontSize: 11),
        ),
      ],
      if (state.error case final error?)
        AppText(
          error,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Spark.of(context).danger, fontSize: 11),
        ),
      Expanded(child: _results(context, state)),
    ],
  );

  Widget _controls(BuildContext context, NodePowerState state, bool narrow) {
    final metric = _metric(context, state);
    final distance = SizedBox(width: 100, child: _distance(context, state));
    final allocation = _allocation(context, state);
    final action = FilledButton(
      key: const Key('node-power-calculate'),
      onPressed: enabled
          ? (state.progress == null ? model.calculate : model.cancel)
          : null,
      child: AppText(state.progress == null ? 'Найти' : 'Отмена'),
    );
    if (narrow)
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: metric),
              const SizedBox(width: 8),
              distance,
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: allocation),
              const SizedBox(width: 8),
              action,
            ],
          ),
        ],
      );
    return Row(
      children: [
        Expanded(child: metric),
        const SizedBox(width: 8),
        distance,
        const SizedBox(width: 8),
        SizedBox(width: 135, child: allocation),
        const SizedBox(width: 8),
        action,
      ],
    );
  }

  Widget _metric(BuildContext context, NodePowerState state) =>
      DropdownButtonFormField<String>(
        key: const Key('node-power-stat'),
        initialValue: state.options.stat,
        isExpanded: true,
        decoration: const InputDecoration(
          label: AppText('Характеристика'),
          contentPadding: EdgeInsets.all(10),
        ),
        style: TextStyle(
          fontFamily: 'Nunito Sans',
          fontSize: 12,
          color: Spark.of(context).ink,
        ),
        dropdownColor: Spark.of(context).surface,
        items: [
          for (final metric in state.metrics)
            DropdownMenuItem(
              value: '${metric['id']}',
              child: AppText(nodePowerLabel(metric), game: true),
            ),
        ],
        onChanged: (value) {
          if (value != null)
            model.configure((
              stat: value,
              distance: state.options.distance,
              allocation: state.options.allocation,
            ));
        },
      );

  Widget _allocation(BuildContext context, NodePowerState state) =>
      DropdownButtonFormField<String>(
        initialValue: state.options.allocation,
        isExpanded: true,
        decoration: const InputDecoration(
          label: AppText('Узлы'),
          contentPadding: EdgeInsets.all(10),
        ),
        style: TextStyle(
          fontFamily: 'Nunito Sans',
          fontSize: 12,
          color: Spark.of(context).ink,
        ),
        dropdownColor: Spark.of(context).surface,
        items: const [
          DropdownMenuItem(value: 'unallocated', child: AppText('Не выбраны')),
          DropdownMenuItem(value: 'allocated', child: AppText('Выбраны')),
          DropdownMenuItem(value: 'all', child: AppText('Все')),
        ],
        onChanged: (value) {
          if (value != null)
            model.configure((
              stat: state.options.stat,
              distance: state.options.distance,
              allocation: value,
            ));
        },
      );

  Widget _distance(BuildContext context, NodePowerState state) {
    final selected = state.options.distance ?? 0;
    final values = {0, 5, 10, 15, selected};
    return InputDecorator(
      decoration: const InputDecoration(
        label: AppText('До узла'),
        contentPadding: EdgeInsets.all(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          key: const Key('node-power-distance'),
          value: selected,
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 12,
            color: Spark.of(context).ink,
          ),
          dropdownColor: Spark.of(context).surface,
          isDense: true,
          isExpanded: true,
          items: [
            for (final value in values)
              DropdownMenuItem(
                value: value,
                child: AppText(value == 0 ? 'Все' : '$value'),
              ),
            const DropdownMenuItem(value: -1, child: AppText('Свои…')),
          ],
          onChanged: (value) => _selectDistance(context, value),
        ),
      ),
    );
  }

  Future<void> _selectDistance(BuildContext context, int? value) async {
    if (value == null) return;
    if (value == -1) value = await _customDistance(context);
    if (value == null) return;
    final options = model.state.options;
    await model.configure((
      stat: options.stat,
      distance: value == 0 ? null : value,
      allocation: options.allocation,
    ));
  }

  Future<int?> _customDistance(BuildContext context) async {
    var text = '${model.state.options.distance ?? 10}';
    final form = GlobalKey<FormState>();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Расстояние до узла'),
        content: Form(
          key: form,
          child: TextFormField(
            initialValue: text,
            onChanged: (value) => text = value,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              label: AppText('От 1 до 200 очков'),
            ),
            validator: (value) =>
                translateUiError(context, _validateDistance(value)),
          ),
        ),
        actions: [
          const DialogCloseButton(label: 'Отмена'),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate())
                Navigator.pop(context, int.parse(text));
            },
            child: const AppText('Выбрать'),
          ),
        ],
      ),
    );
    return result;
  }

  String? _validateDistance(String? text) {
    final value = int.tryParse(text ?? '');
    return value != null && value >= 1 && value <= 200
        ? null
        : 'Укажите число от 1 до 200';
  }

  Widget _results(BuildContext context, NodePowerState state) {
    final entries = state.report?.entries;
    if (entries == null)
      return const Center(
        child: AppText(
          'Выберите характеристику и нажмите «Найти».',
          style: TextStyle(fontSize: 12),
        ),
      );
    if (state.options.stat == 'OffenceDefence')
      return const Center(
        child: AppText(
          'Общая карта урона и защиты. Для списка выберите отдельный показатель.',
          style: TextStyle(fontSize: 12),
        ),
      );
    if (entries.isEmpty)
      return const Center(
        child: AppText(
          'На этом расстоянии подходящих узлов нет.',
          style: TextStyle(fontSize: 12),
        ),
      );
    return LayoutBuilder(
      builder: (context, size) {
        final wide = size.maxWidth >= 460;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: _row(
                wide,
                'Узел · ${entries.length}',
                'Эффект',
                'Очки',
                'На очко',
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                key: const Key('node-power-results'),
                itemCount: entries.length,
                itemBuilder: (context, index) =>
                    _entry(context, entries[index], wide),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _entry(BuildContext context, JsonMap entry, bool wide) => AppTooltip(
    game: true,
    message: [
      ...jsonStrings(entry['sd']),
      'Очки: ${entry['pathDist']}',
      'На очко: ${cleanPoB('${entry['pathPowerStr']}')}',
    ].join('\n'),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('power-node-${entry['id']}'),
        onTap: () => onFocus(entry['id'] as int),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          child: _row(
            wide,
            '${entry['name']}',
            cleanPoB('${entry['powerStr']}'),
            '${entry['pathDist']}',
            cleanPoB('${entry['pathPowerStr']}'),
          ),
        ),
      ),
    ),
  );

  Widget _row(
    bool wide,
    String name,
    String power,
    String points,
    String perPoint,
  ) => Row(
    children: [
      Expanded(
        child: AppText(
          name,
          game: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      ),
      SizedBox(
        width: 75,
        child: AppText(
          power,
          textAlign: TextAlign.right,
          style: Spark.mono.copyWith(fontSize: 11),
        ),
      ),
      SizedBox(
        width: 45,
        child: AppText(
          points,
          textAlign: TextAlign.right,
          style: Spark.mono.copyWith(fontSize: 11),
        ),
      ),
      if (wide)
        SizedBox(
          width: 80,
          child: AppText(
            perPoint,
            textAlign: TextAlign.right,
            style: Spark.mono.copyWith(fontSize: 11),
          ),
        ),
    ],
  );
}
