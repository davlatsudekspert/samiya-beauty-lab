import 'package:flutter/material.dart';

import '../app/theme.dart';

/// SAMIYA belgisi: egasining asl logotipi, oltin hoshiya bilan.
class SamiyaMark extends StatelessWidget {
  const SamiyaMark({super.key, this.size = 96, this.color = SamiyaColors.gold, this.letterColor});
  final double size;
  final Color color;
  final Color? letterColor;

  @override
  Widget build(BuildContext context) {
    // Egasining asl logotipi (hijobli ayol profili), oltin hoshiyali ilova belgisi bilan bir xil.
    final r = size * 0.23;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [BoxShadow(color: const Color(0x408E4A5E), blurRadius: size * 0.32, spreadRadius: -size * 0.08, offset: Offset(0, size * 0.12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Image.asset('assets/images/logo_square.jpg', fit: BoxFit.cover, filterQuality: FilterQuality.high),
      ),
    );
  }
}

/// SAMIYA yozuvi (keng harf oralig'i) va BEAUTY LAB.
class SamiyaWordmark extends StatelessWidget {
  const SamiyaWordmark({super.key, this.color = SamiyaColors.heading, this.scale = 1});
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SAMIYA',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w500,
            fontSize: 44 * scale,
            letterSpacing: 14 * scale,
            height: 1,
            color: color,
          ),
        ),
        SizedBox(height: 10 * scale),
        Text(
          'BEAUTY  LAB',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.w400,
            fontSize: 11.5 * scale,
            letterSpacing: 7 * scale,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
