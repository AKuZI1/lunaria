import 'package:flutter/material.dart';

class AppTheme {
  // ─── Цвета ────────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7B5EA7);
  static const Color primaryLight = Color(0xFFE0D8F0);
  static const Color background = Color(0xFFF0ECF9);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF2D1F4B);
  static const Color textMuted = Color(0xFF9E8EC0);
  static const Color textHint = Color(0xFFB0A8C8);
  static const Color border = Color(0xFFE0D8F0);

  // ─── ThemeData ────────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    fontFamily: 'Roboto',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
  );
}
