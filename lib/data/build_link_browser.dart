import 'dart:io';

import '../domain/build_import_link.dart';

class BuildLinkBrowser {
  Future<void> open(Uri uri) async {
    if (!BuildImportLink.parse(uri.toString()).needsExport)
      throw const FormatException('Нужна страница персонажа poe.ninja.');
    final command = Platform.isWindows
        ? 'rundll32.exe'
        : Platform.isMacOS
        ? '/usr/bin/open'
        : 'xdg-open';
    await Process.start(
      command,
      Platform.isWindows
          ? ['url.dll,FileProtocolHandler', uri.toString()]
          : [uri.toString()],
      mode: ProcessStartMode.detached,
    );
  }
}
