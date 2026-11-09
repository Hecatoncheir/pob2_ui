import 'core/app_text.dart';

import 'package:flutter/material.dart';

import '../domain/library_entry.dart';
import 'core/motion.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'shell_cubit.dart';
import 'workshop_cubit.dart';
import 'build_notes_dialog.dart';
import 'core/ui_translation.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key, required this.model, required this.shell});
  final WorkshopCubit model;
  final ShellCubit shell;
  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final entries = widget.model.state.library.entries
        .where(
          (entry) => '${entry.title} ${entry.characterClass}'
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
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
                TextField(
                  onChanged: (value) => setState(() => query = value),
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
        if (entries.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyPanel(
              title: 'Здесь будут ваши сборки',
              message: 'Создайте персонажа или откройте XML из PoB. Успешные расчёты сохраняются автоматически.',
              art: 'components',
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) => SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 430,
                mainAxisExtent: 250,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) =>
                  _BuildCard(entries[index], widget.model, widget.shell),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 26)),
      ],
    );
  }
}

class _BuildCard extends StatelessWidget {
  const _BuildCard(this.entry, this.model, this.shell);
  final LibraryEntry entry;
  final WorkshopCubit model;
  final ShellCubit shell;
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
                      shell.page(AppPage.workspace);
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
