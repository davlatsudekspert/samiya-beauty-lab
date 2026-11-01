import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/arch_photo.dart';

/// Akademiya tanishtiruvi: kurs mavzulari (darslar kosmetolog tekshiruvidan keyin ochiladi).
class AcademyPage extends StatelessWidget {
  const AcademyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final topics = [l.academyT1, l.academyT2, l.academyT3, l.academyT4, l.academyT5, l.academyT6];
    return KeyedSubtree(
      key: const Key('tab-academy'),
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 28),
        children: [
          const ArchPhoto('assets/photos/deco_peony.jpg', height: 190, alignment: Alignment(0, -0.2)),
          const SizedBox(height: 18),
          Text(l.navAcademy, textAlign: TextAlign.center, style: t.headlineMedium?.copyWith(fontSize: 34)),
          const SizedBox(height: 8),
          Text(l.academySubtitle, textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(fontSize: 15)),
          const SizedBox(height: 22),
          for (var i = 0; i < topics.length; i++) ...[
            Container(
              key: Key('academy-topic-$i'),
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x1A3B1E2B)),
              ),
              child: Row(children: [
                Text('${i + 1}'.padLeft(2, '0'),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600, fontSize: 26, color: SamiyaColors.gold)),
                const SizedBox(width: 16),
                Expanded(child: Text(topics[i], style: t.titleMedium?.copyWith(fontSize: 15.5))),
                const Icon(Icons.lock_outline_rounded, size: 18, color: SamiyaColors.muted),
              ]),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Text(l.comingSoon.toUpperCase(),
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(color: const Color(0xFF8C6A3A), letterSpacing: Localizations.localeOf(context).languageCode == 'ar' ? 0 : 2)),
        ],
      ),
    );
  }
}
