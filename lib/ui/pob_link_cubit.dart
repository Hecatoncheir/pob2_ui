import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/build_link_browser.dart';
import '../domain/build_import_link.dart';

typedef PobLinkState = ({Uri? profile, bool busy, String? error});

class PobLinkCubit extends Cubit<PobLinkState> {
  PobLinkCubit({
    Future<String?> Function()? readClipboard,
    Future<void> Function(Uri)? openPage,
  }) : _readClipboard = readClipboard ?? _clipboard,
       _openPage = openPage ?? BuildLinkBrowser().open,
       super((profile: null, busy: false, error: null));

  final Future<String?> Function() _readClipboard;
  final Future<void> Function(Uri) _openPage;

  static Future<String?> _clipboard() async =>
      (await Clipboard.getData(Clipboard.kTextPlain))?.text;

  void changed(String value) {
    Uri? profile;
    try {
      final link = BuildImportLink.parse(value);
      if (link.needsExport) profile = link.source;
    } on FormatException {
      profile = null;
    }
    emit((profile: profile, busy: false, error: null));
  }

  Future<void> openProfile() async {
    final profile = state.profile;
    if (profile == null || state.busy) return;
    emit((profile: profile, busy: true, error: null));
    try {
      await _openPage(profile);
    } catch (_) {
      if (!isClosed)
        emit((
          profile: profile,
          busy: true,
          error: 'Не удалось открыть браузер. Откройте ссылку вручную.',
        ));
    } finally {
      if (!isClosed) emit((profile: profile, busy: false, error: state.error));
    }
  }

  Future<String?> pasteCode() async {
    if (state.busy) return null;
    emit((profile: state.profile, busy: true, error: null));
    try {
      final value = (await _readClipboard())?.trim();
      if (value == null || value.isEmpty) {
        if (!isClosed)
          emit((
            profile: state.profile,
            busy: true,
            error: 'В буфере обмена нет кода PoB.',
          ));
        return null;
      }
      return value;
    } catch (_) {
      if (!isClosed)
        emit((
          profile: state.profile,
          busy: true,
          error: 'Не удалось прочитать буфер обмена.',
        ));
      return null;
    } finally {
      if (!isClosed)
        emit((profile: state.profile, busy: false, error: state.error));
    }
  }
}
