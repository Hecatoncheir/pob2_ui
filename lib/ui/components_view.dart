import 'core/app_text.dart';

import 'package:flutter/material.dart';

import '../domain/component.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'pob_bridge_dialog.dart';
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
          icon: SparkArt(
            'icons/refresh',
            color: Spark.of(context).paper,
            width: 17,
          ),
          label: const AppText('Проверить обновления'),
        ),
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 760
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final component in Component.values)
                SizedBox(width: width, child: _Component(model, component)),
            ],
          );
        },
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton(
            onPressed: model.state.busy || !model.ready ? null : model.connect,
            child: const AppText('Подключить Lua'),
          ),
          TextButton(
            onPressed: model.state.busy || !model.ready ? null : model.doctor,
            child: const AppText('Проверить совместимость'),
          ),
          TextButton(
            onPressed: model.state.busy || !model.canRollback
                ? null
                : model.rollback,
            child: const AppText('Вернуть предыдущую пару'),
          ),
          if (model.pobWindow.supported) _BridgeSetupButton(model),
        ],
      ),
      const SizedBox(height: 24),
      AppText(
        'Для установки нужны Git и 64-битный Python 3.11+. После загрузки компонентов расчёты работают без сети.',
        style: TextStyle(color: Spark.of(context).muted),
      ),
      const SizedBox(height: 20),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const AppText('Журнал и подробности'),
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
            style: TextStyle(color: Spark.of(context).muted, fontSize: 11),
          ),
        ],
      ),
    ],
  );
}

class _BridgeSetupButton extends StatelessWidget {
  const _BridgeSetupButton(this.model);
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) {
    final mcp = model.components.active[Component.mcp];
    return OutlinedButton(
      onPressed: model.state.busy || mcp == null
          ? null
          : () => showPobBridgeSetup(context, model.pobWindow, mcp),
      child: const AppText('Настроить мост PoB'),
    );
  }
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
      key: ValueKey('component-card-${component.name}'),
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
                child: AppText(
                  component.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            component.description,
            style: TextStyle(color: Spark.of(context).muted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppText(
                'Установлена: ${installed?.tag ?? 'нет'}',
                style: Spark.mono.copyWith(fontSize: 12),
              ),
              if (latest != null)
                AppText(
                  'Последняя: ${latest.tag}',
                  style: TextStyle(color: Spark.of(context).green),
                ),
              FilledButton.tonalIcon(
                onPressed: model.state.busy || current
                    ? null
                    : () => model.install(component),
                icon: const SparkArt('icons/download', width: 17),
                label: AppText(
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
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ExpansionTile(
                key: ValueKey('component-source-${component.name}'),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                clipBehavior: Clip.antiAlias,
                collapsedBackgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh,
                backgroundColor: Color.alphaBlend(
                  Theme.of(context).colorScheme.primary.withValues(alpha: .06),
                  Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Spark.of(context).line),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Spark.of(context).line),
                ),
                title: const AppText(
                  'Источник',
                  style: TextStyle(fontSize: 11),
                ),
                children: [
                  SelectableText(
                    '${component.url}\n${installed.commit}\n${installed.directory}',
                    style: Spark.mono.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
