import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../data/engine_maintenance.dart';
import '../domain/component.dart';
import 'app_update_cubit.dart';
import 'app_update_dialog.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'engine_session_cubit.dart';
import 'pob_bridge_dialog.dart';
import 'profile_cleanup_dialog.dart';
import 'workshop_cubit.dart';

class ComponentsView extends StatefulWidget {
  const ComponentsView({
    super.key,
    required this.model,
    this.appUpdates,
    this.maintenance,
  });

  final WorkshopCubit model;
  final AppUpdateCubit? appUpdates;
  final EngineMaintenance? maintenance;

  @override
  State<ComponentsView> createState() => _ComponentsViewState();
}

class _ComponentsViewState extends State<ComponentsView> {
  WorkshopCubit get model => widget.model;
  late final _maintenance =
      widget.maintenance ??
      EngineMaintenance(
        model.components.engineExecutable ?? model.engine.executable,
      );
  Map<String, dynamic>? _version;
  Map<String, dynamic>? _diagnosis;
  EngineUpdates? _updates;
  String? _operation, _message, _error;

  @override
  void initState() {
    super.initState();
    if (model.components.engineExecutable != null ||
        widget.maintenance != null) {
      _run('Читаем версию движка…', _readVersion);
    }
  }

  Future<void> _readVersion() async {
    final result = await _maintenance.version();
    if (mounted) setState(() => _version = result);
  }

  Future<void> _run(String operation, Future<void> Function() action) async {
    if (_operation != null) return;
    setState(() {
      _operation = operation;
      _error = null;
      _message = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _operation = null);
    }
  }

  Future<void> _checkUpdates() => _run('Проверяем выпуски…', () async {
    final updates = await _maintenance.checkUpdates();
    if (mounted) setState(() => _updates = updates);
  });

  Future<void> _doctor() => _run('Запускаем диагностику…', () async {
    final session = model.engineSession.state;
    final result = await _maintenance.doctor(
      session.connected ? session.options : null,
    );
    if (mounted) setState(() => _diagnosis = result);
  });

  Future<void> _updateStandalone() => _run('Обновляем PoB2Engine…', () async {
    await model.checkpoint();
    final restart = await _maintenance.updateStandalone();
    await _readVersion();
    if (!mounted) return;
    setState(() {
      _updates = null;
      _message = restart
          ? 'Движок обновлён. Перезапустите PoB II.'
          : 'Установлена актуальная версия движка';
    });
  });

  Future<void> _changePob(Future<void> Function() action) =>
      _run('Проверяем данные PoB и открытую сборку…', () async {
        await action();
        if (model.state.error case final error?) throw StateError(error);
        if (mounted)
          setState(() {
            _updates = null;
            _message = 'Версия данных PoB изменена. Перезапустите PoB II для обновления всех сессий.';
          });
      });

  bool get _busy => _operation != null || model.state.busy;

