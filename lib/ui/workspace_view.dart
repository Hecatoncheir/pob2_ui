import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/ui_translation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/tree_progression_repository.dart';
import 'build_dialogs.dart';
import 'build_setup.dart';
import 'build_sections.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'mcp_editor_cubit.dart';
import 'mcp_editor_dialog.dart';
import 'pob_character_dialog.dart';
import 'report_views.dart';
import 'shell_bloc.dart';
import 'tree_view.dart';
import 'tree_progression_bloc.dart';
import 'workspace_inspector.dart';
import 'workshop_cubit.dart';
import 'workshop_state.dart';
import 'build_notes_dialog.dart';

class WorkspaceView extends StatelessWidget {
  const WorkspaceView({super.key, required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellBloc shell;
  @override
  Widget build(BuildContext context) {
    if (model.state.report == null) {
      final step = BuildSetup.pending(model);
      return EmptyPanel(
        title: 'Ваша следующая сборка',
        message: step?.message ?? 'Создайте персонажа или откройте XML из PoB. Все показатели рассчитает Lua.',
        action: step == null
            ? _buildActions(context)
            : BuildSetupAction(step, model),
      );
    }
    return BlocListener<McpEditorCubit, McpEditorState>(
      bloc: model.mcpEditor,
      listenWhen: (before, after) =>
          before.change != after.change && after.change != null,
      listener: (context, state) =>
          shell.add(WorkshopTabSelected(state.change!.tab)),
      child: _withPlan(_workspace(context)),
    );
  }

  Widget _withPlan(Widget child) {
    final document = model.state.document!;
    final id = model.state.library.activeId;
    final tree = document.tree;
    if (id == null || tree == null) return child;
    final key = (
      folder: model.sharedLibrary?.directory ?? '',
      build: id,
      version: tree.version,
      characterClass: document.report.characterClass,
    );
    return BlocProvider(
      key: ValueKey(key),
      create: (_) => TreeProgressionBloc(
        TreeProgressionRepository(model.components.store.root, key),
      )..add(const TreeProgressionOpened()),
      child: child,
    );
  }

  Widget _workspace(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 650 ? 14 : 24),
      child: Column(
        children: [
          _WorkspaceHeading(model),
          const SizedBox(height: 20),
          _Tabs(model: model, shell: shell),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _EditorStage(model: model, shell: shell),
                ),
                if (MediaQuery.sizeOf(context).width >= 1100) ...[
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 284,
                    child: WorkspaceInspector(model: model, shell: shell),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final busy = model.state.busy;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        FilledButton(
          onPressed: busy ? null : () => showNewBuild(context, model),
          child: const AppText('Новая сборка'),
        ),
        OutlinedButton(
          onPressed: busy ? null : () => showXmlImport(context, model),
          child: const AppText('Открыть XML'),
        ),
        if (model.pobWindow.supported) ...[
          OutlinedButton(
            key: const Key('import-from-pob'),
            onPressed: busy ? null : model.importFromPob,
            child: const AppText('Импортировать из PoB'),
          ),
          PobCharacterImportButton(model),
        ],
      ],
    );
  }
}

class _WorkspaceHeading extends StatelessWidget {
  const _WorkspaceHeading(this.model);
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) {
    final report = model.state.report!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: model.state.busy
                    ? null
                    : () => renameBuild(context, model),
                child: AppText(
                  model.state.library.active?.title ?? report.name,
                  localize: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _historyButtons(context, model),
            McpEditorButton(model),
            ArtIconButton(
              'upload',
              label: 'Открыть XML',
              onPressed: model.state.busy
                  ? null
                  : () => showXmlImport(context, model),
            ),
            ArtIconButton(
              'download',
              label: 'Экспорт XML',
              onPressed: model.state.busy
                  ? null
                  : () => exportXml(context, model),
            ),
            _BuildMenu(model),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: AppText(
                '${translateGame(context, report.characterClass)} · уровень ${report.level}',
                style: TextStyle(color: Spark.of(context).muted, fontSize: 11),
              ),
            ),
            if (report.warnings.isNotEmpty)
              TextButton.icon(
                onPressed: () => showWarnings(context, report),
                style: TextButton.styleFrom(
                  foregroundColor: Spark.of(context).danger,
                  minimumSize: const Size(0, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: SparkArt(
                  'icons/info',
                  width: 14,
                  color: Spark.of(context).danger,
                ),
                label: AppText(
                  'Предупреждения: ${report.warnings.length}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            if (MediaQuery.sizeOf(context).width >= 650)
              DotLabel(
                model.state.document!.stale ? 'Ожидает расчёта' : 'Сохранено',
                active: !model.state.document!.stale,
              ),
          ],
        ),
      ],
    );
  }
}

Widget _historyButtons(BuildContext context, WorkshopCubit model) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      key: const Key('undo-build'),
      tooltip: translateUi(context, 'Отменить действие'),
      onPressed: model.state.busy || model.state.undoCount == 0
          ? null
          : model.undo,
      icon: const Icon(Icons.undo_rounded, size: 20),
    ),
    IconButton(
      key: const Key('redo-build'),
      tooltip: translateUi(context, 'Повторить действие'),
      onPressed: model.state.busy || model.state.redoCount == 0
          ? null
          : model.redo,
      icon: const Icon(Icons.redo_rounded, size: 20),
    ),
  ],
);

