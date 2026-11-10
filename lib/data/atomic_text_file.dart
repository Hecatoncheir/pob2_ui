import 'dart:io';

class AtomicTextFile {
  Future<void> write(File target, String text, {bool backup = false}) =>
      writeChecked(target, text, backup: backup);

  Future<void> writeChecked(
    File target,
    String text, {
    bool backup = false,
    Future<void> Function()? beforeReplace,
  }) async {
    await target.parent.create(recursive: true);
    final temporary = File(
      '${target.path}.$pid-${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await temporary.writeAsString(text, flush: true);
      if (backup && await target.exists()) {
        await target.copy('${target.path}.bak');
      }
      await beforeReplace?.call();
      await temporary.rename(target.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<String> read(File file, {String? missing}) async {
    try {
      if (!await file.exists() &&
          !await File('${file.path}.bak').exists() &&
          missing != null)
        return missing;
      return await file.readAsString();
    } on FileSystemException {
      return File('${file.path}.bak').readAsString();
    } on FormatException {
      return File('${file.path}.bak').readAsString();
    }
  }
}
