import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';

/// Yagona "Ochiq aytamiz" izohi: halollik eslatmalari xatoga o'xshamaydi, lekin doim ko'rinadi.
class HonestNote extends StatelessWidget {
  const HonestNote(this.text, {super.key, this.lead = true});
  final String text;
  final bool lead;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final base = t.bodyMedium?.copyWith(fontSize: 13.5, color: const Color(0xFF5A3B4A), height: 1.5);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(12)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 2, decoration: const BoxDecoration(color: SamiyaColors.gold)),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                child: Text.rich(
                  TextSpan(
                    style: base,
                    children: [
                      if (lead)
                        TextSpan(
                          text: '${AppLocalizations.of(context).honestLead} ',
                          style: TextStyle(
                            fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? null : 'CormorantGaramond',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.5,
                            color: SamiyaColors.heading,
                          ),
                        ),
                      TextSpan(text: text),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
