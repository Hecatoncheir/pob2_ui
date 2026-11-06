import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/skill_gem.dart';
import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'skill_group_cubit.dart';
import 'skill_gem_catalog_tile.dart';
import 'skill_group_composer.dart';
import 'workshop_cubit.dart';

Future<void> showSkillGroupEditor(BuildContext context, WorkshopCubit model) =>
    sparkDialog<void>(
      context,
      _SkillGroupDialog(model),
      barrierDismissible: false,
    );

class _SkillGroupDialog extends StatefulWidget {
  const _SkillGroupDialog(this.model);
  final WorkshopCubit model;
  @override
  State<_SkillGroupDialog> createState() => _SkillGroupDialogState();
}

class _SkillGroupDialogState extends State<_SkillGroupDialog> {
  late final AppLifecycleListener exitListener;
  late final editor = SkillGroupCubit(
    widget.model.catalogs,
    widget.model.addSkillGroup,
  );
  @override
  void initState() {
    super.initState();
    exitListener = AppLifecycleListener(
      onExitRequested: () async =>
          editor.mayExit() ? AppExitResponse.exit : AppExitResponse.cancel,
    );
    editor.load();
  }

  @override
  void dispose() {
    exitListener.dispose();
    editor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SkillGroupCubit, SkillGroupState>(
        bloc: editor,
        builder: (context, state) => PopScope(
          canPop: !state.saving,
          child: AlertDialog(
            insetPadding: const EdgeInsets.all(18),
            title: const AppText('Новая группа умений'),
            content: SizedBox(
              width: 1100,
              height: (MediaQuery.sizeOf(context).height * .65).clamp(250, 570),
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('skill-group-label'),
                    enabled: !state.saving,
                    onChanged: editor.label,
                    decoration: const InputDecoration(
                      label: AppText('Название группы'),
                      hint: AppText('Необязательно'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _GemPanes(editor, state)),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppText(
                        state.error!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Spark.of(context).danger),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                key: const Key('skill-group-cancel'),
                onPressed: state.saving ? null : () => Navigator.pop(context),
                child: const AppText('Отмена'),
              ),
              FilledButton(
                key: const Key('skill-group-save'),
                onPressed: state.canSave ? _save : null,
                child: AppText(
                  state.saving ? 'Расчёт…' : 'Добавить и рассчитать',
                ),
              ),
            ],
          ),
        ),
      );
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (await editor.save() && mounted) Navigator.pop(context);
  }
}

class _GemPanes extends StatelessWidget {
  const _GemPanes(this.editor, this.state);
  final SkillGroupCubit editor;
  final SkillGroupState state;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final catalog = _GemCatalog(editor, state);
      final chosen = SkillGroupComposer(editor: editor, state: state);
      if (constraints.maxWidth >= 620) {
        return Row(
          children: [
            Expanded(child: catalog),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: chosen),
          ],
        );
      }
      return DefaultTabController(
        length: 2,
        animationDuration: motionDuration(context, milliseconds: 200),
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(child: AppText('Каталог')),
                Tab(child: AppText('Выбрано')),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: TabBarView(children: [catalog, chosen])),
          ],
        ),
      );
    },
  );
}

class _GemCatalog extends StatelessWidget {
  const _GemCatalog(this.editor, this.state);
  final SkillGroupCubit editor;
  final SkillGroupState state;
  @override
  Widget build(BuildContext context) {
    final query = state.query.trim().toLowerCase();
    final entries = state.catalog
        .where(
          (gem) =>
              '${gem.id} ${gem.name} ${translateGame(context, gem.name)}'
                  .toLowerCase()
                  .contains(query) &&
              _visible(gem),
        )
        .toList();
    return Column(
      children: [
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const AppText('Умения'),
              selected: !state.showSupports,
              onSelected: state.saving
                  ? null
                  : (_) => editor.chooseSupports(false),
            ),
            ChoiceChip(
              label: const AppText('Подходящие поддержки'),
              selected: state.showSupports,
              onSelected: state.saving || state.gems.isEmpty
                  ? null
                  : (_) => editor.chooseSupports(true),
            ),
          ],
        ),
        const SizedBox(height: 10),
        KeyedSubtree(
          key: ValueKey(state.showSupports),
          child: TextFormField(
            key: const Key('gem-search'),
            initialValue: state.query,
            enabled: !state.saving,
            onChanged: editor.search,
            decoration: const InputDecoration(
              hint: AppText('Найти камень'),
              prefixIcon: Icon(Icons.search, size: 19),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _results(context, entries)),
      ],
    );
  }

  bool _visible(SkillGem gem) {
    if (!state.showSupports) return !gem.support;
    return gem.support &&
        state.support.ids.contains(gem.id) &&
        !state.gems.any((draft) => draft.gem.id == gem.id);
  }

  Widget _results(BuildContext context, List<SkillGem> entries) {
    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.showSupports && state.support.loading)
      return const Center(child: CircularProgressIndicator());
    if (state.showSupports && state.support.error != null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(state.support.error!),
            TextButton(
              onPressed: editor.refreshSupports,
              child: const AppText('Повторить'),
            ),
          ],
        ),
      );
    if (state.catalog.isEmpty && state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(state.error!),
            TextButton(
              onPressed: editor.load,
              child: const AppText('Повторить загрузку'),
            ),
          ],
        ),
      );
    }
    if (entries.isEmpty)
      return const Center(child: AppText('Камни не найдены'));
    if (!state.showSupports)
      return ListView.separated(
        key: const Key('gem-catalog'),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            _tile(context, entries[index], compact: true),
      );
    return GridView.builder(
      key: const Key('gem-catalog'),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisExtent: 132,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) => _tile(context, entries[index]),
    );
  }

  Widget _tile(BuildContext context, SkillGem gem, {bool compact = false}) =>
      SkillGemCatalogTile(
        key: ValueKey('catalog-gem-${gem.id}'),
        gem: gem,
        saving: state.saving,
        repository: editor.repository,
        compact: compact,
        add: () {
          editor.add(gem);
          DefaultTabController.maybeOf(context)?.animateTo(1);
        },
      );
}
