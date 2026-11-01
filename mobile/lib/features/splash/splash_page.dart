import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/brand.dart';

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
            builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child)),
            child: Semantics(
              label: l.appName,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SamiyaMark(size: 92),
                const SizedBox(height: 34),
                const SamiyaWordmark(color: Color(0xFFEAD7BF)),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(l.welcomeTagline,
                      textAlign: TextAlign.center,
                      style: t.bodyLarge?.copyWith(color: const Color(0xFFEAD7BF).withValues(alpha: 0.85), fontSize: 15)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
