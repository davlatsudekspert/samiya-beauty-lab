import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_page.dart';
import '../features/home/home_page.dart';
import '../features/language/language_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/role/role_page.dart';
import '../features/shell/app_shell.dart';
import '../features/tabs/placeholder_tab.dart';
import '../features/splash/splash_page.dart';
import '../features/welcome/welcome_page.dart';
import '../l10n/app_localizations.dart';
import 'app_state.dart';
import 'theme.dart';

String _academyTitle(AppLocalizations l) => l.navAcademy;
String _scannerTitle(AppLocalizations l) => l.navScanner;
String _journalTitle(AppLocalizations l) => l.navJournal;
String _profileTitle(AppLocalizations l) => l.navProfile;

class SamiyaApp extends StatefulWidget {
  const SamiyaApp({
    super.key,
    required this.state,
    this.initialLocation = '/splash',
    this.splashDuration = const Duration(milliseconds: 1800),
  });

  final AppState state;
  final String initialLocation;
  final Duration splashDuration;

  @override
  State<SamiyaApp> createState() => _SamiyaAppState();
}

class _SamiyaAppState extends State<SamiyaApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: widget.initialLocation,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => SplashPage(duration: widget.splashDuration)),
      GoRoute(path: '/language', builder: (_, _) => const LanguagePage()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/role', builder: (_, _) => const RolePage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomePage())]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/academy',
                builder: (_, _) => const PlaceholderTab(pageKey: 'tab-academy', title: _academyTitle)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/scanner',
                builder: (_, _) => const PlaceholderTab(pageKey: 'tab-scanner', title: _scannerTitle)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/journal',
                builder: (_, _) => const PlaceholderTab(pageKey: 'tab-journal', title: _journalTitle)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                builder: (_, _) => const PlaceholderTab(pageKey: 'tab-profile', title: _profileTitle)),
          ]),
        ],
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.state,
      child: ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: buildTheme(widget.state.locale),
          locale: widget.state.locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
