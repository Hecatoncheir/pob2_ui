import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'workshop_state.dart';
import 'app_update_state.dart';

import '../domain/component.dart';
import 'calculator_view.dart';
import 'workshop_cubit.dart';
import 'app_update_cubit.dart';
import 'app_update_dialog.dart';
import '../domain/app_info.dart';

const accent = Color(0xFF8FE3CB);

class PobApp extends StatelessWidget {
  const PobApp({super.key, required this.model, this.updates});
  final WorkshopCubit model;
  final AppUpdateCubit? updates;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PoB II · Мастерская',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        surface: const Color(0xFF171D21),
      ),
      scaffoldBackgroundColor: const Color(0xFF101518),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: accent,
          foregroundColor: const Color(0xFF10271F),
        ),
      ),
    ),
    home: WorkshopView(model: model, updates: updates),
  );
}

class WorkshopView extends StatefulWidget {
  const WorkshopView({super.key, required this.model, this.updates});
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  State<WorkshopView> createState() => _WorkshopViewState();
}

class _WorkshopViewState extends State<WorkshopView> {
  int selected = 0;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkshopCubit, WorkshopState>(
        bloc: widget.model,
        builder: (context, _) {
          final model = widget.model;
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  if (MediaQuery.sizeOf(context).width >= 850)
                    NavigationRail(
                      selectedIndex: selected,
                      onDestinationSelected: (value) =>
                          setState(() => selected = value),
                      labelType: NavigationRailLabelType.all,
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Icon(
                          Icons.auto_awesome_outlined,
                          color: accent,
                          size: 30,
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.widgets_outlined),
                          label: Text('Компоненты'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.tune),
                          label: Text('Сборка'),
                        ),
                      ],
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 24,
                            children: [
                              if (widget.updates != null)
                                _AppVersionButton(
                                  updates: widget.updates!,
                                  workshop: model,
                                ),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'POB II / МАСТЕРСКАЯ',
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 13,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Место для вашей следующей сборки',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Chip(
                                avatar: Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: model.engine.connected
                                      ? accent
                                      : Colors.grey,
                                ),
                                label: Text(
                                  model.engine.connected
                                      ? 'Lua подключён'
                                      : 'Lua не подключён',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            model.state.status,
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (model.state.busy)
                          const LinearProgressIndicator(minHeight: 2),
                        if (model.state.error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 8,
                            ),
                            child: SelectableText(
                              model.state.error!,
                              maxLines: 4,
                              style: const TextStyle(color: Color(0xFFFFB4AB)),
                            ),
                          ),
                        Expanded(
                          child: IndexedStack(
                            index: selected,
                            children: [
                              _ComponentsView(model: model),
                              CalculatorView(model: model),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: MediaQuery.sizeOf(context).width < 850
                ? NavigationBar(
                    selectedIndex: selected,
                    onDestinationSelected: (value) =>
                        setState(() => selected = value),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.widgets_outlined),
                        label: 'Компоненты',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.tune),
                        label: 'Сборка',
                      ),
                    ],
                  )
                : null,
          );
        },
      );
}

class _ComponentsView extends StatelessWidget {
  const _ComponentsView({required this.model});
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      const Text(
        'Два компонента. Одна рабочая среда.',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      const Text(
        'Интерфейс живёт отдельно. Механики и числа поступают из исходного Lua PoB.',
        style: TextStyle(color: Colors.white60),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          FilledButton.icon(
            onPressed: model.state.busy ? null : model.checkUpdates,
            icon: const Icon(Icons.sync),
            label: const Text('Проверить обновления'),
          ),
          OutlinedButton.icon(
            onPressed: model.state.busy || !model.ready ? null : model.connect,
            icon: const Icon(Icons.cable),
            label: const Text('Подключить Lua'),
          ),
          TextButton(
            onPressed: model.state.busy || !model.ready ? null : model.doctor,
            child: const Text('Проверить совместимость'),
          ),
        ],
      ),
      const SizedBox(height: 24),
      for (final component in Component.values)
        _ComponentCard(model: model, component: component),
      const SizedBox(height: 8),
      const Text(
        'Для этой версии нужны Git и 64-битный Python 3.11+ в PATH. '
        'Проверка обновлений обращается к GitHub; расчёты после установки работают локально.',
        style: TextStyle(color: Colors.white60),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: model.state.busy || !model.canRollback
              ? null
              : model.rollback,
          icon: const Icon(Icons.history),
          label: const Text('Вернуться к предыдущей паре'),
        ),
      ),
      const SizedBox(height: 16),
      ExpansionTile(
        title: const Text('Журнал операций'),
        subtitle: Text(model.components.store.root.path),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              model.state.log.isEmpty
                  ? 'Операций пока нет'
                  : model.state.log.join('\n'),
              style: const TextStyle(fontFamily: 'Consolas', fontSize: 12),
            ),
          ),
        ],
      ),
    ],
  );
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.model, required this.component});
  final WorkshopCubit model;
  final Component component;

  @override
  Widget build(BuildContext context) {
    final installed = model.components.active[component];
    final latest = model.state.releases[component];
    final current = installed != null && installed.tag == latest?.tag;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      component == Component.pob
                          ? Icons.hub_outlined
                          : Icons.terminal,
                      color: accent,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      component.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                FilledButton.tonalIcon(
                  onPressed: model.state.busy || current
                      ? null
                      : () => model.install(component),
                  icon: Icon(
                    installed == null
                        ? Icons.download
                        : Icons.system_update_alt,
                  ),
                  label: Text(
                    installed == null
                        ? 'Скачать'
                        : current
                        ? 'Актуальная версия'
                        : 'Обновить',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(component.description),
            const SizedBox(height: 4),
            SelectableText(
              component.url,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const Divider(height: 32),
            Wrap(
              spacing: 32,
              runSpacing: 12,
              children: [
                Text('Установлена: ${installed?.tag ?? 'нет'}'),
                Text(
                  'Последний выпуск: ${latest?.tag ?? 'проверьте обновления'}',
                  style: const TextStyle(color: accent),
                ),
              ],
            ),
            if (installed != null) ...[
              const SizedBox(height: 12),
              SelectableText(
                'Git: ${installed.commit}\n${installed.directory}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppVersionButton extends StatelessWidget {
  const _AppVersionButton({required this.updates, required this.workshop});
  final AppUpdateCubit updates;
  final WorkshopCubit workshop;
  @override
  Widget build(BuildContext context) =>
      BlocSelector<AppUpdateCubit, AppUpdateState, bool>(
        bloc: updates,
        selector: (state) => state.available,
        builder: (context, available) => TextButton.icon(
          onPressed: () => showAppUpdates(context, updates, workshop),
          icon: Icon(available ? Icons.update : Icons.info_outline),
          label: Text(available ? 'Есть обновление' : 'v$appVersion'),
        ),
      );
}
