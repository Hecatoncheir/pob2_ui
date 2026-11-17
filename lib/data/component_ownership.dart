import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../domain/component.dart';

const componentOwnershipFile = '.pob2-component.json';
File _marker(Directory directory) =>
    File(path.join(directory.path, componentOwnershipFile));

Future<void> recordComponent(
  Directory directory,
  Component component,
  Installation installation,
) => _marker(directory).writeAsString(
  jsonEncode({
    'schema': 1,
    'component': component.name,
    'tag': installation.tag,
    'commit': installation.commit,
  }),
  flush: true,
);

Future<String?> managedComponentTag(Directory directory) async {
  final marker = _marker(directory);
  if (await FileSystemEntity.type(marker.path, followLinks: false) !=
      FileSystemEntityType.file) {
    return null;
  }
  if (await marker.length() > 4096) return null;
  try {
    return switch (jsonDecode(await marker.readAsString())) {
      {
        'schema': 1,
        'component': final String component,
        'tag': final String tag,
        'commit': final String commit,
      }
          when _matches(directory, component, tag, commit) =>
        tag,
      _ => null,
    };
  } on FormatException {
    return null;
  }
}

bool _matches(
  Directory directory,
  String component,
  String tag,
  String commit,
) =>
    RegExp(r'^(pob|mcp)-[A-Za-z0-9]+$')
            .firstMatch(path.basename(directory.path))
            ?.group(1) ==
        component &&
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$').hasMatch(tag) &&
    RegExp(r'^[a-f0-9]{40}$').hasMatch(commit);
