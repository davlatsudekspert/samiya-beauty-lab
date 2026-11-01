import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';

/// Pastki 5 bandli navigatsiya. Yozuvlar 1.2x dan katta o'smaydi (kichik ekranda sig'ishi uchun).
class SamiyaBottomNav extends StatelessWidget {
  const SamiyaBottomNav({super.key, required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = <(String, String, IconData, IconData)>[
      ('home', l.navHome, Icons.home_outlined, Icons.home_rounded),
      ('academy', l.navAcademy, Icons.school_outlined, Icons.school_rounded),
      ('scanner', l.navScanner, Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_rounded),
      ('journal', l.navJournal, Icons.event_note_outlined, Icons.event_note_rounded),
      ('profile', l.navProfile, Icons.person_outline_rounded, Icons.person_rounded),
    ];
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [BoxShadow(color: Color(0x123B1E2B), blurRadius: 24, offset: Offset(0, -6))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      key: Key('nav-${items[i].$1}'),
                      label: items[i].$2,
                      icon: i == index ? items[i].$4 : items[i].$3,
                      selected: i == index,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({super.key, required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SamiyaColors.heading : SamiyaColors.muted;
    // Tanlangan belgi yumshoq ko'tariladi va kattalashadi (iOS uslubi); "harakatni kamaytirish" yoqilgan bo'lsa animatsiyasiz.
    final calm = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final d = calm ? Duration.zero : const Duration(milliseconds: 280);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSlide(
                  duration: d,
                  curve: Curves.easeOutBack,
                  offset: selected ? const Offset(0, -0.12) : Offset.zero,
                  child: AnimatedScale(
                    duration: d,
                    curve: Curves.easeOutBack,
                    scale: selected ? 1.12 : 1,
                    child: AnimatedContainer(
                      duration: d,
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(color: selected ? SamiyaColors.blush : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                      child: Icon(icon, size: 24, color: color),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: color, fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, letterSpacing: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
