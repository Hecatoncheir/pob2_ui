import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/app_installer.dart';
import '../data/app_release_service.dart';
import '../data/managed_installation.dart';
import '../data/verified_download.dart';
import '../domain/app_info.dart';
import '../domain/app_release.dart';
import 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit({
    required this.root,
    AppReleaseService? releases,
    VerifiedDownload? downloader,
    AppInstaller? installer,
    AppUpdateState initialState = const AppUpdateState(),
  }) : releases = releases ?? AppReleaseService(),
       downloader = downloader ?? VerifiedDownload(),
       installer = installer ?? AppInstaller(),
       super(initialState);
  final Directory root;
  final AppReleaseService releases;
  final VerifiedDownload downloader;
  final AppInstaller installer;
  Directory get cache => Directory.fromUri(root.uri.resolve('updates/'));
  File get preferences =>
      File.fromUri(root.uri.resolve('update-preferences.json'));

  void _update(AppUpdateState next) {
    if (!isClosed) emit(next);
  }

  void _fail(String message, {UpdatePhase? phase}) =>
      _update(state.copyWith(error: message, phase: phase));

  Future<void> initialize() async {
    _update(
      state.copyWith(
        installation: await installer.detect(),
        autoDownload: await _readPreference(),
      ),
    );
    await check();
  }

  Future<bool> _readPreference() async {
    try {
      if (!await preferences.exists()) return false;
      return switch (jsonDecode(await preferences.readAsString())) {
        {'autoDownload': final bool value} => value,
        _ => false,
      };
    } on Object {
      return false;
    }
  }

  Future<void> setAutoDownload(bool value) async {
    _update(state.copyWith(autoDownload: value));
    try {
      await root.create(recursive: true);
      final temporary = File('${preferences.path}.tmp');
      await temporary.writeAsString(
        jsonEncode({'autoDownload': value}),
        flush: true,
      );
      await temporary.rename(preferences.path);
      await _downloadAutomatically();
    } on Object catch (failure) {
      _fail('$failure');
    }
  }

  Future<void> _downloadAutomatically() async {
    if (state.autoDownload &&
        state.phase == UpdatePhase.available &&
        state.installation != null)
      await download();
  }

  Future<void> check() async {
    if (state.busy || isClosed) return;
    final target = currentAppTarget();
    if (target == null) {
      _update(
        state.copyWith(message: 'Для этой платформы пока нет установщика'),
      );
      return;
    }
    _update(
      AppUpdateState(
        installation: state.installation,
        autoDownload: state.autoDownload,
        phase: UpdatePhase.checking,
        message: 'Проверяем выпуски…',
      ),
    );
    try {
      _acceptRelease(await releases.latest(target));
      await _restorePackage();
    } on Object catch (failure) {
      _fail(
        'Не удалось проверить обновления: $failure',
        phase: UpdatePhase.idle,
      );
    }
    await _downloadAutomatically();
  }

  void _acceptRelease(AppRelease? release) {
    if (release == null) {
      _update(
        state.copyWith(
          phase: UpdatePhase.idle,
          message: 'Стабильных выпусков пока нет',
        ),
      );
      return;
    }
    if (release.version.compareTo(AppVersion.parse(appVersion)) <= 0) {
      _update(
        state.copyWith(
          phase: UpdatePhase.idle,
          message: 'Установлена актуальная версия',
        ),
      );
      return;
    }
    _update(
      state.copyWith(
        release: release,
        phase: UpdatePhase.available,
        message: 'Доступна версия ${release.version}',
      ),
    );
  }

  Future<void> _restorePackage() async {
    final asset = state.release?.installer;
    if (!state.available || asset == null) return;
    final package = File.fromUri(cache.uri.resolve(asset.name));
    if (await downloader.verify(package, asset))
      _update(state.copyWith(package: package, phase: UpdatePhase.ready));
  }

  Future<void> download() async {
    final asset = state.release?.installer;
    if (state.busy || asset == null || isClosed) return;
    _update(
      state.copyWith(
        phase: UpdatePhase.downloading,
        clearError: true,
        progress: 0,
      ),
    );
    try {
      final package = await downloader.download(
        asset,
        cache,
        onProgress: (value) => _update(state.copyWith(progress: value)),
      );
      _update(state.copyWith(package: package, phase: UpdatePhase.ready));
    } on DownloadCancelled {
      _update(state.copyWith(phase: UpdatePhase.available));
    } on Object catch (failure) {
      _fail('Загрузка не завершена: $failure', phase: UpdatePhase.available);
    }
  }

  void cancel() => downloader.cancel();

  Future<void> openReleases() async {
    try {
      await installer.openReleases();
    } on Object catch (failure) {
      _fail('Не удалось открыть страницу выпусков: $failure');
    }
  }

  Future<bool> install(Future<void> Function() checkpoint) async {
    final AppUpdateState(:phase, :installation, :package, :release) = state;
    if (phase != UpdatePhase.ready ||
        installation == null ||
        package == null ||
        release?.installer == null)
      return false;
    _update(state.copyWith(phase: UpdatePhase.installing, clearError: true));
    try {
      if (!await downloader.verify(package, release!.installer!))
        throw const FormatException(
          'Проверка пакета перед установкой не пройдена',
        );
      await checkpoint();
      await installer.start(
        package,
        installation,
        version: '${release.version}',
      );
      return true;
    } on Object catch (failure) {
      _fail('Обновление не запущено: $failure', phase: UpdatePhase.ready);
      return false;
    }
  }

  @override
  Future<void> close() async {
    downloader.cancel();
    await super.close();
  }
}
