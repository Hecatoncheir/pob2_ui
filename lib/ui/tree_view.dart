import 'core/dialog_close_button.dart';
import 'core/app_text.dart';

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
import 'tree_jewel_artwork.dart';
import 'original_tree_artwork.dart';
import 'attribute_picker.dart';
import 'tree_point_counters.dart';
import '../domain/node_power.dart';
import 'node_power_cubit.dart';
import 'node_power_panel.dart';
import 'loaded_tree_artwork.dart';
import 'workshop_state.dart';
import 'mcp_editor_cubit.dart';
import 'core/language_scope.dart';

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
  final editorFocus = FocusNode(debugLabel: 'Passive tree');
  bool powerVisible = false;
  int powerGeneration = 0;
  LoadedTreeArtwork? powerArtwork;
  String? powerBuildId;
  late final powerModel = NodePowerCubit(
    widget.model.engine,
    widget.model.loadTreeSceneImages,
  );
  @override
  void initState() {
    super.initState();
    powerBuildId = widget.model.state.library.activeId;
    _loadIcons();
  }

  @override
  void didUpdateWidget(TreeView old) {
    super.didUpdateWidget(old);
    if (old.tree == widget.tree) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPower());
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

  void _refreshPower() {
    if (!mounted) return;
    final nextBuild = widget.model.state.library.activeId;
    if (powerBuildId != nextBuild) {
      powerBuildId = nextBuild;
      powerModel.cancel();
      return;
    }
    if (powerVisible) {
      powerModel.refresh(
        widget.tree.nodes
            .where((node) => node.allocated)
            .map((node) => node.id)
            .toSet(),
      );
    }
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
    return decodeTreeImage(entry.value);
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
    editorFocus.dispose();
    powerGeneration++;
    powerModel.close();
    powerArtwork?.dispose();
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
      BlocListener<McpEditorCubit, McpEditorState>(
        bloc: widget.model.mcpEditor,
        listenWhen: (before, after) =>
            before.change != after.change && after.change?.node != null,
        listener: (context, state) => _scheduleMcpFocus(state.change!.node!),
        child: _treeListeners(context),
      );

  Widget _treeListeners(BuildContext context) =>
      BlocListener<WorkshopCubit, WorkshopState>(
        bloc: widget.model,
        listenWhen: (before, after) =>
            before.document?.stale != after.document?.stale,
        listener: (context, state) {
          if (state.document?.stale == true)
            powerModel.cancel(preserveReport: true);
        },
        child: BlocListener<NodePowerCubit, NodePowerState>(
          bloc: powerModel,
          listenWhen: (before, after) =>
              before.report != after.report || before.stale != after.stale,
          listener: _powerChanged,
          child: BlocListener<TreeHoverCubit, TreeHoverState>(
            bloc: hoverModel,
            listener: _hoverChanged,
            child: OverlayPortal(
              controller: tooltipPortal,
              overlayChildBuilder: _tooltip,
              child: Focus(focusNode: editorFocus, child: _body()),
            ),
          ),
        ),
      );

  Widget _body() => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
    child: Column(
      children: [
        _toolbar(),
        const SizedBox(height: 12),
        Expanded(child: _treeArea()),
        if (decodeError case final error?)
          AppText(
            error,
            key: const Key('tree-decode-error'),
            style: TextStyle(color: Spark.of(context).danger, fontSize: 11),
          ),
        if (widget.tree.iconError case final error?)
          AppText(
            error,
            style: TextStyle(color: Spark.of(context).danger, fontSize: 11),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(child: _pointCounters()),
              AppText(
                'PoB · ${widget.tree.version.replaceAll('_', '.')}',
                style: TextStyle(color: Spark.of(context).muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _treeArea() => LayoutBuilder(
    builder: (context, constraints) => Column(
      children: [
        if (powerVisible)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.min(210, constraints.maxHeight * .55),
            ),
            child: NodePowerPanel(
              key: const Key('node-power-panel'),
              model: powerModel,
              onFocus: _focusPowerNode,
              enabled:
                  !widget.model.state.busy &&
                  widget.model.state.document?.stale == false,
            ),
          ),
        if (powerVisible && constraints.maxHeight >= 40)
          const SizedBox(height: 8),
        Expanded(child: _treeCanvas()),
      ],
    ),
  );

  Widget _treeCanvas() => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: ColoredBox(
      color: Spark.of(context).treeBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (viewport == null) {
            viewport = size;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _focusAllocated();
            });
          }
          viewport = size;
          return MouseRegion(
            onHover: (event) => _hover(event.localPosition, event.position),
            onExit: (_) => hoverModel.clear(),
            child: GestureDetector(
              onTapUp: _select,
              onLongPressStart: (event) => _detailsAt(event.localPosition),
              child: InteractiveViewer(
                key: const Key('passive-tree'),
                transformationController: transform,
                onInteractionStart: (_) {
                  editorFocus.requestFocus();
                  zoomAnimation.stop();
                  hoverModel.clear();
                },
                constrained: false,
                minScale: .08,
                maxScale: 12,
                boundaryMargin: const EdgeInsets.all(500),
                child: TreeJewelArtwork(
                  scene: scene,
                  report: widget.model.state.report!,
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
                      powerArtwork?.artwork.picture ?? artwork?.picture,
                      hoverArtwork?.picture,
                      matches: _matchedIds(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _pointCounters() => TreePointCounters(
    widget.model.state.report!.points,
    mode: widget.model.state.treeMode,
    onModeChanged:
        widget.model.state.busy ||
            !widget.model.engine.tools.contains('pob_tree_options')
        ? null
        : widget.model.selectTreeMode,
  );

  Widget _toolbar() => Row(
    children: [
      Expanded(
        child: TextField(
          key: const Key('tree-search'),
          onChanged: (value) => setState(() => query = value),
          onSubmitted: (_) => _focusMatch(),
          decoration: const InputDecoration(
            hint: AppText('Найти узел'),
            prefixIcon: Padding(
              padding: EdgeInsets.all(13),
              child: SparkArt('icons/search', width: 17),
            ),
          ),
        ),
      ),
      const SizedBox(width: 6),
      ArtIconButton.material(
        Icons.manage_search_rounded,
        key: const Key('node-power-toggle'),
        label: 'Найти узлы по характеристике',
        selected: powerVisible,
        onPressed: _togglePower,
      ),
      ArtIconButton('minus', label: 'Отдалить', onPressed: () => _zoom(.8)),
      ArtIconButton('plus', label: 'Приблизить', onPressed: () => _zoom(1.25)),
      ArtIconButton('fit', label: 'Показать всё дерево', onPressed: _fit),
    ],
  );

  void _togglePower() {
    setState(() => powerVisible = !powerVisible);
    if (powerVisible) {
      if (powerModel.state.metrics.isEmpty) powerModel.load();
    } else {
      powerModel.cancel();
    }
  }

  void _focusPowerNode(int id) {
    editorFocus.requestFocus();
    final point = scene.points[id];
    if (point == null || viewport == null) return;
    setState(() => selected = id);
    _center(point, 8);
  }

  void _scheduleMcpFocus(int id) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || viewport == null) return;
        final point = scene.points[id];
        if (point == null) return;
        setState(() => selected = id);
        _center(point, math.max(3, transform.value.getMaxScaleOnAxis()));
      });

  void _powerChanged(BuildContext context, NodePowerState state) {
    final generation = ++powerGeneration;
    hoverModel.clear();
    setState(() {
      powerArtwork?.dispose();
      powerArtwork = null;
    });
    if (!state.stale && state.report != null)
      _loadPowerArtwork(state.report!, generation);
  }

  Future<void> _loadPowerArtwork(NodePowerReport report, int generation) async {
    try {
      final loaded = await LoadedTreeArtwork.load(
        report.scene,
        report.images,
        icons,
      );
      if (!mounted || generation != powerGeneration) {
        loaded.dispose();
        return;
      }
      setState(() => powerArtwork = loaded);
    } catch (error) {
      if (mounted && generation == powerGeneration) {
        setState(
          () => decodeError = 'Не удалось показать тепловую карту: $error',
        );
      }
    }
  }

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
    final node = widget.tree.nodes.where(_matches).firstOrNull;
    if (node == null) return;
    setState(() => selected = node.id);
    _center(scene.points[node.id]!, widget.tree.original == null ? 4 : 8);
  }

  bool _matches(TreeNode node) =>
      node.matches(query) ||
      translateGame(
        context,
        node.name,
      ).toLowerCase().contains(query.trim().toLowerCase());

  Set<int> _matchedIds() => query.trim().isEmpty
      ? const {}
      : widget.tree.nodes.where(_matches).map((node) => node.id).toSet();

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
    _selectNode(node);
  }

  Future<void> _selectNode(TreeNode node) async {
    editorFocus.requestFocus();
    try {
      final attribute =
          node.isAttribute ?? await widget.model.isAttributeNode(node.id);
      if (!mounted || widget.model.state.busy) return;
      if (attribute || node.kind == 'Mastery' && !node.allocated) {
        sparkDialog<void>(context, _NodeDialog(widget.model, node));
      } else {
        widget.model.treeAction(node.id, node.allocated);
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AppText('Не удалось прочитать узел: $error')),
        );
    }
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
        final image = await decodeTreeImage(entry.value);
        if (!_previewIsCurrent(generation)) {
          image.dispose();
          return;
        }
        extraImages[entry.key] = image;
      }
      _recordPreview(preview, generation);
    } catch (error) {
      if (_previewIsCurrent(generation))
        setState(() => decodeError = 'Не удалось показать подсветку: $error');
    }
  }

  bool _previewIsCurrent(int generation) =>
      mounted && generation == previewGeneration;

  void _recordPreview(NodePreview preview, int generation) {
    final scene = preview.scene;
    if (!_previewIsCurrent(generation) || scene == null) return;
    setState(() {
      hoverArtwork?.dispose();
      hoverArtwork = OriginalTreeArtwork(scene, {...icons, ...extraImages});
    });
  }

  Widget _tooltip(BuildContext context) {
    final name = scene.nodes[hoverModel.state.id]?.name ?? '';
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: NodeTooltipLayout(overlay.globalToLocal(mouse)),
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
    final attributes = jsonRows(node?['attributeOptions']);
    final index = attributes.indexWhere(
      (option) => option['name'] == widget.node.name,
    );
    if (index >= 0) attribute = index + 1;
    return (
      lines: NodePreview(tooltip: tooltip).lines
          .map((line) => cleanPoB('${line['text'] ?? ''}'))
          .where((line) => line.isNotEmpty)
          .toList(),
      attributes: attributes,
    );
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<({List<String> lines, List<JsonMap> attributes})>(
        future: details,
        builder: (context, snapshot) => AlertDialog(
          title: AppText(widget.node.name, game: true),
          content: SizedBox(
            width: 470,
            child: SingleChildScrollView(child: _content(snapshot)),
          ),
          actions: [
            const DialogCloseButton(label: 'Закрыть'),
            if (widget.node.allocated &&
                snapshot.data?.attributes.isNotEmpty == true)
              TextButton(
                onPressed: _refund,
                child: const AppText('Вернуть очко'),
              ),
            if (snapshot.hasData &&
                !{
                  'Mastery',
                  'ClassStart',
                  'AscendClassStart',
                }.contains(widget.node.kind))
              FilledButton(
                onPressed: _canApply(snapshot.data!.attributes) ? _apply : null,
                child: AppText(_actionLabel(snapshot.data!.attributes)),
              ),
          ],
        ),
      );
  Widget _content(
    AsyncSnapshot<({List<String> lines, List<JsonMap> attributes})> snapshot,
  ) {
    if (snapshot.hasError)
      return AppText('Не удалось прочитать узел: ${snapshot.error}');
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
            child: AppText(line, game: true),
          ),
        ),
        if (attributes.isNotEmpty)
          AttributePicker(
            options: attributes,
            value: attribute,
            onChanged: (value) => setState(() => attribute = value),
          ),
        if (widget.node.kind == 'Mastery')
          AppText(
            'Выбор эффекта мастерства пока доступен через XML.',
            style: TextStyle(color: Spark.of(context).muted),
          ),
      ],
    );
  }

  bool _canApply(List<JsonMap> attributes) =>
      !widget.model.state.busy &&
      (widget.node.allocated || attributes.isEmpty || attribute != null);

  String _actionLabel(List<JsonMap> attributes) {
    if (!widget.node.allocated) return 'Выбрать путь';
    return attributes.isEmpty ? 'Вернуть узел' : 'Применить';
  }

  void _refund() {
    widget.model.treeAction(widget.node.id, true);
    Navigator.pop(context);
  }

  void _apply() {
    widget.model.treeAction(
      widget.node.id,
      widget.node.allocated,
      attribute: attribute,
    );
    Navigator.pop(context);
  }
}
