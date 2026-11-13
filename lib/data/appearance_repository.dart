import 'dart:convert';
import 'dart:io';

import '../domain/appearance.dart';

class AppearanceRepository {
  AppearanceRepository(Directory root)
    : file = File.fromUri(root.uri.resolve('appearance.json'));
  final File file;

  Future<AppTheme> load() async {
    try {
      if (!await file.exists() || await file.length() > 4096)
        return AppTheme.system;
      return switch (jsonDecode(await file.readAsString())) {
        {'schema': 1, 'theme': 'dark'} => AppTheme.dark,
        {'schema': 1, 'theme': 'light'} => AppTheme.light,
        _ => AppTheme.system,
      };
    } on FormatException {
      return AppTheme.system;
    } on FileSystemException {
      return AppTheme.system;
    }
  }

  Future<void> save(AppTheme theme) async {
    await file.parent.create(recursive: true);
    final temporary = File(
      '${file.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await temporary.writeAsString(
        jsonEncode({'schema': 1, 'theme': theme.name}),
        flush: true,
      );
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
