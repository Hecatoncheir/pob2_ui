import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_info.dart';
import 'app_update_cubit.dart';
import 'app_update_dialog.dart';
import 'app_update_state.dart';
import 'build_dialogs.dart';
import 'components_view.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'library_view.dart';
import 'shell_cubit.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';
import 'workspace_view.dart';

class PobApp extends StatelessWidget {
  const PobApp({super.key, required this.model, this.updates});
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ShellCubit(),
    child: _MaterialApp(model, updates),
  );
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp(this.model, this.updates);
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  Widget build(BuildContext context) => BlocBuilder<ShellCubit, ShellState>(
    builder: (context, state) => MaterialApp(
      title: 'PoB II · Мастерская',
      debugShowCheckedModeBanner: false,
      theme: Spark.theme(),
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: constraints.biggest,
            disableAnimations:
                MediaQuery.disableAnimationsOf(context) || !state.motion,
          ),
          child: child!,
        ),
      ),
      home: _Shell(model, updates),
    ),
  );
}

class _Shell extends StatelessWidget {
  const _Shell(this.model, this.updates);
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkshopCubit, WorkshopState>(
        bloc: model,
        builder: (context, _) => BlocBuilder<ShellCubit, ShellState>(
          builder: (context, state) {
            final shell = context.read<ShellCubit>();
            final narrow = MediaQuery.sizeOf(context).width < 650;
            return _KeyboardActions(
              model: model,
              shell: shell,
              child: Scaffold(
                body: SafeArea(
                  child: Row(
                    children: [
                      if (!narrow) _Sidebar(model, updates),
                      Expanded(
                        child: Column(
                          children: [
                            _TopBar(
                              page: state.page,
                              model: model,
                              updates: narrow ? updates : null,
                            ),
                            if (model.state.busy)
                              const LinearProgressIndicator(
                                minHeight: 2,
                                color: Spark.green,
                                backgroundColor: Spark.sage,
                              ),
                            if (model.state.error != null)
                              _ErrorNotice(model.state.error!),
                            Expanded(
                              child: ClipRect(
                                child: SoftSwitch(
                                  child: KeyedSubtree(
                                    key: ValueKey(state.page),
                                    child: _page(state.page, model, shell),
                                  ),
                                ),
                              ),
                            ),
                            _StatusBar(model),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: narrow
                    ? _BottomNav(state.page, shell)
                    : null,
              ),
            );
          },
        ),
      );
  Widget _page(AppPage page, WorkshopCubit model, ShellCubit shell) =>
      switch (page) {
        AppPage.library => LibraryView(model: model, shell: shell),
        AppPage.workspace => WorkspaceView(model: model, shell: shell),
        AppPage.components => ComponentsView(model: model),
      };
}

class _KeyboardActions extends StatelessWidget {
  const _KeyboardActions({
    required this.model,
    required this.shell,
    required this.child,
  });
  final WorkshopCubit model;
  final ShellCubit shell;
  final Widget child;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
          _new(context, model, shell),
      const SingleActivator(LogicalKeyboardKey.keyO, control: true): () =>
          _import(context),
      const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
          _export(context),
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
          _new(context, model, shell),
      const SingleActivator(LogicalKeyboardKey.keyO, meta: true): () =>
          _import(context),
      const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () =>
          _export(context),
    },
    child: child,
  );
  void _import(BuildContext context) {
    if (model.engine.connected && !model.state.busy)
      showXmlImport(context, model);
  }

  void _export(BuildContext context) {
    if (model.state.report != null && !model.state.busy)
      exportXml(context, model);
  }
}

void _new(BuildContext context, WorkshopCubit model, ShellCubit shell) {
  if (model.state.busy) return;
  if (!model.engine.connected) {
    shell.page(AppPage.components);
    return;
  }
  shell.page(AppPage.workspace);
  showNewBuild(context, model);
}

class _Sidebar extends StatelessWidget {
  const _Sidebar(this.model, this.updates);
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 1250;
    final shell = context.read<ShellCubit>();
    return Container(
      width: compact ? 78 : 198,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Spark.line)),
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 88,
            child: Center(
              child: compact
                  ? const SparkArt(
                      'brand/badge',
                      width: 30,
                      height: 32,
                      label: 'PoB II',
                    )
                  : const SparkArt(
                      'brand/wordmark',
                      width: 110,
                      height: 40,
                      label: 'PoB II',
                    ),
            ),
          ),
          _NewButton(model: model, shell: shell, compact: compact),
          const SizedBox(height: 24),
          ...AppPage.values.map((page) => _NavItem(page, compact: compact)),
          if (!compact) _Recents(model, shell),
          const Spacer(),
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: DotLabel(
                model.engine.connected ? 'Lua подключён' : 'Lua не подключён',
                active: model.engine.connected,
              ),
            ),
          _SettingsButton(compact: compact),
          if (updates != null)
            _VersionButton(updates!, model, compact: compact),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _NewButton extends StatelessWidget {
  const _NewButton({
    required this.model,
    required this.shell,
    this.compact = false,
  });
  final WorkshopCubit model;
  final ShellCubit shell;
  final bool compact;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: model.state.busy ? null : () => _new(context, model, shell),
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SparkArt('icons/plus', color: Spark.paper, width: 18),
        if (!compact) ...[
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'Новая сборка',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.page, {required this.compact});
  final AppPage page;
  final bool compact;
  @override
  Widget build(BuildContext context) => BlocBuilder<ShellCubit, ShellState>(
    builder: (context, state) {
      final selected = state.page == page;
      final color = selected ? Spark.paper : Spark.ink;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Tooltip(
          message: compact ? pageLabels[page]! : '',
          child: AnimatedContainer(
            duration: motionDuration(context, milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? Spark.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: InkWell(
              key: ValueKey('page-${page.name}'),
              borderRadius: BorderRadius.circular(11),
              onTap: () => context.read<ShellCubit>().page(page),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: compact
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    SparkArt(
                      'icons/${pageIcons[page]}',
                      width: 19,
                      color: color,
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          pageLabels[page]!,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _Recents extends StatelessWidget {
  const _Recents(this.model, this.shell);
  final WorkshopCubit model;
  final ShellCubit shell;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'НЕДАВНИЕ',
          style: TextStyle(color: Spark.muted, fontSize: 9, letterSpacing: 1.3),
        ),
        const SizedBox(height: 10),
        ...model.state.library.entries
            .take(3)
            .map(
              (entry) => TextButton(
                onPressed: model.state.busy || !model.engine.connected
                    ? null
                    : () {
                        model.openBuild(entry.id);
                        shell.page(AppPage.workspace);
                      },
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                ),
                child: Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
      ],
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav(this.page, this.shell);
  final AppPage page;
  final ShellCubit shell;
  @override
  Widget build(BuildContext context) => NavigationBar(
    height: 68,
    backgroundColor: Spark.surface,
    indicatorColor: Spark.sage,
    selectedIndex: page.index,
    onDestinationSelected: (index) => shell.page(AppPage.values[index]),
    destinations: AppPage.values
        .map(
          (page) => NavigationDestination(
            key: ValueKey('page-${page.name}'),
            icon: SparkArt('icons/${pageIcons[page]}', width: 21),
            label: pageLabels[page]!,
          ),
        )
        .toList(),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.page, required this.model, this.updates});
  final AppPage page;
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Spark.line)),
    ),
    child: Row(
      children: [
        Text(
          pageLabels[page]!,
          style: const TextStyle(color: Spark.muted, fontSize: 12),
        ),
        const Spacer(),
        if (updates != null)
          _VersionButton(updates!, model, compact: true)
        else if (MediaQuery.sizeOf(context).width >= 650)
          const DotLabel('Локальное пространство'),
      ],
    ),
  );
}

class _VersionButton extends StatelessWidget {
  const _VersionButton(this.updates, this.model, {required this.compact});
  final AppUpdateCubit updates;
  final WorkshopCubit model;
  final bool compact;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppUpdateCubit, AppUpdateState>(
        bloc: updates,
        builder: (context, state) => TextButton(
          onPressed: () => showAppUpdates(context, updates, model),
          child: compact
              ? SparkArt(
                  'icons/${state.available ? 'download' : 'info'}',
                  width: 18,
                )
              : Text(
                  state.available ? 'Есть обновление' : 'PoB II · v$appVersion',
                  style: const TextStyle(fontSize: 10, color: Spark.muted),
                ),
        ),
      );
}

class _StatusBar extends StatelessWidget {
  const _StatusBar(this.model);
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) => Container(
    height: 30,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Spark.line)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            model.state.busy ? 'Выполняем операцию…' : model.state.status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Spark.muted, fontSize: 10),
          ),
        ),
        if (MediaQuery.sizeOf(context).width > 700)
          const Text(
            'ЧИСЛА И ПРАВИЛА · LUA POB',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 8,
              color: Spark.muted,
            ),
          ),
      ],
    ),
  );
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice(this.error);
  final String error;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: const Color(0xFFF2DFD5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    child: Semantics(
      liveRegion: true,
      child: Text(
        error,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Spark.danger, fontSize: 12),
      ),
    ),
  );
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => _show(context),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SparkArt('icons/settings', width: 18),
        if (!compact) ...[
          const SizedBox(width: 8),
          const Text('Оформление', style: TextStyle(fontSize: 11)),
        ],
      ],
    ),
  );
  void _show(BuildContext context) {
    final shell = context.read<ShellCubit>();
    sparkDialog<void>(
      context,
      AlertDialog(
        title: const Text('Оформление'),
        content: SizedBox(
          width: 380,
          child: BlocBuilder<ShellCubit, ShellState>(
            bloc: shell,
            builder: (context, state) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Плавные анимации'),
              subtitle: const Text(
                'Системное уменьшение движения имеет приоритет',
              ),
              value: state.motion,
              onChanged: shell.motion,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }
}
