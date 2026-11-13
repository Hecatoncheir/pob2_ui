import 'core/app_text.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/library_entry.dart';
import 'build_setup.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/search_query_bloc.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'mcp_editor_dialog.dart';
import 'pob_character_dialog.dart';
import 'shell_bloc.dart';
import 'workshop_cubit.dart';
import 'build_notes_dialog.dart';
import 'core/ui_translation.dart';
import 'pob_build_folder_actions.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key, required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellBloc shell;
  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.model.sharedLibrary?.directory != null) {
        widget.model.refreshPobBuilds();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SearchQueryBloc(),
    child: Builder(builder: _library),
  );

  Widget _library(BuildContext context) {
    final model = widget.model;
    final step = model.sharedLibrary == null ? null : BuildSetup.pending(model);
    if (!model.buildFolderReady && step != null) {
      return EmptyPanel(
        title: 'Мои сборки',
        message: step.message,
        art: 'components',
        action: BuildSetupAction(step, model),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  'Мои сборки',
                  subtitle: 'Идеи, к которым хочется вернуться',
                ),
                _libraryActions(context, step),
                TextField(
                  key: const Key('library-search'),
                  controller: _search,
                  onChanged: (value) => context.read<SearchQueryBloc>().add(
                    SearchQueryChanged(value),
                  ),
                  decoration: const InputDecoration(
                    hint: AppText('Найти сборку'),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(13),
                      child: SparkArt('icons/search', width: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        BlocBuilder<SearchQueryBloc, String>(builder: _results),
        const SliverToBoxAdapter(child: SizedBox(height: 26)),
      ],
    );
  }

  Widget _libraryActions(BuildContext context, BuildSetup? step) {
    final model = widget.model;
    final busy = model.state.busy;
    final hasFolder = model.sharedLibrary != null;
    final canImport = model.pobWindow.supported && step == null;
    final canEdit = model.mcpEditor.canEnable;
    if (!hasFolder && !canImport && !canEdit) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          if (step != null) BuildSetupAction(step, model),
          if (canImport) ...[
            OutlinedButton.icon(
              key: const Key('import-from-pob'),
              onPressed: busy || !model.engine.connected
                  ? null
                  : model.importFromPob,
              icon: const SparkArt('icons/upload', width: 16),
              label: const AppText('Импортировать из PoB'),
            ),
            PobCharacterImportButton(model),
          ],
          if (canEdit) McpEditorButton(model, outlined: true),
          if (hasFolder)
            OutlinedButton.icon(
              key: const Key('build-folder-menu'),
              onPressed: busy ? null : () => showPobBuildFolder(context, model),
              icon: const Icon(Icons.folder_open_outlined, size: 16),
              label: const AppText('Папка сборок'),
            ),
        ],
      ),
    );
  }

  Widget _results(BuildContext context, String query) {
    final model = widget.model;
    final entries = model.state.library.entries
        .where(
          (entry) => '${entry.title} ${entry.characterClass}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    if (entries.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: query.isNotEmpty
            ? _noMatches(context)
            : const EmptyPanel(
                title: 'Здесь будут ваши сборки',
                message: 'Создайте персонажа или откройте XML из PoB. Успешные расчёты сохраняются автоматически.',
                art: 'components',
              ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 430,
          mainAxisExtent: 250,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) =>
            _BuildCard(entries[index], model, widget.shell),
      ),
    );
  }

  Widget _noMatches(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppText('Ничего не найдено'),
        TextButton(
          onPressed: () {
            _search.clear();
            context.read<SearchQueryBloc>().add(const SearchQueryChanged(''));
          },
          child: const AppText('Очистить поиск'),
        ),
      ],
    ),
  );
}

class _BuildCard extends StatelessWidget {
  const _BuildCard(this.entry, this.model, this.shell);
  final LibraryEntry entry;
  final WorkshopCubit model;
  final ShellBloc shell;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SparkArt('illustrations/gem', width: 60, height: 55),
            const Spacer(),
            AppText(
              'ур. ${entry.level}',
              style: Spark.mono.copyWith(
                fontSize: 11,
                color: Spark.of(context).muted,
              ),
            ),
            ArtIconButton(
              'trash',
              key: ValueKey('delete-build-${entry.id}'),
              label: 'Удалить сборку',
              onPressed: model.state.busy
                  ? null
                  : () => _confirmDelete(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppText(
          entry.title,
          localize: false,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        AppText(
          entry.characterClass,
          game: true,
          style: TextStyle(color: Spark.of(context).muted),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: AppText(
                '${entry.updated.day.toString().padLeft(2, '0')}.${entry.updated.month.toString().padLeft(2, '0')}.${entry.updated.year}',
                style: TextStyle(color: Spark.of(context).muted, fontSize: 10),
              ),
            ),
            IconButton(
              tooltip: translateUi(context, 'Заметки к сборке'),
              onPressed: () => showBuildNotes(context, model, entry.id),
              icon: const Icon(Icons.notes_rounded, size: 18),
            ),
            TextButton(
              onPressed: model.state.busy || !model.engine.connected
                  ? null
                  : () {
                      model.openBuild(entry.id);
                      shell.add(const PageSelected(AppPage.workspace));
                    },
              child: const AppText('Открыть'),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _confirmDelete(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await sparkDialog<bool>(
      context,
      AlertDialog(
        title: const AppText('Удалить сборку?'),
        content: AppText(entry.title, localize: false),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: const AppText('Отмена'),
          ),
          FilledButton(
            key: const Key('confirm-delete-build'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const AppText('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await model.deleteBuild(entry.id);
  }
}
