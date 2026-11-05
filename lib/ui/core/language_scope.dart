import 'package:flutter/material.dart';

import '../../domain/game_dictionary.dart';
import 'ui_translation.dart';

class LanguageScope extends InheritedWidget {
  const LanguageScope({
    super.key,
    required this.dictionary,
    required super.child,
  });
  final GameDictionary? dictionary;
  static GameDictionary? dictionaryOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LanguageScope>()?.dictionary;
  @override
  bool updateShouldNotify(LanguageScope oldWidget) =>
      oldWidget.dictionary != dictionary;
}

String translateGame(BuildContext context, String source) {
  final value =
      LanguageScope.dictionaryOf(context)?.translate(source) ?? source;
  if (value != source) return value;
  final translated = translateUi(context, source);
  if (translated != source) return translated;
  // Числовые значения остаются строками Lua. Переводится только имя показателя.
  final match = RegExp(r'^([+-]?[0-9.,]+%? )([^\n(\[]+)(.*)$')
      .firstMatch(source);
  if (match == null) return source;
  final label = match[2]!.trimRight();
  final suffix = source.substring(match[1]!.length + label.length);
  return '${match[1]}${translateUi(context, label)}${suffix.replaceAll('per point', translateUi(context, 'На очко'))}';
}
