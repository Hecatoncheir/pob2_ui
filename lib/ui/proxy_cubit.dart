import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/proxy_preferences.dart';
import '../domain/proxy_settings.dart';

class ProxyCubit extends Cubit<ProxySettings> {
  ProxyCubit(this._preferences, {required ProxySettings initial})
    : super(initial);

  final ProxyPreferences _preferences;

  Future<void> save(ProxySettings settings) async {
    await _preferences.save(settings);
    if (!isClosed) emit(settings);
  }
}
