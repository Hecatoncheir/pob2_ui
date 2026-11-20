import 'package:material_ui/material_ui.dart';

import '../data/mcp_error_message.dart';
import '../domain/build_report.dart';
import '../domain/skill_gem.dart';
import 'core/app_text.dart';
import 'core/motion.dart';

Future<void> showSkillSupportPreview(
  BuildContext context,
  SkillGem support,
  SkillGem target,
  Future<SupportDps> Function() load,
) => sparkDialog<void>(context, _SkillSupportPreview(support, target, load));

class _SkillSupportPreview extends StatefulWidget {
  const _SkillSupportPreview(this.support, this.target, this.load);

  final SkillGem support, target;
  final Future<SupportDps> Function() load;

  @override
  State<_SkillSupportPreview> createState() => _SkillSupportPreviewState();
}

class _SkillSupportPreviewState extends State<_SkillSupportPreview> {
  late final preview = widget.load();

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: AppText(widget.support.name, game: true),
    content: SizedBox(
      width: 350,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(widget.target.name, game: true),
          const SizedBox(height: 12),
          FutureBuilder(
            future: preview,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return AppText(mcpErrorMessage(snapshot.error!));
              }
              if (snapshot.data case final result?) {
                return SupportDpsValues(result);
              }
              return const LinearProgressIndicator();
            },
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
  );
}

class SupportDpsValues extends StatelessWidget {
  const SupportDpsValues(this.result, {super.key});
  final SupportDps result;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _row('DPS до', _dps(result.before)),
      _row('DPS после', _dps(result.after)),
      _row('Прирост DPS', _delta),
    ],
  );

  String get _delta {
    final delta = result.delta;
    return delta != null && delta > 0 ? '+${_dps(delta)}' : _dps(delta);
  }

  String _dps(num? value) => formatStat(
    value,
    fractionDigits: value == value?.roundToDouble() ? 0 : 4,
  );

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [AppText(label), Text(value)],
  );
}
