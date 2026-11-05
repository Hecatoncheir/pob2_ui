import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/app_installer.dart';
import '../data/app_release_service.dart';
import '../data/managed_installation.dart';
import '../data/verified_download.dart';
import '../domain/app_info.dart';
import '../domain/app_release.dart';

enum UpdatePhase { idle, checking, available, downloading, ready, installing }

class AppUpdateModel extends ChangeNotifier {
  AppUpdateModel({
    required this.root,
    AppReleaseService? releases,
    VerifiedDownload? downloader,
    AppInstaller? installer,
  }) : releases = releases ?? AppReleaseService(),
       downloader = downloader ?? VerifiedDownload(),
       installer = installer ?? AppInstaller();
  final Directory root;
  final AppReleaseService releases;
  final VerifiedDownload downloader;
  final AppInstaller installer;
  AppRelease? release;
  ManagedInstallation? installation;
  File? package;
  UpdatePhase phase = UpdatePhase.idle;
  String message = 'Проверка ещё не выполнялась';
  String? error;
  double progress = 0;
  bool autoDownload = false;
  bool _disposed = false;
  bool get busy => [
    UpdatePhase.checking,
    UpdatePhase.downloading,
    UpdatePhase.installing,
  ].contains(phase);
  bool get available =>
      release != null &&
      release!.version.compareTo(AppVersion.parse(appVersion)) > 0;
  Directory get cache => Directory.fromUri(root.uri.resolve('updates/'));
  File get preferences =>
      File.fromUri(root.uri.resolve('update-preferences.json'));
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    installation = await installer.detect();
    try {
      if (await preferences.exists())
        autoDownload =
            (jsonDecode(await preferences.readAsString())
                as Map<String, dynamic>)['autoDownload'] ==
            true;
    } on Object {
      autoDownload = false;
    }
    await check();
  }

  Future<void> setAutoDownload(bool value) async {
    autoDownload = value;
    _notify();
    try {
      await root.create(recursive: true);
      final temporary = File('${preferences.path}.tmp');
      await temporary.writeAsString(
        jsonEncode({'autoDownload': value}),
        flush: true,
      );
      await temporary.rename(preferences.path);
      if (value &&
          available &&
          phase == UpdatePhase.available &&
          installation != null)
        await download();
    } on Object catch (failure) {
      error = '$failure';
      _notify();
    }
  }

  Future<void> check() async {
    if (busy) return;
    final target = currentAppTarget();
    if (target == null) {
      message = 'Для этой платформы пока нет установщика';
      _notify();
      return;
    }
    phase = UpdatePhase.checking;
    error = null;
    _notify();
    try {
      final latest = await releases.latest(target);
      if (latest == null) {
        message = 'Стабильных выпусков пока нет';
      } else if (latest.version.compareTo(AppVersion.parse(appVersion)) <= 0) {
        message = 'Установлена актуальная версия';
      } else {
        release = latest;
        message = 'Доступна версия ${latest.version}';
      }
      phase = available ? UpdatePhase.available : UpdatePhase.idle;
      if (available && release!.installer != null) {
        final cached = File.fromUri(
          cache.uri.resolve(release!.installer!.name),
        );
        if (await downloader.verify(cached, release!.installer!)) {
          package = cached;
          phase = UpdatePhase.ready;
        }
      }
    } on Object catch (failure) {
      error = 'Не удалось проверить обновления: $failure';
      phase = UpdatePhase.idle;
    }
    _notify();
    if (autoDownload && phase == UpdatePhase.available && installation != null)
      await download();
  }

  Future<void> download() async {
    final asset = release?.installer;
    if (busy || asset == null) return;
    phase = UpdatePhase.downloading;
    error = null;
    progress = 0;
    _notify();
    try {
      package = await downloader.download(
        asset,
        cache,
        onProgress: (value) {
          progress = value;
          _notify();
        },
      );
      phase = UpdatePhase.ready;
    } on DownloadCancelled {
      phase = UpdatePhase.available;
    } on Object catch (failure) {
      error = 'Загрузка не завершена: $failure';
      phase = UpdatePhase.available;
    }
    _notify();
  }

  void cancel() => downloader.cancel();

  Future<bool> install(Future<void> Function() checkpoint) async {
    if (phase != UpdatePhase.ready || installation == null || package == null)
      return false;
    phase = UpdatePhase.installing;
    error = null;
    _notify();
    try {
      if (!await downloader.verify(package!, release!.installer!))
        throw const FormatException(
          'Проверка пакета перед установкой не пройдена',
        );
      await checkpoint();
      await installer.start(package!, installation!);
      return true;
    } on Object catch (failure) {
      error = 'Обновление не запущено: $failure';
      phase = UpdatePhase.ready;
      _notify();
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    downloader.cancel();
    super.dispose();
  }
}
