import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/arch_photo.dart';
import '../../ui/safe_nav.dart';
import '../../ui/widgets.dart';

/// SAMIYA Pro: nima doim bepul, nima Pro'da. To'lov hali ulanmagan (sotib olish tugmasi yo'q).
class ProPage extends StatelessWidget {
  const ProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final app = AppScope.of(context);
    final c = app.campaign;
    Widget row(String s, {required bool plus}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(plus ? Icons.auto_awesome : Icons.check_rounded, size: 17, color: plus ? const Color(0xFFE9D3A8) : SamiyaColors.rose),
          const SizedBox(width: 10),
          Expanded(
            child: Text(s, style: t.bodyLarge?.copyWith(fontSize: 15, height: 1.45, color: plus ? Colors.white : SamiyaColors.ink)),
          ),
        ],
      ),
    );
    return Scaffold(
      key: const Key('pro-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(title: 'SAMIYA Pro', onBack: () => context.canPop() ? context.pop() : context.go('/home')),
              Expanded(
                child: ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 28),
                  children: [
                    const ArchPhoto('assets/tiles/pro.jpg', height: 210),
                    const SizedBox(height: 14),
                    Text('SAMIYA Pro', textAlign: TextAlign.center, style: t.headlineMedium?.copyWith(fontSize: 34)),
                    const SizedBox(height: 6),
                    Text(l.proSubtitle, textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(fontSize: 15)),
                    const SizedBox(height: 18),
                    if (app.isPro)
                      _Pill(key: const Key('pro-active'), text: l.proActive)
                    else if (c.allOpen)
                      _Pill(
                        key: const Key('pro-campaign'),
                        text: c.phase == 'free_campaign' && c.daysRemaining != null ? '${l.proCampaign}\n${l.proDaysLeft(c.daysRemaining!)}' : l.proCampaign,
                      ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x1A3B1E2B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.proFreeTitle, style: t.titleLarge?.copyWith(fontSize: 19)),
                          const SizedBox(height: 12),
                          for (final s in [l.proFree1, l.proFree2, l.proFree3, l.proFree4]) row(s, plus: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      key: const Key('pro-benefits'),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4E2738), SamiyaColors.heading]),
                        border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.proPlusTitle, style: t.titleLarge?.copyWith(fontSize: 19, color: const Color(0xFFE9D3A8))),
                          const SizedBox(height: 12),
                          for (final s in [l.proB1, l.proB2, l.proB3, l.proB4, l.proB5, l.proB6]) row(s, plus: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.proEarly,
                      textAlign: TextAlign.center,
                      style: t.titleMedium?.copyWith(color: const Color(0xFF8C6A3A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.proSoon,
                      textAlign: TextAlign.center,
                      style: t.bodySmall?.copyWith(color: SamiyaColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: SamiyaColors.blush,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.4)),
    ),
    child: Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5, height: 1.45)),
  );
}

/// Qulflangan element: kichik Pro belgisi, bosilganda Pro sahifasi.
class ProLockBadge extends StatelessWidget {
  const ProLockBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: SamiyaColors.heading, borderRadius: BorderRadius.circular(10)),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_rounded, size: 11, color: Color(0xFFE9D3A8)),
        SizedBox(width: 3),
        Text(
          'Pro',
          style: TextStyle(color: Color(0xFFE9D3A8), fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

/// Qulflangan sahifa o'rnida ko'rsatiladigan nafis karta.
class ProLockedCard extends StatelessWidget {
  const ProLockedCard({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      key: const Key('pro-locked'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const ProLockBadge(),
              const SizedBox(width: 10),
              Expanded(child: Text(l.proLocked, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 12),
          GradientButton(label: l.proUnlock, onPressed: () => context.safePush('/pro')),
        ],
      ),
    );
  }
}
