import 'dart:io';

import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/domain/component.dart';

class LegacyProcessService extends ProcessService {
  const LegacyProcessService();

  Future<String> runtimePython(Installation mcp) async {
    if (mcp.archiveSha256 == null) return python();
    final file = File.fromUri(
      Directory(mcp.directory).absolute.uri.resolve(
        Platform.isWindows ? 'python/python.exe' : 'python/bin/python3',
      ),
    );
    if (!await file.exists()) {
      throw StateError('В пакете MCP отсутствует Python');
    }
    return file.path;
  }

  Future<String> python() async {
    final executable =
        Platform.environment['POB2_UI_PYTHON'] ??
        (Platform.isWindows ? 'python' : 'python3');
    await run(executable, [
      '-c',
      'import sys, struct; assert sys.version_info >= (3,11) and struct.calcsize("P") == 8, "Нужен 64-битный Python 3.11+"',
    ], timeout: const Duration(seconds: 15));
    return executable;
  }
}
