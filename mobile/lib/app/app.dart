import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'theme.dart';

class SamiyaApp extends StatelessWidget {
  const SamiyaApp({super.key, required this.controller});
  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: controller,
      builder: (context, locale, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Arab tilida GlobalWidgetsLocalizations avtomatik RTL beradi.
        home: WelcomePage(controller: controller),
      ),
    );
  }
}

/// Phase 0 uchun vaqtinchalik sahifa: 4 til + RTL asosini isbotlaydi.
/// Haqiqiy 03_welcome dizayni Phase 1 da quriladi.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.controller});
  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('welcome-page'),
      body: SafeArea(
        child: Padding(
          // Directional: arab tilida avtomatik aks etadi.
          padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final code in languageNativeNames.keys)
                    ChoiceChip(
                      key: Key('lang-$code'),
                      label: Text(languageNativeNames[code]!),
                      selected: controller.value.languageCode == code,
                      onSelected: (_) => controller.select(code),
                    ),
                ],
              ),
              const Spacer(),
              Text(l.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: SamiyaColors.roseDeep)),
              const SizedBox(height: 12),
              Text(l.welcomeTagline, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l.campaignPill, style: const TextStyle(color: SamiyaColors.muted)),
              const Spacer(),
              FilledButton(onPressed: () {}, child: Text(l.start)),
              const SizedBox(height: 12),
              OutlinedButton(key: const Key('btn-google'), onPressed: () {}, child: Text(l.continueWithGoogle)),
              const SizedBox(height: 8),
              OutlinedButton(key: const Key('btn-apple'), onPressed: () {}, child: Text(l.continueWithApple)),
              const SizedBox(height: 8),
              TextButton(key: const Key('btn-guest'), onPressed: () {}, child: Text(l.continueAsGuest)),
            ],
          ),
        ),
      ),
    );
  }
}
