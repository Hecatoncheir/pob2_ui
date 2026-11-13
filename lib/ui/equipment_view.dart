import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';

import 'core/app_text.dart';
import 'core/panels.dart';
import 'core/spark_theme.dart';
import 'equipment_board.dart';
import 'equipment_cubit.dart';
import 'equipment_jewels.dart';
import 'equipment_presentation.dart';
import 'item_description.dart';
import 'item_editor_dialog.dart';
import 'workshop_cubit.dart';
import 'trade_search_dialog.dart';
import '../data/trade_search_repository.dart';

class ItemsView extends StatefulWidget {
  const ItemsView({super.key, required this.model});
  final WorkshopCubit model;
  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  late final equipment = EquipmentCubit(widget.model);
  @override
  void dispose() {
    equipment.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EquipmentCubit, EquipmentState>(
        bloc: equipment,
        builder: (context, state) => LayoutBuilder(
          builder: (context, constraints) {
            final report = widget.model.state.report!;
            final busy = widget.model.state.busy;
            final board = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SurfacePanel(
                  child: Column(
                    children: [
                      _weapons(),
                      const SizedBox(height: 12),
                      EquipmentBoard(
                        report: report,
                        selected: state.slot,
                        select: equipment.select,
                        busy: busy,
                      ),
                    ],
                  ),
                ),
                if (report.items.isNotEmpty)
                  EquipmentJewels(
                    report: report,
                    bases: widget.model.catalogs.itemBases(),
                    repository: equipment.repository,
                    busy: busy,
                  ),
              ],
            );
            final details = _details(state);
            if (constraints.maxWidth >= 640)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: board,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
                      child: details,
                    ),
                  ),
                ],
              );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: board,
                    ),
                  ),
                  const SizedBox(height: 16),
                  details,
                ],
              ),
            );
          },
        ),
      );

  Widget _weapons() {
    final current = widget.model.state.report!.raw['weaponSet'] as int? ?? 1;
    return Row(
      children: [
        const Expanded(child: AppText('Набор оружия')),
        for (final index in [1, 2])
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              key: ValueKey('equipment-weapon-$index'),
              label: Text(index == 1 ? 'I' : 'II'),
              selected: current == index,
              onSelected:
                  widget.model.state.busy || !equipment.repository.available
                  ? null
                  : (_) => widget.model.selectWeaponSet(index),
            ),
          ),
      ],
    );
  }

  Widget _details(EquipmentState state) {
    if (state.slot == null)
      return const SurfacePanel(
        child: Center(child: AppText('Выберите ячейку экипировки')),
      );
    final slot = widget.model.state.report!.slots.firstWhere(
      (slot) => slot['name'] == state.slot,
    );
    final filled = (slot['itemId'] as int? ?? 0) != 0;
    final disabled = widget.model.state.busy || !equipment.repository.available;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                equipmentLabel(state.slot!),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    key: const Key('equipment-edit'),
                    onPressed: disabled
                        ? null
                        : () => showItemEditor(
                            context,
                            widget.model,
                            state.slot!,
                          ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: AppText(
                      filled ? 'Заменить предмет' : 'Добавить предмет',
                    ),
                  ),
                  if (filled)
                    OutlinedButton.icon(
                      key: const Key('equipment-remove'),
                      onPressed: disabled
                          ? null
                          : () =>
                                widget.model.equipItem(state.slot!, itemId: 0),
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const AppText('Снять'),
                    ),
                  OutlinedButton.icon(
                    key: const Key('equipment-trade'),
                    onPressed:
                        widget.model.state.busy ||
                            !TradeSearchRepository(widget.model.engine)
                                .available
                        ? null
                        : () => showTradeSearch(
                            context,
                            widget.model,
                            state.slot!,
                          ),
                    icon: const Icon(Icons.search, size: 18),
                    label: const AppText('Искать на рынке'),
                  ),
                ],
              ),
              if (!equipment.repository.available)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: AppText('Обновите MCP для редактора экипировки'),
                ),
              if (widget.model.state.error case final error?)
                AppText(
                  mcpErrorMessage(error),
                  style: TextStyle(color: Spark.of(context).danger),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (state.loading) const LinearProgressIndicator(),
        if (state.error case final error?)
          AppText(error, style: TextStyle(color: Spark.of(context).danger)),
        if (state.preview case final preview?) ItemDescription(preview),
      ],
    );
  }
}
