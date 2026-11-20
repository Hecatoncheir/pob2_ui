import 'package:material_ui/material_ui.dart';

import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'skill_group_cubit.dart';

class SkillSocketSummary extends StatelessWidget {
  const SkillSocketSummary(this.state, {super.key});
  final SkillGroupState state;

  @override
  Widget build(BuildContext context) {
    final info = state.compatibility;
    final sockets = info?.sockets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sockets != null) ...[
          Wrap(
            spacing: 6,
            children: [
              const AppText('Установлено поддержек:'),
              Text('${sockets.count}'),
              const AppText('Включено:'),
              Text('${sockets.enabled}'),
              if (info!.warnings.isNotEmpty)
                IconButton(
                  key: const Key('skill-support-warnings'),
                  tooltip: translateUi(context, 'Предупреждения'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showWarnings(context, info.warnings),
                  icon: const Icon(Icons.warning_amber, size: 18),
                ),
            ],
          ),
          if (!sockets.allowed)
            const AppText('Для этого умения нельзя добавить поддержки'),
        ],
        const AppTooltip(
          message: 'PoB не предоставляет число доступных ячеек этого умения',
          child: AppText('Вместимость ячеек неизвестна'),
        ),
      ],
    );
  }

  Future<void> _showWarnings(BuildContext context, List<String> warnings) =>
      sparkDialog<void>(
        context,
        AlertDialog(
          scrollable: true,
          title: const AppText('Предупреждения'),
          content: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final warning in warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppText(warning, game: true),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText('Закрыть'),
            ),
          ],
        ),
      );
}
