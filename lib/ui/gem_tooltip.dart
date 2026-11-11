import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/game_catalog_repository.dart';
import '../data/mcp_error_message.dart';
import '../domain/build_report.dart';
import 'core/app_text.dart';
import 'core/frosted_surface.dart';
import 'core/pob_text.dart';

typedef GemTooltipRequest = ({
  String id,
  int level,
  int quality,
  int? groupId,
  int? sourceIndex,
});
typedef GemTooltipState = ({bool loading, List<JsonMap> lines, String? error});

class GemTooltipCubit extends Cubit<GemTooltipState> {
  GemTooltipCubit() : super((loading: true, lines: const [], error: null));

  Future<void> load(
    GameCatalogRepository repository,
    GemTooltipRequest request,
  ) async {
    try {
      final lines = await repository.gemTooltip(
        id: request.id,
        level: request.level,
        quality: request.quality,
        groupId: request.groupId,
        sourceIndex: request.sourceIndex,
      );
      if (!isClosed) emit((loading: false, lines: lines, error: null));
    } catch (error) {
      if (!isClosed) {
        emit((loading: false, lines: const [], error: mcpErrorMessage(error)));
      }
    }
  }
}

class GemTooltip extends StatelessWidget {
  const GemTooltip({
    super.key,
    required this.repository,
    required this.request,
    required this.child,
  });
  final GameCatalogRepository repository;
  final GemTooltipRequest request;
  final Widget child;

  @override
  Widget build(BuildContext context) => Tooltip(
    waitDuration: const Duration(milliseconds: 400),
    exitDuration: const Duration(milliseconds: 120),
    triggerMode: TooltipTriggerMode.manual,
    ignorePointer: false,
    excludeFromSemantics: true,
    padding: EdgeInsets.zero,
    decoration: const BoxDecoration(),
    richMessage: WidgetSpan(
      child: BlocProvider(
        key: ValueKey(request),
        create: (_) => GemTooltipCubit()..load(repository, request),
        child: _GemTooltipCard(anchor: context),
      ),
    ),
    child: child,
  );
}

class _GemTooltipCard extends StatelessWidget {
  const _GemTooltipCard({required this.anchor});
  final BuildContext anchor;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    return SizedBox(
      width: math.min(420, math.max(0, viewport.width - 48)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: _availableHeight(viewport)),
        child: FrostedSurface(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: BlocBuilder<GemTooltipCubit, GemTooltipState>(
              builder: (context, state) => _content(state),
            ),
          ),
        ),
      ),
    );
  }

  double _availableHeight(Size viewport) {
    final target = anchor.findRenderObject();
    final overlay = Overlay.of(anchor).context.findRenderObject();
    final height = overlay is RenderBox && overlay.hasSize
        ? overlay.size.height
        : viewport.height;
    final center = target is RenderBox && target.hasSize
        ? target
              .localToGlobal(target.size.center(Offset.zero), ancestor: overlay)
              .dy
        : height / 2;
    final space = math.max(center, height - center) - 60;
    return math.min(540, math.max(40, space));
  }

  Widget _content(GemTooltipState state) {
    if (state.loading) return const LinearProgressIndicator(minHeight: 2);
    if (state.error case final error?) return AppText(error);
    return SingleChildScrollView(
      key: const Key('gem-tooltip-description'),
      child: GemDescriptionLines(state.lines),
    );
  }
}

class GemDescriptionLines extends StatelessWidget {
  const GemDescriptionLines(this.lines, {super.key});
  final List<JsonMap> lines;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [for (final line in lines) _line(line)],
  );

  Widget _line(JsonMap line) {
    if (line['separator'] == true) return const Divider(height: 20);
    final heading = (line['size'] as num? ?? 16) >= 20;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: PoBText(
        '${line['text'] ?? ''}',
        size: heading ? 17 : 14,
        bold: heading,
      ),
    );
  }
}
