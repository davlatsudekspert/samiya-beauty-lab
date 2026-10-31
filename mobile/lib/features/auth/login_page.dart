import 'package:flutter/material.dart';
import '../../ui/safe_nav.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/portrait_banner.dart';
import '../../ui/widgets.dart';
import 'auth_service.dart';

/// 07 Kirish: faqat Google, Apple va mehmon rejimi (email/parol YO'Q: mahsulot qarori).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _busy = false;
  String? _error; // sahifa ichidagi xabar: pastdagi tugmalarni yopmaydi

  void _message(String text) => setState(() => _error = text);

  Future<void> _signIn(Future<AuthUser> Function(AuthService) run) async {
    if (_busy) return;
    final state = AppScope.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await run(state.auth);
      if (!mounted) return;
      // Rol allaqachon tanlangan bo'lsa (qayta kirish), rol ekranini o'tkazib yuboramiz.
      if (state.onboarded && state.role != null) {
        context.go('/home');
      } else {
        context.safePush('/role');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      switch (e.kind) {
        case AuthFailure.cancelled:
          break; // foydalanuvchi o'zi bekor qildi: xabar kerak emas
        case AuthFailure.unavailable:
          _message(l.authUnavailable);
        case AuthFailure.requiresRecentLogin || AuthFailure.failed:
          _message(l.authFailed);
      }
    } catch (_) {
      if (mounted) _message(AppLocalizations.of(context).authFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
            if (_busy) const LinearProgressIndicator(key: Key('login-busy'), minHeight: 3, color: SamiyaColors.rose),
            Expanded(
              child: PageBody(
                child: Column(children: [
                  const SizedBox(height: 4),
                  PortraitBanner(key: const Key('login-banner'), title: l.loginBanner, eyebrow: l.appName),
                  const SizedBox(height: 18),
                  InfoPill(l.campaignNoCard),
                  const SizedBox(height: 14),
                  Text(l.welcomeTitle, textAlign: TextAlign.center, style: t.headlineMedium),
                  const SizedBox(height: 8),
                  Text(l.loginSubtitle, textAlign: TextAlign.center, style: t.bodyLarge),
                  const SizedBox(height: 22),
                  if (_error != null) ...[
                    _InlineError(key: const Key('login-error'), text: _error!),
                    const SizedBox(height: 12),
                  ],
                  _ProviderButton(
                    key: const Key('btn-google'),
                    label: l.continueWithGoogle,
                    dark: false,
                    leading: const Text('G',
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF4285F4))),
                    onTap: _busy ? null : () => _signIn((a) => a.signInWithGoogle()),
                  ),
                  const SizedBox(height: 12),
                  _ProviderButton(
                    key: const Key('btn-apple'),
                    label: l.continueWithApple,
                    dark: true,
                    leading: const Icon(Icons.apple, size: 24, color: Colors.white),
                    onTap: _busy ? null : () => _signIn((a) => a.signInWithApple()),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton(
                      key: const Key('btn-guest'),
                      onPressed: _busy ? null : () => context.safePush('/role'),
                      child: Text(l.continueAsGuest,
                          textAlign: TextAlign.center, style: t.titleMedium?.copyWith(color: SamiyaColors.heading)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(l.legalNotice,
                      textAlign: TextAlign.center, style: t.bodyMedium?.copyWith(fontSize: 12, color: SamiyaColors.muted)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF2B8BD)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFB3261E)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7A1F1A)))),
        ]),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({super.key, required this.label, required this.dark, required this.leading, required this.onTap});
  final String label;
  final bool dark;
  final Widget leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : SamiyaColors.ink;
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: Semantics(
        button: true,
        enabled: onTap != null,
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
      ),
    );
  }
}
