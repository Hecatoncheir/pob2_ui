import 'dart:io';

import '../domain/proxy_settings.dart';

class ProxyHttpOverrides extends HttpOverrides {
  ProxyHttpOverrides(this._settings);

  final ProxySettings Function() _settings;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..findProxy = (uri) => _settings().findProxy(uri);
}
