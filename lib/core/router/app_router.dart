import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/providers/recipe_gating_provider.dart';
import 'package:fruitlens/ui/screens/account_settings_screen.dart';
import 'package:fruitlens/ui/screens/auth_screen.dart';
import 'package:fruitlens/ui/screens/chat_screen.dart';
import 'package:fruitlens/ui/screens/forgot_password_screen.dart';
import 'package:fruitlens/ui/screens/history_detail_screen.dart';
import 'package:fruitlens/ui/screens/history_screen.dart';
import 'package:fruitlens/ui/screens/home_screen.dart';
import 'package:fruitlens/ui/screens/onboarding_screen.dart';
import 'package:fruitlens/ui/screens/profile_screen.dart';
import 'package:fruitlens/ui/screens/recipe_detail_screen.dart';
import 'package:fruitlens/ui/screens/recipes_list_screen.dart';
import 'package:fruitlens/ui/screens/result_screen.dart';
import 'package:fruitlens/ui/screens/scan_recipes_screen.dart';
import 'package:fruitlens/ui/screens/scan_screen.dart';
import 'package:fruitlens/ui/screens/splash_screen.dart';
import 'package:fruitlens/ui/screens/theme_preview_screen.dart';
import 'package:fruitlens/ui/widgets/main_scaffold_with_nav.dart';
import 'package:go_router/go_router.dart';

/// Helper notifier that alerts [GoRouter] when auth state changes in Riverpod.
class _AuthRouterRefreshNotifier extends ChangeNotifier {
  _AuthRouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<UserProfile?>>(
      authNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }
}

/// Riverpod provider supplying the configured [GoRouter] for [FruitLensApp].
/// Directs first-time launches to `/onboarding`.
/// Enforces gated authentication (Opsi 2): unauthenticated users must log in
/// or register at `/auth` before accessing any protected tabs.
final appRouterProvider = Provider<GoRouter>((ref) {
  var showOnboarding = false;
  try {
    final prefs = ref.read(sharedPreferencesProvider);
    showOnboarding = !(prefs.getBool(kOnboardingSeenKey) ?? false);
  } catch (_) {
    // Fallback for test harnesses that do not override sharedPreferencesProvider.
    showOnboarding = false;
  }

  final refreshNotifier = _AuthRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  // In Gated Flow (Opsi 2): first-time users start at /onboarding;
  // returning users start at / if session is already active, else /auth.
  final initialAuthState = ref.read(authNotifierProvider);
  final alreadyLoggedIn = initialAuthState.asData?.value != null;
  final initialRoute = showOnboarding
      ? '/onboarding'
      : (alreadyLoggedIn ? '/' : '/auth');

  final router = createAppRouter(
    initialLocation: initialRoute,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;

      // 1. Onboarding check
      bool hasSeenOnboarding = false;
      try {
        final prefs = ref.read(sharedPreferencesProvider);
        hasSeenOnboarding = prefs.getBool(kOnboardingSeenKey) ?? false;
      } catch (_) {
        hasSeenOnboarding = true;
      }

      if (!hasSeenOnboarding) {
        if (location == '/onboarding') return null;
        return '/onboarding';
      }

      // 2. Gated Flow Authentication check (Opsi 2)
      final authState = ref.read(authNotifierProvider);
      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute =
          location == '/auth' ||
          location == '/forgot-password' ||
          location == '/splash';

      if (!isLoggedIn) {
        // Unauthenticated user is restricted to auth, onboarding, and splash
        if (location == '/onboarding' || isAuthRoute) {
          return null;
        }
        return '/auth';
      }

      // Logged-in user should not linger on auth (forgot-password remains accessible for password updates)
      if (location == '/auth') {
        return '/';
      }

      return null;
    },
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Builds a fresh [GoRouter] instance with an isolated navigator key.
GoRouter createAppRouter({
  String initialLocation = '/',
  Listenable? refreshListenable,
  GoRouterRedirect? redirect,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: redirect,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return MainScaffoldWithNav(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          // Branch 0: Beranda
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Tanya AI
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/chat',
                builder: (BuildContext context, GoRouterState state) =>
                    const ChatScreen(),
              ),
            ],
          ),
          // Branch 2: Pindai (Center FAB)
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/scan',
                builder: (BuildContext context, GoRouterState state) =>
                    const ScanScreen(),
              ),
            ],
          ),
          // Branch 3: Riwayat
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/history',
                builder: (BuildContext context, GoRouterState state) =>
                    const HistoryScreen(),
              ),
            ],
          ),
          // Branch 4: Profil
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Layar Splash Beranimasi
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      // Layar Onboarding
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      // Layar Hasil Pindai (Full screen di atas bottom nav)
      GoRoute(
        path: '/result',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const ResultScreen(),
      ),
      // Layar Autentikasi (Login / Register)
      GoRoute(
        path: '/auth',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final mode = state.uri.queryParameters['mode'];
          return _horizontalSlidePage<void>(
            key: state.pageKey,
            child: AuthScreen(initialRegister: mode == 'register'),
          );
        },
      ),
      // Layar Lupa Kata Sandi
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return _horizontalSlidePage<bool>(
            key: state.pageKey,
            child: ForgotPasswordScreen(initialEmail: email),
          );
        },
      ),
      // Layar Pengaturan Akun & Preferensi Kesehatan
      GoRoute(
        path: '/account-settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const AccountSettingsScreen(),
      ),
      // Layar Daftar Resep
      GoRoute(
        path: '/recipes',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final fruit = state.uri.queryParameters['fruit'];
          final ripeness = state.uri.queryParameters['ripeness'];
          return RecipesListScreen(fruitLabel: fruit, ripenessLabel: ripeness);
        },
      ),
      // Layar Rekomendasi Resep Hasil Scan (Live Gemini AI + Backup Lokal)
      GoRoute(
        path: '/scan-recipes',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final args = state.extra! as ScanRecipesArgs;
          return ScanRecipesScreen(args: args);
        },
      ),
      // Layar Detail Resep
      GoRoute(
        path: '/recipe-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final recipe = state.extra! as Recipe;
          return RecipeDetailScreen(recipe: recipe);
        },
      ),
      // Layar Detail Riwayat Pindai
      GoRoute(
        path: '/history-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final item = state.extra! as ScanResult;
          return HistoryDetailScreen(initialItem: item);
        },
      ),
      // Preview tema mandiri
      GoRoute(
        path: '/theme-preview',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const ThemePreviewScreen(),
      ),
    ],
  );
}

CustomTransitionPage<T> _horizontalSlidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    child: child,
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final slideIn =
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          final slideOut =
              Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.25, 0.0),
              ).animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeOutCubic,
                ),
              );
          return SlideTransition(
            position: slideOut,
            child: SlideTransition(position: slideIn, child: child),
          );
        },
  );
}
