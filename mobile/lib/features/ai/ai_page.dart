import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/backend_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/arch_photo.dart';
import '../../ui/honest_note.dart';
import '../../ui/safe_nav.dart';
import '../../ui/widgets.dart';

/// SAMIYA AI: ta'limiy suhbat. Kalit faqat serverda; birinchi marta foydalanishdan oldin rozilik so'raladi.
class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _Msg {
  _Msg(this.role, this.text, {this.error});
  final String role; // user | model
  final String text;
  final String? error; // xato kodi (model xabari o'rnida)
}

class _AiPageState extends State<AiPage> {
  static const _consentKey = 'ai_consent_v1';
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[];
  bool _busy = false;
  bool? _consent;
  int? _remaining;
  String? _lastQuestion;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((p) {
          if (mounted) setState(() => _consent = p.getBool(_consentKey) ?? false);
        })
        .catchError((_) {
          if (mounted) setState(() => _consent = false);
        });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    setState(() => _consent = true);
    try {
      (await SharedPreferences.getInstance()).setBool(_consentKey, true);
    } catch (_) {}
  }

  String _rid() {
    final r = Random.secure();
    return List.generate(24, (_) => '0123456789abcdef'[r.nextInt(16)]).join();
  }

  Future<void> _ask(String q) async {
    final question = q.trim();
    if (question.length < 2 || _busy) return;
    final app = AppScope.of(context);
    final history = [for (final m in _msgs.where((m) => m.error == null).toList().reversed.take(6).toList().reversed) AiTurn(m.role, m.text)];
    setState(() {
      _msgs.add(_Msg('user', question));
      _busy = true;
      _lastQuestion = question;
      _input.clear();
    });
    _toEnd();
    try {
      final a = await app.askAi(question, requestId: _rid(), history: history);
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg('model', a.answer));
        _remaining = a.remaining;
      });
    } on BackendException catch (e) {
      if (!mounted) return;
      final code =
          e.code ??
          (e.status == 429
              ? 'quota_exceeded'
              : e.status == 401
              ? 'sign_in_required'
              : 'error');
      setState(() => _msgs.add(_Msg('model', '', error: code)));
    } catch (_) {
      if (mounted) setState(() => _msgs.add(_Msg('model', '', error: 'error')));
    } finally {
      if (mounted) setState(() => _busy = false);
      _toEnd();
    }
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final signedIn = AppScope.of(context).user != null;
    final suggestions = [l.aiS1, l.aiS2, l.aiS3, l.aiS4];
    return Scaffold(
      key: const Key('ai-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(title: l.tileAi, onBack: () => context.canPop() ? context.pop() : context.go('/home')),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 16),
                  children: [
                    const SizedBox(height: 6),
                    const ArchPhoto('assets/tiles/ai.jpg', height: 200),
                    const SizedBox(height: 14),
                    Text(l.tileAi, textAlign: TextAlign.center, style: t.headlineMedium?.copyWith(fontSize: 30)),
                    const SizedBox(height: 6),
                    Text(l.aiSubtitle, textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(fontSize: 15)),
                    const SizedBox(height: 14),
                    HonestNote(l.aiDisclaimer),
                    const SizedBox(height: 14),
                    if (!signedIn)
                      _Card(key: const Key('ai-signin'), text: l.aiSignIn, action: l.aiSignInBtn, onTap: () => context.safePush('/login'))
                    else if (_consent == false)
                      _Card(key: const Key('ai-consent'), text: l.aiConsent, action: l.aiAccept, onTap: _accept)
                    else if (_msgs.isEmpty) ...[
                      Text(
                        l.aiTry.toUpperCase(),
                        style: t.labelSmall?.copyWith(
                          color: const Color(0xFF8C6A3A),
                          letterSpacing: Localizations.localeOf(context).languageCode == 'ar' ? 0 : 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < suggestions.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            key: Key('ai-suggest-$i'),
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _ask(suggestions[i]),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0x1A3B1E2B)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 16, color: SamiyaColors.gold),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(suggestions[i], style: t.bodyMedium?.copyWith(fontSize: 14.5))),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                    for (final m in _msgs) _Bubble(m: m, onRetry: _lastQuestion == null ? null : () => _ask(_lastQuestion!)),
                    if (_busy)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.6)),
                            const SizedBox(width: 10),
                            Text(
                              l.aiThinking,
                              style: t.bodySmall?.copyWith(color: SamiyaColors.muted, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (signedIn && _consent == true)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_remaining != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(l.aiRemaining(_remaining!), style: t.bodySmall?.copyWith(color: SamiyaColors.muted)),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('ai-input'),
                              controller: _input,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 800,
                              textInputAction: TextInputAction.send,
                              onSubmitted: _ask,
                              decoration: InputDecoration(hintText: l.aiHint, counterText: ''),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            key: const Key('ai-send'),
                            onPressed: _busy ? null : () => _ask(_input.text),
                            style: IconButton.styleFrom(backgroundColor: SamiyaColors.heading, foregroundColor: Colors.white),
                            icon: const Icon(Icons.arrow_upward_rounded),
                          ),
                        ],
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

class _Card extends StatelessWidget {
  const _Card({super.key, required this.text, required this.action, required this.onTap});
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.5)),
          const SizedBox(height: 14),
          GradientButton(label: action, onPressed: onTap),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.m, this.onRetry});
  final _Msg m;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final user = m.role == 'user';
    final text = switch (m.error) {
      null => m.text,
      'ai_not_configured' => l.aiNotReady,
      'quota_exceeded' => l.aiQuota,
      'sign_in_required' => l.aiSignIn,
      _ => l.aiError,
    };
    return Align(
      alignment: user ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.84),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: user ? SamiyaColors.heading : (m.error != null ? SamiyaColors.blush : Colors.white),
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(user ? 18 : 4),
            bottomEnd: Radius.circular(user ? 4 : 18),
          ),
          border: user ? null : Border.all(color: const Color(0x1A3B1E2B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(text, style: t.bodyMedium?.copyWith(fontSize: 15, height: 1.5, color: user ? Colors.white : SamiyaColors.ink)),
            if (m.error == 'error' && onRetry != null) TextButton(onPressed: onRetry, child: Text(l.aiRetry)),
          ],
        ),
      ),
    );
  }
}
