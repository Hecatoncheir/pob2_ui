import 'dart:io';

import '../data/managed_installation.dart';
import '../domain/app_info.dart';
import '../domain/app_release.dart';

enum UpdatePhase { idle, checking, available, downloading, ready, installing }

class AppUpdateState {
  const AppUpdateState({
    this.release,
    this.installation,
    this.package,
    this.phase = UpdatePhase.idle,
    this.message = 'Проверка ещё не выполнялась',
    this.error,
    this.progress = 0,
    this.autoDownload = false,
  });
  final AppRelease? release;
  final ManagedInstallation? installation;
  final File? package;
  final UpdatePhase phase;
  final String message;
  final String? error;
  final double progress;
  final bool autoDownload;

  bool get busy => switch (phase) {
    UpdatePhase.checking ||
    UpdatePhase.downloading ||
    UpdatePhase.installing => true,
    _ => false,
  };
  bool get available =>
      release != null &&
      release!.version.compareTo(AppVersion.parse(appVersion)) > 0;

  AppUpdateState copyWith({
    AppRelease? release,
    ManagedInstallation? installation,
    File? package,
    UpdatePhase? phase,
    String? message,
    String? error,
    bool clearError = false,
    double? progress,
    bool? autoDownload,
  }) => AppUpdateState(
    release: release ?? this.release,
    installation: installation ?? this.installation,
    package: package ?? this.package,
    phase: phase ?? this.phase,
    message: message ?? this.message,
    error: clearError ? null : error ?? this.error,
    progress: progress ?? this.progress,
    autoDownload: autoDownload ?? this.autoDownload,
  );
}
