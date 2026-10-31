import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
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
    return Scaffold(
      key: const Key('splash-page'),
      body: SamiyaBackground(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(44),
                  boxShadow: SamiyaShadows.soft,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(44),
                  child: Image.asset('assets/images/logo_icon.png',
                      fit: BoxFit.cover, filterQuality: FilterQuality.high, semanticLabel: l.appName),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(l.welcomeTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: SamiyaColors.heading)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
