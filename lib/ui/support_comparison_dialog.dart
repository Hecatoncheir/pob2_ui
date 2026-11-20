import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/build_report.dart';
import '../domain/support_comparison.dart';
import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/motion.dart';
import 'core/spark_theme.dart';
import 'skill_group_cubit.dart';
import 'skill_support_preview.dart';
import 'support_comparison_cubit.dart';

Future<void> showSupportComparison(
  BuildContext context,
  SkillGroupCubit editor,
) => sparkDialog<void>(context, _SupportComparisonDialog(editor));

class _SupportComparisonDialog extends StatefulWidget {
  const _SupportComparisonDialog(this.editor);
  final SkillGroupCubit editor;
  @override
  State<_SupportComparisonDialog> createState() =>
      _SupportComparisonDialogState();
}

class _SupportComparisonDialogState extends State<_SupportComparisonDialog>
    with SingleTickerProviderStateMixin {
  late final model = SupportComparisonCubit(widget.editor);
  late final target = widget.editor.state.supportTarget!.gem;
  late final tabs = TabController(length: 2, vsync: this);
  @override
  void dispose() {
    model.close();
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SupportComparisonCubit, SupportComparisonState>(
    bloc: model,
    builder: (context, state) => AlertDialog(
      insetPadding: const EdgeInsets.all(18),
      title: const AppText('Сравнение поддержек'),
      content: SizedBox(
        width: 1000,
        height: (MediaQuery.sizeOf(context).height * .7).clamp(280, 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(target.name, game: true),
            const SizedBox(height: 8),
            const AppText(
              'Уровень поддержек — 1, качество — 0. Сравнение только по DPS.',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final children = [
                    Expanded(child: _candidates(state)),
                    const SizedBox(width: 18, height: 12),
                    Expanded(flex: 2, child: _results(state)),
                  ];
                  return constraints.maxWidth >= 650
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        )
                      : Column(
                          children: [
                            TabBar(
                              controller: tabs,
                              tabs: const [
                                Tab(child: AppText('Камни поддержки')),
                                Tab(child: AppText('Результаты')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TabBarView(
                                controller: tabs,
                                children: [_candidates(state), _results(state)],
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),
            if (state.error != null)
              AppText(
                state.error!,
                style: TextStyle(color: Spark.of(context).danger),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('support-comparison-close'),
          onPressed: () => Navigator.pop(context),
          child: const AppText('Закрыть'),
        ),
        FilledButton(
          key: const Key('support-comparison-calculate'),
          onPressed: state.loading || state.invalid || state.selected.isEmpty
              ? null
              : () {
                  model.calculate();
                  tabs.animateTo(1);
                },
          child: AppText(
            state.loading ? 'Расчёт поддержек…' : 'Рассчитать сравнение',
          ),
        ),
      ],
    ),
  );

  Widget _candidates(SupportComparisonState state) {
    final query = state.query.trim().toLowerCase();
    final gems = model.candidates
        .where(
          (gem) => '${gem.name} ${translateGame(context, gem.name)} ${gem.id}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('support-comparison-search'),
          onChanged: model.search,
          decoration: const InputDecoration(hint: AppText('Найти камень')),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            const AppText('Выбрано поддержек:'),
            Text('${state.selected.length} / 8'),
          ],
        ),
        Expanded(
          child: ListView.builder(
            key: const Key('support-comparison-candidates'),
            itemCount: gems.length,
            itemBuilder: (context, index) {
              final gem = gems[index];
              return CheckboxListTile(
                key: ValueKey('compare-support-${gem.id}'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: AppText(gem.name, game: true),
                value: state.selected.contains(gem.id),
                onChanged: state.loading || state.invalid
                    ? null
                    : (_) => model.toggle(gem.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _results(SupportComparisonState state) {
    if (state.loading) return const Center(child: CircularProgressIndicator());
    final result = state.result;
    if (result == null)
      return const Center(
        child: AppText(
          'Выберите поддержки для сравнения. Сборка не изменится.',
        ),
      );
    return ListView.separated(
      key: const Key('support-comparison-results'),
      itemCount: result.entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _result(result.ranked[index]),
    );
  }

  Widget _result(SupportComparisonEntry entry) {
    final name = model.candidates.firstWhere((gem) => gem.id == entry.id).name;
    return Container(
      key: ValueKey('support-result-${entry.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Spark.of(context).line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            name,
            game: true,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (entry.dps case final dps?) SupportDpsValues(dps),
          if (entry.error case final error?) AppText(cleanPoB(error)),
          for (final warning in entry.warnings)
            AppText(cleanPoB(warning), game: true),
        ],
      ),
    );
  }
}
