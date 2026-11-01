import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

const knownStudyTypes = {'systematic review', 'meta-analysis', 'RCT', 'observational', 'in vitro', 'regulatory opinion', 'narrative review'};

String studyTypeLabel(AppLocalizations l, String type) => switch (type) {
  'systematic review' => l.studyTypeSystematicReview,
  'meta-analysis' => l.studyTypeMetaAnalysis,
  'RCT' => l.studyTypeRct,
  'observational' => l.studyTypeObservational,
  'in vitro' => l.studyTypeInVitro,
  'regulatory opinion' => l.studyTypeRegulatory,
  'narrative review' => l.studyTypeNarrative,
  _ => type,
};

String evidenceLabel(AppLocalizations l, String level) => switch (level) {
  'A' => l.evidenceA,
  'B' => l.evidenceB,
  'C' => l.evidenceC,
  _ => l.evidenceInsufficient,
};

/// Dalil darajasi yorlig'i (A, B, C yoki ?). Rang faqat ko'rinish; ma'nosi matnda ham beriladi.
class EvidenceChip extends StatelessWidget {
  const EvidenceChip({super.key, required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (level) {
      'A' => (const Color(0xFFB92E5E), Colors.white),
      'B' => (SamiyaColors.rose, Colors.white),
      'C' => (SamiyaColors.roseLight, SamiyaColors.heading),
      _ => (const Color(0xFFE4D6D1), SamiyaColors.muted),
    };
    return Semantics(
      label: evidenceLabel(AppLocalizations.of(context), level),
      child: ExcludeSemantics(
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Text(
            level == 'A' || level == 'B' || level == 'C' ? level : '?',
            style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w700, fontSize: 15, color: fg),
          ),
        ),
      ),
    );
  }
}
