import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/portrait_banner.dart';
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
                  PortraitBanner(title: l.loginBanner, eyebrow: l.appName),
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
