import 'package:flutter/material.dart';

import '../../ui/safe_nav.dart';

import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/links.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import '../auth/auth_service.dart';
import '../role/role_labels.dart';

/// 59 Profil: hisob, til, rol, huquqiy havolalar, chiqish va hisobni o'chirish (do'konlar talab qiladi).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _busy = false;

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  Future<void> _signOut() async {
    final state = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await state.signOut();
      if (mounted) context.go('/login');
    } catch (_) {
      if (mounted) _message(AppLocalizations.of(context).actionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteConfirmTitle),
        content: Text(l.deleteConfirmBody),
        actions: [
          TextButton(key: const Key('delete-cancel'), onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(
            key: const Key('delete-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFB3261E)),
            child: Text(l.deleteAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await state.deleteAccount();
      if (!mounted) return;
      _message(l.deleteDone);
      context.go('/login');
    } on AuthException catch (e) {
      if (mounted) _message(e.kind == AuthFailure.requiresRecentLogin ? l.deleteNeedsRelogin : l.actionFailed);
    } catch (_) {
      if (mounted) _message(l.actionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLegal(String page) async {
    final ok = await openExternalUrl(legalUri(page, Localizations.localeOf(context).languageCode));
    if (!ok && mounted) _message(AppLocalizations.of(context).actionFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final state = AppScope.of(context);
    final user = state.user;
    final name = user?.displayName ?? user?.email ?? l.guestName;
    return KeyedSubtree(
      key: const Key('profile-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_busy) const LinearProgressIndicator(minHeight: 3, color: SamiyaColors.rose),
            _AccountCard(name: name, isGuest: user == null, email: user?.displayName != null ? user?.email : null, provider: user?.provider, pro: state.isPro),
            const SizedBox(height: 16),
            if (user == null)
              GradientButton(
                key: const Key('profile-signin'),
                label: l.actionSignIn,
                trailing: Icons.arrow_forward_rounded,
                onPressed: _busy ? null : () => context.safePush('/login'),
              ),
            const SizedBox(height: 16),
            _ProCard(key: const Key('profile-pro-row'), active: state.isPro, onTap: () => context.safePush('/pro')),
            const SizedBox(height: 20),
            _Section(
              title: l.chooseLanguage,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final code in languageNativeNames.keys)
                    _LangChoice(code: code, selected: state.locale.languageCode == code, onTap: () => state.setLocale(code)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: null,
              child: Column(
                children: [
                  _Row(
                    key: const Key('profile-role'),
                    icon: Icons.badge_outlined,
                    label: l.roleSection,
                    value: state.role == null ? '—' : roleLabel(l, state.role!),
                    onTap: () => context.safePush('/role'),
                  ),
                  const Divider(height: 1, color: SamiyaColors.border),
                  if (state.isAdmin) ...[
                    _Row(
                      key: const Key('profile-admin'),
                      icon: Icons.admin_panel_settings_outlined,
                      label: l.adminPanel,
                      onTap: () => context.safePush('/profile/admin'),
                    ),
                    const Divider(height: 1, color: SamiyaColors.border),
                  ],
                  _Row(key: const Key('profile-privacy'), icon: Icons.privacy_tip_outlined, label: l.privacyPolicy, onTap: () => _openLegal('privacy')),
                  const Divider(height: 1, color: SamiyaColors.border),
                  _Row(key: const Key('profile-terms'), icon: Icons.description_outlined, label: l.termsOfUse, onTap: () => _openLegal('terms')),
                ],
              ),
            ),
            if (user != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                key: const Key('profile-signout'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: SamiyaColors.rose, width: 1.4),
                ),
                onPressed: _busy ? null : _signOut,
                child: Text(
                  l.signOut,
                  style: t.titleMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('profile-delete'),
                style: TextButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: _busy ? null : _delete,
                child: Text(
                  l.deleteAccount,
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(color: const Color(0xFFB3261E)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.name, required this.isGuest, required this.email, required this.provider, required this.pro});
  final bool pro;
  final String name;
  final bool isGuest;
  final String? email;
  final String? provider;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    // Lyuks sarlavha: mavzuli rasm, ud-olxo'ri pardasi, oltin halqali avatar va oq serif ism.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.6)),
        boxShadow: const [BoxShadow(color: Color(0x2A3B1E2B), blurRadius: 22, spreadRadius: -6, offset: Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/tiles/welcome.jpg', fit: BoxFit.cover)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x993B1E2B), Color(0xE63B1E2B)]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SamiyaGradients.cta,
                      border: Border.all(color: const Color(0xFFE9D3A8), width: 2),
                    ),
                    child: isGuest
                        ? const Icon(Icons.person_rounded, color: Colors.white, size: 30)
                        : Text(
                            initial,
                            style: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w700, fontSize: 24, color: Colors.white),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lotin ism arab interfeysida ham to'g'ri o'qilsin (tinish belgisi teskari tomonga o'tmasin).
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: isGuest || RegExp(r'[\u0600-\u06FF]').hasMatch(name) ? null : TextDirection.ltr,
                          style: t.headlineSmall?.copyWith(fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(height: 1, width: 40, color: const Color(0xFFE9D3A8)),
                        if (email != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            email!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: t.bodyMedium?.copyWith(color: const Color(0xDDFFFFFF)),
                          ),
                        ],
                        if (provider != null) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              InfoPill(
                                provider == 'apple.com'
                                    ? 'Apple'
                                    : provider == 'google.com'
                                    ? 'Google'
                                    : provider!,
                                upper: false,
                              ),
                              if (pro) InfoPill(AppLocalizations.of(context).proBadge, key: const Key('profile-pro'), upper: false),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
        ],
        Container(
          width: double.infinity,
          padding: title == null ? EdgeInsets.zero : const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SamiyaColors.border),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({super.key, required this.icon, required this.label, required this.onTap, this.value});
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SamiyaColors.blush,
                    border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.6)),
                  ),
                  child: Icon(icon, size: 19, color: SamiyaColors.heading),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (value != null)
                  Flexible(
                    child: Text(value!, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodyMedium),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: SamiyaColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChoice extends StatelessWidget {
  const _LangChoice({required this.code, required this.selected, required this.onTap});
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? SamiyaColors.blush : Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          key: Key('profile-lang-$code'),
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: selected ? SamiyaColors.rose : SamiyaColors.border, width: selected ? 1.6 : 1.2),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                languageNativeNames[code]!,
                style: TextStyle(
                  fontFamily: code == 'ar' ? 'IBMPlexSansArabic' : 'Jost',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: selected ? SamiyaColors.rose : SamiyaColors.heading,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pro taklifi: ud-olxo'ri gradiyent, oltin hoshiya va mavzuli rasm.
class _ProCard extends StatelessWidget {
  const _ProCard({super.key, required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5A2D40), SamiyaColors.heading]),
            border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30), bottom: Radius.circular(12)),
                child: Image.asset('assets/tiles/pro.jpg', width: 62, height: 74, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SAMIYA Pro', style: t.titleLarge?.copyWith(color: const Color(0xFFE9D3A8), fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(active ? l.proActive : l.proSubtitle, maxLines: 3, style: t.bodySmall?.copyWith(color: const Color(0xDDFFFFFF), height: 1.4)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFE9D3A8)),
            ],
          ),
        ),
      ),
    );
  }
}
