import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/safe_nav.dart';
import 'ingredient_models.dart';

Future<void> openSourceUrl(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {/* havola ochilmasa, jim: PMID matni ko'rinib turadi */}
}

/// An'ana nomi foydalanuvchi tilida.
String traditionLabel(AppLocalizations l, String? tradition) {
  final t = (tradition ?? '').toLowerCase();
  if (t.contains('canon')) return l.tradCanon;
  if (t.contains('persian')) return l.tradPersian;
  if (t.contains('unani')) return l.tradUnani;
  if (t.contains('ayurveda')) return l.tradAyurveda;
  if (t.contains('chinese')) return l.tradChinese;
  if (t.contains('korean')) return l.tradKorean;
  return l.tradFolk;
}

/// "Tarixiy manba, ilmiy dalil emas" izohi: an'anaviy matn yonida doim ko'rinadi.
class TraditionalCaveat extends StatelessWidget {
  const TraditionalCaveat({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('note-traditional'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.55)),
        color: Colors.white,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.history_edu_outlined, size: 20, color: SamiyaColors.gold),
        const SizedBox(width: 10),
        Expanded(
          child: Text(AppLocalizations.of(context).traditionalNote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SamiyaColors.heading)),
        ),
      ]),
    );
  }
}

class TraditionalNoteCard extends StatelessWidget {
  const TraditionalNoteCard({super.key, required this.note, required this.lang, this.showTradition = true});
  final TraditionalNote note;
  final String lang;
  final bool showTradition;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      key: Key('trad-${note.id}'),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SamiyaColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (showTradition) ...[
          Text(traditionLabel(l, note.tradition), style: t.headlineSmall?.copyWith(fontSize: 19)),
          const SizedBox(height: 6),
        ],
        Text(note.textFor(lang), style: t.bodyLarge?.copyWith(color: SamiyaColors.ink, fontSize: 15)),
        const SizedBox(height: 6),
        for (final s in note.sources)
          InkWell(
            key: Key('trad-source-${note.id}-${s.pmid}'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => openSourceUrl(s.url),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(children: [
                const Icon(Icons.open_in_new_rounded, size: 17, color: SamiyaColors.rose),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('${l.detailSource}: PubMed · PMID ${s.pmid} · ${s.year}',
                        textDirection: TextDirection.ltr,
                        style: t.bodyMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w600, fontSize: 12.5)),
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

/// Ingredient sahifasidagi blok.
class TraditionalSection extends StatelessWidget {
  const TraditionalSection({super.key, required this.notes, required this.lang});
  final List<TraditionalNote> notes;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(key: const Key('traditional-section'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.traditionalTitle, style: t.headlineSmall?.copyWith(fontSize: 24)),
      const SizedBox(height: 10),
      const TraditionalCaveat(),
      const SizedBox(height: 12),
      for (final n in notes) ...[
        TraditionalNoteCard(note: n, lang: lang),
        const SizedBox(height: 10),
      ],
      if (notes.any((n) => n.citesCanon))
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const Key('trad-ibn-sina-link'),
            onPressed: () => context.safePush('/scanner/ibn-sina'),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: Text(l.ibnSinaMore),
          ),
        ),
    ]);
  }
}