class _BuildMenu extends StatelessWidget {
  const _BuildMenu(this.model);
  final WorkshopCubit model;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: translateUi(context, 'Ещё'),
    enabled: !model.state.busy,
    icon: const Icon(Icons.more_horiz, size: 20),
    itemBuilder: (_) => [
      const PopupMenuItem(value: 'notes', child: AppText('Заметки к сборке')),
      if (model.pobWindow.supported)
        PopupMenuItem(
          key: const Key('import-from-pob'),
          enabled: model.engine.connected,
          value: 'import-pob',
          child: const AppText('Импортировать из PoB'),
        ),
      if (model.pobWindow.supported)
        PopupMenuItem(
          enabled: model.engine.connected,
          value: 'import-character',
          child: const AppText('Импортировать персонажа'),
        ),
      const PopupMenuItem(value: 'paste', child: AppText('Вставить XML')),
      const PopupMenuItem(value: 'xml', child: AppText('Скопировать XML')),
      const PopupMenuItem(value: 'copy', child: AppText('Создать копию')),
    ],
    onSelected: (value) => _select(context, value),
  );
  void _select(BuildContext context, String value) {
    switch (value) {
      case 'notes':
        final id = model.state.library.activeId;
        if (id != null) showBuildNotes(context, model, id);
      case 'paste':
        showXmlPaste(context, model);
      case 'import-pob':
        model.importFromPob();
      case 'import-character':
        showPobCharacterImport(context, model);
      case 'xml':
        showXmlCopy(context, model);
      case 'copy':
        model.copyBuild();
    }
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellBloc shell;
  @override
  Widget build(BuildContext context) => BlocBuilder<ShellBloc, ShellState>(
    bloc: shell,
    builder: (context, state) => Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Spark.of(context).line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: WorkshopTab.values
                    .map(
                      (tab) =>
                          _TabButton(tab, shell, selected: state.tab == tab),
                    )
                    .toList(),
              ),
            ),
          ),
          if (MediaQuery.sizeOf(context).width < 1100)
            _statisticsButton(context),
        ],
      ),
    ),
  );

  Widget _statisticsButton(BuildContext context) {
    final plan = context.read<TreeProgressionBloc?>();
    Future<void> open() async {
      await sparkDialog<void>(
        context,
        Dialog(
          child: SizedBox(
            width: 330,
            height: MediaQuery.sizeOf(context).height * .75,
            child: _dialogInspector(plan),
          ),
        ),
      );
      if (plan != null && !plan.isClosed) {
        plan.add(const TreeProgressionNodeHovered(null));
      }
    }

    const icon = Icons.leaderboard_outlined;
    const key = Key('open-statistics');
    if (MediaQuery.sizeOf(context).width >= 650) {
      return TextButton.icon(
        key: key,
        onPressed: open,
        icon: const Icon(icon, size: 20),
        label: const AppText('Показатели'),
      );
    }
    return ArtIconButton.material(
      icon,
      key: key,
      label: 'Показатели',
      onPressed: open,
    );
  }

  Widget _dialogInspector(TreeProgressionBloc? plan) {
    final inspector = BlocBuilder<WorkshopCubit, WorkshopState>(
      bloc: model,
      builder: (context, state) => state.report == null
          ? const SizedBox.shrink()
          : WorkspaceInspector(model: model, shell: shell, inDialog: true),
    );
    return plan == null
        ? inspector
        : BlocProvider.value(value: plan, child: inspector);
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(this.tab, this.shell, {required this.selected});
  final WorkshopTab tab;
  final ShellBloc shell;
  final bool selected;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: InkWell(
      key: ValueKey('tab-${tab.name}'),
      onTap: () => shell.add(WorkshopTabSelected(tab)),
      child: AnimatedContainer(
        duration: motionDuration(context, milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(4, 12, 18, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: selected ? Spark.of(context).ink : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            SparkArt(
              'icons/${tabIcons[tab]}',
              width: 17,
              color: selected ? Spark.of(context).ink : Spark.of(context).muted,
            ),
            const SizedBox(width: 7),
            AppText(
              tabLabels[tab]!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Spark.of(context).ink
                    : Spark.of(context).muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EditorStage extends StatefulWidget {
  const _EditorStage({required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellBloc shell;
  @override
  State<_EditorStage> createState() => _EditorStageState();
}

class _EditorStageState extends State<_EditorStage>
    with SingleTickerProviderStateMixin {
  late final animation = AnimationController(vsync: this, value: 1);
  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ShellBloc, ShellState>(
    bloc: widget.shell,
    listenWhen: (before, after) => before.tab != after.tab,
    listener: (context, _) {
      animation.duration = motionDuration(context, milliseconds: 300);
      animation.forward(from: 0);
    },
    builder: (context, state) {
      final document = widget.model.state.document!;
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Spark.curve),
        child: IndexedStack(
          index: state.tab.index,
          children: [
            document.tree == null
                ? EmptyPanel(
                    title: 'Дерево пока недоступно',
                    message:
                        document.treeError ?? 'Попробуйте пересчитать сборку.',
                  )
                : TreeView(model: widget.model, tree: document.tree!),
            ItemsView(model: widget.model),
            SkillsView(model: widget.model),
            ConditionsView(model: widget.model),
            CalculationsView(report: document.report),
          ],
        ),
      );
    },
  );
}
