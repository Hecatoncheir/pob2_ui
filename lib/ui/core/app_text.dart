import 'package:flutter/material.dart';

import 'language_scope.dart';
import 'ui_translation.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.game = false,
    this.localize = true,
  });
  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;
  final bool game, localize;

  @override
  Widget build(BuildContext context) => Text(
    _value(context),
    style: style,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    softWrap: softWrap,
  );

  String _value(BuildContext context) {
    if (!localize) return data;
    return game ? translateGame(context, data) : translateUi(context, data);
  }
}

class AppTooltip extends StatelessWidget {
  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.game = false,
  });
  final String message;
  final Widget child;
  final bool game;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: game
        ? message
              .split('\n')
              .map((line) => translateGame(context, line))
              .join('\n')
        : translateUi(context, message),
    child: child,
  );
}
