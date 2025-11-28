import 'package:flutter/material.dart';

// Tuscan Color Palette
const kPrimary = Color(0xFFC67C4E);       // Warm Terracotta/Brown
const kSecondary = Color(0xFF8A9A5B);     // Muted Olive Green
const kBackground = Color(0xFFFFF7F0);    // Creamy Off-white
const kSurface = Color(0xFFFFFFFF);       // Clean White for cards
const kTextDark = Color(0xFF312621);      // Dark Earthy Brown
const kTextLight = Color(0xFF6D6D6D);     // Muted Grey

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      secondary: kSecondary,
      background: kBackground,
      surface: kSurface,
      onPrimary: Colors.white,
      onSurface: kTextDark,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: kTextDark),
      bodyMedium: TextStyle(color: kTextLight),
      bodySmall: TextStyle(color: kTextLight),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent, // Make it blend with the scaffold
      foregroundColor: kTextDark,   // Dark text on light background
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: kTextLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: kPrimary.withOpacity(0.4),
      ),
    ),
  );
}
