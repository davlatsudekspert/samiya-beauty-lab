import 'package:flutter/material.dart';
import '../../ui/safe_nav.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return Scaffold(
      key: const Key('welcome-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(children: [
            PageHeader(onBack: () => context.canPop() ? context.pop() : context.go('/language')),
            Expanded(
              child: PageBody(
                bottom: Column(mainAxisSize: MainAxisSize.min, children: [
                  GradientButton(
                    key: const Key('welcome-start'),
                    label: l.start,
                    trailing: Icons.arrow_forward_rounded,
                    onPressed: () => context.safePush('/onboarding'),
                  ),
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                    for (final code in languageNativeNames.keys)
                      _LangChip(
                        code: code,
                        selected: state.locale.languageCode == code,
                        onTap: () => state.setLocale(code),
                      ),
                  ]),
                ]),
                child: Column(children: [
                  const _Wordmark(),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l.welcomeTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: SamiyaColors.heading, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 12),
                  InfoPill(l.campaignPill),
                  const SizedBox(height: 16),
                  const _Hero(),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Brend nomi har tilda lotin yozuvida qoladi (tasdiqlangan brend).
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(children: [
        const Text('SAMIYA',
            style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.w500,
                fontSize: 52,
                letterSpacing: 2,
                height: 1.1,
                color: Color(0xFF8E4A5E))),
        const SizedBox(height: 4),
        Text('BEAUTY LAB',
            style: TextStyle(
                fontFamily: 'Jost',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: 8,
                color: SamiyaColors.rose.withValues(alpha: 0.9))),
      ]),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    // Katta ekranda bo'sh joy qolmasin, kichikda sig'sin (260..440 px).
    final height = (MediaQuery.sizeOf(context).height * 0.42).clamp(260.0, 440.0);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, 0.78, 1],
      ).createShader(rect),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(120)),
        child: Image.asset('assets/images/hero_welcome.png',
            height: height, width: double.infinity, fit: BoxFit.cover, filterQuality: FilterQuality.high),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.code, required this.selected, required this.onTap});
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: languageNativeNames[code],
      child: Material(
        color: selected ? Colors.white : SamiyaColors.blush,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          key: Key('welcome-lang-$code'),
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 56, minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: selected ? SamiyaColors.rose : Colors.transparent, width: 1.4),
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(code.toUpperCase(),
                  style: TextStyle(
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: selected ? SamiyaColors.rose : SamiyaColors.heading)),
            ),
          ),
        ),
      ),
    );
  }
}
