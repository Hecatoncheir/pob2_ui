import 'dart:convert';
import 'dart:io';

import '../domain/component.dart';
import 'mcp_client.dart';
import 'process_service.dart';

class PobWindowRepository {
  const PobWindowRepository();

  bool get supported => Platform.isWindows;

  Future<List<String>> findInstallations(Installation mcp) async {
    final output = await _run(mcp, ['-c', _discovery]);
    final paths = (jsonDecode(output) as List).cast<String>();
    return List.unmodifiable(paths);
  }

  Future<void> installBridge(Installation mcp, String directory) async {
    final folder = Directory(directory);
    final executable = File.fromUri(
      folder.uri.resolve(Uri.encodeComponent('Path of Building-PoE2.exe')),
    );
    if (!await executable.exists()) {
      throw const FormatException('Выберите папку с приложением PoB для PoE 2');
    }
    await _run(mcp, ['run.py', 'install-bridge', '--pob-dir', folder.path]);
  }

  Future<void> checkBridge(Installation mcp, String directory) async {
    await _exportXml(mcp, directory: directory);
  }

  Future<String> readXml(Installations components) async {
    final mcp = components[Component.mcp];
    if (mcp == null) throw StateError('Подключите Lua');
    return _exportXml(mcp);
  }

  Future<String> _exportXml(Installation mcp, {String? directory}) async {
    final client = McpClient();
    try {
      await client.connectToPobWindow(mcp, directory: directory);
      return await client.exportBuildXml();
    } finally {
      await client.close();
    }
  }

  Future<String> _run(Installation mcp, List<String> arguments) async {
    final process = ProcessService();
    final python = await process.python();
    try {
      return await process.run(
        python,
        ['-X', 'utf8', ...arguments],
        directory: mcp.directory,
        timeout: const Duration(seconds: 30),
      );
    } on ProcessException catch (error) {
      throw StateError(error.message.trim());
    }
  }
}

const _discovery = '''
import json
from pathlib import Path

from pob_poe2_mcp.bridge import load_config
from pob_poe2_mcp.engine import engine_layout, installed_engine_dirs
from pob_poe2_mcp.transport import bridge_state_dir

paths = installed_engine_dirs()
saved = load_config(bridge_state_dir()).get("installDir")
if isinstance(saved, str):
    path = Path(saved).resolve()
    if engine_layout(path) and path not in paths:
        paths.append(path)

print(json.dumps([
    str(path) for path in paths if (path / "Path of Building-PoE2.exe").is_file()
]))
''';
