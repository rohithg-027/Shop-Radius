import 'package:flutter/material.dart';

ThemeData appTheme() {
  const primary = Color(0xFF00695C);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    appBarTheme: const AppBarTheme(centerTitle: true),
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
  );
}
