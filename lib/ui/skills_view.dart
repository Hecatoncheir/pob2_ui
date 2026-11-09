import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/build_report.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'core/spark_theme.dart';
import 'skill_group_dialog.dart';
import 'skill_group_list_row.dart';
import 'skill_workspace_cubit.dart';
import 'workshop_cubit.dart';

class SkillsView extends StatefulWidget {
  const SkillsView({super.key, required this.model});
  final WorkshopCubit model;
  @override
  State<SkillsView> createState() => _SkillsViewState();
}

class _SkillsViewState extends State<SkillsView> {
  late final workspace = SkillWorkspaceCubit(widget.model);
  late final AppLifecycleListener exitListener;
  @override
  void initState() {
    super.initState();
    exitListener = AppLifecycleListener(
      onExitRequested: () async =>
          workspace.state.busy ? AppExitResponse.cancel : AppExitResponse.exit,
    );
    workspace.initialize();
  }

  @override
  void dispose() {
    exitListener.dispose();
    workspace.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SkillWorkspaceCubit, SkillWorkspaceState>(
        bloc: workspace,
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.busy)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  FilledButton.icon(
                    key: const Key('add-skill-group'),
                    onPressed: _busy
                        ? null
                        : () => showSkillGroupEditor(context, widget.model),
                    icon: const Icon(Icons.add, size: 18),
                    label: const AppText('Новая группа'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (state.error case final error?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppText(
                    error,
                    style: TextStyle(color: Spark.of(context).danger),
                  ),
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final groups = _groups(state);
                    final library = _library(state);
                    if (constraints.maxWidth >= 620)
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: groups),
                          const SizedBox(width: 18),
                          Expanded(flex: 2, child: library),
                        ],
                      );
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(child: AppText('Группы')),
                              Tab(child: AppText('Камни поддержки')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TabBarView(children: [groups, library]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  bool get _busy =>
      workspace.state.busy ||
      widget.model.state.busy ||
      !widget.model.engine.connected;

  Widget _groups(SkillWorkspaceState state) {
    final groups = widget.model.state.report!.skillGroups.toList();
    if (groups.isEmpty)
      return const EmptyPanel(
        title: 'Умения ещё не добавлены',
        message: 'Добавьте группу камней, чтобы получить расчёт умения.',
        art: 'gem',
      );
    return ListView.separated(
      key: const Key('skill-groups-list'),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = groups[index];
        final id = group['id'] as int;
        return SkillGroupListRow(
          key: ValueKey('skill-group-$id'),
          group: group,
          repository: widget.model.catalogs,
          selected: state.groupId == id,
          main: widget.model.state.report!.groupSelector['selected'] == id,
          busy: _busy,
          select: () => workspace.select(id),
          edit: () => _edit(group),
          chooseMain: () => _chooseMain(id),
          add: (data) => workspace.add(id, data),
          remove: () => workspace.delete(id),
        );
      },
    );
  }

  Future<void> _edit(JsonMap group) async {
    await workspace.select(group['id'] as int);
    if (mounted)
      await showSkillGroupEditor(context, widget.model, group: group);
  }

  Future<void> _chooseMain(int id) async {
    await workspace.select(id);
    await widget.model.selectMain('groups', id);
  }

  Widget _library(SkillWorkspaceState state) {
    final editor = workspace.editor;
    if (editor == null || state.draft == null)
      return const SurfacePanel(
        child: Center(child: AppText('Выберите умение для подбора поддержек')),
      );
    return SurfacePanel(
      key: const Key('skills-support-library'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppText(
            'Камни поддержки',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          AppText(
            editor.state.gems.first.gem.name,
            game: true,
            style: TextStyle(fontSize: 12, color: Spark.of(context).muted),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AbsorbPointer(
              absorbing: _busy,
              child: SkillGemCatalog(
                editor,
                state.draft!,
                key: ValueKey('group-catalog-${state.groupId}'),
                supportsOnly: true,
                searchKey: const Key('support-search'),
                onAdd: (gem) => workspace.add(state.groupId!, (
                  gem: gem,
                  draftKey: null,
                  groupId: null,
                  sourceIndex: null,
                )),
                onReturn: workspace.remove,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const AppText(
            'Перенос в список добавляет поддержку, обратно — убирает',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
