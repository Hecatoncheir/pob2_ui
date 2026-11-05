import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/node_preview.dart';
import 'tree_hover_cubit.dart';
import 'tree_hover_card.dart';

import 'package:flutter/foundation.dart' show mapEquals;

import '../domain/build_report.dart';
import '../domain/tree_geometry.dart';
import 'core/motion.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'workshop_cubit.dart';
import 'tree_canvas.dart';
import 'original_tree_artwork.dart';

class TreeView extends StatefulWidget {
  const TreeView({super.key, required this.model, required this.tree});
  final WorkshopCubit model;
  final TreeGeometry tree;
  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView>
    with SingleTickerProviderStateMixin {
  final transform = TransformationController();
  late TreeScene scene = TreeScene(widget.tree);
  int? selected;
  String query = '';
  Size? viewport;
  late final zoomAnimation = AnimationController(vsync: this)
    ..addListener(_zoomFrame);
  Animation<Matrix4>? zoomTween;
  final icons = <String, ui.Image>{};
  Map<String, Uint8List> decodedBytes = const {};
  int iconGeneration = 0;
  int? hovered;
  String? decodeError;
  OriginalTreeArtwork? artwork;
  OriginalTreeArtwork? hoverArtwork;
  final extraImages = <String, ui.Image>{};
  final tooltipPortal = OverlayPortalController();
  late final hoverModel = TreeHoverCubit(widget.model.previewNode);
  Offset mouse = Offset.zero;
  int previewGeneration = 0;
  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  @override
  void didUpdateWidget(TreeView old) {
    super.didUpdateWidget(old);
    if (old.tree == widget.tree) return;
    scene = TreeScene(widget.tree);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) hoverModel.clear();
    });
    _updateArtwork(old.tree);
    if (_root(old.tree) != _root(widget.tree) ||
        old.tree.version != widget.tree.version)
      _scheduleFocus();
  }

  void _updateArtwork(TreeGeometry old) {
    if (mapEquals(old.icons, widget.tree.icons))
      _recordArtwork();
    else
      _loadIcons();
  }

  void _scheduleFocus() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _focusAllocated();
  });

  Future<void> _loadIcons() async {
    final generation = ++iconGeneration;
    final loaded = <String, ui.Image>{};
    try {
      for (final entry in widget.tree.icons.entries) {
        loaded[entry.key] = await _imageFor(entry);
      }
      _acceptIcons(generation, loaded);
    } catch (error) {
      for (final image in loaded.values) {
        image.dispose();
      }
      if (mounted && generation == iconGeneration) {
        setState(
          () => decodeError = 'Не удалось прочитать изображения: $error',
        );
      }
    }
  }

  Future<ui.Image> _imageFor(MapEntry<String, Uint8List> entry) async {
    final cached = icons[entry.key];
    if (cached != null && identical(decodedBytes[entry.key], entry.value))
      return cached.clone();
    final codec = await ui.instantiateImageCodec(entry.value);
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  void _acceptIcons(int generation, Map<String, ui.Image> loaded) {
    if (!mounted || generation != iconGeneration) {
      for (final image in loaded.values) {
        image.dispose();
      }
      return;
    }
    setState(() {
      decodeError = null;
      artwork?.dispose();
      artwork = null;
      for (final image in icons.values) {
        image.dispose();
      }
      icons
        ..clear()
        ..addAll(loaded);
      decodedBytes = widget.tree.icons;
      _recordArtwork();
    });
  }

  void _recordArtwork() {
    artwork?.dispose();
    final original = widget.tree.original;
    artwork = original == null ? null : OriginalTreeArtwork(original, icons);
  }

  @override
  void dispose() {
    hoverModel.close();
    hoverArtwork?.dispose();
    for (final image in extraImages.values) {
      image.dispose();
    }
    zoomAnimation.dispose();
    transform.dispose();
    artwork?.dispose();
    for (final image in icons.values) {
      image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<TreeHoverCubit, TreeHoverState>(
        bloc: hoverModel,
        listener: _hoverChanged,
        child: OverlayPortal(
          controller: tooltipPortal,
          overlayChildBuilder: _tooltip,
          child: _body(),
        ),
      );

  Widget _body() => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
    child: Column(
      children: [
        _toolbar(),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ColoredBox(
              color: Spark.ink,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  if (viewport == null) {
                    viewport = size;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _focusAllocated();
                    });
                  }
                  viewport = size;
                  return MouseRegion(
                    onHover: (event) =>
                        _hover(event.localPosition, event.position),
                    onExit: (_) => hoverModel.clear(),
                    child: GestureDetector(
                      onTapUp: _select,
                      onLongPressStart: (event) =>
                          _detailsAt(event.localPosition),
                      child: InteractiveViewer(
                        key: const Key('passive-tree'),
                        transformationController: transform,
                        onInteractionStart: (_) {
                          zoomAnimation.stop();
                          hoverModel.clear();
                        },
                        constrained: false,
                        minScale: .08,
                        maxScale: 12,
                        boundaryMargin: const EdgeInsets.all(500),
                        child: CustomPaint(
                          size: const Size(1800, 1800),
                          isComplex: true,
                          painter: TreePainter(
                            scene,
                            selected,
                            hovered,
                            query,
                            icons,
                            transform,
                            size,
                            artwork?.picture,
                            hoverArtwork?.picture,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (decodeError case final error?)
          Text(
            error,
            key: const Key('tree-decode-error'),
            style: const TextStyle(color: Spark.danger, fontSize: 11),
          ),
        if (widget.tree.iconError case final error?)
          Text(
            error,
            style: const TextStyle(color: Spark.danger, fontSize: 11),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.model.state.report!.points,
                  style: Spark.mono.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'PoB · ${widget.tree.version.replaceAll('_', '.')}',
                style: const TextStyle(color: Spark.muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _toolbar() => Row(
    children: [
      Expanded(
        child: TextField(
          key: const Key('tree-search'),
          onChanged: (value) => setState(() => query = value),
          onSubmitted: (_) => _focusMatch(),
          decoration: const InputDecoration(
            hintText: 'Найти узел',
            prefixIcon: Padding(
              padding: EdgeInsets.all(13),
              child: SparkArt('icons/search', width: 17),
            ),
          ),
        ),
      ),
      const SizedBox(width: 6),
      ArtIconButton('minus', label: 'Отдалить', onPressed: () => _zoom(.8)),
      ArtIconButton('plus', label: 'Приблизить', onPressed: () => _zoom(1.25)),
      ArtIconButton('fit', label: 'Показать всё дерево', onPressed: _fit),
    ],
  );
  void _fit() {
    final size = viewport!;
    final scale = math.min(size.width, size.height) / 1800;
    _animateTo(
      Matrix4.diagonal3Values(scale, scale, 1)..setTranslationRaw(
        (size.width - 1800 * scale) / 2,
        (size.height - 1800 * scale) / 2,
        0,
      ),
    );
  }

  void _zoom(double factor) {
    final center = Offset(viewport!.width / 2, viewport!.height / 2);
    final value = transform.value;
    final scale = (value.getMaxScaleOnAxis() * factor).clamp(.08, 12.0);
    final point = transform.toScene(center);
    _animateTo(
      Matrix4.diagonal3Values(scale, scale, 1)..setTranslationRaw(
        center.dx - point.dx * scale,
        center.dy - point.dy * scale,
        0,
      ),
    );
  }

  void _zoomFrame() {
    if (zoomTween != null) transform.value = zoomTween!.value;
  }

  void _animateTo(Matrix4 target) {
    hoverModel.clear();
    zoomAnimation.stop();
    if (MediaQuery.disableAnimationsOf(context)) {
      transform.value = target;
      return;
    }
    zoomAnimation.duration = motionDuration(context, milliseconds: 450);
    zoomTween = Matrix4Tween(
      begin: transform.value.clone(),
      end: target,
    ).animate(CurvedAnimation(parent: zoomAnimation, curve: Spark.curve));
    zoomAnimation.forward(from: 0);
  }

  void _focusAllocated() {
    final root = _root(widget.tree);
    final node = widget.tree.nodes.where((node) => node.id == root).firstOrNull;
    if (node == null) {
      _fit();
      return;
    }
    _center(
      scene.points[node.id]!,
      widget.tree.original == null
          ? 3.2
          : (viewport!.shortestSide / 130).clamp(2.0, 5.0),
      animate: false,
    );
  }

  int? _root(TreeGeometry tree) => tree.nodes
      .where((node) => node.allocated && node.kind == 'ClassStart')
      .firstOrNull
      ?.id;

  void _focusMatch() {
    if (query.isEmpty) return;
    final node = widget.tree.nodes
        .where((node) => node.matches(query))
        .firstOrNull;
    if (node == null) return;
    setState(() => selected = node.id);
    _center(scene.points[node.id]!, widget.tree.original == null ? 4 : 8);
  }

  void _center(Offset point, double scale, {bool animate = true}) {
    final target = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(
        viewport!.width / 2 - point.dx * scale,
        viewport!.height / 2 - point.dy * scale,
        0,
      );
    if (animate)
      _animateTo(target);
    else
      transform.value = target;
  }

  void _select(TapUpDetails event) {
    final id = _hit(event.localPosition);
    setState(() => selected = id);
    hoverModel.clear();
    final node = scene.nodes[id];
    if (node == null || widget.model.state.busy) return;
    if ({'ClassStart', 'AscendClassStart'}.contains(node.kind)) return;
    if (node.kind == 'Mastery' && !node.allocated) {
      sparkDialog<void>(context, _NodeDialog(widget.model, node));
      return;
    }
    widget.model.treeAction(node.id, node.allocated);
  }

  void _detailsAt(Offset point) {
    final node = scene.nodes[_hit(point)];
    if (node != null)
      sparkDialog<void>(context, _NodeDialog(widget.model, node));
  }

  void _hover(Offset local, Offset global) {
    if (widget.model.state.busy) return;
    final id = _hit(local);
    if (hoverModel.state.id == id) return;
    mouse = global;
    hoverModel.hover(id);
  }

  void _hoverChanged(BuildContext context, TreeHoverState state) {
    final generation = ++previewGeneration;
    setState(() {
      hovered = state.id;
      hoverArtwork?.dispose();
      hoverArtwork = null;
    });
    if (state.id == null) {
      tooltipPortal.hide();
      return;
    }
    tooltipPortal.show();
    if (state.preview case final preview?) _loadPreview(preview, generation);
  }

  Future<void> _loadPreview(NodePreview preview, int generation) async {
    try {
      for (final entry in preview.images.entries) {
        if (icons.containsKey(entry.key) || extraImages.containsKey(entry.key))
          continue;
        final codec = await ui.instantiateImageCodec(entry.value);
        final image = (await codec.getNextFrame()).image;
        codec.dispose();
        if (!mounted || generation != previewGeneration) {
          image.dispose();
          return;
        }
        extraImages[entry.key] = image;
      }
      _recordPreview(preview, generation);
    } catch (error) {
      if (mounted)
        setState(() => decodeError = 'Не удалось показать подсветку: $error');
    }
  }

  void _recordPreview(NodePreview preview, int generation) {
    if (!mounted || generation != previewGeneration || preview.scene == null)
      return;
    setState(() {
      hoverArtwork?.dispose();
      hoverArtwork = OriginalTreeArtwork(preview.scene!, {
        ...icons,
        ...extraImages,
      });
    });
  }

  Widget _tooltip(BuildContext context) {
    final name = scene.nodes[hoverModel.state.id]?.name ?? '';
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: NodeTooltipLayout(mouse),
        child: IgnorePointer(
          child: TreeHoverCard(
            key: const Key('node-tooltip'),
            title: name,
            state: hoverModel.state,
          ),
        ),
      ),
    );
  }

  int? _hit(Offset localPosition) {
    final point = transform.toScene(localPosition);
    final radius = 14 / transform.value.getMaxScaleOnAxis();
    final hits =
        scene.points.entries
            .where((entry) => (entry.value - point).distance < radius)
            .toList()
          ..sort(
            (a, b) => (a.value - point).distance.compareTo(
              (b.value - point).distance,
            ),
          );
    return hits.firstOrNull?.key;
  }
}

class _NodeDialog extends StatefulWidget {
  const _NodeDialog(this.model, this.node);
  final WorkshopCubit model;
  final TreeNode node;
  @override
  State<_NodeDialog> createState() => _NodeDialogState();
}

class _NodeDialogState extends State<_NodeDialog> {
  late final details = _load();
  int? attribute;
  Future<({List<String> lines, List<JsonMap> attributes})> _load() async {
    final tooltip = await widget.model.engine.call('pob_node_tooltip', {
      'id': widget.node.id,
      'compare': false,
    });
    final catalog = await widget.model.engine.call('pob_catalog', {
      'kind': 'nodes',
      'query': '${widget.node.id}',
      'limit': 200,
    });
    final node = jsonRows(catalog['entries'])
        .where((entry) => entry['id'] == widget.node.id)
        .firstOrNull;
    return (
      lines: jsonRows(tooltip['lines'])
          .map((line) => cleanPoB('${line['text'] ?? ''}'))
          .where((line) => line.isNotEmpty)
          .toList(),
      attributes: jsonRows(node?['attributeOptions']),
    );
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<({List<String> lines, List<JsonMap> attributes})>(
        future: details,
        builder: (context, snapshot) => AlertDialog(
          title: Text(widget.node.name),
          content: SizedBox(
            width: 470,
            child: SingleChildScrollView(child: _content(snapshot)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
            if (snapshot.hasData &&
                !{
                  'Mastery',
                  'ClassStart',
                  'AscendClassStart',
                }.contains(widget.node.kind))
              FilledButton(
                onPressed: _canApply(snapshot.data!.attributes) ? _apply : null,
                child: Text(
                  widget.node.allocated ? 'Вернуть узел' : 'Выбрать путь',
                ),
              ),
          ],
        ),
      );
  Widget _content(
    AsyncSnapshot<({List<String> lines, List<JsonMap> attributes})> snapshot,
  ) {
    if (snapshot.hasError)
      return Text('Не удалось прочитать узел: ${snapshot.error}');
    if (!snapshot.hasData)
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      );
    final (:lines, :attributes) = snapshot.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(line),
          ),
        ),
        if (attributes.isNotEmpty)
          DropdownButtonFormField<int>(
            hint: const Text('Выберите характеристику'),
            items: attributes
                .map(
                  (option) => DropdownMenuItem(
                    value: option['id'] as int,
                    child: Text('${option['name']}'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => attribute = value),
          ),
        if (widget.node.kind == 'Mastery')
          const Text(
            'Выбор эффекта мастерства пока доступен через XML.',
            style: TextStyle(color: Spark.muted),
          ),
      ],
    );
  }

  bool _canApply(List<JsonMap> attributes) =>
      !widget.model.state.busy &&
      (widget.node.allocated || attributes.isEmpty || attribute != null);
  void _apply() {
    widget.model.treeAction(
      widget.node.id,
      widget.node.allocated,
      attribute: attribute,
    );
    Navigator.pop(context);
  }
}
