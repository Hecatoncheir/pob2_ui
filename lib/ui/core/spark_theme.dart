import 'package:flutter/material.dart';

import 'gruvbox.dart';

abstract final class Spark {
  static const paper = Color(0xFFF2EFE5);
  static const surface = Color(0xFFFAF8F1);
  static const ink = Color(0xFF242722);
  static const muted = Color(0xFF77796F);
  static const line = Color(0xFFD9D8CD);
  static const sage = Color(0xFFD5DBB5);
  static const green = Color(0xFF526342);
  static const danger = Color(0xFF98513F);
  static const curve = Cubic(.22, 1, .36, 1);
  static const mono = TextStyle(fontFamily: 'JetBrains Mono');

  static SparkColors of(BuildContext context) => SparkColors(Theme.of(context));

  static ThemeData theme({Brightness brightness = Brightness.light}) {
    final dark = brightness == Brightness.dark;
    final background = dark ? Gruvbox.background : paper;
    final scheme = dark ? _darkScheme : _lightScheme();
    final panel = scheme.surface;
    final foreground = scheme.onSurface;
    final secondaryText = scheme.onSurfaceVariant;
    final border = scheme.outline;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Nunito Sans',
      fontFamilyFallback: const ['Noto Thai', 'Noto CJK'],
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 34,
          color: foreground,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 28,
          color: foreground,
          letterSpacing: -.6,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 21,
          color: foreground,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: foreground,
        ),
        bodyMedium: TextStyle(fontSize: 13, height: 1.5, color: foreground),
        bodySmall: TextStyle(fontSize: 11, height: 1.5, color: secondaryText),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        isDense: true,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 400),
      ),
    );
  }

  static ColorScheme _lightScheme() =>
      ColorScheme.fromSeed(seedColor: green, surface: surface).copyWith(
        primary: ink,
        onPrimary: paper,
        secondary: green,
        secondaryContainer: sage,
        onSecondaryContainer: ink,
        onSurface: ink,
        onSurfaceVariant: muted,
        outline: line,
        outlineVariant: line,
        error: danger,
        errorContainer: const Color(0xFFF2DFD5),
        onErrorContainer: danger,
      );

  static const _darkScheme = ColorScheme.dark(
    primary: Gruvbox.yellow,
    onPrimary: Gruvbox.background,
    primaryContainer: Gruvbox.raised,
    onPrimaryContainer: Gruvbox.brightText,
    secondary: Gruvbox.green,
    onSecondary: Gruvbox.background,
    secondaryContainer: Gruvbox.raised,
    onSecondaryContainer: Gruvbox.brightText,
    tertiary: Gruvbox.aqua,
    onTertiary: Gruvbox.background,
    tertiaryContainer: Gruvbox.raised,
    onTertiaryContainer: Gruvbox.brightText,
    surface: Gruvbox.surface,
    onSurface: Gruvbox.foreground,
    onSurfaceVariant: Gruvbox.muted,
    surfaceContainerLowest: Gruvbox.canvas,
    surfaceContainerLow: Gruvbox.background,
    surfaceContainer: Gruvbox.surface,
    surfaceContainerHigh: Gruvbox.raised,
    surfaceContainerHighest: Gruvbox.border,
    outline: Gruvbox.border,
    outlineVariant: Gruvbox.border,
    error: Gruvbox.red,
    onError: Gruvbox.background,
    errorContainer: Gruvbox.raised,
    onErrorContainer: Gruvbox.red,
    inverseSurface: Gruvbox.foreground,
    onInverseSurface: Gruvbox.background,
    inversePrimary: Gruvbox.background,
    surfaceTint: Colors.transparent,
  );
}

class SparkColors {
  const SparkColors(this.theme);
  final ThemeData theme;
  Color get paper => theme.scaffoldBackgroundColor;
  Color get surface => theme.colorScheme.surface;
  Color get ink => theme.colorScheme.onSurface;
  Color get muted => theme.colorScheme.onSurfaceVariant;
  Color get line => theme.colorScheme.outline;
  Color get sage => theme.colorScheme.secondaryContainer;
  Color get green => theme.colorScheme.secondary;
  Color get danger => theme.colorScheme.error;
  Color get treeBackground => const Color(0xFF080C11);
}
