import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_state.dart';
import '../../ui/arch_photo.dart';
import '../../ui/safe_nav.dart';
import '../academy/lesson_models.dart';
import '../academy/lesson_page.dart' show lessonPhotos;
import '../../app/pro_gate.dart';
import '../pro/pro_page.dart';

/// Akademiya: dalillarga asoslangan darslar (qoralama, ekspert tekshiruvi kutilmoqda) va testlar.
class AcademyPage extends StatelessWidget {
  const AcademyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final app = AppScope.of(context);
    final lessons = app.ingredients.lessons;
    bool open(int i) => ProGate.open(unlocked: app.unlocked, index: i, freeCount: ProGate.freeLessons);
    final fallback = [l.academyT1, l.academyT2, l.academyT3, l.academyT4, l.academyT5, l.academyT6];
    final topics = lessons.isEmpty ? fallback : [for (final x in lessons) pickLoc(x.title, lang)];
    return KeyedSubtree(
      key: const Key('tab-academy'),
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 28),
        children: [
          const ArchPhoto('assets/tiles/academy.jpg', height: 210, alignment: Alignment(0, -0.2)),
          const SizedBox(height: 18),
          Text(l.navAcademy, textAlign: TextAlign.center, style: t.headlineMedium?.copyWith(fontSize: 34)),
          const SizedBox(height: 8),
          Text(l.academySubtitle, textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(fontSize: 15)),
          const SizedBox(height: 22),
          if (lessons.isNotEmpty) ...[
            Text(
              l.lessonCount(lessons.length).toUpperCase(),
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(color: const Color(0xFF8C6A3A), letterSpacing: lang == 'ar' ? 0 : 2),
            ),
            const SizedBox(height: 14),
          ],
          for (var i = 0; i < topics.length; i++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: Key('academy-topic-$i'),
                borderRadius: BorderRadius.circular(16),
                onTap: i < lessons.length ? () => context.safePush(open(i) ? '/academy/lesson/${lessons[i].id}' : '/pro') : null,
                child: Ink(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x1A3B1E2B)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 58,
                        height: 70,
                        child: Stack(fit: StackFit.expand, children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(29), bottom: Radius.circular(10)),
                            child: i < lessons.length
                                ? Image.asset(lessonPhotos[lessons[i].id] ?? 'assets/photos/deco_peony.jpg', fit: BoxFit.cover)
                                : const ColoredBox(color: SamiyaColors.blush),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(color: const Color(0xCC3B1E2B), borderRadius: BorderRadius.circular(8)),
                              child: Text('${i + 1}'.padLeft(2, '0'),
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFFE9D3A8))),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(topics[i], style: t.titleMedium?.copyWith(fontSize: 15.5)),
                            if (i < lessons.length)
                              Text(
                                '${l.lessonMinutes(lessons[i].minutesFor(lang))} · ${l.lessonQuiz}',
                                style: t.bodySmall?.copyWith(color: SamiyaColors.muted),
                              ),
                          ],
                        ),
                      ),
                      if (i < lessons.length && !open(i))
                        const ProLockBadge()
                      else
                        Icon(i < lessons.length ? Icons.chevron_right_rounded : Icons.lock_outline_rounded, size: 20, color: SamiyaColors.muted),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
