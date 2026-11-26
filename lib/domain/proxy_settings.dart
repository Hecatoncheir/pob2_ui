import 'dart:io';

enum ProxyMode { automatic, direct, manual }

final class ProxySettings {
  const ProxySettings._(this.mode, [this.address = '']);

  const ProxySettings.automatic() : this._(ProxyMode.automatic);

  const ProxySettings.direct() : this._(ProxyMode.direct);

  factory ProxySettings.manual(String address) {
    final endpoint = _endpointPattern.firstMatch(address.trim());
    if (endpoint != null) {
      final host = endpoint[1]!.toLowerCase();
      final port = int.tryParse(endpoint[2]!);
      if (port != null && port >= 1 && port <= 65535 && _isValidHost(host)) {
        return ProxySettings._(ProxyMode.manual, '$host:$port');
      }
    }
    throw const FormatException(
      'Введите адрес HTTP-прокси в формате хост:порт.',
    );
  }

  static final _endpointPattern = RegExp(
    r'^(?:http://)?(\[[a-f0-9:.]+\]|[a-z0-9_.-]+):([0-9]+)$',
    caseSensitive: false,
  );

  static final _hostLabel = RegExp(r'^[a-z0-9_](?:[a-z0-9_-]*[a-z0-9_])?$');

  final ProxyMode mode;
  final String address;

  String findProxy(Uri uri) {
    if (_isLoopback(uri.host)) return 'DIRECT';
    return switch (mode) {
      ProxyMode.automatic => HttpClient.findProxyFromEnvironment(uri),
      ProxyMode.direct => 'DIRECT',
      ProxyMode.manual => 'PROXY $address',
    };
  }

  Map<String, String> get engineEnvironment {
    if (mode == ProxyMode.automatic) return const {};
    final proxyUrl = mode == ProxyMode.manual ? 'http://$address' : '';
    final values = {
      'HTTP_PROXY': proxyUrl,
      'HTTPS_PROXY': proxyUrl,
      'ALL_PROXY': '',
      'NO_PROXY': mode == ProxyMode.manual
          ? 'localhost,localhost.,127.0.0.0/8,::1'
          : '',
    };
    return {
      ...values,
      if (!Platform.isWindows)
        for (final entry in values.entries)
          entry.key.toLowerCase(): entry.value,
    };
  }

  static bool _isValidHost(String host) {
    if (host.startsWith('[')) {
      final ip = InternetAddress.tryParse(host.substring(1, host.length - 1));
      return ip?.type == InternetAddressType.IPv6;
    }
    final name = host.endsWith('.') ? host.substring(0, host.length - 1) : host;
    return name.split('.').every(_hostLabel.hasMatch);
  }

  static bool _isLoopback(String host) {
    if (host == 'localhost' || host == 'localhost.') return true;
    final address = InternetAddress.tryParse(host);
    if (address == null) return false;
    if (address.isLoopback) return true;
    // IPv4-адрес из диапазона 127.0.0.0/8, представленный в формате IPv6.
    return switch (address.rawAddress) {
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 127, _, _, _] => true,
      _ => false,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is ProxySettings && other.mode == mode && other.address == address;

  @override
  int get hashCode => Object.hash(mode, address);
}
