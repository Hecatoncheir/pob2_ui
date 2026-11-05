import 'package:flutter/material.dart';

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

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(seedColor: green, surface: surface)
        .copyWith(
          primary: ink,
          onPrimary: paper,
          secondary: green,
          outline: line,
          error: danger,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Nunito Sans',
      scaffoldBackgroundColor: paper,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 34,
          color: ink,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 28,
          color: ink,
          letterSpacing: -.6,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 21,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 13, height: 1.5, color: ink),
        bodySmall: TextStyle(fontSize: 11, height: 1.5, color: muted),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: line),
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
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 400),
      ),
    );
  }
}
