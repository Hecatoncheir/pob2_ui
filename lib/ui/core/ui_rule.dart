import '../../l10n/generated/app_localizations.dart';

typedef UiRenderer = String Function(AppLocalizations, List<String>);

class UiRule {
  UiRule(String source, this.render) : _compiled = _compile(source);
  final ({RegExp expression, List<int> indices}) _compiled;
  final UiRenderer render;

  String? translate(AppLocalizations localizations, String source) {
    final match = _compiled.expression.firstMatch(source);
    if (match == null) return null;
    final arguments = List.filled(_compiled.indices.length, '');
    for (final (index, parameter) in _compiled.indices.indexed) {
      arguments[parameter] = match[index + 1] ?? '';
    }
    return render(localizations, arguments);
  }

  static ({RegExp expression, List<int> indices}) _compile(String source) {
    final pattern = StringBuffer('^');
    final indices = <int>[];
    var start = 0;
    for (final match in RegExp(r'\{p(\d+)\}').allMatches(source)) {
      pattern.write(RegExp.escape(source.substring(start, match.start)));
      pattern.write('(.*?)');
      indices.add(int.parse(match[1]!));
      start = match.end;
    }
    pattern.write(RegExp.escape(source.substring(start)));
    pattern.write(r'$');
    return (expression: RegExp('$pattern', dotAll: true), indices: indices);
  }
}
