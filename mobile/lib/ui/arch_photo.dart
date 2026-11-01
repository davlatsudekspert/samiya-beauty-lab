import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Ravoq (arka) shaklidagi bezak fotosurat: oltin ingichka chiziq bilan.
class ArchPhoto extends StatelessWidget {
  const ArchPhoto(this.asset, {super.key, this.height = 170, this.alignment = Alignment.center});
  final String asset;
  final double height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.vertical(top: Radius.circular(height * 0.55), bottom: const Radius.circular(20));
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: r,
        child: Container(
          height: height,
          width: double.infinity,
          foregroundDecoration: BoxDecoration(
            borderRadius: r,
            border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.7), width: 1.2),
          ),
          child: Image.asset(asset, fit: BoxFit.cover, alignment: alignment, filterQuality: FilterQuality.medium),
        ),
      ),
    );
  }
}
