import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../domain/tree_progression.dart';
import 'pob_progression_loadout.dart';

const _invalidTree = FormatException('Некорректное дерево сборки');
const _allocationAttributes = [
  'ascendClassId',
  'ascendancyInternalId',
  'secondaryAscendClassId',
  'masteryEffects',
];
const _allocationElements = ['WeaponSet1', 'WeaponSet2', 'Overrides'];
final _masterySelection = RegExp(r'\{(\d+),(\d+)\}');

class PobBuildDocument {
  PobBuildDocument(String text) : _xml = XmlDocument.parse(text) {
    final root = _xml.childElements.singleOrNull;
    if (root?.name.qualified != 'PathOfBuilding2' ||
        root?.getElement('Build') == null) {
      throw const FormatException(
        'Ожидался XML сборки Path of Building для PoE 2.',
      );
    }
  }

  final XmlDocument _xml;
  XmlElement? get _build => _xml.rootElement.getElement('Build');
  XmlElement? get _notes => _xml.rootElement.getElement('Notes');

  XmlElement get _activeSpec {
    final tree = _xml.rootElement.getElement('Tree');
    final index = int.tryParse(tree?.getAttribute('activeSpec') ?? '1');
    final specs = tree?.findElements('Spec').toList() ?? [];
    if (index == null || index < 1 || index > specs.length) throw _invalidTree;
    return specs[index - 1];
  }

  Set<int> get allocatedNodes =>
      _nodeIds(_activeSpec.getAttribute('nodes') ?? '');

  Map<int, int> get allocationModes => {
    for (final id in allocatedNodes) id: 0,
    for (final mode in [1, 2])
      for (final id in _nodeIds(
        _activeSpec.getElement('WeaponSet$mode')?.getAttribute('nodes') ?? '',
      ))
        id: mode,
  };

  Map<int, int> get masteryEffects => {
    for (final match in _masterySelection.allMatches(
      _activeSpec.getAttribute('masteryEffects') ?? '',
    ))
      int.parse(match[1]!): int.parse(match[2]!),
  };

  String get progressionAllocation => _progressionAllocation.toXmlString();

  XmlElement get _progressionAllocation {
    final snapshot = XmlElement(const XmlName.qualified('Spec'));
    _copyAllocation(_activeSpec, snapshot);
    for (final element in snapshot.descendants.whereType<XmlElement>()) {
      for (final attribute in element.attributes.where(
        (item) => const {
          'nodes',
          'strNodes',
          'dexNodes',
          'intNodes',
        }.contains(item.name.local),
      )) {
        final nodes = _nodeIds(attribute.value).toList()..sort();
        attribute.value = nodes.join(',');
      }
    }
    return snapshot;
  }

  bool hasSameTreeAllocation(PobBuildDocument other) {
    final result = _progressionAllocation.xpathEvaluate(
      r'deep-equal(., $other)',
      configuration: XPathConfiguration(
        variables: {'other': other._progressionAllocation},
      ),
    );
    return result.single == XPathBoolean.trueInstance;
  }

  String get progressionSkills => captureProgressionSkills(_xml.rootElement);
  String get progressionEquipment =>
      captureProgressionEquipment(_xml.rootElement, _activeSpec);

  String withTreeAllocation(PobBuildDocument source) {
    final target = _activeSpec;
    final allocation = source._activeSpec;
    target.setAttribute('nodes', allocation.getAttribute('nodes'));
    _copyAllocation(allocation, target);
    return _xml.toXmlString();
  }

  String withCalculationConditions(PobBuildDocument source) {
    final root = _xml.rootElement;
    for (final section in ['Config', 'Party']) {
      final previous = root.findElements(section).toList();
      for (final child in previous) {
        child.remove();
      }
      if (source._xml.rootElement.getElement(section) case final condition?) {
        root.children.add(condition.copy());
      }
    }
    return _xml.toXmlString();
  }

  String withProgression(
    TreeProgressionStep step, {
    Set<ProgressionPart> parts = const {ProgressionPart.tree},
  }) {
    final root = _xml.rootElement;
    if (parts.contains(ProgressionPart.tree)) _applyTree(step);
    if (parts.contains(ProgressionPart.skills)) {
      applyProgressionSkills(root, step.skills!);
    }
    if (parts.contains(ProgressionPart.equipment)) {
      applyProgressionEquipment(root, _activeSpec, step.equipment!);
    }
    return _xml.toXmlString();
  }

  void _applyTree(TreeProgressionStep step) {
    final build = _build!;
    final spec = _activeSpec;
    build.setAttribute('level', '${step.level}');
    build.setAttribute('characterLevelAutoMode', 'false');
    final nodes = step.nodes;
    spec.setAttribute('nodes', nodes.join(','));
    if (step.allocation case final saved?) {
      final snapshot = XmlDocument.parse(saved).rootElement;
      if (snapshot.name.qualified != 'Spec') throw _invalidTree;
      _copyAllocation(snapshot, spec);
    }
    _trimAllocation(spec, nodes);
  }

  String get characterClass => _build?.getAttribute('className') ?? '';
  int get level => int.tryParse(_build?.getAttribute('level') ?? '') ?? 1;
  String get notes {
    final text = _notes?.innerText.replaceAll('\r\n', '\n') ?? '';
    // Lua PoB обрамляет содержимое Notes отступами XML.
    if (text.startsWith('\n\t\t') && text.endsWith('\n\t')) {
      return text.substring(3, text.length - 2);
    }
    return text;
  }

  String get revision {
    final game = _xml.rootElement.childElements.where((node) => node != _notes);
    return sha256
        .convert(utf8.encode(game.map((node) => node.toXmlString()).join()))
        .toString();
  }

  String withNotes(String text) {
    final node = _notes ?? XmlElement(const XmlName.qualified('Notes'));
    if (node.parent == null) _xml.rootElement.children.add(node);
    node.children
      ..clear()
      ..add(XmlText(text));
    return _xml.toXmlString();
  }
}

Set<int> _nodeIds(String text) =>
    text.isEmpty ? {} : text.split(',').map(int.parse).toSet();

void _copyAllocation(XmlElement source, XmlElement target) {
  for (final name in _allocationAttributes) {
    target.setAttribute(name, source.getAttribute(name));
  }
  for (final name in _allocationElements) {
    target.getElement(name)?.remove();
    if (source.getElement(name) case final child?) {
      target.children.add(child.copy());
    }
  }
}

void _trimAllocation(XmlElement spec, Set<int> nodes) {
  for (final name in ['WeaponSet1', 'WeaponSet2']) {
    final set = spec.getElement(name);
    final retained = _nodeIds(set?.getAttribute('nodes') ?? '')
        .intersection(nodes);
    set?.setAttribute('nodes', retained.join(','));
  }
  final selections = spec.getAttribute('masteryEffects') ?? '';
  final retained = _masterySelection
      .allMatches(selections)
      .where((match) => nodes.contains(int.parse(match[1]!)));
  spec.setAttribute(
    'masteryEffects',
    retained.map((match) => match[0]).join(','),
  );
}
