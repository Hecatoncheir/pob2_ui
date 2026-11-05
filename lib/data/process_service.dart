import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ProcessService {
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: directory,
    );
    final output = StringBuffer();
    final errors = StringBuffer();
    final streams = [
      _read(process.stdout, output, onOutput),
      _read(process.stderr, errors, onOutput),
    ];
    try {
      final code = await process.exitCode.timeout(timeout);
      await Future.wait(streams);
      if (code != 0) {
        throw ProcessException(
          executable,
          arguments,
          '${errors.toString()}\n$output',
          code,
        );
      }
      return output.toString().trim();
    } on TimeoutException {
      process.kill();
      throw StateError('Превышено время выполнения $executable');
    }
  }

  Future<void> _read(
    Stream<List<int>> stream,
    StringBuffer buffer,
    void Function(String)? onOutput,
  ) async {
    await for (final chunk in stream.transform(
      const Utf8Decoder(allowMalformed: true),
    )) {
      buffer.write(chunk);
      onOutput?.call(chunk);
    }
  }

  Future<String> python() async {
    final executable = Platform.environment['POB2_UI_PYTHON'] ?? 'python';
    await run(executable, [
      '-c',
      'import sys, struct; assert sys.version_info >= (3,11) and struct.calcsize("P") == 8, "Нужен Python x64 3.11+"',
    ], timeout: const Duration(seconds: 15));
    return executable;
  }
}
