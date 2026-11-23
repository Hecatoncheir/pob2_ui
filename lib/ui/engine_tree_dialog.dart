import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/engine_session.dart';
import '../domain/tree_allocation_mode.dart';
import 'core/app_text.dart';
import 'core/dialog_close_button.dart';
import 'core/motion.dart';
import 'engine_build_comparison.dart';
import 'engine_session_cubit.dart';

class EngineTreeButton extends StatelessWidget {
  const EngineTreeButton(this.session, {required this.enabled, super.key});

  final EngineSessionCubit session;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    key: const Key('engine-open-tree'),
    onPressed: enabled
        ? () => sparkDialog<void>(context, EngineTreeDialog(session))
        : null,
    icon: const Icon(Icons.account_tree_outlined),
    label: const AppText('Дерево пассивов'),
  );
}

class EngineTreeDialog extends StatefulWidget {
  const EngineTreeDialog(this.session, {super.key});

  final EngineSessionCubit session;

  @override
  State<EngineTreeDialog> createState() => _EngineTreeDialogState();
}

class _EngineTreeDialogState extends State<EngineTreeDialog> {
  final _query = TextEditingController();
  ({String version, EnginePassivePage page})? _catalog;
  EnginePassive? _node;
  EnginePassiveAttribute? _attribute;
  bool _refund = false;
  TreeAllocationMode _mode = TreeAllocationMode.common;
  EngineTreeOffer? _offer;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
    } catch (error) {
      if (mounted) setState(() => _error = engineError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _clearSearch() => setState(() {
    _catalog = null;
    _select(null);
  });

  Future<void> _search(EngineSnapshot snapshot, String version, int offset) =>
      _run(() async {
        final query = _query.text.trim();
        if (query.isEmpty) return;
        setState(() => _select(null));
        final page = await widget.session.findPassives(
          snapshot,
          version,
          query,
          offset,
        );
        if (!mounted) return;
        setState(() {
          _catalog = (version: version, page: page);
          _select(_matchingNode(page.entries, query));
        });
      });

  EnginePassive? _matchingNode(List<EnginePassive> entries, String query) {
    final id = int.tryParse(query);
    if (id != null) return entries.where((node) => node.id == id).firstOrNull;
    return entries.length == 1 ? entries.single : null;
  }

  void _select(EnginePassive? node) {
    _node = node;
    _attribute = null;
    _refund = false;
    _offer = null;
    _error = null;
  }

  void _chooseAttribute(EnginePassiveAttribute? value) => setState(() {
    _attribute = value;
    _offer = null;
    _error = null;
  });

  void _chooseRefund(bool? value) => setState(() {
    _refund = value ?? false;
    _offer = null;
    _error = null;
  });

  void _chooseMode(TreeAllocationMode? mode) {
    if (mode == null) return;
    setState(() {
      _mode = mode;
      _offer = null;
      _error = null;
    });
  }

  EnginePassive? _attributeNode(EngineTree tree) {
    final node = _node;
    if (_catalog?.version != tree.version ||
        node?.attributeChoice != true ||
        !widget.session.supportsTreeAttributes) {
      return null;
    }
    return node;
  }

  Future<void> _preview(EngineSnapshot snapshot, EngineTreeEdit edit) =>
      _run(() async {
        setState(() => _offer = null);
        final offer = await widget.session.previewTree(snapshot, edit);
        if (mounted) setState(() => _offer = offer);
      });

  Future<void> _apply(EngineTreeOffer offer) => _run(() async {
    await widget.session.editTree(offer);
    if (mounted) Navigator.pop(context);
  });

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EngineSessionCubit, EngineSessionState>(
        bloc: widget.session,
        builder: (_, state) => _dialog(state.snapshot),
      );

  Widget _dialog(EngineSnapshot? snapshot) {
    final tree = snapshot?.build?.tree;
    final current = widget.session.supportsTreePreview && !_busy
        ? snapshot
        : null;
    final offer = _offer;
    final fresh = offer != null && widget.session.isCurrentTreeOffer(offer);
    final edit = _selectedEdit(tree);
    return AlertDialog(
      title: const AppText('Дерево пассивов'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(child: _content(current, tree, fresh)),
      ),
      actions: [
        const DialogCloseButton(
          key: Key('engine-tree-cancel'),
          label: 'Отмена',
        ),
        TextButton(
          key: const Key('engine-tree-preview'),
          onPressed: current != null && edit != null
              ? () => _preview(current, edit)
              : null,
          child: AppText(switch (edit?.action) {
            EngineTreeAction.refund => 'Предпросмотр снятия',
            EngineTreeAction.allocate => 'Предпросмотр назначения',
            EngineTreeAction.setAttribute => 'Предпросмотр смены атрибута',
            null => 'Предпросмотр',
          }),
        ),
        FilledButton(
          key: const Key('engine-tree-apply'),
          onPressed: fresh && current != null ? () => _apply(offer) : null,
          child: const AppText('Применить'),
        ),
      ],
    );
  }

  EngineTreeEdit? _selectedEdit(EngineTree? tree) {
    final node = _node;
    if (tree == null || node == null || _catalog?.version != tree.version) {
      return null;
    }
    final allocated = tree.nodes.contains(node.id);
    final mode = _allocationMode(tree, node.id);
    if (_attributeNode(tree) == null) {
      final action = allocated
          ? EngineTreeAction.refund
          : EngineTreeAction.allocate;
      return (
        nodeId: node.id,
        action: action,
        attribute: null,
        allocationMode: mode,
      );
    }
    return _attributeEdit(tree, node.id, allocated, mode);
  }

  TreeAllocationMode? _allocationMode(EngineTree tree, int id) {
    if (!widget.session.supportsTreeAllocationModes) return null;
    if (!tree.nodes.contains(id)) return _mode;
    return tree.allocations[id] ?? TreeAllocationMode.common;
  }

  EngineTreeEdit? _attributeEdit(
    EngineTree tree,
    int id,
    bool allocated,
    TreeAllocationMode? mode,
  ) {
    if (allocated && _refund) {
      return (
        nodeId: id,
        action: EngineTreeAction.refund,
        attribute: null,
        allocationMode: mode,
      );
    }
    final attribute = _attribute;
    if (attribute == null || attribute == tree.attributes[id]) return null;
    final action = allocated
        ? EngineTreeAction.setAttribute
        : EngineTreeAction.allocate;
    return (
      nodeId: id,
      action: action,
      attribute: attribute,
      allocationMode: mode,
    );
  }

  Widget _content(
    EngineSnapshot? current,
    EngineTree? tree,
    bool fresh,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (tree != null) AppText('Спецификация дерева ${tree.spec}'),
      _searchField(current, tree?.version),
      if (tree != null && _catalog?.version == tree.version)
        _results(tree, current, _catalog!.page),
      if (_modeControls(tree, current != null) case final controls?) controls,
      if (_attributeControls(tree, current != null) case final controls?)
        controls,
      if (_offer case final offer?) _TreeComparison(offer.preview, fresh),
      if (_error case final error?)
        AppText(error, key: const Key('engine-tree-error'), localize: false),
      if (_busy) const LinearProgressIndicator(),
    ],
  );

  Widget? _modeControls(EngineTree? tree, bool enabled) {
    final node = _node;
    if (tree == null || node == null || _catalog?.version != tree.version) {
      return null;
    }
    final mode = _allocationMode(tree, node.id);
    if (mode == null) return null;
    return _modePicker(tree, node.id, mode, enabled);
  }

  Widget _modePicker(
    EngineTree tree,
    int id,
    TreeAllocationMode mode,
    bool enabled,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText('Активное оружие · ${tree.weaponSet == 2 ? "II" : "I"}'),
      const AppText('Режим назначения'),
      DropdownButton<TreeAllocationMode>(
        key: const Key('engine-tree-allocation-mode'),
        isExpanded: true,
        value: mode,
        onChanged: enabled && !tree.nodes.contains(id) ? _chooseMode : null,
        items: [
          for (final entry in TreeAllocationMode.values)
            DropdownMenuItem(value: entry, child: AppText(_modeLabel(entry))),
        ],
      ),
    ],
  );

  Widget? _attributeControls(EngineTree? tree, bool enabled) {
    if (tree == null) return null;
    final node = _attributeNode(tree);
    if (node == null) return null;
    return _attributePicker(tree, node.id, enabled);
  }

  Widget _attributePicker(EngineTree tree, int id, bool enabled) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppText('Атрибут пассива'),
      DropdownButton<EnginePassiveAttribute>(
        key: const Key('engine-tree-attribute'),
        isExpanded: true,
        hint: const AppText('Выберите атрибут'),
        value: _attribute ?? tree.attributes[id],
        onChanged: enabled && !_refund ? _chooseAttribute : null,
        items: [
          for (final attribute in EnginePassiveAttribute.values)
            DropdownMenuItem(
              value: attribute,
              child: AppText(_attributeLabel(attribute)),
            ),
        ],
      ),
      if (tree.nodes.contains(id))
        CheckboxListTile(
          key: const Key('engine-tree-refund'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const AppText('Снять пассив'),
          value: _refund,
          onChanged: enabled ? _chooseRefund : null,
        ),
    ],
  );

  Widget _searchField(EngineSnapshot? current, String? version) {
    final enabled = current != null && version != null;
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('engine-tree-query'),
            controller: _query,
            enabled: enabled,
            decoration: const InputDecoration(
              label: AppText('Имя или ID пассива'),
            ),
            onChanged: (_) => _clearSearch(),
            onSubmitted: enabled ? (_) => _search(current, version, 0) : null,
          ),
        ),
        TextButton(
          key: const Key('engine-tree-search'),
          onPressed: enabled ? () => _search(current, version, 0) : null,
          child: const AppText('Найти'),
        ),
      ],
    );
  }

  Widget _results(
    EngineTree tree,
    EngineSnapshot? current,
    EnginePassivePage page,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (page.entries.isEmpty) const AppText('Ничего не найдено'),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 160),
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: [
            for (final node in page.entries)
              _nodeTile(node, tree.nodes.contains(node.id), current != null),
          ],
        ),
      ),
      if (page.nextOffset case final offset?)
        TextButton(
          onPressed: current == null
              ? null
              : () => _search(current, tree.version, offset),
          child: const AppText('Показать ещё'),
        ),
    ],
  );

  Widget _nodeTile(EnginePassive node, bool allocated, bool enabled) =>
      ListTile(
        key: ValueKey('engine-tree-node-${node.id}'),
        dense: true,
        contentPadding: EdgeInsets.zero,
        selected: _node == node,
        title: AppText(node.name, game: true),
        subtitle: AppText('#${node.id}', localize: false),
        trailing: allocated ? const Icon(Icons.check) : null,
        onTap: enabled ? () => setState(() => _select(node)) : null,
      );
}

