import 'package:flutter/material.dart';

import '../../ui/safe_nav.dart';

import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import '../../ui/ingredient_palette.dart';
import 'analysis.dart';

/// 20 Tahlil natijasi. Faqat "bazada bor/yo'q": xavfsizlik bahosi, foiz yoki "sizga mos" xulosasi YO'Q.
class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.raw});
  final String raw;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final result = analyze(raw, AppScope.of(context).ingredients);
    final found = result.recognized, unknown = result.unknown;
    final avoidHits = AppScope.of(context).personal.avoidHits(result.items.map((e) => e.name));
    return KeyedSubtree(
      key: const Key('result-page'),
      child: Column(
        children: [
          PageHeader(title: l.resultTitle, onBack: () => context.canPop() ? context.pop() : context.go('/scanner')),
          Expanded(
            child: PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(key: const Key('stat-found'), value: found.length, label: l.inDatabase, strong: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Stat(key: const Key('stat-unknown'), value: unknown.length, label: l.notInDatabase, strong: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (avoidHits.isNotEmpty) ...[
                    Container(
                      key: const Key('result-avoid'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF2B8BD)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.do_not_disturb_on_outlined, color: Color(0xFFB3261E), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(l.avoidFound(avoidHits.join(', ')), style: t.bodyMedium?.copyWith(color: const Color(0xFF7A1F1A))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (found.isEmpty)
                    Container(
                      key: const Key('result-none'),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: SamiyaColors.border),
                      ),
                      child: Text(l.resultNoneFound, style: t.bodyLarge),
                    )
                  else
                    for (final item in found) ...[
                      _FoundCard(
                        key: Key('result-card-${item.ingredient!.slug}'),
                        position: item.position,
                        slug: item.ingredient!.slug,
                        name: item.ingredient!.nameFor(lang),
                        friendly: item.ingredient!.hasFriendlyName,
                        inci: item.ingredient!.inci,
                        summary: item.ingredient!.summaryFor(lang),
                        onTap: () => context.safePush('/scanner/ingredient/${item.ingredient!.slug}'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  if (unknown.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(l.notInDatabase, style: t.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      key: const Key('result-unknown-chips'),
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final u in unknown)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: SamiyaColors.border),
                            ),
                            child: Text(
                              u.name,
                              textDirection: TextDirection.ltr,
                              style: t.bodyMedium?.copyWith(color: SamiyaColors.ink),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(l.resultNote, style: t.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.value, required this.label, required this.strong});
  final int value;
  final String label;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: strong ? SamiyaGradients.cta : null,
        color: strong ? null : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: strong ? null : Border.all(color: SamiyaColors.border),
        boxShadow: strong ? SamiyaShadows.cta : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600, fontSize: 38, color: strong ? Colors.white : SamiyaColors.heading),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: t.bodyMedium?.copyWith(color: strong ? Colors.white : SamiyaColors.muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FoundCard extends StatelessWidget {
  const _FoundCard({
    super.key,
    required this.position,
    required this.slug,
    required this.name,
    required this.friendly,
    required this.inci,
    required this.summary,
    required this.onTap,
  });
  final int position;
  final String slug;
  final String name;
  final bool friendly;
  final String inci;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SamiyaColors.border),
              boxShadow: SamiyaShadows.soft,
            ),
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IngredientMonogram(slug: slug, name: name, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          textDirection: friendly ? null : TextDirection.ltr,
                          style: t.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: SamiyaColors.heading),
                        ),
                        Text(
                          friendly ? '$inci · #$position' : '#$position',
                          textDirection: TextDirection.ltr,
                          style: t.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: t.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: SamiyaColors.rose),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
