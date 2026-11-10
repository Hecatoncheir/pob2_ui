import 'dart:io';

import 'package:file_selector/file_selector.dart';

import 'atomic_text_file.dart';

abstract interface class XmlFileDialogs {
  Future<String?> open();
  Future<String?> save(String suggestedName);
}

class NativeXmlFileDialogs implements XmlFileDialogs {
  static const types = [
    XTypeGroup(
      label: 'XML',
      extensions: ['xml'],
      uniformTypeIdentifiers: ['public.xml'],
    ),
  ];
  @override
  Future<String?> open() async =>
      (await openFile(acceptedTypeGroups: types))?.path;
  @override
  Future<String?> save(String suggestedName) async => (await getSaveLocation(
    suggestedName: suggestedName,
    acceptedTypeGroups: types,
  ))?.path;
}

class XmlFileService {
  XmlFileService({XmlFileDialogs? dialogs, AtomicTextFile? files})
    : dialogs = dialogs ?? NativeXmlFileDialogs(),
      files = files ?? AtomicTextFile();
  final XmlFileDialogs dialogs;
  final AtomicTextFile files;

  Future<({String xml, String title, String path})?> open() async {
    final path = await dialogs.open();
    if (path == null) return null;
    final file = File(path);
    if (await file.length() > 16 * 1024 * 1024) {
      throw const FormatException('XML больше 16 МБ');
    }
    final xml = await file.readAsString();
    if (xml.trim().isEmpty) throw const FormatException('XML пуст');
    final name = file.uri.pathSegments.last;
    final title = name.toLowerCase().endsWith('.xml')
        ? name.substring(0, name.length - 4)
        : name;
    return (xml: xml, title: title, path: path);
  }

  Future<String?> save(
    String xml,
    String title, {
    Future<void> Function(File)? beforeSave,
  }) async {
    final path = await dialogs.save(_suggestedName(title));
    if (path == null) return null;
    final file = File(path);
    await beforeSave?.call(file);
    await files.write(file, xml);
    return path;
  }

  String _suggestedName(String title) {
    final clean = title
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
        .replaceFirst(RegExp(r'[.\s]+$'), '');
    final name = clean.isEmpty ? 'build' : clean;
    final reserved = RegExp(
      r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)',
      caseSensitive: false,
    ).hasMatch(name);
    return '${reserved ? 'build-$name' : name}.xml';
  }
}
