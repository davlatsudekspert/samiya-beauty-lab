import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/brand.dart';
import '../../ui/widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.duration});
  final Duration duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      context.go(AppScope.of(context).onboarded ? '/home' : '/language');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    // Qaytgan foydalanuvchi: tanlangan tilda portretli jurnal muqovasi (1-2 soniya), keyin bosh sahifa.
    if (AppScope.of(context).onboarded) return _Greeting(l: l, t: t);
    return Scaffold(
      key: const Key('splash-page'),
      backgroundColor: SamiyaColors.heading,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 1.1,
            colors: [Color(0xFF4E2738), SamiyaColors.heading, Color(0xFF24121A)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
            ),
            child: Semantics(
              label: l.appName,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SamiyaMark(size: 156),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      l.welcomeTagline,
                      textAlign: TextAlign.center,
                      style: t.bodyLarge?.copyWith(color: const Color(0xFFEAD7BF).withValues(alpha: 0.85), fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.l, required this.t});
  final AppLocalizations l;
  final TextTheme t;

  @override
  Widget build(BuildContext context) {
    final heroH = (MediaQuery.sizeOf(context).height * 0.6).clamp(300.0, 560.0);
    return Scaffold(
      key: const Key('splash-page'),
      body: SamiyaBackground(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(opacity: v, child: child),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              key: const Key('splash-greeting'),
              children: [
                SizedBox(
                  height: heroH,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
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
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Semantics(
                      label: l.appName,
                      child: Column(
                        children: [
                          const ExcludeSemantics(child: SamiyaWordmark(scale: 1.05)),
                          const SizedBox(height: 16),
                          Container(height: 1, width: 56, color: SamiyaColors.gold),
                          const SizedBox(height: 16),
                          Text(
                            l.welcomeTagline,
                            textAlign: TextAlign.center,
                            style: t.headlineSmall?.copyWith(fontSize: 22, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
