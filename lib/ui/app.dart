import 'dart:io';

import 'core/dialog_close_button.dart';
import 'core/app_text.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_info.dart';
import '../domain/appearance.dart';
import '../data/appearance_repository.dart';
import '../data/setup_preferences.dart';
import 'appearance_bloc.dart';
import 'appearance_picker.dart';
import '../data/language_preferences.dart';
import '../data/game_dictionary_repository.dart';
import '../l10n/generated/app_localizations.dart';
import 'language_bloc.dart';
import 'language_picker.dart';
import 'core/language_scope.dart';
import 'app_update_cubit.dart';
import 'app_update_dialog.dart';
import 'app_update_state.dart';
import 'build_dialogs.dart';
import 'build_setup.dart';
import 'components_view.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'library_view.dart';
import 'shell_bloc.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';
import 'workspace_view.dart';
import '../data/interface_scale_repository.dart';
import 'interface_scale_bloc.dart';
import 'interface_scale_picker.dart';
import 'interface_viewport.dart';
import 'core/scrollable_workspace.dart';
import '../data/workspace_preferences_repository.dart';
import '../domain/workspace_preferences.dart';
import 'workspace_preferences_bloc.dart';
import 'keyboard_bindings.dart';
import 'shortcut_settings.dart';
import 'resizable_sidebar.dart';
import 'setup_wizard.dart';
import 'core/ui_translation.dart';

class PobApp extends StatelessWidget {
  const PobApp({
    super.key,
    required this.model,
    this.updates,
    this.appearance,
    this.language,
    this.interfaceScale,
    this.workspacePreferences,
    this.initialization,
  });
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  final AppearanceBloc? appearance;
  final LanguageBloc? language;
  final InterfaceScaleBloc? interfaceScale;
  final WorkspacePreferencesBloc? workspacePreferences;
  final Future<void>? initialization;
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<WorkshopCubit>.value(value: model),
      BlocProvider(create: (_) => ShellBloc()),
      if (workspacePreferences case final preferences?)
        BlocProvider<WorkspacePreferencesBloc>.value(value: preferences)
      else
        BlocProvider(
          create: (_) => WorkspacePreferencesBloc(
            WorkspacePreferencesRepository(model.components.store.root),
          ),
        ),
      if (interfaceScale case final settings?)
        BlocProvider<InterfaceScaleBloc>.value(value: settings)
      else
        BlocProvider(
          create: (_) => InterfaceScaleBloc(
            InterfaceScaleRepository(model.components.store.root),
          ),
        ),
      if (language case final settings?)
        BlocProvider<LanguageBloc>.value(value: settings)
      else
        BlocProvider(
          create: (_) => LanguageBloc(
            LanguagePreferences(model.components.store.root),
            GameDictionaryRepository(model.components.store.root),
          ),
        ),
      if (appearance case final settings?)
        BlocProvider<AppearanceBloc>.value(value: settings)
      else
        BlocProvider(
          create: (_) =>
              AppearanceBloc(AppearanceRepository(model.components.store.root)),
        ),
    ],
    child: _MaterialApp(model, updates, initialization),
  );
}

class _MaterialApp extends StatefulWidget {
  const _MaterialApp(this.model, this.updates, this.initialization);
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  final Future<void>? initialization;
  @override
  State<_MaterialApp> createState() => _MaterialAppState();
}

class _MaterialAppState extends State<_MaterialApp> {
  final navigator = GlobalKey<NavigatorState>();
  late final AppLifecycleListener _lifecycle;
  late final _BuildSyncNavigatorObserver _navigation;

