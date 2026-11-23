import 'dart:io';

Future<void> removeTemporaryDirectory(Directory directory) async {
  if (!await directory.exists()) return;
  final target = Directory(await directory.resolveSymbolicLinks());
  final parent = await target.parent.resolveSymbolicLinks();
  final temporary = await Directory.systemTemp.resolveSymbolicLinks();
  if (parent != temporary)
    throw StateError('Каталог теста находится вне временной папки');
  await _remove(target, 20);
}

Future<void> _remove(Directory target, int attempts) async {
  try {
    await target.delete(recursive: true);
  } on FileSystemException catch (error) {
    if (!await target.exists()) return;
    if (!Platform.isWindows ||
        !const {32, 145}.contains(error.osError?.errorCode) ||
        attempts == 0) {
      rethrow;
    }
    // После остановки сервера Windows может ещё освобождать файлы профиля.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _remove(target, attempts - 1);
  }
}
