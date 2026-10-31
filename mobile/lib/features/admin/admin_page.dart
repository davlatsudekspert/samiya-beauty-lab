import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/backend_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

final _emailRe = RegExp(r'^[^\s@]{1,64}@[^\s@.]+(\.[^\s@.]+)+$');

/// Admin paneli (faqat serverda admin deb tasdiqlangan foydalanuvchi): o'rnatishlar statistikasi va emailga Pro berish.
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final AppState _state = AppScope.of(context);
  final _email = TextEditingController();
  AdminStats? _stats;
  List<ProGrant> _grants = const [];
  bool _loading = true;
  bool _loadFailed = false;
  bool _busy = false;
  int? _days = 30; // null = cheksiz
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final stats = await _state.adminStats();
      final grants = await _state.listGrants();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _grants = grants;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
    }
  }

  void _say(String text, {bool error = false}) => setState(() {
        _message = text;
        _messageIsError = error;
      });

  Future<void> _grant() async {
    final l = AppLocalizations.of(context);
    final email = _email.text.trim().toLowerCase();
    if (_busy) return;
    if (email.length > 254 || !_emailRe.hasMatch(email)) {
      _say(l.adminInvalidEmail, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await _state.grantPro(email, days: _days);
      final grants = await _state.listGrants();
      if (!mounted) return;
      _email.clear();
      setState(() => _grants = grants);
      _say(l.adminGranted);
    } catch (_) {
      if (mounted) _say(l.adminLoadFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke(String email) async {
    final l = AppLocalizations.of(context);
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _state.revokePro(email);
      final grants = await _state.listGrants();
      if (!mounted) return;
      setState(() => _grants = grants);
      _say(l.adminRevoked);
    } catch (_) {
      if (mounted) _say(l.adminLoadFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      key: const Key('admin-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(children: [
            PageHeader(title: l.adminPanel, onBack: () => context.canPop() ? context.pop() : context.go('/profile')),
            Expanded(
              child: PageBody(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_loading)
                    const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: SamiyaColors.rose)))
                  else if (_loadFailed)
                    _LoadError(onRetry: _load)
                  else if (_stats != null)
                    _StatsBlock(stats: _stats!),
                  const SizedBox(height: 22),
                  Text(l.adminGrantTitle, style: t.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('admin-email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: l.adminEmailHint,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: SamiyaColors.border)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final d in [30, 90, 365, null])
                      ChoiceChip(
                        key: Key('admin-days-${d ?? 'forever'}'),
                        label: Text(d == null ? l.adminForever : l.adminDays(d)),
                        selected: _days == d,
                        onSelected: (_) => setState(() => _days = d),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  GradientButton(
                    key: const Key('admin-grant'),
                    label: l.adminGrantAction,
                    trailing: Icons.workspace_premium_rounded,
                    onPressed: _busy ? null : _grant,
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 10),
                    Semantics(
                      liveRegion: true,
                      child: Text(_message!,
                          key: const Key('admin-message'),
                          style: t.bodyMedium?.copyWith(color: _messageIsError ? const Color(0xFFB3261E) : SamiyaColors.heading, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Text(l.adminGrantsList, style: t.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (_grants.isEmpty)
                    Text(l.adminGrantsEmpty, style: t.bodyMedium)
                  else
                    for (final g in _grants)
                      _GrantRow(grant: g, onRevoke: _busy ? null : () => _revoke(g.email)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      key: const Key('admin-load-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2B8BD)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.adminLoadFailed, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7A1F1A))),
        const SizedBox(height: 8),
        TextButton(key: const Key('admin-retry'), onPressed: onRetry, child: Text(l.adminRetry)),
      ]),
    );
  }
}

class _StatsBlock extends StatelessWidget {
  const _StatsBlock({required this.stats});
  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final tiles = <(String, String, int)>[
      ('android', 'Android', stats.android),
      ('ios', 'iOS', stats.ios),
      ('web', l.adminWeb, stats.web),
      ('new7d', l.adminNew7d, stats.new7d),
      ('active7d', l.adminActive7d, stats.active7d),
      ('active30d', l.adminActive30d, stats.active30d),
      ('users', l.adminUsers, stats.usersTotal),
      ('propaid', l.adminProPaid, stats.proPaid),
      ('progranted', l.adminProGranted, stats.proGranted),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.adminInstalls, style: t.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Container(
        key: const Key('admin-stat-total'),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: SamiyaGradients.cta, borderRadius: BorderRadius.circular(24), boxShadow: SamiyaShadows.cta),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${stats.installsTotal}',
              style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 34, color: Colors.white)),
          Text(l.adminTotal, style: t.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(height: 8),
      Text(l.adminInstallsNote, key: const Key('admin-installs-note'), style: t.bodyMedium?.copyWith(fontSize: 12)),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final (id, label, value) in tiles)
            SizedBox(
              width: w,
              child: Container(
                key: Key('admin-stat-$id'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SamiyaColors.border),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$value',
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 24, color: SamiyaColors.heading)),
                  Text(label, style: t.bodyMedium?.copyWith(fontSize: 13)),
                ]),
              ),
            ),
        ]);
      }),
    ]);
  }
}

class _GrantRow extends StatelessWidget {
  const _GrantRow({required this.grant, required this.onRevoke});
  final ProGrant grant;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final until = grant.endsAt == null ? l.adminForever : l.adminUntil(grant.endsAt!.split(' ').first);
    return Container(
      key: Key('admin-grant-${grant.email}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SamiyaColors.border),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(grant.email, textDirection: TextDirection.ltr, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleMedium?.copyWith(fontSize: 15)),
            Text(until, style: t.bodyMedium?.copyWith(fontSize: 12)),
          ]),
        ),
        TextButton(key: Key('admin-revoke-${grant.email}'), onPressed: onRevoke, child: Text(l.adminRevoke)),
      ]),
    );
  }
}
