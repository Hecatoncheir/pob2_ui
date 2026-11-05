import 'package:flutter/material.dart';

import '../domain/library_entry.dart';
import 'core/panels.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'shell_cubit.dart';
import 'workshop_cubit.dart';

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
                    hintText: 'Найти сборку',
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
            Text(
              'ур. ${entry.level}',
              style: Spark.mono.copyWith(fontSize: 11, color: Spark.muted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          entry.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Text(entry.characterClass, style: const TextStyle(color: Spark.muted)),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: Text(
                '${entry.updated.day.toString().padLeft(2, '0')}.${entry.updated.month.toString().padLeft(2, '0')}.${entry.updated.year}',
                style: const TextStyle(color: Spark.muted, fontSize: 10),
              ),
            ),
            TextButton(
              onPressed: model.state.busy || !model.engine.connected
                  ? null
                  : () {
                      model.openBuild(entry.id);
                      shell.page(AppPage.workspace);
                    },
              child: const Text('Открыть'),
            ),
          ],
        ),
      ],
    ),
  );
}
