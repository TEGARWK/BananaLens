import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/router/app_router.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/ui/screens/onboarding_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LoggedInAuthNotifier extends AuthNotifier {
  @override
  Future<UserProfile?> build() async =>
      const UserProfile(uid: 'u1', email: 'user@fruitlens.id', name: 'User');
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders redesigned 3 slides and steps through them', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: <RouteBase>[
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Beranda Target')),
        ),
        GoRoute(
          path: '/auth',
          builder: (_, _) => const Scaffold(body: Text('Auth Target')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
    );
    await tester.pumpAndSettle();

    // Slide 1
    expect(find.text('Deteksi Kematangan Seketika'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);

    // Tap Lanjut -> Slide 2
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Pantau Gizi & Peringatan Alergi'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Tap Lanjut -> Slide 3
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Ide Resep & Asisten AI'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Sudah punya akun? Masuk di sini'), findsOneWidget);

    // Tap Daftar Akun Baru navigates to '/auth' and persists onboarding flag
    await tester.tap(find.text('Daftar Akun Baru'));
    await tester.pumpAndSettle();
    expect(find.text('Auth Target'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('fruitlens_onboarding_seen'), isTrue);
  });

  test(
    'appRouterProvider starts at /onboarding until seen flag is set, then /auth if unauthenticated',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      var prefs = await SharedPreferences.getInstance();

      final firstContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(firstContainer.dispose);
      final firstRouter = firstContainer.read(appRouterProvider);
      expect(
        firstRouter.routeInformationProvider.value.uri.path,
        '/onboarding',
      );

      SharedPreferences.setMockInitialValues(<String, Object>{
        kOnboardingSeenKey: true,
      });
      prefs = await SharedPreferences.getInstance();

      final returningContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(returningContainer.dispose);
      final returningRouter = returningContainer.read(appRouterProvider);
      expect(returningRouter.routeInformationProvider.value.uri.path, '/auth');
    },
  );

  test(
    'appRouterProvider routes to / when onboarding is seen and user is logged in',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        kOnboardingSeenKey: true,
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authNotifierProvider.overrideWith(() => _LoggedInAuthNotifier()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authNotifierProvider.future);
      final router = container.read(appRouterProvider);
      expect(router.routeInformationProvider.value.uri.path, '/');
    },
  );
}
