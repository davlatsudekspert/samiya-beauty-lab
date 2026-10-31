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
  static const heading = Color(0xFF9B3357);
  static const border = Color(0xFFF1D6DD);
  static const appleBlack = Color(0xFF241D21);
}

abstract final class SamiyaGradients {
  static const cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF78FAE), Color(0xFFD94F7A), Color(0xFFB92E5E)],
  );
  static const page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE3EC), Color(0xFFFFF3F5), SamiyaColors.ivory],
    stops: [0, 0.45, 1],
  );
}

abstract final class SamiyaShadows {
  static const soft = [BoxShadow(color: Color(0x1FB85B6A), blurRadius: 32, offset: Offset(0, 14))];
  static const cta = [BoxShadow(color: Color(0x4DD94F7A), blurRadius: 24, offset: Offset(0, 10))];
}

/// Tilga qarab shrift: arabcha uchun IBM Plex Sans Arabic + Amiri, qolganlari uchun Inter + Playfair.
ThemeData buildTheme(Locale locale) {
  final ar = locale.languageCode == 'ar';
  final body = ar ? 'IBMPlexSansArabic' : 'Inter';
  final serif = ar ? 'Amiri' : 'PlayfairDisplay';
  final k = ar ? 1.12 : 1.0; // Amiri vizual jihatdan kichikroq
  TextStyle s(String f, double size, FontWeight w, Color c, {double? h, double? ls}) => TextStyle(
        fontFamily: f,
        fontSize: size,
        fontWeight: w,
        color: c,
        height: h,
        // Arab yozuvida harf oralig'i ulanishni buzadi.
        letterSpacing: ar ? 0 : ls,
      );
  final scheme = ColorScheme.fromSeed(seedColor: SamiyaColors.rose, surface: SamiyaColors.ivory);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: body,
    scaffoldBackgroundColor: SamiyaColors.ivory,
    textTheme: TextTheme(
      headlineMedium: s(serif, 34 * k, FontWeight.w600, SamiyaColors.heading, h: 1.2),
      headlineSmall: s(serif, 26 * k, FontWeight.w600, SamiyaColors.heading, h: 1.25),
      titleMedium: s(body, 16, FontWeight.w600, SamiyaColors.ink, h: 1.3),
      bodyLarge: s(body, 16, FontWeight.w400, SamiyaColors.muted, h: 1.55),
      bodyMedium: s(body, 14, FontWeight.w400, SamiyaColors.muted, h: 1.5),
      labelLarge: s(body, 16, FontWeight.w700, Colors.white),
      labelSmall: s(body, 12, FontWeight.w700, SamiyaColors.rose, ls: 1.2),
    ),
  );
}
