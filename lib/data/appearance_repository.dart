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
        return AppTheme.light;
      return switch (jsonDecode(await file.readAsString())) {
        {'schema': 1, 'theme': 'dark'} => AppTheme.dark,
        _ => AppTheme.light,
      };
    } on FormatException {
      return AppTheme.light;
    } on FileSystemException {
      return AppTheme.light;
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
