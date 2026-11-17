import 'dart:io';

import '../../lib/data/profile_use.dart';

Future<void> main(List<String> args) async {
  final use = await ProfileUse.open(Directory(args.single));
  if (use == null) throw StateError('Не удалось открыть общий профиль');
  stdout.writeln('ready');
  await stdout.flush();
  try {
    await stdin.drain<void>();
  } finally {
    await use.close();
  }
}
