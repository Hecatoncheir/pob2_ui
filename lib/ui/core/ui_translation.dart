import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import 'ui_messages.g.dart';

final _caseFolded = {
  for (final entry in uiExactTranslations.entries)
    entry.key.toLowerCase(): entry.value,
};

String? translateUiError(BuildContext context, String? error) =>
    error == null ? null : translateUi(context, error);

String translateUi(BuildContext context, String source) {
  final localizations = AppLocalizations.of(context);
  if (localizations == null) return source;
  final exact =
      uiExactTranslations[source] ?? _caseFolded[source.toLowerCase()];
  if (exact != null) return exact(localizations);
  for (final rule in uiPatternTranslations) {
    final result = rule.translate(localizations, source);
    if (result != null) return result;
  }
  return source;
}
