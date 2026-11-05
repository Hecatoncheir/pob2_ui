import 'dart:io';

import 'managed_installation.dart';

class AppInstaller {
  Future<ManagedInstallation?> detect() async {
    try {
      return await ManagedInstallation.detect();
    } on FileSystemException {
      return null;
    }
  }

  Future<void> start(File package, ManagedInstallation installation) async {
    final root = installation.root.path;
    final arguments = switch (installation.kind) {
      'windows-inno' => [
        '/VERYSILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
        '/SP-',
        '/RELAUNCH',
        '/DIR=$root',
        '/LOG=${package.path}.log',
      ],
      'linux-run' => [
        package.path,
        '--prefix',
        root,
        '--wait-pid',
        '$pid',
        '--relaunch',
      ],
      'macos-dmg' => [
        File.fromUri(
          installation.root.uri.resolve('Contents/Resources/update-macos.sh'),
        ).path,
        package.path,
        root,
        '$pid',
      ],
      _ => throw UnsupportedError('Неизвестный тип установки'),
    };
    await Process.start(
      Platform.isWindows ? package.path : '/bin/sh',
      arguments,
      mode: ProcessStartMode.detached,
    );
  }

  Future<void> openReleases() async {
    const url = 'https://github.com/Hecatoncheir/pob2_ui/releases';
    final command = Platform.isWindows
        ? 'rundll32.exe'
        : Platform.isMacOS
        ? '/usr/bin/open'
        : 'xdg-open';
    await Process.start(
      command,
      Platform.isWindows ? ['url.dll,FileProtocolHandler', url] : [url],
      mode: ProcessStartMode.detached,
    );
  }
}
