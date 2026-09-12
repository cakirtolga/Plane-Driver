import 'package:flutter/material.dart';

/// Plane Driver visual source of truth in code.
/// See docs/PLANE_DRIVER_DESIGN_SYSTEM.md for usage rules.
class PlaneDriverTheme {
  // Brand / surfaces
  static const sky = Color(0xFF67C9F4);
  static const skyDeep = Color(0xFF1689D4);
  static const navy = Color(0xFF092F55);
  static const navyDeep = Color(0xFF05233F);
  static const panel = Color(0xFF07569B);
  static const panelLight = Color(0xFF147BC0);
  static const panelSoft = Color(0xFFEAF7FF);
  static const cyan = Color(0xFF20B8FF);

  // Semantic accents
  static const yellow = Color(0xFFFFBE35);
  static const orange = Color(0xFFE78A16);
  static const coral = Color(0xFFFF4B55);
  static const green = Color(0xFF52D273);
  static const purple = Color(0xFFA944E8);
  static const pink = Color(0xFFF451C5);

  // World / text
  static const apron = Color(0xFF657B92);
  static const apronLight = Color(0xFF71869A);
  static const white = Color(0xFFF8FCFF);
  static const ink = Color(0xFF113453);
  static const mutedInk = Color(0xFF56718A);

  static const double rSm = 14;
  static const double rMd = 18;
  static const double rLg = 24;
  static const double rXl = 30;

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;

  static const Duration fast = Duration(milliseconds: 110);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration celebration = Duration(milliseconds: 420);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x33052D5D), blurRadius: 12, offset: Offset(0, 5)),
  ];

  static ThemeData data() {
    const baseText = TextStyle(
      color: white,
      fontWeight: FontWeight.w700,
      height: 1.05,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: sky,
      colorScheme: ColorScheme.fromSeed(
        seedColor: skyDeep,
        brightness: Brightness.light,
        primary: skyDeep,
        secondary: yellow,
        error: coral,
        surface: panel,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.4, color: white, height: .95),
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -.8, color: white, height: 1),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.5, color: white, height: 1),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: white),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: white),
        bodyLarge: baseText,
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: white),
        labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: .2, color: navy),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: white),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rLg)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: navy,
          elevation: 0,
          minimumSize: const Size(140, 54),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: const BorderSide(color: Color(0x80FFFFFF), width: 2),
          minimumSize: const Size(120, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navyDeep,
        contentTextStyle: const TextStyle(color: white, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
