import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';

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
