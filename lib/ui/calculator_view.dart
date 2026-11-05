import 'dart:convert';

import 'package:flutter/material.dart';

import 'workshop_model.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key, required this.model});
  final WorkshopModel model;
  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final xml = TextEditingController();
  final level = TextEditingController(text: '90');
  int? classId;

  @override
  void dispose() {
    xml.dispose();
    level.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final enabled = model.engine.connected && !model.busy;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Text(
          'Сборка начинается здесь',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Создайте персонажа или вставьте XML из PoB. Все показатели рассчитывает Lua.',
          style: TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 24),
        if (!model.engine.connected)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: model.busy || !model.ready ? null : model.connect,
              icon: const Icon(Icons.cable),
              label: const Text('Подключить Lua'),
            ),
          ),
        if (model.sessionSaved)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: enabled ? model.restoreSession : null,
              icon: const Icon(Icons.restore),
              label: const Text('Восстановить последнюю сборку'),
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<int>(
                key: ValueKey(model.classes),
                initialValue: model.classes.any((item) => item['id'] == classId)
                    ? classId
                    : null,
                decoration: const InputDecoration(labelText: 'Класс из Lua'),
                items: model.classes
                    .map(
                      (item) => DropdownMenuItem<int>(
                        value: item['id'] as int,
                        child: Text(item['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: enabled
                    ? (value) => setState(() => classId = value)
                    : null,
              ),
            ),
            SizedBox(
              width: 110,
              child: TextField(
                controller: level,
                enabled: enabled,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Уровень'),
              ),
            ),
            FilledButton(
              onPressed: enabled && classId != null
                  ? () => model.createBuild(
                      classId!,
                      int.tryParse(level.text) ?? 0,
                    )
                  : null,
              child: const Text('Создать сборку'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: xml,
          minLines: 5,
          maxLines: 9,
          decoration: const InputDecoration(
            labelText: 'XML сборки',
            hintText: '<PathOfBuilding2>…</PathOfBuilding2>',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: enabled ? () => model.importXml(xml.text) : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Импортировать и рассчитать'),
            ),
            OutlinedButton(
              onPressed: enabled && model.report != null
                  ? () async {
                      final result = await model.exportXml();
                      if (mounted && result != null) xml.text = result;
                    }
                  : null,
              child: const Text('Получить XML'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (model.report != null) _ReportView(report: model.report!),
        if (model.report == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Text(
              'Показатели появятся после расчёта сборки.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ),
      ],
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report});
  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final stats = report['stats'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Результаты исходного Lua', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final stat in const {
              'Life': 'Здоровье',
              'EnergyShield': 'Энергощит',
              'FullDPS': 'Полный DPS',
              'TotalDPS': 'DPS',
              'Armour': 'Броня',
            }.entries)
              SizedBox(
                width: 170,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.value,
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _number(stats[stat.key]),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Условия и предупреждения', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        SelectableText(
          const JsonEncoder.withIndent('  ').convert({
            'warnings': report['warnings'],
            'config': report['config'],
          }),
          style: const TextStyle(fontFamily: 'Consolas', fontSize: 12),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: const Text('Полный отчёт Lua'),
          children: [
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(report),
              style: const TextStyle(fontFamily: 'Consolas', fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  String _number(dynamic value) =>
      value is num ? value.toStringAsFixed(value.abs() < 10 ? 2 : 0) : '—';
}
