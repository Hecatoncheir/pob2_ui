import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../domain/engine_session.dart';

import 'bundled_engine.dart';
import 'process_service.dart';

typedef EngineVersions = ({String? latest, String status, String? message});
typedef EngineUpdates = ({EngineVersions engine, EngineVersions pob});

class EngineMaintenance {
  const EngineMaintenance(
    this.executable, {
    this.processes = const ProcessService(),
  });

  final String executable;
  final ProcessService processes;

  bool get bundled =>
      path.equals(path.absolute(executable), bundledEngineFile().path);

  Future<bool> _isPackagedTarget() async {
    if (bundled) return true;
    final packaged = bundledEngineFile();
    final supplied = File(executable);
    if (!await packaged.exists() || !await supplied.exists()) return false;
    return path.equals(
      await supplied.resolveSymbolicLinks(),
      await packaged.resolveSymbolicLinks(),
    );
  }

  Future<Map<String, dynamic>> version() => _read(['--version']);

  Future<Map<String, dynamic>> doctor([EngineOptions? options]) => _read([
    'doctor',
    if (options != null) ...[
      '--profile',
      options.profile,
      if (options.runtimeDirectory.isNotEmpty) ...[
        '--runtime-dir',
        options.runtimeDirectory,
      ],
      if (options.dataDirectory.isNotEmpty) ...[
        '--data-dir',
        options.dataDirectory,
      ],
    ],
  ]);

  Future<EngineUpdates> checkUpdates() async {
    final result = await _read(['update', '--check']);
    return (engine: _versions(result['engine']), pob: _versions(result['pob']));
  }

  Future<bool> updateStandalone() async {
    if (await _isPackagedTarget())
      throw StateError('Комплектный движок обновляется вместе с PoB II');
    final result = await _read([
      'update',
      '--target',
      'engine',
    ], timeout: const Duration(minutes: 7));
    return result['restart_required'] == true;
  }

  EngineVersions _versions(Object? value) {
    final data = value as Map<String, dynamic>;
    return (
      latest: data['latest_version'] as String?,
      status: data['status'] as String,
      message: data['message'] as String?,
    );
  }

  Future<Map<String, dynamic>> _read(
    List<String> arguments, {
    Duration timeout = const Duration(seconds: 35),
  }) async =>
      jsonDecode(await processes.run(executable, arguments, timeout: timeout))
          as Map<String, dynamic>;
}
