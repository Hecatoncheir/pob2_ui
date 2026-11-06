import 'package:flutter/material.dart';

import '../domain/skill_gem.dart';
import '../data/game_catalog_repository.dart';
import 'core/app_text.dart';
import 'core/panels.dart';
import 'gem_medallion.dart';

typedef GemDrag = ({
  SkillGem gem,
  int? draftKey,
  int? groupId,
  int? sourceIndex,
});

class DraggableGem extends StatelessWidget {
  const DraggableGem({
    super.key,
    required this.data,
    required this.child,
    required this.saving,
    required this.repository,
  });
  final GemDrag data;
  final Widget child;
  final bool saving;
  final GameCatalogRepository repository;

  @override
  Widget build(BuildContext context) => Draggable<GemDrag>(
    data: data,
    maxSimultaneousDrags: saving ? 0 : 1,
    rootOverlay: true,
    feedback: SizedBox(
      width: 140,
      child: SurfacePanel(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GemMedallion(
              highlighted: true,
              id: data.gem.id,
              repository: repository,
            ),
            const SizedBox(height: 8),
            AppText(
              data.gem.name,
              game: true,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
    childWhenDragging: Opacity(opacity: .3, child: child),
    child: child,
  );
}
