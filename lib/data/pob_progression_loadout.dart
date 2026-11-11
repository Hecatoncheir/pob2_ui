import 'dart:convert';

import 'package:xml/xml.dart';

const _invalidLoadout = FormatException('Некорректные данные этапа');

String captureProgressionSkills(XmlElement root) {
  final snapshot = _activeSet(root, 'Skills', 'SkillSet').copy();
  snapshot.setAttribute(
    'mainSocketGroup',
    root.getElement('Build')!.getAttribute('mainSocketGroup'),
  );
  return snapshot.toXmlString();
}

void applyProgressionSkills(XmlElement root, String saved) {
  final snapshot = _parseSnapshot(saved, 'SkillSet');
  final set = _activeSet(root, 'Skills', 'SkillSet');
  _replaceChildren(set, snapshot.findElements('Skill'));
  final build = root.getElement('Build')!;
  build.setAttribute('mainSkillIndex', null);
  build.setAttribute(
    'mainSocketGroup',
    snapshot.getAttribute('mainSocketGroup'),
  );
}

String captureProgressionEquipment(XmlElement root, XmlElement spec) {
  final snapshot = XmlElement(const XmlName.qualified('Equipment'));
  final set = _activeSet(root, 'Items', 'ItemSet');
  final sockets = spec.getElement('Sockets');
  final ids = _equipmentReferences(
    set,
    sockets,
  ).map((node) => node.getAttribute('itemId')).toSet();
  final items = root.getElement('Items')!.findElements('Item');
  snapshot.children.addAll([
    set.copy(),
    if (sockets != null) sockets.copy(),
    for (final item in items)
      if (ids.contains(item.getAttribute('id'))) item.copy(),
  ]);
  return snapshot.toXmlString();
}

void applyProgressionEquipment(XmlElement root, XmlElement spec, String saved) {
  final snapshot = _parseSnapshot(saved, 'Equipment');
  final savedSet = snapshot.getElement('ItemSet');
  if (savedSet == null) throw _invalidLoadout;
  final items = root.getElement('Items')!;
  final sockets =
      snapshot.getElement('Sockets') ??
      XmlElement(const XmlName.qualified('Sockets'));
  final allocated = (spec.getAttribute('nodes') ?? '').split(',').toSet();
  for (final socket in sockets.findElements('Socket').toList()) {
    if (!allocated.contains(socket.getAttribute('nodeId'))) socket.remove();
  }
  final remap = _mergeItems(
    items,
    snapshot,
    _equipmentReferences(savedSet, sockets),
  );
  for (final reference in _equipmentReferences(savedSet, sockets)) {
    final id = _itemId(reference, 'itemId');
    if (id != 0) reference.setAttribute('itemId', '${remap[id]!}');
  }
  final set = _activeSet(root, 'Items', 'ItemSet');
  _replaceChildren(set, savedSet.childElements);
  final weaponSet = savedSet.getAttribute('useSecondWeaponSet');
  set.setAttribute('useSecondWeaponSet', weaponSet);
  items.setAttribute('useSecondWeaponSet', weaponSet);
  spec.getElement('Sockets')?.remove();
  spec.children.add(sockets.copy());
}

Map<int, int> _mergeItems(
  XmlElement items,
  XmlElement snapshot,
  Iterable<XmlElement> references,
) {
  final saved = {
    for (final item in snapshot.findElements('Item')) _itemId(item, 'id'): item,
  };
  final ids = references.map((node) => _itemId(node, 'itemId')).toSet()
    ..remove(0);
  final inventory = _ProgressionInventory(items);
  final result = <int, int>{};
  for (final id in ids) {
    final item = saved[id];
    if (item == null) throw _invalidLoadout;
    result[id] = inventory.addOrReuse(item);
  }
  return result;
}

class _ProgressionInventory {
  _ProgressionInventory(this.items) {
    for (final item in items.findElements('Item')) {
      final id = _itemId(item, 'id');
      if (id >= _nextId) _nextId = id + 1;
      (_ids[_itemContent(item)] ??= []).add(id);
    }
  }

  final XmlElement items;
  final _ids = <String, List<int>>{};
  int _nextId = 1;

  int addOrReuse(XmlElement item) {
    final matches = _ids[_itemContent(item)];
    // Два одинаковых предмета в разных ячейках сохраняют отдельные ID.
    if (matches != null && matches.isNotEmpty) return matches.removeAt(0);
    final id = _nextId++;
    final copy = item.copy()..setAttribute('id', '$id');
    items.children.add(copy);
    return id;
  }
}

String _itemContent(XmlElement item) => jsonEncode([
  item.innerText.trim(),
  _attributes(item, skip: 'id'),
  item.childElements
      .map((child) => [child.name.qualified, _attributes(child)])
      .toList(),
]);

List<String> _attributes(XmlElement element, {String? skip}) => [
  for (final attribute in element.attributes)
    if (attribute.name.qualified != skip)
      jsonEncode([attribute.name.qualified, attribute.value]),
]..sort();

Iterable<XmlElement> _equipmentReferences(
  XmlElement set,
  XmlElement? sockets,
) sync* {
  yield* set.findElements('Slot');
  if (sockets != null) yield* sockets.findElements('Socket');
}

int _itemId(XmlElement element, String attribute) {
  final id = int.tryParse(element.getAttribute(attribute) ?? '');
  if (id == null || id < 0) throw _invalidLoadout;
  return id;
}

XmlElement _activeSet(XmlElement root, String section, String setName) {
  final parent = root.getElement(section);
  final id = parent?.getAttribute('active$setName') ?? '1';
  return parent
          ?.findElements(setName)
          .where((set) => set.getAttribute('id') == id)
          .singleOrNull ??
      (throw _invalidLoadout);
}

XmlElement _parseSnapshot(String saved, String name) {
  final element = XmlDocument.parse(saved).rootElement;
  if (element.name.qualified != name) throw _invalidLoadout;
  return element;
}

void _replaceChildren(XmlElement target, Iterable<XmlElement> source) {
  target.children
    ..clear()
    ..addAll(source.map((element) => element.copy()));
}
