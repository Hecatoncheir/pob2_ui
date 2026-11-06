import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'workshop_cubit.dart';

class ExitProtection extends StatefulWidget {
  const ExitProtection({super.key, required this.model, required this.child});
  final WorkshopCubit model;
  final Widget child;
  @override
  State<ExitProtection> createState() => _ExitProtectionState();
}

class _ExitProtectionState extends State<ExitProtection> {
  late final AppLifecycleListener listener;
  static const channel = MethodChannel('pob2_ui/window');
  @override
  void initState() {
    super.initState();
    listener = AppLifecycleListener(onExitRequested: _exit);
    channel.setMethodCallHandler(_windowRequest);
  }

  @override
  void dispose() {
    listener.dispose();
    channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<bool> _windowRequest(MethodCall call) async {
    if (call.method != 'requestClose') throw MissingPluginException();
    return await WidgetsBinding.instance.handleRequestAppExit() ==
        AppExitResponse.exit;
  }

  Future<AppExitResponse> _exit() async {
    try {
      await widget.model.checkpoint();
      return AppExitResponse.exit;
    } catch (error) {
      widget.model.reportPersistenceError(
        'Приложение остаётся открытым, чтобы сохранить данные: $error',
      );
      return AppExitResponse.cancel;
    }
  }
}
