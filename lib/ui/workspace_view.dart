import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'build_dialogs.dart';
import 'build_sections.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'report_views.dart';
import 'shell_cubit.dart';
import 'tree_view.dart';
import 'workshop_cubit.dart';

class WorkspaceView extends StatelessWidget {
  const WorkspaceView({super.key, required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellCubit shell;
  @override
  Widget build(BuildContext context) {
    if (model.state.report == null)
      return EmptyPanel(
        title: 'Ваша следующая сборка',
        message: model.engine.connected
            ? 'Создайте персонажа или откройте XML из PoB. Все показатели рассчитает Lua.'
            : 'Установите компоненты, чтобы открыть сборку и получить настоящий расчёт.',
        action: _emptyActions(context),
      );
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
                    child: StatisticsPanel(model: model, shell: shell),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyActions(BuildContext context) {
    if (!model.engine.connected)
      return FilledButton(
        onPressed: model.state.busy
            ? null
            : () => shell.page(AppPage.components),
        child: const Text('Настроить компоненты'),
      );
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        FilledButton(
          onPressed: model.state.busy
              ? null
              : () => showNewBuild(context, model),
          child: const Text('Новая сборка'),
        ),
        OutlinedButton(
          onPressed: model.state.busy
              ? null
              : () => showXmlImport(context, model),
          child: const Text('Открыть XML'),
        ),
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
                child: Text(
                  model.state.library.active?.title ?? report.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
            ArtIconButton(
              'copy',
              label: 'Создать копию',
              onPressed: model.state.busy ? null : model.copyBuild,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                '${report.characterClass} · уровень ${report.level}',
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
                label: Text(
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

class _Tabs extends StatelessWidget {
  const _Tabs({required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellCubit shell;
  @override
  Widget build(BuildContext context) => BlocBuilder<ShellCubit, ShellState>(
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
            ArtIconButton(
              'chart',
              label: 'Показатели',
              onPressed: () => sparkDialog<void>(
                context,
                Dialog(
                  child: SizedBox(
                    width: 330,
                    height: MediaQuery.sizeOf(context).height * .75,
                    child: StatisticsPanel(model: model, shell: shell),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton(this.tab, this.shell, {required this.selected});
  final WorkshopTab tab;
  final ShellCubit shell;
  final bool selected;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: InkWell(
      key: ValueKey('tab-${tab.name}'),
      onTap: () => shell.tab(tab),
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
            Text(
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
  final ShellCubit shell;
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
  Widget build(BuildContext context) => BlocConsumer<ShellCubit, ShellState>(
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
            ItemsView(report: document.report),
            SkillsView(model: widget.model),
            ConditionsView(model: widget.model),
            CalculationsView(report: document.report),
          ],
        ),
      );
    },
  );
}
