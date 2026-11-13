import 'package:material_ui/material_ui.dart';

import '../domain/progression_loadout_change.dart';
import '../domain/tree_progression.dart';
import 'core/app_text.dart';
import 'core/ui_translation.dart';
import 'equipment_presentation.dart';
import 'progression_plan_actions.dart';
import 'progression_timeline_reports.dart';

class ProgressionShoppingDialog extends StatefulWidget {
  const ProgressionShoppingDialog(
    this.steps,
    this.load,
    this.search, {
    super.key,
  });

  final List<TreeProgressionStep> steps;
  final ProgressionReportsLoader load;
  final void Function(BuildContext, String slot, String? base)? search;

  @override
  State<ProgressionShoppingDialog> createState() =>
      _ProgressionShoppingDialogState();
}

class _ProgressionShoppingDialogState extends State<ProgressionShoppingDialog> {
  late var _purchases = _load();

  Future<List<List<ProgressionPurchase>>> _load() async {
    final (:current, :stages) = await widget.load(widget.steps);
    return progressionShopping(current, stages);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const AppText('Список покупок'),
    content: SizedBox(
      width: 480,
      child: FutureBuilder(
        future: _purchases,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }
          if (snapshot.data case final purchases?) return _list(purchases);
          return TextButton(
            onPressed: () => setState(() => _purchases = _load()),
            child: const AppText('Повторить расчёт этапов'),
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const AppText('Закрыть'),
      ),
    ],
  );

  Widget _list(List<List<ProgressionPurchase>> purchases) {
    if (purchases.every((rows) => rows.isEmpty)) {
      return const AppText('Для следующих этапов покупки не нужны');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < purchases.length; index++)
          if (purchases[index].isNotEmpty) _stage(index, purchases[index]),
      ],
    );
  }

  Widget _stage(int index, List<ProgressionPurchase> purchases) =>
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        initiallyExpanded: true,
        title: ProgressionStageName(widget.steps[index]),
        children: [for (final purchase in purchases) _row(context, purchase)],
      );

  Widget _row(BuildContext context, ProgressionPurchase purchase) {
    final (:name, :slot, :base, :count) = purchase;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        slot == null && base == null
            ? Icons.diamond_outlined
            : Icons.inventory_2_outlined,
        size: 18,
      ),
      title: AppText(name, game: true),
      subtitle: slot == null ? null : AppText(equipmentLabel(slot)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 1) Text('×$count'),
          if (slot != null && widget.search != null)
            IconButton(
              tooltip: translateUi(context, 'Искать на рынке'),
              onPressed: () => widget.search!(context, slot, base),
              icon: const Icon(Icons.search),
            ),
        ],
      ),
    );
  }
}
