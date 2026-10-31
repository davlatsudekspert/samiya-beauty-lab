import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// Faqat Google, Apple va mehmon rejimi. Email/parol YO'Q (mahsulot qarori).
/// Google/Apple haqiqiy ulanishi Phase 2 da (Firebase Auth); hozir halol "tez orada" xabari.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _soon(BuildContext context) {
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.comingSoon), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      key: const Key('login-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(children: [
            PageHeader(onBack: () => context.canPop() ? context.pop() : context.go('/onboarding')),
            Expanded(
              child: PageBody(
                child: Column(children: [
                  const SizedBox(height: 4),
                  _Banner(title: l.loginBanner),
                  const SizedBox(height: 18),
                  InfoPill(l.campaignNoCard),
                  const SizedBox(height: 14),
                  Text(l.welcomeTitle, textAlign: TextAlign.center, style: t.headlineMedium),
                  const SizedBox(height: 8),
                  Text(l.loginSubtitle, textAlign: TextAlign.center, style: t.bodyLarge),
                  const SizedBox(height: 22),
                  _ProviderButton(
                    key: const Key('btn-google'),
                    label: l.continueWithGoogle,
                    dark: false,
                    leading: const Text('G',
                        style: TextStyle(
                            fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF4285F4))),
                    onTap: () => _soon(context),
                  ),
                  const SizedBox(height: 12),
                  _ProviderButton(
                    key: const Key('btn-apple'),
                    label: l.continueWithApple,
                    dark: true,
                    leading: const Icon(Icons.apple, size: 24, color: Colors.white),
                    onTap: () => _soon(context),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton(
                      key: const Key('btn-guest'),
                      onPressed: () => context.push('/role'),
                      child: Text(l.continueAsGuest,
                          textAlign: TextAlign.center,
                          style: t.titleMedium?.copyWith(color: SamiyaColors.heading)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(l.legalNotice,
                      textAlign: TextAlign.center,
                      style: t.bodyMedium?.copyWith(fontSize: 12, color: SamiyaColors.muted)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 168),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: SamiyaShadows.soft,
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [Color(0xFFB85B7C), Color(0xFFD98BA2)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(children: [
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            width: 180,
            child: ExcludeSemantics(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0, 0.55],
                ).createShader(r, textDirection: Directionality.of(context)),
                child: Image.asset('assets/images/ob2_routine.png',
                    fit: BoxFit.cover, alignment: Alignment.topCenter, filterQuality: FilterQuality.high),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(22, 22, 150, 22),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('SAMIYA BEAUTY LAB',
                      style: t.labelSmall?.copyWith(color: Colors.white, fontSize: 11, letterSpacing: 1.6)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(title, style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton(
      {super.key, required this.label, required this.dark, required this.leading, required this.onTap});
  final String label;
  final bool dark;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : SamiyaColors.ink;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: dark ? SamiyaColors.appleBlack : Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: dark ? SamiyaColors.appleBlack : SamiyaColors.border, width: 1.4),
            ),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark ? Colors.white.withValues(alpha: 0.14) : const Color(0xFFF1F6FF),
                ),
                child: leading,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w700)),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: fg.withValues(alpha: 0.7)),
            ]),
          ),
        ),
      ),
    );
  }
}
