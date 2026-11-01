import 'package:flutter/material.dart';

import '../../ui/safe_nav.dart';

import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pages = 3;
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages - 1) {
      context.safePush('/login');
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  void _back() {
    if (_index > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      context.canPop() ? context.pop() : context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slides = [
      (l.onboarding1Title, l.onboarding1Body, 'assets/tiles/ingredients.jpg'),
      (l.onboarding2Title, l.onboarding2Body, 'assets/tiles/morning.jpg'),
      (l.onboarding3Title, l.onboarding3Body, 'assets/tiles/academy.jpg'),
    ];
    final last = _index == _pages - 1;
    return Scaffold(
      key: const Key('onboarding-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(onBack: _back),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _Slide(number: '0${i + 1} / 0$_pages', title: slides[i].$1, body: slides[i].$2, asset: slides[i].$3),
                ),
              ),
              _Dots(count: _pages, index: _index),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GradientButton(
                      key: const Key('onboarding-next'),
                      label: last ? l.start : l.continueLabel,
                      trailing: Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                    // Joy band bo'lib turadi: oxirgi sahifada ham maket sakramasligi uchun.
                    SizedBox(
                      height: 48,
                      child: last
                          ? null
                          : TextButton(
                              key: const Key('onboarding-skip'),
                              onPressed: () => context.safePush('/login'),
                              child: Text(
                                l.skip,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SamiyaColors.heading, fontWeight: FontWeight.w600),
                              ),
                            ),
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

class _Slide extends StatelessWidget {
  const _Slide({required this.number, required this.title, required this.body, required this.asset});
  final String number;
  final String title;
  final String body;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final imageHeight = (c.maxHeight * 0.52).clamp(150.0, 340.0);
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
          child: Column(
            children: [
              Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(160), bottom: Radius.circular(24)),
                  boxShadow: SamiyaShadows.soft,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(160), bottom: Radius.circular(24)),
                  child: ExcludeSemantics(
                    child: Image.asset(asset, fit: BoxFit.cover, filterQuality: FilterQuality.high),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Semantics(
                label: number,
                child: Container(height: 1, width: 48, color: SamiyaColors.gold),
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: i == index ? SamiyaGradients.cta : null,
              borderRadius: BorderRadius.circular(5),
              border: i == index ? null : Border.all(color: SamiyaColors.rose, width: 1.6),
            ),
          ),
      ],
    );
  }
}
