const poeNinjaExportHint =
    'Откройте персонажа на poe.ninja, нажмите Copy PoB code и вставьте код в PoB II.';

class BuildImportLink {
  const BuildImportLink(this.source, this.site, this.download);
  final Uri source;
  final String site;
  final Uri? download;
  bool get needsExport => download == null;

  static final _pobb = RegExp(r'^/([A-Za-z0-9_-]{1,128})/?$');
  static final _ninjaCode = RegExp(
    r'^/poe2/pob/(?:raw/)?([A-Za-z0-9_-]{1,128})/?$',
  );
  static final _ninjaProfile = RegExp(
    r'^/poe2/profile/[^/]+/[^/]+/character/[^/]+/?$',
  );
  static final _ninjaBuilds = RegExp(r'^/poe2/builds(?:/[^/]+)*/?$');

  static BuildImportLink parse(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.port != 443 ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException(
        'Введите ссылку на сборку с pobb.in или poe.ninja.',
      );
    }
    return switch (uri.host) {
      'pobb.in' => _pobbLink(uri),
      'poe.ninja' || 'poe2.ninja' => _ninjaLink(uri),
      _ => throw const FormatException(
        'Введите ссылку на сборку с pobb.in или poe.ninja.',
      ),
    };
  }

  static BuildImportLink _pobbLink(Uri uri) {
    final match = _pobb.firstMatch(uri.path);
    if (match == null)
      throw const FormatException('Введите ссылку на сборку с pobb.in.');
    return BuildImportLink(
      uri,
      'pobb.in',
      Uri.https('pobb.in', '/pob/${match.group(1)}'),
    );
  }

  static BuildImportLink _ninjaLink(Uri uri) {
    final path = uri.host == 'poe2.ninja' && !uri.path.startsWith('/poe2/')
        ? '/poe2${uri.path}'
        : uri.path;
    final match = _ninjaCode.firstMatch(path);
    if (match != null) {
      return BuildImportLink(
        uri,
        'poe.ninja',
        Uri.https('poe.ninja', '/poe2/pob/raw/${match.group(1)}'),
      );
    }
    if (_ninjaProfile.hasMatch(path) || _ninjaBuilds.hasMatch(path)) {
      return BuildImportLink(uri, 'poe.ninja', null);
    }
    throw const FormatException('Введите ссылку на сборку PoE 2 с poe.ninja.');
  }
}
