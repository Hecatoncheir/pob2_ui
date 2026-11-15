import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/build_report.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/spark_art.dart';
import 'workshop_cubit.dart';

const _title = 'Сменить класс или восхождение';
const _treeChoiceError = 'Смена класса требует соединения или сброса дерева';

typedef _Character = ({int classId, int ascendancyId});
typedef _DialogState = ({
  _Character selection,
  bool applying,
  bool needsTreeChoice,
  String? error,
});

enum _TreeChange { select, connect, reset }

class TreeClassButton extends StatelessWidget {
  const TreeClassButton(this.model, {super.key});
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) {
    final report = model.state.report!;
    final entry = model.state.classes
        .where((entry) => entry['name'] == report.characterClass)
        .firstOrNull;
    if (entry == null || !model.engine.tools.contains('pob_tree_options')) {
      return const SizedBox.shrink();
    }
    final initial = (
      classId: entry['id'] as int,
      ascendancyId: _ascendancyId(entry, report.character['ascendancy']),
    );
    return ArtIconButton.material(
      Icons.person_outline,
      key: const Key('tree-class'),
      label: _title,
      onPressed: model.state.busy || model.state.document!.stale
          ? null
          : () => sparkDialog<void>(
              context,
              BlocProvider(
                create: (_) => _TreeClassCubit(model, initial),
                child: const _TreeClassDialog(),
              ),
              barrierDismissible: false,
            ),
    );
  }
}

int _ascendancyId(JsonMap entry, Object? name) =>
    jsonRows(entry['ascendancies'])
            .where((entry) => entry['name'] == name)
            .firstOrNull?['id']
        as int? ??
    0;

class _TreeClassCubit extends Cubit<_DialogState> {
  _TreeClassCubit(this.model, this.initial)
    : classes = model.state.classes,
      super((
        selection: initial,
        applying: false,
        needsTreeChoice: false,
        error: null,
      ));

  final WorkshopCubit model;
  final _Character initial;
  final List<JsonMap> classes;

  void choose(_Character selection) => emit((
    selection: selection,
    applying: false,
    needsTreeChoice: false,
    error: null,
  ));

  Future<bool> apply(_TreeChange change) async {
    final current = state;
    if (current.applying) return false;
    emit((
      selection: current.selection,
      applying: true,
      needsTreeChoice: current.needsTreeChoice,
      error: null,
    ));
    final result = await model.selectTreeClass(
      classId: current.selection.classId,
      ascendancyId: current.selection.ascendancyId,
      connect: change == _TreeChange.connect,
      reset: change == _TreeChange.reset,
    );
    if (isClosed) return false;
    final needsChoice = result.error == _treeChoiceError;
    emit((
      selection: current.selection,
      applying: false,
      needsTreeChoice: current.needsTreeChoice || needsChoice,
      error: needsChoice ? null : result.error,
    ));
    return result.committed;
  }
}

class _TreeClassDialog extends StatelessWidget {
  const _TreeClassDialog();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<_TreeClassCubit, _DialogState>(
        builder: (context, state) {
          final cubit = context.read<_TreeClassCubit>();
          return PopScope(
            canPop: !state.applying,
            child: AlertDialog(
              title: const AppText(_title),
              scrollable: true,
              content: _content(cubit, state),
              actions: _actions(context, cubit, state),
            ),
          );
        },
      );

  Widget _content(_TreeClassCubit cubit, _DialogState state) {
    final (:classId, :ascendancyId) = state.selection;
    final character = cubit.classes.firstWhere(
      (entry) => entry['id'] == classId,
    );
    return SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _picker(
            key: const Key('tree-class-choice'),
            label: 'Класс',
            options: cubit.classes,
            value: classId,
            onChanged: state.applying
                ? null
                : (id) => cubit.choose((classId: id, ascendancyId: 0)),
          ),
          const SizedBox(height: 16),
          _picker(
            key: ValueKey('tree-ascendancy-$classId'),
            label: 'Восхождение',
            options: jsonRows(character['ascendancies']),
            value: ascendancyId,
            noAscendancyLabel: true,
            onChanged: state.applying
                ? null
                : (id) => cubit.choose((classId: classId, ascendancyId: id)),
          ),
          if (state.needsTreeChoice)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: AppText(
                'Соединение может потратить пассивные очки. Сброс снимет все назначенные узлы текущего дерева.',
              ),
            ),
          if (state.error case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AppText(error),
            ),
          if (state.applying) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _picker({
    required Key key,
    required String label,
    required List<JsonMap> options,
    required int value,
    required ValueChanged<int>? onChanged,
    bool noAscendancyLabel = false,
  }) => DropdownButtonFormField<int>(
    key: key,
    decoration: InputDecoration(label: AppText(label)),
    initialValue: value,
    isExpanded: true,
    onChanged: onChanged == null ? null : (id) => onChanged(id!),
    items: [
      for (final entry in options)
        DropdownMenuItem(
          value: entry['id'] as int,
          child: noAscendancyLabel && entry['id'] == 0
              ? const AppText('Без восхождения')
              : AppText(entry['name'] as String, game: true),
        ),
    ],
  );

  List<Widget> _actions(
    BuildContext context,
    _TreeClassCubit cubit,
    _DialogState state,
  ) => [
    TextButton(
      onPressed: state.applying ? null : () => Navigator.pop(context),
      child: const AppText('Отмена'),
    ),
    if (state.needsTreeChoice) ...[
      OutlinedButton(
        onPressed: _action(context, cubit, state, _TreeChange.reset),
        child: const AppText('Сбросить дерево'),
      ),
      FilledButton(
        onPressed: _action(context, cubit, state, _TreeChange.connect),
        child: const AppText('Соединить дерево'),
      ),
    ] else
      FilledButton(
        onPressed: _action(context, cubit, state, _TreeChange.select),
        child: const AppText('Применить'),
      ),
  ];

  VoidCallback? _action(
    BuildContext context,
    _TreeClassCubit cubit,
    _DialogState state,
    _TreeChange change,
  ) {
    if (state.applying || state.selection == cubit.initial) return null;
    return () async {
      if (await cubit.apply(change) && context.mounted) Navigator.pop(context);
    };
  }
}
