import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/skill_gem.dart';
import '../domain/build_report.dart';
import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'skill_group_cubit.dart';
import 'skill_gem_catalog_tile.dart';
import 'skill_group_composer.dart';
import 'gem_drag.dart';
import 'workshop_cubit.dart';

Future<void> showSkillGroupEditor(
  BuildContext context,
  WorkshopCubit model, {
  JsonMap? group,
}) async {
  try {
    final initial = group == null ? const <GemDraft>[] : groupGemDrafts(group);
    await sparkDialog<void>(
      context,
      _SkillGroupDialog(model, group, initial),
      barrierDismissible: false,
    );
  } on FormatException catch (error) {
    if (context.mounted)
      await sparkDialog<void>(
        context,
        AlertDialog(
          title: const AppText('Группа недоступна для редактирования'),
          content: AppText(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText('Закрыть'),
            ),
          ],
        ),
      );
  }
}

class _SkillGroupDialog extends StatefulWidget {
  const _SkillGroupDialog(this.model, this.group, this.initial);
  final WorkshopCubit model;
  final JsonMap? group;
  final List<GemDraft> initial;
  @override
  State<_SkillGroupDialog> createState() => _SkillGroupDialogState();
}

class _SkillGroupDialogState extends State<_SkillGroupDialog> {
  late final AppLifecycleListener exitListener;
  late final editor = SkillGroupCubit(
    widget.model.catalogs,
    widget.group == null
        ? widget.model.addSkillGroup
        : (label, gems) => widget.model.updateSkillGroup(
            widget.group!['id'] as int,
            label,
            gems,
          ),
    groupId: widget.group?['id'] as int?,
    initial: widget.initial,
    label: widget.group?['customLabel'] as String? ?? '',
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
            title: AppText(_title),
            content: SizedBox(
              width: 1100,
              height: (MediaQuery.sizeOf(context).height * .65).clamp(250, 570),
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('skill-group-label'),
                    initialValue: state.label,
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
                child: AppText(_saveLabel(state)),
              ),
            ],
          ),
        ),
      );
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (await editor.save() && mounted) Navigator.pop(context);
  }

  String get _title =>
      widget.group == null ? 'Новая группа умений' : 'Редактор группы умений';
  String _saveLabel(SkillGroupState state) {
    if (state.saving) return 'Расчёт…';
    return widget.group == null
        ? 'Добавить и рассчитать'
        : 'Сохранить и рассчитать';
  }
}

class _GemPanes extends StatelessWidget {
  const _GemPanes(this.editor, this.state);
  final SkillGroupCubit editor;
  final SkillGroupState state;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final catalog = SkillGemCatalog(editor, state);
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

class SkillGemCatalog extends StatelessWidget {
  const SkillGemCatalog(
    this.editor,
    this.state, {
    super.key,
    this.supportsOnly = false,
    this.onAdd,
    this.onReturn,
    this.searchKey = const Key('gem-search'),
  });
  final SkillGroupCubit editor;
  final SkillGroupState state;
  final bool supportsOnly;
  final Key searchKey;
  final void Function(SkillGem gem)? onAdd;
  final void Function(GemDrag data)? onReturn;
  bool get supportMode => supportsOnly || state.showSupports;
  @override
  Widget build(BuildContext context) => DragTarget<GemDrag>(
    key: const Key('gem-return-target'),
    onWillAcceptWithDetails: (details) =>
        !state.saving &&
        details.data.gem.support &&
        (onReturn != null
            ? details.data.groupId != null
            : details.data.draftKey != null &&
                  details.data.groupId == editor.groupId),
    onAcceptWithDetails: (details) {
      if (onReturn case final action?)
        action(details.data);
      else
        editor.remove(details.data.draftKey!);
    },
    builder: (context, candidates, _) => DecoratedBox(
      decoration: BoxDecoration(
        color: candidates.isEmpty
            ? null
            : Spark.of(context).danger.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: _catalog(context),
    ),
  );

  Widget _catalog(BuildContext context) {
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
        if (!supportsOnly)
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
            key: searchKey,
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
    if (!supportMode) return !gem.support;
    return gem.support &&
        state.support.ids.contains(gem.id) &&
        !state.gems.any((draft) => draft.gem.id == gem.id);
  }

  Widget _results(BuildContext context, List<SkillGem> entries) {
    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (supportMode && state.support.loading)
      return const Center(child: CircularProgressIndicator());
    if (supportMode && state.support.error != null)
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
    if (!supportMode)
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
          if (onAdd case final action?)
            action(gem);
          else {
            editor.add(gem);
            DefaultTabController.maybeOf(context)?.animateTo(1);
          }
        },
      );
}
