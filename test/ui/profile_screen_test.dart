import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:fruitlens/ui/screens/account_settings_screen.dart';
import 'package:fruitlens/ui/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService([this._currentUser]);

  UserProfile? _currentUser;

  @override
  Future<UserProfile?> getCurrentUser() async => _currentUser;

  @override
  Future<UserProfile> login(String email, String password) async {
    return _currentUser ??= UserProfile(
      uid: 'u1',
      email: email,
      name: 'Budi Santoso',
    );
  }

  @override
  Future<UserProfile> loginWithGoogle() async {
    return _currentUser ??= const UserProfile(
      uid: 'u_google',
      email: 'google@fruitlens.id',
      name: 'Budi Google',
    );
  }

  @override
  Future<UserProfile> register(
    String email,
    String password,
    String name,
  ) async {
    return _currentUser ??= UserProfile(uid: 'u1', email: email, name: name);
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _currentUser = profile;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}

class _PresetHistoryNotifier extends HistoryListNotifier {
  _PresetHistoryNotifier(this._items);

  final List<ScanResult> _items;

  @override
  Future<List<ScanResult>> build() async => _items;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget buildApp({
    UserProfile? user,
    List<ScanResult> history = const <ScanResult>[],
  }) {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: <RouteBase>[
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        GoRoute(
          path: '/account-settings',
          builder: (_, _) => const AccountSettingsScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (_, _) => const Scaffold(body: Text('Halaman Riwayat')),
        ),
        GoRoute(
          path: '/auth',
          builder: (_, _) => const Scaffold(body: Text('Halaman Masuk')),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, _) => const Scaffold(body: Text('Halaman Lupa Sandi')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const Scaffold(body: Text('Halaman Panduan')),
        ),
        GoRoute(
          path: '/scan',
          builder: (_, _) => const Scaffold(body: Text('Halaman Scan')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(_FakeAuthService(user)),
        historyListProvider.overrideWith(() => _PresetHistoryNotifier(history)),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final mode = ref.watch(themeControllerProvider);
          return MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            routerConfig: router,
          );
        },
      ),
    );
  }

  testWidgets('guest state renders profile CTA, history card, and menus', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Belum Masuk ke Akun'), findsOneWidget);
    expect(find.text('Riwayat Pemindaian'), findsOneWidget);
    expect(find.text('Mulai Pindai'), findsOneWidget);
    expect(find.text('Pengaturan Akun'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Keluar dari Akun'), findsNothing);
  });

  testWidgets(
    'history card previews up to 2 recent scans and links to history',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime(2026, 11, 11, 9, 30);
      final items = <ScanResult>[
        ScanResult(
          id: 1,
          imagePath: '',
          fruitLabel: 'banana',
          ripenessLabel: 'ripe',
          confidence: 0.96,
          createdAt: now,
          isFavorite: true,
        ),
        ScanResult(
          id: 2,
          imagePath: '',
          fruitLabel: 'apple',
          ripenessLabel: 'unripe',
          confidence: 0.89,
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        ScanResult(
          id: 3,
          imagePath: '',
          fruitLabel: 'mango',
          ripenessLabel: 'overripe',
          confidence: 0.91,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ];

      await tester.pumpWidget(buildApp(history: items));
      await tester.pumpAndSettle();

      expect(find.text('3 scan · 1 favorit'), findsOneWidget);
      expect(find.text('Pisang'), findsOneWidget);
      expect(find.text('Apel'), findsOneWidget);
      expect(find.text('Mangga'), findsNothing);

      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();
      expect(find.text('Halaman Riwayat'), findsOneWidget);
    },
  );

  testWidgets(
    'logged-in user can change theme sheet and edit account settings',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      const user = UserProfile(
        uid: 'u1',
        email: 'sari@fruitlens.id',
        name: 'Sari Dewi',
        age: 24,
        weight: 55.0,
        goal: 'Pola Hidup Sehat',
        allergies: <String>['Susu / Laktosa'],
      );

      await tester.pumpWidget(buildApp(user: user));
      await tester.pumpAndSettle();

      expect(find.text('Sari Dewi'), findsOneWidget);
      expect(find.text('sari@fruitlens.id'), findsOneWidget);
      expect(find.text('Keluar dari Akun'), findsOneWidget);

      await tester.ensureVisible(find.text('Tema & Tampilan'));
      await tester.tap(find.text('Tema & Tampilan'));
      await tester.pumpAndSettle();
      expect(find.text('Night Harvest (Gelap)'), findsOneWidget);

      await tester.tap(find.text('Night Harvest (Gelap)'));
      await tester.pumpAndSettle();
      expect(find.text('Night Harvest (Gelap)'), findsOneWidget);

      await tester.tap(find.text('Profil & Preferensi Kesehatan'));
      await tester.pumpAndSettle();
      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      await tester.ensureVisible(find.text('Diet & Defisit Kalori'));
      await tester.tap(find.text('Diet & Defisit Kalori'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Pisang / Lateks'));
      await tester.tap(find.text('Pisang / Lateks'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(find.text('Diet & Defisit Kalori'), findsWidgets);
    },
  );
}
