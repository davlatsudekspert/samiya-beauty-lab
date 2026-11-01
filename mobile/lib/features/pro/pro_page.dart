import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/links.dart';
import '../../data/purchase_service.dart';
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
                    if (app.purchases.isAvailable && !app.isPro)
                      const _Purchase()
                    else if (!app.isPro) ...[
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

/// Xarid bloki: do'kon narxlari (mahalliy valyutada), obuna, tiklash, avtomatik yangilanish haqida izoh va huquqiy havolalar.
class _Purchase extends StatefulWidget {
  const _Purchase();
  @override
  State<_Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<_Purchase> {
  List<ProOffer>? _offers;
  ProOffer? _sel;
  bool _busy = false;
  String? _msg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_offers == null) {
      AppScope.of(context).purchases.offers().then((o) {
        if (!mounted) return;
        setState(() {
          _offers = o;
          _sel = o.where((x) => x.yearly).firstOrNull ?? o.firstOrNull;
        });
      });
    }
  }

  Future<void> _run(Future<bool> Function() f, String ok, String none) async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    try {
      final r = await f();
      if (mounted) setState(() => _msg = r ? ok : none);
    } catch (_) {
      if (mounted) setState(() => _msg = AppLocalizations.of(context).proBuyFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final app = AppScope.of(context);
    final signedIn = app.user != null;
    final offers = _offers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (offers == null)
          const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 1.6)),
          )
        else
          for (final o in [...offers.where((x) => x.yearly), ...offers.where((x) => !x.yearly)])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                key: Key('pro-offer-${o.yearly ? 'yearly' : 'monthly'}'),
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _sel = o),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _sel == o ? SamiyaColors.gold : const Color(0x1A3B1E2B), width: _sel == o ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(_sel == o ? Icons.radio_button_checked : Icons.radio_button_off, color: _sel == o ? SamiyaColors.gold : SamiyaColors.muted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.yearly ? l.proYearly : l.proMonthly, style: t.titleMedium),
                            Text(o.yearly ? l.proPerYear(o.price) : l.proPerMonth(o.price), style: t.bodyMedium?.copyWith(color: SamiyaColors.muted)),
                          ],
                        ),
                      ),
                      if (o.yearly)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: SamiyaColors.heading, borderRadius: BorderRadius.circular(10)),
                          child: Text(l.proBestValue, style: t.labelSmall?.copyWith(color: const Color(0xFFE9D3A8))),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 6),
        if (!signedIn) ...[
          Text(l.proSignInFirst, textAlign: TextAlign.center, style: t.bodyMedium),
          const SizedBox(height: 10),
          GradientButton(key: const Key('pro-signin'), label: l.aiSignInBtn, onPressed: () => context.safePush('/login')),
        ] else
          GradientButton(
            key: const Key('pro-buy'),
            label: l.proSubscribe,
            onPressed: _busy || _sel == null ? null : () => _run(() => app.buyPro(_sel!), l.proThanks, ''),
          ),
        if (signedIn)
          TextButton(
            key: const Key('pro-restore'),
            onPressed: _busy ? null : () => _run(app.restorePro, l.proThanks, l.proRestoreNone),
            child: Text(l.proRestore),
          ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.6)),
          ),
        if (_msg != null && _msg!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_msg!, key: const Key('pro-msg'), textAlign: TextAlign.center, style: t.titleSmall),
          ),
        const SizedBox(height: 12),
        Text(
          l.proAutoRenew,
          textAlign: TextAlign.center,
          style: t.bodySmall?.copyWith(color: SamiyaColors.muted, height: 1.45),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            TextButton(onPressed: () => openExternalUrl(legalUri('terms', Localizations.localeOf(context).languageCode)), child: Text(l.termsOfUse)),
            TextButton(onPressed: () => openExternalUrl(legalUri('privacy', Localizations.localeOf(context).languageCode)), child: Text(l.privacyPolicy)),
          ],
        ),
      ],
    );
  }
}
