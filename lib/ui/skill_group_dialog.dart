import 'dart:ui' show AppExitResponse;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/skill_gem.dart';
import '../domain/build_report.dart';
import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'core/ui_translation.dart';
import 'skill_group_cubit.dart';
import 'skill_gem_catalog_tile.dart';
import 'skill_group_composer.dart';
import 'skill_support_preview.dart';
import 'skill_support_target_picker.dart';
import 'skill_socket_summary.dart';
import 'support_comparison_dialog.dart';
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
    group: widget.group,
    contextVersion: () => widget.model.state.report,
    contextChanges: widget.model.stream.map((state) => state.report).distinct(),
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
                  if (!editor.locksPrimary) ...[
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
                  ],
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
                onPressed:
                    state.canSave && (!editor.locksPrimary || editor.dirty)
                    ? _save
                    : null,
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
    onWillAcceptWithDetails: (details) => _canReturn(details.data),
    onAcceptWithDetails: (details) => _returnGem(details.data),
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

  bool _canReturn(GemDrag data) {
    if (state.saving || !data.gem.support) return false;
    if (onReturn != null) return data.groupId != null;
    return data.draftKey != null && data.groupId == editor.groupId;
  }

  void _returnGem(GemDrag data) {
    if (onReturn case final action?) {
      action(data);
    } else {
      editor.remove(data.draftKey!);
    }
  }

  Widget _catalog(BuildContext context) {
    if (editor.supportScope == 'none') {
      return const Center(
        child: AppText('Для этого умения нельзя добавить поддержки'),
      );
    }
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
    return CustomScrollView(
      key: const Key('gem-catalog'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (supportsOnly && state.activeGems.length > 1)
                SkillSupportTargetPicker(
                  editor,
                  state,
                  key: const Key('workspace-support-target'),
                ),
              if (editor.supportScope == 'slot')
                const AppText(
                  'Поддержки общие для умений этого слота',
                  style: TextStyle(fontSize: 11),
                ),
              if (!supportsOnly && !editor.locksPrimary)
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
                      onSelected: state.saving || state.supportTarget == null
                          ? null
                          : (_) => editor.chooseSupports(true),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              if (supportMode &&
                  !state.support.loading &&
                  state.supportTarget != null) ...[
                SkillSocketSummary(state),
                const SizedBox(height: 8),
              ],
              KeyedSubtree(
                key: ValueKey(state.showSupports),
                child: TextFormField(
                  key: searchKey,
                  initialValue: state.query,
                  enabled: !state.saving,
                  onChanged: editor.search,
                  decoration: InputDecoration(
                    hint: const AppText('Найти камень'),
                    prefixIcon: const Icon(Icons.search, size: 19),
                    suffixIcon: _comparisonButton(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        _results(context, entries),
      ],
    );
  }

  Widget? _comparisonButton(BuildContext context) {
    if (!supportMode || !editor.repository.hasSupportComparison) return null;
    return IconButton(
      key: const Key('compare-supports'),
      tooltip: translateUi(context, 'Сравнить поддержки'),
      onPressed: editor.canCompareSupports
          ? () => showSupportComparison(context, editor)
          : null,
      icon: const Icon(Icons.compare_arrows, size: 18),
    );
  }

  bool _visible(SkillGem gem) {
    if (!supportMode) return !gem.support;
    return gem.support &&
        state.support.ids.contains(gem.id) &&
        !state.gems.any((draft) => draft.gem.id == gem.id);
  }

  Widget _results(BuildContext context, List<SkillGem> entries) {
    if (state.loading || supportMode && state.support.loading)
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(key: Key('gem-catalog-loading')),
        ),
      );
    if (supportMode && state.support.error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _loadError(
          state.support.error!,
          'Повторить',
          editor.refreshSupports,
        ),
      );
    }
    if (state.catalog.isEmpty && state.error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _loadError(state.error!, 'Повторить загрузку', editor.load),
      );
    }
    if (entries.isEmpty)
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: AppText('Камни не найдены')),
      );
    if (!supportMode)
      return SliverList.separated(
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            _tile(context, entries[index], compact: true),
      );
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisExtent: editor.repository.hasSupportPreview ? 158 : 132,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) => _tile(context, entries[index]),
    );
  }

  Widget _loadError(String error, String label, VoidCallback retry) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(error),
        TextButton(onPressed: retry, child: AppText(label)),
      ],
    ),
  );

  Widget _tile(BuildContext context, SkillGem gem, {bool compact = false}) =>
      SkillGemCatalogTile(
        key: ValueKey('catalog-gem-${gem.id}'),
        gem: gem,
        saving: state.saving,
        repository: editor.repository,
        compact: compact,
        preview: editor.canPreviewSupport(gem)
            ? () => showSkillSupportPreview(
                context,
                gem,
                state.supportTarget!.gem,
                () => editor.previewSupport(gem),
              )
            : null,
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
