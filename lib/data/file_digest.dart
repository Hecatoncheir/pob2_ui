import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';

Future<String> fileSha256(File file) {
  final path = file.path;
  return Isolate.run(() async {
    final digest = await sha256.bind(File(path).openRead()).single;
    return digest.toString();
  });
}
