import 'package:flutter/material.dart';

class AppTheme {
  // ─── Primary palette ───────────────────────────────────────
  static const Color primary        = Color(0xFFFFFFFF);
  static const Color primaryLight   = Color(0xFFE0E0E0);
  static const Color primaryDark    = Color(0xFFBDBDBD);
  static const Color accent         = Color(0xFFB8CCE8); // periwinkle-blue card color

  // ─── Backgrounds ───────────────────────────────────────────
  static const Color background     = Color(0xFF1E1E1E); // near-black page bg
  static const Color surface        = Color(0xFF1E1E1E); // dark card / nav bg
  static const Color surfaceVariant = Color(0xFF2A2A2A); // inputs, chips bg

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFF9E9E9E);
  static const Color textHint       = Color(0xFF555555);

  // ─── Semantic ──────────────────────────────────────────────
  static const Color success        = Color(0xFF4CAF50);
  static const Color warning        = Color(0xFFFF9800);
  static const Color error          = Color(0xFFE53935);
  static const Color divider        = Color(0xFF2A2A2A);

  // ─── Task card colors (from screenshot) ────────────────────
  static const Color cardBlue       = Color(0xFFB8CCE8); // light periwinkle-blue card
  static const Color cardDark       = Color(0xFF1E1E1E); // dark charcoal card

  // ─── Border Radius ─────────────────────────────────────────
  static const double radiusSmall   = 10.0;
  static const double radiusMedium  = 14.0;
  static const double radiusLarge   = 20.0;
  static const double radiusXL      = 28.0;

  // ─── Shadows ───────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  // ─── ThemeData ─────────────────────────────────────────────
  static ThemeData get lightTheme => darkTheme; // always use dark

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF2A2A2A),
      secondary: accent,
      surface: surface,
      background: background,
      error: error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),

    // White circle FAB with black icon — exactly like screenshot
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 4,
      shape: CircleBorder(),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: const BorderSide(color: Colors.white, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: const BorderSide(color: error),
      ),
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: Colors.white,
      labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: Colors.black, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      side: BorderSide.none,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFF555555),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),

    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 1,
    ),

    textTheme: const TextTheme(
      displayLarge:   TextStyle(color: textPrimary, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1.2, height: 1.1),
      displayMedium:  TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall:   TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
      headlineLarge:  TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall:  TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge:     TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium:    TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      titleSmall:     TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge:      TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium:     TextStyle(color: textSecondary, fontSize: 14),
      bodySmall:      TextStyle(color: textHint, fontSize: 12),
      labelLarge:     TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );
}
//Color(0xFF111111);