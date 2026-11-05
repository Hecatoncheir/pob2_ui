import 'dart:convert';
import 'dart:io';

import '../domain/interface_scale.dart';

class InterfaceScaleRepository {
  InterfaceScaleRepository(Directory root)
    : file = File.fromUri(root.uri.resolve('interface-scale.json'));
  final File file;

  Future<int> load() async {
    try {
      if (!await file.exists() || await file.length() > 4096) return 100;
      return switch (jsonDecode(await file.readAsString())) {
        {'schema': 1, 'percent': final int percent} => normalizeInterfaceScale(
          percent,
        ),
        _ => 100,
      };
    } on FormatException {
      return 100;
    } on FileSystemException {
      return 100;
    }
  }

  Future<void> save(int percent) async {
    await file.parent.create(recursive: true);
    final temporary = File(
      '${file.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await temporary.writeAsString(
        jsonEncode({'schema': 1, 'percent': percent}),
        flush: true,
      );
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
