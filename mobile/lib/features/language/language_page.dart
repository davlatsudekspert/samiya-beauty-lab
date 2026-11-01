import 'package:flutter/material.dart';

import '../../ui/safe_nav.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/brand.dart';
import '../../ui/widgets.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final codes = languageNativeNames.keys.toList();
    return Scaffold(
      key: const Key('language-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(title: l.chooseLanguage),
              Expanded(
                child: PageBody(
                  bottom: GradientButton(
                    key: const Key('language-continue'),
                    label: l.continueLabel,
                    trailing: Icons.arrow_forward_rounded,
                    onPressed: () => context.safePush('/welcome'),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Semantics(label: l.appName, child: const SamiyaMark(size: 112)),
                      const SizedBox(height: 24),
                      Text(l.languageTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 24),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 104 + 30 * MediaQuery.textScalerOf(context).scale(16) / 16,
                        ),
                        children: [
                          for (final code in codes) _LanguageCard(code: code, selected: state.locale.languageCode == code, onTap: () => state.setLocale(code)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.code, required this.selected, required this.onTap});
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: Key('lang-$code'),
      child: SelectCardFrame(
        selected: selected,
        onTap: onTap,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: selected ? SamiyaGradients.cta : null,
                      color: selected ? null : SamiyaColors.blush,
                    ),
                    child: Text(
                      code.toUpperCase(),
                      style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w700, fontSize: 15, color: selected ? Colors.white : SamiyaColors.rose),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    languageNativeNames[code]!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: code == 'ar' ? 'IBMPlexSansArabic' : 'Jost'),
                  ),
                ],
              ),
            ),
            if (selected) const PositionedDirectional(top: 10, end: 10, child: Icon(Icons.check_circle_rounded, size: 20, color: SamiyaColors.rose)),
          ],
        ),
      ),
    );
  }
}
