import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Har bir ingredientning o'z "rang hikoyasi" (tabiiy manbasidan ilhomlangan yumshoq ton).
const _tints = <String, Color>{
  'honey': Color(0xFFE5BE6E),
  'aloe-vera': Color(0xFF9DBB93),
  'banana': Color(0xFFE4CF7E),
  'cucumber': Color(0xFF8FB487),
  'coconut-oil': Color(0xFFD4C3AA),
  'nigella-sativa-oil': Color(0xFF8E7B74),
  'rosehip-oil': Color(0xFFD9897A),
  'oat': Color(0xFFD4C29C),
  'green-tea': Color(0xFF94AE80),
  'olive-oil': Color(0xFFA3AA72),
  'chamomile': Color(0xFFE6D08A),
  'rose-water': Color(0xFFE0A2B1),
  'turmeric': Color(0xFFDDA048),
  'lemon-juice': Color(0xFFE2D062),
  'baking-soda': Color(0xFFBFCDD4),
  'facial-massage': Color(0xFFD3B1BB),
  'gua-sha': Color(0xFF9EC0B6),
  'niacinamide': Color(0xFFC3B0D6),
  'hyaluronic-acid': Color(0xFFA3C2DB),
  'salicylic-acid': Color(0xFFAFCDC2),
  'ascorbic-acid': Color(0xFFEBB473),
  'retinol': Color(0xFFE2AC9C),
  'ceramide-np': Color(0xFFD3C6E0),
  'glycerin': Color(0xFFC3DAE2),
  'glycolic-acid': Color(0xFFDDC79B),
  'panthenol': Color(0xFFCEBEDB),
  'urea': Color(0xFFC9D3DC),
  'zinc-oxide': Color(0xFFD3D1CF),
};

Color ingredientTint(String slug) => _tints[slug] ?? SamiyaColors.roseLight;

/// Monogramma medalyon: oltin halqa ichida kursiv serif bosh harf, ingredient rangida.
class IngredientMonogram extends StatelessWidget {
  const IngredientMonogram({super.key, required this.slug, required this.name, this.size = 54});
  final String slug;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = ingredientTint(slug);
    final letter = name.trim().isEmpty ? '·' : name.trim().characters.first.toUpperCase();
    final arabic = RegExp(r'[؀-ۿ]').hasMatch(letter);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: [
          SamiyaColors.gold,
          const Color(0xFFEADBC6),
          SamiyaColors.gold.withValues(alpha: 0.7),
          const Color(0xFFF5EBDF),
          SamiyaColors.gold,
        ]),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 0.95,
            colors: [Colors.white, Color.lerp(Colors.white, tint, 0.45)!, Color.lerp(Colors.white, tint, 0.75)!],
          ),
        ),
        child: Text(
          letter,
          style: TextStyle(
            fontFamily: arabic ? 'Amiri' : 'CormorantGaramond',
            fontStyle: arabic ? FontStyle.normal : FontStyle.italic,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.5,
            height: 1.0,
            color: SamiyaColors.heading,
          ),
        ),
      ),
    );
  }
}
