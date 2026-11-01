import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_page.dart';
import '../features/auth/login_page.dart';
import '../features/home/home_page.dart';
import '../features/language/language_page.dart';
import '../features/personal/journal_page.dart';
import '../features/personal/routine_page.dart';
import '../features/personal/skin_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/profile/profile_page.dart';
import '../features/role/role_page.dart';
import '../features/scanner/ibn_sina_page.dart';
import '../features/scanner/ingredient_detail_page.dart';
import '../features/scanner/ingredient_list_page.dart';
import '../features/scanner/manual_input_page.dart';
import '../features/scanner/result_page.dart';
import '../features/scanner/scanner_page.dart';
import '../features/shell/app_shell.dart';
import '../features/academy/lesson_page.dart';
import '../features/ai/ai_page.dart';
import '../features/pro/pro_page.dart';
import '../features/care/care_pages.dart';
import '../features/shelf/shelf_page.dart';
import '../features/tabs/academy_page.dart';
import '../features/splash/splash_page.dart';
import '../features/welcome/welcome_page.dart';
import '../l10n/app_localizations.dart';
import 'app_state.dart';
import 'theme.dart';

class SamiyaApp extends StatefulWidget {
  const SamiyaApp({super.key, required this.state, this.initialLocation = '/splash', this.splashDuration = const Duration(milliseconds: 1900)});

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
      GoRoute(
        path: '/splash',
        builder: (_, _) => SplashPage(duration: widget.splashDuration),
      ),
      GoRoute(path: '/language', builder: (_, _) => const LanguagePage()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/role', builder: (_, _) => const RolePage()),
      GoRoute(path: '/pro', builder: (_, _) => const ProPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomePage(),
                routes: [
                  GoRoute(path: 'skin', builder: (_, _) => const SkinPage()),
                  GoRoute(path: 'routine', builder: (_, _) => const RoutinePage()),
                  GoRoute(path: 'ai', builder: (_, _) => const AiPage()),
                  GoRoute(path: 'shelf', builder: (_, _) => const ShelfPage()),
                  GoRoute(
                    path: 'recipes',
                    builder: (_, _) => const RecipesPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, st) => RecipePage(id: st.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'rituals',
                    builder: (_, _) => const RitualsPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, st) => RitualPage(id: st.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/academy',
                builder: (_, _) => const AcademyPage(),
                routes: [
                  GoRoute(
                    path: 'lesson/:id',
                    builder: (_, st) => LessonPage(id: st.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scanner',
                builder: (_, _) => const ScannerPage(),
                routes: [
                  GoRoute(
                    path: 'manual',
                    builder: (_, st) => ManualInputPage(args: st.extra is ManualInputArgs ? st.extra! as ManualInputArgs : null),
                  ),
                  GoRoute(path: 'ibn-sina', builder: (_, _) => const IbnSinaPage()),
                  GoRoute(
                    path: 'ingredients',
                    builder: (_, st) => IngredientListPage(initialFilter: st.uri.queryParameters['filter']),
                  ),
                  GoRoute(
                    path: 'result',
                    builder: (_, st) => ResultPage(raw: st.extra is String ? st.extra! as String : ''),
                  ),
                  GoRoute(
                    path: 'ingredient/:slug',
                    builder: (_, st) => IngredientDetailPage(slug: st.pathParameters['slug']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/journal', builder: (_, _) => const JournalPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfilePage(),
                routes: [
                  // Faqat serverda tasdiqlangan admin; boshqalar profilga qaytariladi.
                  GoRoute(path: 'admin', redirect: (_, _) => widget.state.isAdmin ? null : '/profile', builder: (_, _) => const AdminPage()),
                ],
              ),
            ],
          ),
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
