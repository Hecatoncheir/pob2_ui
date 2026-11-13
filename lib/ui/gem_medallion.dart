import 'package:material_ui/material_ui.dart';

import '../data/game_catalog_repository.dart';
import 'gem_image.dart';
import 'gem_tooltip.dart';

import 'core/motion.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';

class GemMedallion extends StatelessWidget {
  const GemMedallion({
    super.key,
    this.size = 54,
    this.highlighted = false,
    this.enabled = true,
    this.empty = false,
    this.id,
    this.repository,
    this.level = 1,
    this.quality = 0,
    this.groupId,
    this.sourceIndex,
    this.showTooltip = true,
  });
  final double size;
  final bool highlighted, enabled, empty;
  final String? id;
  final GameCatalogRepository? repository;
  final int level, quality;
  final int? groupId, sourceIndex;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Spark.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final image = AnimatedContainer(
      duration: motionDuration(context, milliseconds: 180),
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? accent.withValues(alpha: .14) : colors.surface,
        border: Border.all(
          color: highlighted ? accent : colors.line,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.ink.withValues(alpha: .05),
            border: Border.all(color: colors.line.withValues(alpha: .5)),
          ),
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : .35,
              child: empty
                  ? Icon(Icons.add, size: size * .34, color: colors.muted)
                  : _image(accent),
            ),
          ),
        ),
      ),
    );
    if (!showTooltip || empty || id == null || repository == null) return image;
    return GemTooltip(
      repository: repository!,
      request: (
        id: id!,
        level: level,
        quality: quality,
        groupId: groupId,
        sourceIndex: sourceIndex,
      ),
      child: image,
    );
  }

  Widget _image(Color accent) {
    if (id != null && repository != null) {
      return SizedBox.expand(
        child: OriginalGemImage(
          key: ValueKey(id),
          id: id!,
          repository: repository!,
        ),
      );
    }
    return SparkArt('icons/gem', width: size * .38, color: accent);
  }
}
