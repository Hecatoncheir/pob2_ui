import 'dart:io';

import 'trade_search_repository.dart';

class TradeBrowser {
  Future<void> open(Uri uri) async {
    if (!validTradeLink(uri))
      throw const FormatException('Некорректная ссылка поиска');
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
