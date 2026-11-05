import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main(List<String> arguments) async {
  final driver = await FlutterDriver.connect(dartVmServiceUrl: arguments.first);
  try {
    final file = File(arguments[1]);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(await driver.screenshot());
  } finally {
    await driver.close();
  }
}
