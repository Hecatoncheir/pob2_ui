import 'dart:io';

Future<String> fileSha256(File file) async {
  final ProcessResult result;
  if (Platform.isWindows) {
    result = await Process.run(
      'powershell.exe',
      [
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-WindowStyle',
        'Hidden',
        '-Command',
        r'''$stream = [IO.File]::OpenRead($env:POB2_HASH_FILE); $hash = [Security.Cryptography.SHA256]::Create(); try { [BitConverter]::ToString($hash.ComputeHash($stream)).Replace('-', '').ToLowerInvariant() } finally { $stream.Dispose(); $hash.Dispose() }''',
      ],
      environment: {'POB2_HASH_FILE': file.absolute.path},
    );
  } else {
    result = await Process.run(
      Platform.isMacOS ? '/usr/bin/shasum' : '/usr/bin/sha256sum',
      [
        if (Platform.isMacOS) ...['-a', '256'],
        '--',
        file.absolute.path,
      ],
    );
  }
  final digest = result.stdout
      .toString()
      .trim()
      .split(RegExp(r'\s+'))
      .first
      .toLowerCase();
  if (result.exitCode != 0 || !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
    throw FileSystemException(
      'Не удалось проверить SHA-256 файла: ${result.stderr}',
    );
  }
  return digest;
}
