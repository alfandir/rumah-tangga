import 'package:flutter/material.dart';

class RetroTheme {
  // Modern Clean Aesthetic Palette (Slate & Soft Sky Blue)
  static const Color creamBg = Color(0xFFF8FAFC);          // Slate 50 Background
  static const Color primaryBlue = Color(0xFF0284C7);      // Sky 600 Accent
  static const Color softBlueBg = Color(0xFFF0F9FF);       // Sky 50 Soft Card Fill
  static const Color lavender = Color(0xFFE0F2FE);         // Sky 100 Soft Pill
  static const Color pastelPink = Color(0xFFF1F5F9);       // Slate 100 Neutral Card
  static const Color mintGreen = Color(0xFFECFDF5);        // Emerald 50 Soft Green Fill
  static const Color peachCoral = Color(0xFFFFF1F2);       // Rose 50 Soft Red Fill
  static const Color darkCharcoal = Color(0xFF0F172A);     // Slate 900 Text Primary
  static const Color textSecondary = Color(0xFF64748B);    // Slate 500 Text Secondary
  static const Color borderLight = Color(0xFFE2E8F0);      // Slate 200 Soft Border

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: creamBg,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: lavender,
        surface: Colors.white,
        error: peachCoral,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: darkCharcoal,
          fontSize: 26,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: darkCharcoal,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: darkCharcoal,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  // Modern Clean Card Decoration (Soft ambient shadow & border)
  static BoxDecoration retroBoxDecoration({
    required Color color,
    double radius = 16,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder ? Border.all(color: borderLight, width: 1) : null,
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
