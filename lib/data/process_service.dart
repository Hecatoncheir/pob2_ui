import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ProcessService {
  const ProcessService({this.environment});

  final Map<String, String> Function()? environment;

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
      environment: environment?.call(),
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
}
