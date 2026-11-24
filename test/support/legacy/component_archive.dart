import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:posix/posix.dart' as posix;

Future<void> extractComponentArchive(String source, String destination) =>
    Isolate.run(() => _extract(source, destination));

void _extract(String source, String destination) {
  final input = InputFileStream(source);
  try {
    final seen = <String>{};
    final archive = ZipDecoder().decodeStream(
      input,
      callback: (entry) {
        if (!seen.add(entry.name.toLowerCase())) {
          throw const FormatException('Повторяющийся путь в архиве');
        }
        _validateEntry(entry);
      },
    );
    final size = archive.files.fold(0, (sum, entry) => sum + entry.size);
    if (size > 1024 * 1024 * 1024) {
      throw const FormatException('Распакованный компонент слишком велик');
    }
    final root = Directory(destination).uri;
    for (final entry in archive.files) {
      _extractFile(root, entry);
    }
  } finally {
    input.closeSync();
  }
}

final _unsupportedName = RegExp(r'[<>:"\\|?*\x00-\x1f]');
final _reservedName = RegExp(
  r'^(con|prn|aux|nul|com[1-9¹²³]|lpt[1-9¹²³])(?:\.|$)',
  caseSensitive: false,
);

void _validateEntry(ArchiveFile entry) {
  if (!entry.isFile ||
      entry.isSymbolicLink ||
      (entry.mode & 0xf000) != 0x8000) {
    throw const FormatException('Недопустимый тип файла в архиве');
  }
  if (entry.name.split('/').any(_unsafeSegment)) {
    throw const FormatException('Недопустимый путь в архиве');
  }
}

bool _unsafeSegment(String value) =>
    value.isEmpty ||
    value.endsWith('.') ||
    value.endsWith(' ') ||
    _unsupportedName.hasMatch(value) ||
    _reservedName.hasMatch(value);

void _extractFile(Uri root, ArchiveFile entry) {
  final relative = entry.name.split('/').map(Uri.encodeComponent).join('/');
  final file = File.fromUri(root.resolve(relative));
  file.parent.createSync(recursive: true);
  final output = OutputFileStream(file.path);
  try {
    entry.writeContent(output);
  } finally {
    output.closeSync();
  }
  if (file.lengthSync() != entry.size) {
    throw const FormatException('Распакованный размер файла не совпал');
  }
  if (!Platform.isWindows && (entry.mode & 0x49) != 0) {
    posix.chmodWithMode(file.path, 0x1ed);
  }
}
