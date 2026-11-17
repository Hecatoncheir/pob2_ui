import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/component_repository.dart';
import 'package:pob2_ui/data/file_digest.dart';
import 'package:pob2_ui/data/installation_store.dart';
import 'package:pob2_ui/data/process_service.dart';
import 'package:pob2_ui/data/verified_download.dart';
import 'package:pob2_ui/domain/app_release.dart';
import 'package:pob2_ui/domain/component.dart';

import 'support/temporary_directory.dart';

const _tag = 'v1.0.0';
const _commit = '0123456789012345678901234567890123456789';

void main() {
  late Directory root;
  late InstallationStore store;
  late ComponentRepository repository;
  late _LocalDownload download;
  late _Lua processes;
  late Installations old;
  late Map<Component, Release> releases;
  final log = StringBuffer();

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pob2-component-archives-');
    addTearDown(() => removeTemporaryDirectory(root));
    store = InstallationStore(root);
    download = _LocalDownload();
    processes = _Lua();
    repository = ComponentRepository(
      store: store,
      processes: processes,
      packageDownload: download,
    );
    old = {
      for (final component in Component.values)
        component: Installation(
          tag: _tag,
          commit: _commit,
          directory: Directory.fromUri(
            root.uri.resolve('old-${component.name}/'),
          ).path,
        ),
    };
    await store.save(old, {});
    await repository.load();
    releases = {
      Component.pob: await _pack(root, download, 'pob.zip', [
        'src/Launch.lua',
        'src/Modules/Main.lua',
        'runtime/lua/dkjson.lua',
        'runtime/lua51.dll',
      ]),
      Component.mcp: await _pack(root, download, 'mcp.zip', [
        'pob_poe2_mcp/server.py',
        'run.py',
        Platform.isWindows ? 'python/python.exe' : 'python/bin/python3',
      ]),
    };
  });

  test(
    'Переход с клона на архивы той же версии сохраняет пару для отката',
    () async {
      expect(
        repository.needsInstall(Component.mcp, releases[Component.mcp]!),
        isTrue,
      );
      await repository.installPair(releases, log.writeln);
      final installed = await store.read();
      expect(
        installed.active.values.every((item) => item.archiveSha256 != null),
        isTrue,
      );
      expect(
        installed.previous[Component.mcp]?.directory,
        old[Component.mcp]?.directory,
      );
      expect(processes.calls, everyElement(isNot('git')));
      expect(processes.calls.first, contains('python'));
      await repository.installPair(releases, log.writeln);
      expect(download.attempts, 2);
      await repository.rollback();
      expect(
        repository.active[Component.mcp]?.directory,
        old[Component.mcp]?.directory,
      );
    },
  );

  for (final failure in ['обрыв', 'архив', 'Lua']) {
    test(
      'Сбой «$failure» сохраняет пару и убирает временные каталоги',
      () async {
        download.interrupted = failure == 'обрыв';
        processes.valid = failure != 'Lua';
        if (failure == 'архив') {
          releases[Component.mcp] = await _pack(root, download, 'bad.zip', [
            '../outside',
          ]);
        }

        await expectLater(
          repository.installPair(releases, log.writeln),
          throwsA(anything),
        );
        final installed = await InstallationStore(root).read();
        expect(
          installed.active[Component.mcp]?.directory,
          old[Component.mcp]?.directory,
        );
        expect(installed.previous, isEmpty);
        expect(
          await Directory.fromUri(root.uri.resolve('versions/'))
              .list()
              .toList(),
          isEmpty,
        );
        expect(
          await File.fromUri(root.uri.resolve('outside')).exists(),
          isFalse,
        );
      },
    );
  }
}

Future<Release> _pack(
  Directory root,
  _LocalDownload download,
  String name,
  List<String> paths,
) async {
  final archive = Archive();
  for (final path in paths) {
    archive.addFile(ArchiveFile.string(path, 'fixture')..mode = 0x81a4);
  }
  final source = await File.fromUri(root.uri.resolve(name))
      .writeAsBytes(ZipEncoder().encode(archive));
  download.sources[name] = source;
  return Release(
    _tag,
    '',
    DateTime.utc(2026),
    expectedCommit: _commit,
    package: AppAsset(
      name: name,
      url: Uri.https('github.com', '/${source.uri.pathSegments.last}'),
      size: await source.length(),
      sha256: await fileSha256(source),
    ),
  );
}

class _LocalDownload extends VerifiedDownload {
  final sources = <String, File>{};
  int attempts = 0;
  bool interrupted = false;

  @override
  Future<File> download(
    AppAsset asset,
    Directory directory, {
    required void Function(double) onProgress,
  }) async {
    attempts++;
    if (interrupted) throw const SocketException('Обрыв загрузки');
    await directory.create(recursive: true);
    final file = await sources[asset.name]!.copy(
      File.fromUri(directory.uri.resolve(asset.name)).path,
    );
    expect(await verify(file, asset), isTrue);
    return file;
  }
}

class _Lua extends ProcessService {
  final calls = <String>[];
  bool valid = true;

  @override
  Future<String> python() async => 'legacy-python';

  @override
  Future<String> run(
    String executable,
    List<String> arguments, {
    String? directory,
    Duration timeout = const Duration(minutes: 10),
    void Function(String)? onOutput,
  }) async {
    calls.add(executable);
    return arguments.contains('doctor') ? '{"ok": $valid, "classes": 8}' : '';
  }
}
