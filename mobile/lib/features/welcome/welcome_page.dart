import 'package:flutter/material.dart';
import '../../ui/safe_nav.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/brand.dart';
import '../../ui/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final heroH = (MediaQuery.sizeOf(context).height * 0.56).clamp(300.0, 520.0);
    return Scaffold(
      key: const Key('welcome-page'),
      body: SamiyaBackground(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                // Jurnal muqovasi uslubi: rasm yuqorini to'liq egallaydi va chinni fonga yumshoq o'tadi.
                SizedBox(
                  height: heroH,
                  width: double.infinity,
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset('assets/images/hero_welcome.png', fit: BoxFit.cover, alignment: const Alignment(0, -0.35), filterQuality: FilterQuality.high),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00F7F3F1), Color(0x00F7F3F1), SamiyaColors.ivory],
                          stops: [0, 0.62, 1],
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 0, 0),
                          child: BackChip(onTap: () => context.canPop() ? context.pop() : context.go('/language')),
                        ),
                      ),
                    ),
                  ]),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(children: [
                      const ExcludeSemantics(child: SamiyaWordmark(scale: 1.05)),
                      const SizedBox(height: 16),
                      Container(height: 1, width: 56, color: SamiyaColors.gold),
                      const SizedBox(height: 16),
                      Text(l.welcomeTagline, textAlign: TextAlign.center, style: t.headlineSmall?.copyWith(fontSize: 22, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 14),
                      Text(l.campaignPill.toUpperCase(), textAlign: TextAlign.center, style: t.labelSmall?.copyWith(color: const Color(0xFF8C6A3A), letterSpacing: Localizations.localeOf(context).languageCode == 'ar' ? 0 : 2, fontSize: 11.5)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 20, 14),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                GradientButton(
                  key: const Key('welcome-start'),
                  label: l.start,
                  trailing: Icons.arrow_forward_rounded,
                  onPressed: () => context.safePush('/onboarding'),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
