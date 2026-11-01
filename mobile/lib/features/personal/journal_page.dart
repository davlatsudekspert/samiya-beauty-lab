import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/personal_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/arch_photo.dart';
import '../../ui/empty_state.dart';
import 'personal_widgets.dart';

String feelingLabel(AppLocalizations l, SkinFeeling f) => switch (f) {
  SkinFeeling.great => l.feelGreat,
  SkinFeeling.good => l.feelGood,
  SkinFeeling.okay => l.feelOkay,
  SkinFeeling.dry => l.feelDry,
  SkinFeeling.irritated => l.feelIrritated,
};

IconData feelingIcon(SkinFeeling f) => switch (f) {
  SkinFeeling.great => Icons.wb_sunny_rounded,
  SkinFeeling.good => Icons.spa_rounded,
  SkinFeeling.okay => Icons.cloud_queue_rounded,
  SkinFeeling.dry => Icons.water_drop_outlined,
  SkinFeeling.irritated => Icons.local_fire_department_outlined,
};

/// Kundalik: teri holati va qisqa qaydlar (faqat qurilmada).
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  Future<void> _add(BuildContext context, PersonalStore p) async {
    final l = AppLocalizations.of(context);
    final note = TextEditingController();
    var feeling = SkinFeeling.good;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: SamiyaColors.ivory,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(l.journalFeeling),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in SkinFeeling.values)
                      ChoiceChip(
                        key: Key('feel-${f.name}'),
                        avatar: Icon(feelingIcon(f), size: 18, color: feeling == f ? Colors.white : SamiyaColors.heading),
                        label: Text(feelingLabel(l, f)),
                        selected: feeling == f,
                        onSelected: (_) => setS(() => feeling = f),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('journal-note'),
                  controller: note,
                  maxLines: 4,
                  maxLength: PersonalStore.maxText,
                  decoration: InputDecoration(hintText: l.journalNoteHint),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('journal-save'),
                    style: FilledButton.styleFrom(backgroundColor: SamiyaColors.heading, minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l.saveAction),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved == true) await p.addJournal(feeling, note.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final p = AppScope.of(context).personal;
    final loc = MaterialLocalizations.of(context);
    return KeyedSubtree(
      key: const Key('journal-page'),
      child: ListenableBuilder(
        listenable: p,
        builder: (context, _) => ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Text(l.navJournal, style: t.headlineMedium?.copyWith(fontSize: 32)),
                FilledButton.icon(
                  key: const Key('journal-add'),
                  style: FilledButton.styleFrom(backgroundColor: SamiyaColors.heading, shape: const StadiumBorder()),
                  onPressed: () => _add(context, p),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.journalAdd),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const ArchPhoto('assets/photos/deco_lavender.jpg', height: 150, alignment: Alignment(0, -0.2)),
            const SizedBox(height: 16),
            if (p.journal.isEmpty)
              ElegantEmpty(key: const Key('journal-empty'), title: l.journalEmptyTitle, body: l.journalEmpty)
            else
              for (final e in p.journal) ...[
                Container(
                  key: Key('journal-${e.id}'),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 6, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: SamiyaColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.6)),
                          color: SamiyaColors.blush,
                        ),
                        child: Icon(feelingIcon(e.feeling), color: SamiyaColors.heading, size: 21),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${loc.formatMediumDate(e.date)} · ${feelingLabel(l, e.feeling)}', style: t.titleMedium?.copyWith(fontSize: 15)),
                            if (e.note.isNotEmpty) ...[const SizedBox(height: 4), Text(e.note, style: t.bodyMedium)],
                          ],
                        ),
                      ),
                      IconButton(
                        key: Key('journal-remove-${e.id}'),
                        tooltip: l.removeAction,
                        onPressed: () => p.removeJournal(e.id),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 8),
            Text(l.personalDataNote, style: t.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
