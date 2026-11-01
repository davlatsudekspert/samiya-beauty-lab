import 'package:flutter/material.dart';

/// Dizayn tokenlari: docs/DESIGN_SYSTEM.md (tasdiqlangan rose-pink yo'nalish).
abstract final class SamiyaColors {
  // "Atelier" yo'nalishi: chinni fon, ud-olxo'ri matn, Toif atirguli yuzalar, ozgina shampan oltini.
  static const rose = Color(0xFF8E4A5E); // aksent: havolalar, faol belgilar
  static const roseDeep = Color(0xFF5E3346);
  static const roseLight = Color(0xFFCFA9B2);
  static const blush = Color(0xFFF1E6E2); // yuza (izoh, chip)
  static const roseSoft = Color(0xFFE8D8D3);
  static const ivory = Color(0xFFF7F3F1); // fon (chinni)
  static const ink = Color(0xFF2A1B22);
  static const muted = Color(0xFF6B4E5C); // ikkinchi darajali matn (brend rangida, kulrang emas)
  static const heading = Color(0xFF3B1E2B); // ud-olxo'ri
  static const border = Color(0xFFE4D6D1);
  static const gold = Color(0xFFB08D57); // faqat ingichka chiziq va kichik belgilar
  static const appleBlack = Color(0xFF1E1418);
}

abstract final class SamiyaGradients {
  static const cta = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4E2738), Color(0xFF3B1E2B)]);
  static const page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF1E7E4), SamiyaColors.ivory, SamiyaColors.ivory],
    stops: [0, 0.35, 1],
  );
}

abstract final class SamiyaShadows {
  static const soft = [BoxShadow(color: Color(0x0F3B1E2B), blurRadius: 3, offset: Offset(0, 1))]; // ingichka, "shablon" soyasi yo'q
  static const cta = [BoxShadow(color: Color(0x1F3B1E2B), blurRadius: 10, offset: Offset(0, 4))];
}

/// Tilga qarab shrift: arabcha uchun IBM Plex Sans Arabic + Amiri, qolganlari uchun Jost (matn) + Cormorant Garamond (sarlavha).
ThemeData buildTheme(Locale locale) {
  final ar = locale.languageCode == 'ar';
  final body = ar ? 'IBMPlexSansArabic' : 'Jost';
  final serif = ar ? 'Amiri' : 'CormorantGaramond';
  final k = ar ? 1.12 : 1.08; // Amiri va Cormorant vizual jihatdan kichikroq
  TextStyle s(String f, double size, FontWeight w, Color c, {double? h, double? ls}) => TextStyle(
    fontFamily: f,
    fontSize: size,
    fontWeight: w,
    color: c,
    height: h,
    // Arab yozuvida harf oralig'i ulanishni buzadi.
    letterSpacing: ar ? 0 : ls,
    fontFamilyFallback: const ['Inter'], // Jost'da yo'q belgilar (o'zbekcha ‘) uchun
  );
  final scheme = ColorScheme.fromSeed(
    seedColor: SamiyaColors.heading,
    primary: SamiyaColors.heading,
    secondaryContainer: SamiyaColors.heading,
    onSecondaryContainer: Colors.white,
    surface: SamiyaColors.ivory,
  );
  final field = OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: SamiyaColors.border),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: body,
    scaffoldBackgroundColor: SamiyaColors.ivory,
    splashFactory: InkSparkle.splashFactory,
    chipTheme: ChipThemeData(
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: SamiyaColors.heading,
      side: const BorderSide(color: SamiyaColors.border),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(fontFamily: body, fontSize: 14, fontWeight: FontWeight.w500, color: SamiyaColors.heading, fontFamilyFallback: const ['Inter']),
      secondaryLabelStyle: TextStyle(fontFamily: body, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white, fontFamilyFallback: const ['Inter']),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: field,
      enabledBorder: field,
      focusedBorder: field.copyWith(borderSide: const BorderSide(color: SamiyaColors.gold, width: 1.2)),
      hintStyle: TextStyle(fontFamily: body, color: SamiyaColors.muted.withValues(alpha: 0.8), fontFamilyFallback: const ['Inter']),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: SamiyaColors.rose)),
    dialogTheme: DialogThemeData(
      backgroundColor: SamiyaColors.ivory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: SamiyaColors.heading, behavior: SnackBarBehavior.floating),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: SamiyaColors.rose),
    textTheme: TextTheme(
      headlineMedium: s(serif, 34 * k, FontWeight.w600, SamiyaColors.heading, h: 1.15),
      headlineSmall: s(serif, 26 * k, FontWeight.w600, SamiyaColors.heading, h: 1.2),
      titleMedium: s(body, 16, FontWeight.w500, SamiyaColors.ink, h: 1.3),
      bodyLarge: s(body, 16, FontWeight.w400, SamiyaColors.muted, h: 1.55),
      bodyMedium: s(body, 14, FontWeight.w400, SamiyaColors.muted, h: 1.5),
      labelLarge: s(body, 16, FontWeight.w500, Colors.white, ls: 0.3),
      labelSmall: s(body, 12, FontWeight.w500, SamiyaColors.rose, ls: 0.4),
    ),
  );
}