class _TreeComparison extends StatelessWidget {
  const _TreeComparison(this.preview, this.fresh);

  final EngineTreePreview preview;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final modes = {
      for (final change in preview.allocations) change.nodeId: change,
    };
    return Column(
      key: const Key('engine-tree-result'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (preview.added.isNotEmpty)
          _nodes('Будут назначены', preview.added, (id) => modes[id]?.after),
        if (preview.removed.isNotEmpty)
          _nodes('Будут сняты', preview.removed, (id) => modes[id]?.before),
        for (final change in preview.allocations)
          if (change.before != null && change.after != null)
            _modeChange(change),
        if (preview.points case final points?) _pointChanges(points),
        for (final change in preview.attributes) _attributeChange(change),
        EngineBuildComparisonPanel(preview.comparison, fresh: fresh),
      ],
    );
  }

  Widget _modeChange(EnginePassiveAllocationChange change) => Wrap(
    key: ValueKey('engine-tree-mode-change-${change.nodeId}'),
    spacing: 8,
    children: [
      AppText('#${change.nodeId}', localize: false),
      AppText(_modeLabel(change.before!)),
      const AppText('→', localize: false),
      AppText(_modeLabel(change.after!)),
    ],
  );

  Widget _pointChanges(EnginePassivePointsChange change) => Wrap(
    key: const Key('engine-tree-point-changes'),
    spacing: 12,
    runSpacing: 4,
    children: [
      const AppText('Очки'),
      _pointDelta('Пассивные', change.before.passives, change.after.passives),
      _pointDelta('Оружие I', change.before.weaponOne, change.after.weaponOne),
      _pointDelta('Оружие II', change.before.weaponTwo, change.after.weaponTwo),
    ],
  );

  Widget _pointDelta(String label, int before, int after) => Wrap(
    spacing: 4,
    children: [AppText(label), AppText('$before → $after', localize: false)],
  );

  Widget _attributeChange(EnginePassiveAttributeChange change) => Wrap(
    key: ValueKey('engine-tree-attribute-change-${change.nodeId}'),
    spacing: 8,
    children: [
      AppText('#${change.nodeId}', localize: false),
      if (change.before case final before?) ...[
        AppText(_attributeLabel(before)),
        const AppText('→', localize: false),
      ],
      AppText(_attributeLabel(change.after)),
    ],
  );

  Widget _nodes(
    String label,
    List<int> ids,
    TreeAllocationMode? Function(int) mode,
  ) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [AppText(label), for (final id in ids) _pathNode(id, mode(id))],
  );

  Widget _pathNode(int id, TreeAllocationMode? mode) => Wrap(
    spacing: 4,
    children: [
      AppText('#$id', localize: false),
      if (mode != null) AppText(_modeLabel(mode)),
    ],
  );
}

String _modeLabel(TreeAllocationMode mode) => switch (mode) {
  TreeAllocationMode.common => 'Общие пассивы',
  TreeAllocationMode.weaponOne => 'Оружие I',
  TreeAllocationMode.weaponTwo => 'Оружие II',
};

String _attributeLabel(EnginePassiveAttribute attribute) => switch (attribute) {
  EnginePassiveAttribute.strength => 'Сила',
  EnginePassiveAttribute.dexterity => 'Ловкость',
  EnginePassiveAttribute.intelligence => 'Интеллект',
};
