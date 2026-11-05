import 'dart:convert';
import 'dart:io';

import '../domain/app_language.dart';

class LanguagePreferences {
  LanguagePreferences(Directory root)
    : file = File.fromUri(root.uri.resolve('language.json'));
  final File file;

  Future<AppLanguage> load() async {
    try {
      if (!await file.exists() || await file.length() > 4096)
        return AppLanguage.russian;
      return switch (jsonDecode(await file.readAsString())) {
        {'schema': 1, 'language': final String code} => AppLanguage.parse(code),
        _ => AppLanguage.russian,
      };
    } on FormatException {
      return AppLanguage.russian;
    } on FileSystemException {
      return AppLanguage.russian;
    }
  }

  Future<void> save(AppLanguage language) async {
    await file.parent.create(recursive: true);
    final temporary = File(
      '${file.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await temporary.writeAsString(
        jsonEncode({'schema': 1, 'language': language.code}),
        flush: true,
      );
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
