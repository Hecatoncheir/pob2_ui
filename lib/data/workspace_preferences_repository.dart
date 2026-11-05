import 'dart:convert';
import 'dart:io';

import '../domain/workspace_preferences.dart';

class WorkspacePreferencesRepository {
  WorkspacePreferencesRepository(Directory root)
    : file = File.fromUri(root.uri.resolve('workspace-preferences.json'));
  final File file;

  Future<WorkspacePreferences> load() async {
    try {
      if (!await file.exists() || await file.length() > 32768) {
        return WorkspacePreferences();
      }
      return _decode(jsonDecode(await file.readAsString()));
    } on FormatException {
      return WorkspacePreferences();
    } on FileSystemException {
      return WorkspacePreferences();
    }
  }

  WorkspacePreferences _decode(dynamic json) {
    if (json case {
      'schema': 1,
      'shortcuts': final Map<String, dynamic> bindings,
    }) {
      return WorkspacePreferences(
        sidebarWidth: settledSidebarWidth(_width(json['sidebarWidth'])),
        expandedWidth: _width(json['expandedWidth']).clamp(160, 300),
        shortcuts: {
          for (final command in AppCommand.values)
            if (bindings.containsKey(command.name))
              command: _binding(bindings[command.name]),
        },
      );
    }
    return WorkspacePreferences();
  }

  double _width(dynamic value) => switch (value) {
    final num number when number.isFinite => number.toDouble().clamp(78, 300),
    _ => 198,
  };

  KeyBinding? _binding(dynamic json) => switch (json) {
    {
      'key': final int key,
      'control': final bool control,
      'alt': final bool alt,
      'shift': final bool shift,
      'meta': final bool meta,
    }
        when key > 0 && (control || alt || meta) =>
      (key: key, control: control, alt: alt, shift: shift, meta: meta),
    _ => null,
  };

  Future<void> save(WorkspacePreferences preferences) async {
    await file.parent.create(recursive: true);
    final temporary = File(
      '${file.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await temporary.writeAsString(
        jsonEncode({
          'schema': 1,
          'sidebarWidth': preferences.sidebarWidth,
          'expandedWidth': preferences.expandedWidth,
          'shortcuts': preferences.shortcuts.map(
            (command, binding) => MapEntry(
              command.name,
              binding == null
                  ? null
                  : {
                      'key': binding.key,
                      'control': binding.control,
                      'alt': binding.alt,
                      'shift': binding.shift,
                      'meta': binding.meta,
                    },
            ),
          ),
        }),
        flush: true,
      );
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
