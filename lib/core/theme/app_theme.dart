import 'package:flutter/material.dart';

class AppTheme {
  // Light palette
  static const Color _lightBackground = Color(0xFFF9F9F9); // Off-White
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightTextMain = Color(0xFF333333); // Charcoal
  static const Color _lightTextLight = Color(0xFF888888);
  static const Color _lightDivider = Color(0xFFEEEEEE);

  // Dark palette
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);
  static const Color _darkTextMain = Color(0xFFEDEDED);
  static const Color _darkTextLight = Color(0xFF9E9E9E);
  static const Color _darkDivider = Color(0xFF2A2A2A);

  // Sage green works on both light and dark backgrounds.
  static const Color primary = Color(0xFF9DC183);

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        background: _lightBackground,
        card: _lightCard,
        textMain: _lightTextMain,
        textLight: _lightTextLight,
        divider: _lightDivider,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: _darkBackground,
        card: _darkCard,
        textMain: _darkTextMain,
        textLight: _darkTextLight,
        divider: _darkDivider,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color textMain,
    required Color textLight,
    required Color divider,
  }) {
    final colorScheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: primary,
            secondary: primary,
            surface: card,
            onSurface: textMain,
            onSurfaceVariant: textLight,
          )
        : ColorScheme.dark(
            primary: primary,
            secondary: primary,
            surface: card,
            onSurface: textMain,
            onSurfaceVariant: textLight,
          );
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: colorScheme,
      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textMain),
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textMain,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textMain, fontSize: 16),
        bodyMedium: TextStyle(color: textMain, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 4,
        shadowColor: Colors.black.withValues(
          alpha: brightness == Brightness.light ? 0.05 : 0.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
