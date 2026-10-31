import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Pushti gradient sahifa foni va yumshoq nur dog'lari.
class SamiyaBackground extends StatelessWidget {
  const SamiyaBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: SamiyaGradients.page),
      child: Stack(children: [
        PositionedDirectional(
            top: -110, end: -90, child: _Glow(size: 320, color: SamiyaColors.roseLight.withValues(alpha: 0.38))),
        PositionedDirectional(
            bottom: -140, start: -110, child: _Glow(size: 340, color: SamiyaColors.blush.withValues(alpha: 0.9))),
        Positioned.fill(child: child),
      ]),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
          ),
        ),
      );
}

/// Oq yarim shaffof "orqaga" tugmasi (RTL da avtomatik teskari).
class BackChip extends StatelessWidget {
  const BackChip({super.key = const Key('back-chip'), required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: SamiyaColors.rose, textDirection: null),
          ),
        ),
      ),
    );
  }
}

/// Yuqori qator: orqaga tugmasi + markazda sarlavha.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, this.title, this.onBack});
  final String? title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
      child: Row(children: [
        SizedBox(width: 48, height: 48, child: onBack == null ? null : BackChip(onTap: onBack!)),
        Expanded(
          child: Text(title ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(width: 48),
      ]),
    );
  }
}

/// Asosiy CTA: pushti gradient, 56 px dan past emas.
class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.label, required this.onPressed, this.trailing});
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled ? SamiyaGradients.cta : null,
        color: enabled ? null : SamiyaColors.roseSoft,
        borderRadius: BorderRadius.circular(30),
        boxShadow: enabled ? SamiyaShadows.cta : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: SamiyaColors.muted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const StadiumBorder(),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            child: Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: enabled ? Colors.white : SamiyaColors.muted)),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, size: 20, color: enabled ? Colors.white : SamiyaColors.muted),
          ],
        ]),
      ),
    );
  }
}

/// Kichik yumaloq yorliq (masalan kampaniya, 01 / 03).
class InfoPill extends StatelessWidget {
  const InfoPill(this.text, {super.key, this.upper = true, this.ltr = false});
  final String text;
  final bool upper;

  /// Raqamli yorliqlar (01 / 03) arab matni ichida ham chapdan o'ngga o'qilsin.
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: SamiyaColors.blush, borderRadius: BorderRadius.circular(20)),
      child: Text(upper && !ar ? text.toUpperCase() : text,
          textAlign: TextAlign.center,
          textDirection: ltr ? TextDirection.ltr : null,
          style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/// Oq karta (til va rol kartalari uchun): tanlanganda pushti ramka va soya.
class SelectCardFrame extends StatelessWidget {
  const SelectCardFrame({super.key, required this.selected, required this.onTap, required this.child, this.radius = 24});
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: selected ? SamiyaColors.rose : SamiyaColors.border, width: selected ? 1.8 : 1.2),
          boxShadow: selected ? SamiyaShadows.soft : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: child),
        ),
      ),
    );
  }
}

/// Sahifa tanasi: kontent aylanadi (kichik ekran va katta shriftda overflow yo'q), pastki qism qotirilgan.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.bottom, this.padding = const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16)});
  final Widget child;
  final Widget? bottom;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: SingleChildScrollView(padding: padding, child: child)),
      if (bottom != null)
        Padding(padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16), child: bottom),
    ]);
  }
}
