import 'build_report.dart';

final _damagedName = RegExp(r'\?{2,}|\uFFFD|^\?$');

String readableItemName(String? name, String? base) {
  for (final value in [name, base]) {
    final text = cleanPoB(value ?? '');
    if (text.isNotEmpty && !_damagedName.hasMatch(text)) return text;
  }
  return '—';
}

String itemDisplayName(JsonMap item) =>
    readableItemName(item['name'] as String?, item['base'] as String?);
