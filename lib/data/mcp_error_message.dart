import 'dart:convert';

String mcpErrorMessage(Object error) {
  if (error is FormatException) return error.message;
  final source = error is StateError ? '${error.message}' : '$error';
  final message = source.replaceFirst(
    RegExp(r'^(Bad state: |FormatException: )'),
    '',
  );
  try {
    return switch (jsonDecode(message)) {
      {'message': final String text} => text,
      _ => message,
    };
  } on FormatException {
    return message;
  }
}
