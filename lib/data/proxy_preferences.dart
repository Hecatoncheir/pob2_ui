import 'dart:convert';
import 'dart:io';

import '../domain/proxy_settings.dart';
import 'atomic_text_file.dart';

class ProxyPreferences {
  ProxyPreferences(Directory root)
    : _file = File.fromUri(root.uri.resolve('proxy.json'));

  final File _file;
  final _files = AtomicTextFile();

  Future<ProxySettings> load() async {
    try {
      return switch (jsonDecode(await _files.read(_file, missing: '{}'))) {
        {'schema': 1, 'mode': 'direct'} => const ProxySettings.direct(),
        {'schema': 1, 'mode': 'manual', 'address': final String address} =>
          ProxySettings.manual(address),
        _ => const ProxySettings.automatic(),
      };
    } on FormatException {
      return const ProxySettings.automatic();
    } on FileSystemException {
      return const ProxySettings.automatic();
    }
  }

  Future<void> save(ProxySettings settings) => _files.write(
    _file,
    jsonEncode({
      'schema': 1,
      'mode': settings.mode.name,
      if (settings.mode == ProxyMode.manual) 'address': settings.address,
    }),
  );
}