  @override
  void initState() {
    super.initState();
    widget.model.modalOpen = _modalOpen;
    _lifecycle = AppLifecycleListener(
      onResume: () => widget.model.requestBuildSync(),
    );
    _navigation = _BuildSyncNavigatorObserver(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.model.resumeBuildSync();
      });
    });
    if (widget.initialization case final initialization?) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await initialization;
        if (mounted) await _showFirstSetup();
      });
    }
  }

  Future<void> _showFirstSetup() async {
    final model = widget.model;
    if (model.ready && model.buildFolderReady) return;
    final preferences = SetupPreferences(model.components.store.root);
    if (await preferences.wasShown() || !mounted || _modalOpen()) return;
    final dialogContext = navigator.currentContext;
    if (dialogContext == null || !dialogContext.mounted) return;
    await showSetupWizard(dialogContext, model);
    try {
      await preferences.markShown();
    } on FileSystemException catch (error) {
      model.reportPersistenceError(error);
    }
  }

  @override
  void didUpdateWidget(_MaterialApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model == widget.model) return;
    oldWidget.model.modalOpen = null;
    widget.model.modalOpen = _modalOpen;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    widget.model.modalOpen = null;
    super.dispose();
  }

  bool _modalOpen() => navigator.currentState?.canPop() ?? false;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, language) => LanguageScope(
          dictionary: language.dictionary,
          child: BlocBuilder<AppearanceBloc, AppearanceState>(
            builder: (context, appearance) =>
                _app(context, appearance, language),
          ),
        ),
      );

  Widget _app(
    BuildContext context,
    AppearanceState appearance,
    LanguageState language,
  ) => BlocBuilder<ShellBloc, ShellState>(
    builder: (context, state) => MaterialApp(
      navigatorKey: navigator,
      navigatorObservers: [_navigation],
      title: 'PoB II · Мастерская',
      locale: languageLocale(language.language),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: Spark.theme(),
      darkTheme: Spark.theme(brightness: Brightness.dark),
      themeMode: switch (appearance.theme) {
        AppTheme.system => ThemeMode.system,
        AppTheme.light => ThemeMode.light,
        AppTheme.dark => ThemeMode.dark,
      },
      builder: (context, child) => _KeyboardActions(
        model: widget.model,
        shell: context.read<ShellBloc>(),
        navigator: navigator,
        child: InterfaceViewport(child: child!, motion: state.motion),
      ),
      home: _Shell(widget.model, widget.updates),
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
        builder: (context, _) => BlocBuilder<ShellBloc, ShellState>(
          builder: (context, state) {
            final shell = context.read<ShellBloc>();
            final narrow = MediaQuery.sizeOf(context).width < 650;
            return Scaffold(
              body: SafeArea(
                child: ScrollableWorkspace(
                  child: Row(
                    children: [
                      if (!narrow) _Sidebar(model, updates),
                      Expanded(
                        child: Column(
                          children: [
                            if (narrow) _CompactActions(model, updates),
                            if (model.state.busy)
                              LinearProgressIndicator(
                                minHeight: 2,
                                color: Spark.of(context).green,
                                backgroundColor: Spark.of(context).sage,
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
              ),
              bottomNavigationBar: narrow
                  ? _BottomNav(state.page, shell)
                  : null,
            );
          },
        ),
      );
  Widget _page(AppPage page, WorkshopCubit model, ShellBloc shell) =>
      switch (page) {
        AppPage.library => LibraryView(model: model, shell: shell),
        AppPage.workspace => WorkspaceView(model: model, shell: shell),
        AppPage.components => ComponentsView(model: model),
      };
}

class _BuildSyncNavigatorObserver extends NavigatorObserver {
  _BuildSyncNavigatorObserver(this.onChanged);
  final VoidCallback onChanged;

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    onChanged();
  }
}

class _KeyboardActions extends StatelessWidget {
  const _KeyboardActions({
    required this.model,
    required this.shell,
    required this.child,
    required this.navigator,
  });
  final WorkshopCubit model;
  final ShellBloc shell;
  final Widget child;
  final GlobalKey<NavigatorState> navigator;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkspacePreferencesBloc, WorkspacePreferencesState>(
        builder: (context, state) => CallbackShortcuts(
          bindings: commandCallbacks(state.preferences, {
            AppCommand.newBuild: () =>
                _new(_dialogContext(context), model, shell),
            AppCommand.importXml: () => _import(_dialogContext(context)),
            AppCommand.exportXml: () => _export(_dialogContext(context)),
            AppCommand.undo: () => _historyAction(model.undo),
            AppCommand.redo: () => _historyAction(model.redo),
          }),
          child: child,
        ),
      );
  BuildContext _dialogContext(BuildContext fallback) =>
      navigator.currentState?.overlay?.context ?? fallback;
  void _historyAction(VoidCallback action) {
    if (navigator.currentState?.canPop() == true) return;
    action();
  }

  void _import(BuildContext context) {
    if (model.engine.connected && model.buildFolderReady && !model.state.busy)
      showXmlImport(context, model);
  }

  void _export(BuildContext context) {
    if (model.state.report != null && !model.state.busy)
      exportXml(context, model);
  }
}

void _new(BuildContext context, WorkshopCubit model, ShellBloc shell) {
  if (model.state.busy) return;
  final step = BuildSetup.pending(model);
  final page = step == BuildSetup.components && model.state.report != null
      ? AppPage.components
      : AppPage.workspace;
  shell.add(PageSelected(page));
  if (step == null) showNewBuild(context, model);
}

class _Sidebar extends StatelessWidget {
  const _Sidebar(this.model, this.updates);
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  Widget build(BuildContext context) {
    final shell = context.read<ShellBloc>();
    return ResizableSidebar(
      builder: (compact, adjustable) => Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 88,
              child: Row(
                children: [
                  Expanded(
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
                  if (adjustable)
                    SizedBox(
                      width: 22,
                      child: IconButton(
                        key: const Key('sidebar-toggle'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 28,
                        ),
                        tooltip: translateUi(
                          context,
                          compact ? 'Развернуть панель' : 'Свернуть панель',
                        ),
                        onPressed: () => context
                            .read<WorkspacePreferencesBloc>()
                            .add(const SidebarToggled()),
                        icon: Icon(
                          compact ? Icons.chevron_right : Icons.chevron_left,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _NewButton(model: model, shell: shell, compact: compact),
            const SizedBox(height: 24),
            ...AppPage.values.map((page) => _NavItem(page, compact: compact)),
            if (!compact) _Recents(model, shell),
            const Spacer(),
            _SidebarTools(model, updates, compact: compact),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _SidebarTools extends StatelessWidget {
  const _SidebarTools(this.model, this.updates, {required this.compact});
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 8, vertical: 8),
    decoration: BoxDecoration(
      color: Spark.of(context).surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Spark.of(context).line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
            child: Center(
              child: DotLabel(
                model.engine.connected ? 'Lua подключён' : 'Lua не подключён',
                active: model.engine.connected,
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 4),
        ],
        if (compact)
          const Align(child: _SettingsButton(compact: true))
        else
          const _SettingsButton(compact: false),
        if (compact) const SizedBox(height: 6),
        if (updates != null)
          Align(child: _VersionButton(updates!, model, compact: compact)),
      ],
    ),
  );
}

class _NewButton extends StatelessWidget {
  const _NewButton({
    required this.model,
    required this.shell,
    this.compact = false,
  });
  final WorkshopCubit model;
  final ShellBloc shell;
  final bool compact;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: model.state.busy ? null : () => _new(context, model, shell),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(44, 64),
      backgroundColor: Spark.of(context).surface,
      foregroundColor: Spark.of(context).ink,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Row(
      mainAxisAlignment: compact
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SparkArt(
              'icons/plus',
              color: Theme.of(context).colorScheme.primary,
              width: 18,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 12),
          const Flexible(
            child: AppText(
              'Новая сборка',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
  Widget build(BuildContext context) => BlocBuilder<ShellBloc, ShellState>(
    builder: (context, state) {
      final selected = state.page == page;
      final scheme = Theme.of(context).colorScheme;
      final color = selected ? scheme.onPrimary : scheme.onSurface;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: AppTooltip(
          message: pageLabels[page]!,
          child: AnimatedContainer(
            duration: motionDuration(context, milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? scheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: InkWell(
              key: ValueKey('page-${page.name}'),
              borderRadius: BorderRadius.circular(11),
              onTap: () => context.read<ShellBloc>().add(PageSelected(page)),
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
                        child: AppText(
                          pageLabels[page]!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  final ShellBloc shell;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'НЕДАВНИЕ',
          style: TextStyle(
            color: Spark.of(context).muted,
            fontSize: 9,
            letterSpacing: 1.3,
          ),
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
                        shell.add(const PageSelected(AppPage.workspace));
                      },
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: AppText(
                  entry.title,
                  localize: false,
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
  final ShellBloc shell;
  @override
  Widget build(BuildContext context) => NavigationBar(
    height: 68,
    backgroundColor: Spark.of(context).surface,
    indicatorColor: Spark.of(context).sage,
    selectedIndex: page.index,
    onDestinationSelected: (index) =>
        shell.add(PageSelected(AppPage.values[index])),
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

class _CompactActions extends StatelessWidget {
  const _CompactActions(this.model, this.updates);
  final WorkshopCubit model;
  final AppUpdateCubit? updates;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: Row(
      children: [
        const Spacer(),
        const _SettingsButton(compact: true),
        if (updates != null) _VersionButton(updates!, model, compact: true),
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
          style: _sidebarToolStyle(context, compact),
          child: compact
              ? SparkArt(
                  'icons/${state.available ? 'download' : 'info'}',
                  width: 18,
                  label: 'Обновления приложения',
                )
              : AppText(
                  state.available ? 'Есть обновление' : 'PoB II · v$appVersion',
                  style: TextStyle(
                    fontSize: 10,
                    color: Spark.of(context).muted,
                  ),
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
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Spark.of(context).line)),
    ),
    child: Row(
      children: [
        Expanded(
          child: AppText(
            model.state.busy ? 'Выполняем операцию…' : model.state.status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Spark.of(context).muted, fontSize: 10),
          ),
        ),
        if (MediaQuery.sizeOf(context).width > 700)
          AppText(
            'ЧИСЛА И ПРАВИЛА · LUA POB',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 8,
              color: Spark.of(context).muted,
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
    color: Theme.of(context).colorScheme.errorContainer,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    child: Semantics(
      liveRegion: true,
      child: AppText(
        error,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Spark.of(context).danger, fontSize: 12),
      ),
    ),
  );
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => TextButton(
    key: const Key('appearance-settings'),
    style: _sidebarToolStyle(context, compact),
    onPressed: () => _show(context),
    child: Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SparkArt(
          'icons/settings',
          width: 18,
          label: compact ? 'Настройки' : null,
        ),
        if (!compact) ...[
          const SizedBox(width: 8),
          const Flexible(
            child: AppText(
              'Настройки',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ],
    ),
  );
  Future<void> _show(BuildContext context) async {
    final shell = context.read<ShellBloc>();
    final model = context.read<WorkshopCubit>();
    final openSetup = await sparkDialog<bool>(
      context,
      AlertDialog(
        title: const AppText('Настройки'),
        content: SizedBox(
          width: 620,
          child: BlocBuilder<ShellBloc, ShellState>(
            bloc: shell,
            builder: (context, state) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppearancePicker(),
                  const SizedBox(height: 20),
                  const LanguagePicker(),
                  const SizedBox(height: 20),
                  const InterfaceScalePicker(),
                  const SizedBox(height: 20),
                  const ShortcutSettings(),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const AppText('Плавные анимации'),
                    subtitle: const AppText(
                      'Системное уменьшение движения имеет приоритет',
                    ),
                    value: state.motion,
                    onChanged: (enabled) =>
                        shell.add(ShellMotionChanged(enabled)),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => OutlinedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const AppText('Запустить подготовку'),
            ),
          ),
          const DialogCloseButton(label: 'Готово'),
        ],
      ),
    );
    if (openSetup == true && context.mounted) {
      await showSetupWizard(context, model);
    }
  }
}

ButtonStyle _sidebarToolStyle(BuildContext context, bool compact) {
  if (!compact) {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
  return TextButton.styleFrom(
    padding: EdgeInsets.zero,
    fixedSize: const Size(36, 36),
    minimumSize: const Size(36, 36),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: Theme.of(context).colorScheme.primary
        .withValues(alpha: .12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
