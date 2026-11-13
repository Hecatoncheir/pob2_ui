import 'package:material_ui/material_ui.dart';

import '../domain/skill_gem.dart';
import '../data/game_catalog_repository.dart';
import 'core/app_text.dart';
import 'core/spark_theme.dart';
import 'gem_drag.dart';
import 'gem_medallion.dart';

class SkillGemCatalogTile extends StatelessWidget {
  const SkillGemCatalogTile({
    super.key,
    required this.gem,
    required this.saving,
    required this.add,
    required this.repository,
    this.compact = false,
  });
  final SkillGem gem;
  final bool saving;
  final VoidCallback add;
  final GameCatalogRepository repository;
  final bool compact;

  @override
  Widget build(BuildContext context) => DraggableGem(
    data: (gem: gem, draftKey: null, groupId: null, sourceIndex: null),
    saving: saving,
    repository: repository,
    child: Material(
      color: Spark.of(context).surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Spark.of(context).line),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saving ? null : add,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: compact
              ? Row(
                  children: [
                    GemMedallion(id: gem.id, repository: repository, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        gem.name,
                        game: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const Icon(Icons.add, size: 16),
                  ],
                )
              : Column(
                  children: [
                    GemMedallion(id: gem.id, repository: repository),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: AppText(
                          gem.name,
                          game: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}
