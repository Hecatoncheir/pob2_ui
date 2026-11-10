import 'dart:io';

import '../domain/component.dart';
import 'mcp_client.dart';

class PobWindowRepository {
  const PobWindowRepository();

  bool get supported => Platform.isWindows;

  Future<String> readXml(Installations components) async {
    final mcp = components[Component.mcp];
    if (mcp == null) throw StateError('Подключите Lua');
    final client = McpClient();
    try {
      await client.connectToPobWindow(mcp);
      return await client.exportBuildXml();
    } finally {
      await client.close();
    }
  }
}
