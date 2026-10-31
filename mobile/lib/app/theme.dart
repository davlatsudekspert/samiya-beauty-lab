import 'package:flutter/material.dart';

/// Dizayn tokenlari: docs/DESIGN_SYSTEM.md (tasdiqlangan rose-pink yo'nalish).
abstract final class SamiyaColors {
  static const rose = Color(0xFFD94F7A);
  static const roseDeep = Color(0xFFB85B6A);
  static const roseLight = Color(0xFFF7A7C1);
  static const blush = Color(0xFFFFE5EC);
  static const roseSoft = Color(0xFFF3D7DC);
  static const ivory = Color(0xFFFFF9F8);
  static const ink = Color(0xFF392A31);
  static const muted = Color(0xFF806C73);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: SamiyaColors.rose,
    surface: SamiyaColors.ivory,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: SamiyaColors.ivory,
    appBarTheme: const AppBarTheme(
      backgroundColor: SamiyaColors.ivory,
      foregroundColor: SamiyaColors.ink,
    ),
  );
}
