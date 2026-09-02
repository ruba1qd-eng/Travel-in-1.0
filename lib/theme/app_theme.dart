import 'package:flutter/material.dart';

/// Travel In Design System
/// Deep Navy + Luxury Gold + Teal — Premium & Minimal
class TIColors {
  static const Color navy = Color(0xFF0A1F44);
  static const Color navyDark = Color(0xFF061430);
  static const Color gold = Color(0xFFD4AF37);
  static const Color teal = Color(0xFF14B8A6);
  static const Color softGray = Color(0xFFF4F6FA);
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF2FA96E);
  static const Color warning = Color(0xFFF5A623);
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final cs = ColorScheme.fromSeed(
      seedColor: TIColors.navy,
      brightness: b,
    ).copyWith(secondary: TIColors.teal);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: isDark ? TIColors.navyDark : TIColors.softGray,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : TIColors.navy,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TIColors.gold,
          foregroundColor: TIColors.navyDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerColor: isDark ? Colors.white24 : Colors.black12,
    );
  }
}
