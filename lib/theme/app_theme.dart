import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const ink = Color(0xFF193C32);
  static const muted = Color(0xFF63736B);
  static const canvas = Color(0xFFF5F7F5);
  static const lime = Color(0xFFD9EDAD);
  static const line = Color(0xFFE1E7E1);
}

ThemeData buildAppTheme({String? fontFamily}) {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.ink,
      primary: AppPalette.ink,
      surface: AppPalette.canvas,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppPalette.canvas,
    textTheme: base.textTheme.apply(
      bodyColor: AppPalette.ink,
      displayColor: AppPalette.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.canvas,
      foregroundColor: AppPalette.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppPalette.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPalette.line),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppPalette.lime,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? AppPalette.ink
              : AppPalette.muted,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
