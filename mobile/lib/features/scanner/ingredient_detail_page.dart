import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'evidence_widgets.dart';
import 'ingredient_models.dart';
import 'traditional_widgets.dart';

/// 21 Ingredient tafsiloti: xulosa, dalil darajalari va har da'vo uchun manba (PubMed havolasi bilan).
class IngredientDetailPage extends StatelessWidget {
  const IngredientDetailPage({super.key, required this.slug});
  final String slug;

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {/* havola ochilmasa, jim: PMID matni ko'rinib turadi */}
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final ing = AppScope.of(context).ingredients.bySlug(slug);
    return KeyedSubtree(
      key: const Key('ingredient-page'),
      child: Column(children: [
        PageHeader(title: ing?.nameFor(lang) ?? l.notInDatabase, onBack: () => context.canPop() ? context.pop() : context.go('/scanner')),
        Expanded(
          child: ing == null
              ? Center(child: Text(l.notInDatabase, style: t.bodyLarge))
              : PageBody(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 8),
                    Text(ing.nameFor(lang), textDirection: ing.hasFriendlyName ? null : TextDirection.ltr, style: t.headlineMedium),
                    if (ing.hasFriendlyName && !ing.isPractice) ...[
                      const SizedBox(height: 4),
                      Text(ing.inci, textDirection: TextDirection.ltr, style: t.bodyMedium?.copyWith(fontFamily: 'Jost', fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 10),
                    Text(ing.summaryFor(lang), style: t.bodyLarge),
                    const SizedBox(height: 14),
                    if (ing.isNatural) ...[
                      _Note(key: const Key('note-natural'), icon: Icons.spa_outlined, text: l.naturalNote),
                      const SizedBox(height: 8),
                    ],
                    if (ing.isPractice) ...[
                      _Note(key: const Key('note-practice'), icon: Icons.self_improvement_outlined, text: l.practiceNote),
                      const SizedBox(height: 8),
                    ],
                    if (ing.isCaution) ...[
                      _Note(key: const Key('note-caution'), icon: Icons.warning_amber_rounded, text: l.cautionNote),
                      const SizedBox(height: 8),
                    ],
                    if (ing.status != 'verified') _Note(key: const Key('note-draft'), icon: Icons.edit_note_rounded, text: l.draftNote),
                    if (!ing.euVerified) ...[
                      const SizedBox(height: 8),
                      _Note(key: const Key('note-eu'), icon: Icons.gavel_rounded, text: l.euUnverified),
                    ],
                    const SizedBox(height: 18),
                    _Legend(l: l),
                    const SizedBox(height: 22),
                    Text(l.detailClaims, style: t.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    for (final c in ing.claims) ...[
                      _ClaimCard(key: Key('claim-${c.id}'), claim: c, lang: lang, onOpen: _open),
                      const SizedBox(height: 12),
                    ],
                    if (ing.traditional.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      TraditionalSection(notes: ing.traditional, lang: lang),
                    ],
                    const SizedBox(height: 6),
                    Text(l.resultNote, style: t.bodyMedium?.copyWith(fontSize: 12)),
                  ]),
                ),
        ),
      ]),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: SamiyaColors.blush, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: SamiyaColors.rose),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SamiyaColors.heading))),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      key: const Key('evidence-legend'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(22), border: Border.all(color: SamiyaColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.evidenceLegendTitle, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final level in ['A', 'B', 'C']) ...[
          Row(children: [
            EvidenceChip(level: level),
            const SizedBox(width: 12),
            Expanded(child: Text(evidenceLabel(l, level), style: t.bodyMedium)),
          ]),
          const SizedBox(height: 8),
        ],
        Row(children: [
          const EvidenceChip(level: 'insufficient'),
          const SizedBox(width: 12),
          Expanded(child: Text(l.evidenceInsufficient, style: t.bodyMedium)),
        ]),
      ]),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  const _ClaimCard({super.key, required this.claim, required this.lang, required this.onOpen});
  final Claim claim;
  final String lang;
  final Future<void> Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: SamiyaColors.border), boxShadow: SamiyaShadows.soft),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          EvidenceChip(level: claim.level),
          const SizedBox(width: 12),
          Expanded(child: Text(studyTypeLabel(l, claim.studyType), style: t.titleMedium?.copyWith(fontSize: 14, color: SamiyaColors.heading))),
        ]),
        const SizedBox(height: 12),
        Text(claim.textFor(lang), style: t.bodyLarge?.copyWith(color: SamiyaColors.ink, fontSize: 15)),
        const SizedBox(height: 12),
        for (final s in claim.sources)
          InkWell(
            key: Key('source-${s.pmid}'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => onOpen(s.url),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(children: [
                const Icon(Icons.open_in_new_rounded, size: 18, color: SamiyaColors.rose),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('${l.detailSource}: PubMed · PMID ${s.pmid} · ${s.year}',
                        textDirection: TextDirection.ltr,
                        style: t.bodyMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(s.title, textDirection: TextDirection.ltr, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodyMedium?.copyWith(fontSize: 12)),
                  ]),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}
