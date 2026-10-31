import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'traditional_widgets.dart';

/// Ibn Sino va "Tib qonunlari": tarixiy kirish (PubMed'dagi tarixiy sharhlarga tayanadi), ilmiy dalil sifatida emas.
class IbnSinaPage extends StatelessWidget {
  const IbnSinaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final intro = AppScope.of(context).ingredients.ibnSina;
    return Scaffold(
      key: const Key('ibn-sina-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(children: [
            PageHeader(title: l.ibnSinaMore, onBack: () => context.canPop() ? context.pop() : context.go('/home')),
            Expanded(
              child: PageBody(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 8),
                  Text(intro?.titleFor(lang) ?? l.ibnSinaMore, style: t.headlineMedium),
                  const SizedBox(height: 6),
                  Container(height: 1, width: 64, color: SamiyaColors.gold),
                  const SizedBox(height: 16),
                  const TraditionalCaveat(),
                  const SizedBox(height: 14),
                  for (final n in intro?.items ?? const []) ...[
                    TraditionalNoteCard(note: n, lang: lang, showTradition: false),
                    const SizedBox(height: 10),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
