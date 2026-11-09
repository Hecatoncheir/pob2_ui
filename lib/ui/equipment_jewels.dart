import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../data/item_art_catalog.dart';
import '../data/mcp_error_message.dart';
import '../domain/build_report.dart';
import '../domain/equipment_item.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/panels.dart';
import 'core/spark_theme.dart';
import 'item_artwork_image.dart';
import 'item_description.dart';

class EquipmentJewels extends StatelessWidget {
  const EquipmentJewels({
    super.key,
    required this.report,
    required this.bases,
    required this.repository,
    required this.busy,
  });

  final BuildReport report;
  final Future<List<JsonMap>> bases;
  final EquipmentRepository repository;
  final bool busy;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<JsonMap>>(
    future: bases,
    builder: (context, snapshot) {
      final jewels = _jewels(snapshot.data ?? const []);
      if (jewels.isEmpty && !snapshot.hasError) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText(
                'Самоцветы',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (jewels.isNotEmpty) _list(jewels),
              if (snapshot.hasError)
                AppText(
                  mcpErrorMessage(snapshot.error!),
                  style: TextStyle(color: Spark.of(context).danger),
                ),
            ],
          ),
        ),
      );
    },
  );

  Iterable<JsonMap> _jewels(List<JsonMap> bases) {
    final jewelBases = {
      for (final base in bases)
        if (base['type'] == 'Jewel') base['id'],
    };
    final socketedIds = report.socketedItems.values
        .map((item) => item['id'])
        .toSet();
    return report.items.where(
      (item) =>
          jewelBases.contains(item['base']) || socketedIds.contains(item['id']),
    );
  }

  Widget _list(Iterable<JsonMap> jewels) => FutureBuilder<ItemArtCatalog>(
    future: ItemArtCatalog.shared,
    builder: (context, snapshot) => Column(
      children: [
        for (final jewel in jewels)
          _tile(context, jewel, snapshot.data?.imageForReport(jewel)),
      ],
    ),
  );

  Widget _tile(BuildContext context, JsonMap jewel, String? url) {
    final id = jewel['id'] as int;
    const icon = Icon(Icons.diamond_outlined);
    return ListTile(
      key: ValueKey('equipment-jewel-$id'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: SizedBox.square(
        dimension: 42,
        child: url == null
            ? icon
            : ItemArtworkImage(url: url, placeholder: icon),
      ),
      title: AppText(jewel['name'] as String, game: true),
      trailing: const Icon(Icons.chevron_right),
      onTap: busy || !repository.canInspect
          ? null
          : () => _showDescription(context, id),
    );
  }

  void _showDescription(BuildContext context, int id) {
    final description = repository.inspect(itemId: id);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 568,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: FutureBuilder<ItemInspection>(
                      future: description,
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return AppText(mcpErrorMessage(snapshot.error!));
                        if (snapshot.data case final item?)
                          return ItemDescription(item);
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerRight,
                  child: DialogCloseButton(label: 'Закрыть'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