  VoidCallback? _action(VoidCallback action) => _busy ? null : action;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(26),
    children: [
      const SectionHeading('PoB2Engine'),
      if (_operation case final phase?) _Progress(phase),
      if (_error case final error?) _Feedback(error, error: true),
      if (_message case final message?) _Feedback(message),
      LayoutBuilder(builder: _panels),
      if (_diagnosis case final report?) ...[
        const SizedBox(height: 16),
        _DoctorReport(report),
      ],
      const SizedBox(height: 16),
      _ProfilePanel(model, enabled: !_busy),
    ],
  );

  Widget _panels(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth >= 760
        ? (constraints.maxWidth - 16) / 2
        : constraints.maxWidth;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(width: width, child: _enginePanel(context)),
        SizedBox(width: width, child: _pobPanel(context)),
      ],
    );
  }

  Widget _enginePanel(BuildContext context) => _ManagementPanel(
    key: const Key('engine-management-panel'),
    title: 'Движок',
    children: [
      BlocBuilder<EngineSessionCubit, EngineSessionState>(
        bloc: model.engineSession,
        builder: (context, state) => DotLabel(
          state.connected || model.engine.connected
              ? 'Подключён PoB2Engine'
              : 'PoB2Engine не подключён',
          active: state.connected || model.engine.connected,
        ),
      ),
      if (_version?['version'] case final String version?)
        AppText('Установлена: $version'),
      if (_version?['protocol_version'] case final String protocol?)
        AppText('Протокол: $protocol'),
      _ReleaseStatus(_updates?.engine),
      if (_maintenance.bundled)
        const AppText('Комплектный движок обновляется вместе с PoB II'),
      _Actions([
        FilledButton(
          onPressed: _action(_checkUpdates),
          child: const AppText('Проверить обновления'),
        ),
        OutlinedButton(
          onPressed: _action(_doctor),
          child: const AppText('Запустить doctor'),
        ),
        if (model.ready && !model.engine.connected)
          OutlinedButton(
            onPressed: _action(model.connect),
            child: const AppText('Подключить движок'),
          ),
        if (_engineUpdate(context) case final update?)
          OutlinedButton(
            onPressed: _action(update),
            child: const AppText('Обновить PoB2Engine'),
          ),
      ]),
    ],
  );

  VoidCallback? _engineUpdate(BuildContext context) {
    if (!_maintenance.bundled) {
      return _updates?.engine.status == 'available' ? _updateStandalone : null;
    }
    final updates = widget.appUpdates;
    return updates == null
        ? null
        : () => showAppUpdates(context, updates, model);
  }

  Widget _pobPanel(BuildContext context) {
    final pob = model.components.active[Component.pob];
    final previous = model.components.store.previous[Component.pob];
    final latest = _updates?.pob;
    return _ManagementPanel(
      key: const Key('component-card-pob'),
      title: 'Данные Path of Building',
      help: 'Локальный мост нужен для связи PoB II с окном оригинального Path of Building. Через него PoB2Engine может забрать открытую там сборку, импортировать персонажа или узнать папку сборок из настроек оригинального PoB.',
      children: [
        AppText('Установлена: ${pob?.tag ?? 'нет'}'),
        if (previous != null) AppText('Предыдущая версия: ${previous.tag}'),
        _ReleaseStatus(latest),
        _Actions([
          if (pob == null)
            FilledButton(
              onPressed: _action(model.prepareComponents),
              child: const AppText('Установить данные PoB'),
            ),
          if (latest case (latest: final tag?, status: 'available', message: _))
            FilledButton(
              onPressed: _action(
                () => _changePob(() => model.updatePobData(tag)),
              ),
              child: const AppText('Обновить данные PoB'),
            ),
          if (previous != null && model.canRollback)
            OutlinedButton(
              onPressed: _action(() => _changePob(model.rollback)),
              child: const AppText('Вернуть предыдущую версию PoB'),
            ),
          if (model.pobWindow.supported && pob != null)
            OutlinedButton(
              onPressed: _action(
                () => showPobBridgeSetup(context, model.pobWindow, pob),
              ),
              child: const AppText('Настроить мост PoB'),
            ),
        ]),
        if (pob != null)
          PanelExpansionTile(
            key: const Key('component-source-pob'),
            title: 'Источник',
            children: [
              SelectableText(
                '${Component.pob.url}\n${pob.commit}\n${pob.directory}',
              ),
            ],
          ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions(this.children);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 8, children: children);
}

class _ManagementPanel extends StatelessWidget {
  const _ManagementPanel({
    super.key,
    required this.title,
    required this.children,
    this.help,
  });
  final String title;
  final List<Widget> children;
  final String? help;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(context),
        for (final child in children)
          Padding(padding: const EdgeInsets.only(top: 10), child: child),
      ],
    ),
  );

  Widget _heading(BuildContext context) {
    final label = AppText(title, style: Theme.of(context).textTheme.titleLarge);
    final message = help;
    if (message == null) return label;
    return Row(
      children: [
        Flexible(child: label),
        const SizedBox(width: 4),
        TooltipTheme(
          data: TooltipTheme.of(context).copyWith(
            constraints: const BoxConstraints(maxWidth: 340),
            triggerMode: TooltipTriggerMode.tap,
          ),
          child: AppTooltip(
            message: message,
            child: const SizedBox.square(
              dimension: 36,
              child: Icon(Icons.info_outline, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReleaseStatus extends StatelessWidget {
  const _ReleaseStatus(this.info);
  final EngineVersions? info;

  @override
  Widget build(BuildContext context) {
    final update = info;
    if (update == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (update.latest case final tag?) AppText('Последняя: $tag'),
        AppText(switch (update.status) {
          'available' => 'Доступно обновление',
          'up_to_date' => 'Версия актуальна',
          'local_installation' => 'Используется локальная копия данных PoB',
          'development_build' => 'Сборка для разработки',
          _ => 'Не удалось проверить версию',
        }),
        if (update.message case final message?) SelectableText(message),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text),
        const SizedBox(height: 6),
        const LinearProgressIndicator(),
      ],
    ),
  );
}

class _Feedback extends StatelessWidget {
  const _Feedback(this.text, {this.error = false});
  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Semantics(
      liveRegion: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: error ? Theme.of(context).colorScheme.error : null,
        ),
        child: AppText(text),
      ),
    ),
  );
}

class _DoctorReport extends StatelessWidget {
  const _DoctorReport(this.report);
  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) => _ManagementPanel(
    title: 'Диагностика PoB2Engine',
    children: [
      AppText(
        report['status'] == 'ok'
            ? 'Локальная проверка пройдена'
            : 'Обнаружены проблемы',
      ),
      for (final issue in report['issues'] as List<dynamic>? ?? const [])
        SelectableText('$issue'),
      ExpansionTile(
        title: const AppText('Полный отчёт'),
        children: [
          SelectableText(const JsonEncoder.withIndent('  ').convert(report)),
        ],
      ),
    ],
  );
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel(this.model, {required this.enabled});
  final WorkshopCubit model;
  final bool enabled;

  @override
  Widget build(BuildContext context) => _ManagementPanel(
    title: 'Профиль',
    children: [
      _Actions([
        OutlinedButton(
          onPressed: enabled ? () => showProfileCleanup(context, model) : null,
          child: const AppText('Проверить место в профиле'),
        ),
      ]),
      PanelExpansionTile(
        key: const Key('engine-profile-log'),
        title: 'Журнал и подробности',
        children: [
          SelectableText(model.components.store.root.path),
          for (final line in model.state.log) SelectableText(line),
        ],
      ),
    ],
  );
}
