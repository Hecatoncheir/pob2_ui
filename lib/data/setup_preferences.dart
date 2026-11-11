import 'dart:io';

import 'atomic_text_file.dart';

class SetupPreferences {
  SetupPreferences(Directory root)
    : _marker = File.fromUri(root.uri.resolve('setup-wizard-seen'));

  final File _marker;

  Future<bool> wasShown() => _marker.exists();

  Future<void> markShown() => AtomicTextFile().write(_marker, '1');
}
