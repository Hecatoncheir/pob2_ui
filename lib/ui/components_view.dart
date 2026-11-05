import 'package:flutter/material.dart';

import '../domain/component.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'workshop_cubit.dart';

class ComponentsView extends StatelessWidget {
  const ComponentsView({super.key, required this.model});
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(26),
    children: [
      const SectionHeading(
        'Всё для работы',
        subtitle: 'Два компонента. Расчёты на вашем компьютере.',
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: model.state.busy ? null : model.checkUpdates,
          icon: const SparkArt('icons/refresh', color: Spark.paper, width: 17),
          label: const Text('Проверить обновления'),
        ),
      ),
      const SizedBox(height: 24),
      ...Component.values.map(
        (component) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _Component(model, component),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton(
            onPressed: model.state.busy || !model.ready ? null : model.connect,
            child: const Text('Подключить Lua'),
          ),
          TextButton(
            onPressed: model.state.busy || !model.ready ? null : model.doctor,
            child: const Text('Проверить совместимость'),
          ),
          TextButton(
            onPressed: model.state.busy || !model.canRollback
                ? null
                : model.rollback,
            child: const Text('Вернуть предыдущую пару'),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const Text(
        'Для установки нужны Git и 64-битный Python 3.11+. После загрузки компонентов расчёты работают без сети.',
        style: TextStyle(color: Spark.muted),
      ),
      const SizedBox(height: 20),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text('Журнал и подробности'),
        children: [
          SelectableText(
            model.state.log.isEmpty
                ? 'Операций пока нет'
                : model.state.log.join('\n'),
            style: Spark.mono.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 12),
          SelectableText(
            model.components.store.root.path,
            style: const TextStyle(color: Spark.muted, fontSize: 11),
          ),
        ],
      ),
    ],
  );
}

class _Component extends StatelessWidget {
  const _Component(this.model, this.component);
  final WorkshopCubit model;
  final Component component;
  @override
  Widget build(BuildContext context) {
    final installed = model.components.active[component];
    final latest = model.state.releases[component];
    final current = installed != null && installed.tag == latest?.tag;
    return SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SparkArt(
                'icons/${component == Component.pob ? 'tree' : 'code'}',
                width: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  component.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            component.description,
            style: const TextStyle(color: Spark.muted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Установлена: ${installed?.tag ?? 'нет'}',
                style: Spark.mono.copyWith(fontSize: 12),
              ),
              if (latest != null)
                Text(
                  'Последняя: ${latest.tag}',
                  style: const TextStyle(color: Spark.green),
                ),
              FilledButton.tonalIcon(
                onPressed: model.state.busy || current
                    ? null
                    : () => model.install(component),
                icon: const SparkArt('icons/download', width: 17),
                label: Text(
                  installed == null
                      ? 'Установить'
                      : current
                      ? 'Актуальная версия'
                      : 'Обновить',
                ),
              ),
            ],
          ),
          if (installed != null)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Источник', style: TextStyle(fontSize: 11)),
              children: [
                SelectableText(
                  '${component.url}\n${installed.commit}\n${installed.directory}',
                  style: Spark.mono.copyWith(fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
