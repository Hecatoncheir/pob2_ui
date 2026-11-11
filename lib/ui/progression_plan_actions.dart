import 'package:flutter/material.dart';

import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'progression_apply_dialog.dart';

Future<TreeProgressionStep?> chooseProgressionBaseline(
  BuildContext context,
  TreeProgressionStep target,
  List<TreeProgressionStep> steps,
) => sparkDialog<TreeProgressionStep>(
  context,
  SimpleDialog(
    title: const AppText('С каким этапом сравнить?'),
    children: [
      for (final step in steps)
        if (step.identity != target.identity)
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(step),
            child: ProgressionStageName(step),
          ),
    ],
  ),
);

class ProgressionStageName extends StatelessWidget {
  const ProgressionStageName(this.step, {super.key});
  final TreeProgressionStep step;

  @override
  Widget build(BuildContext context) {
    final level = step.level;
    return Wrap(
      spacing: 8,
      runSpacing: 2,
      children: [
        if (step.title.isNotEmpty) Text(step.title),
        AppText('Уровень $level'),
      ],
    );
  }
}

class UpdateProgressionPartsDialog extends StatefulWidget {
  const UpdateProgressionPartsDialog(this.available, {super.key});
  final Set<ProgressionPart> available;

  @override
  State<UpdateProgressionPartsDialog> createState() =>
      _UpdateProgressionPartsState();
}

class _UpdateProgressionPartsState extends State<UpdateProgressionPartsDialog> {
  final selected = <ProgressionPart>{};

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const AppText('Обновить этап из сборки'),
    scrollable: true,
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final part in widget.available)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: AppText(progressionPartLabel(part)),
              value: selected.contains(part),
              onChanged: (checked) => setState(() {
                if (checked == true) {
                  selected.add(part);
                } else {
                  selected.remove(part);
                }
              }),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const AppText('Отмена'),
      ),
      FilledButton(
        onPressed: selected.isEmpty
            ? null
            : () => Navigator.pop(context, Set.of(selected)),
        child: const AppText('Обновить этап'),
      ),
    ],
  );
}
