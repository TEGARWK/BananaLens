import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/app.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/providers/camera_providers.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:fruitlens/services/camera_access.dart';
import 'package:fruitlens/ui/screens/splash_screen.dart';
import 'package:fruitlens/ui/widgets/splash_scanner_mark.dart';

class _StubCameraAccess implements CameraAccess {
  @override
  Future<CameraAccessStatus> status() async => CameraAccessStatus.denied;

  @override
  Future<CameraAccessStatus> request() async => CameraAccessStatus.denied;

  @override
  Future<void> openSettings() async {}
}

class _EmptyHistoryNotifier extends HistoryListNotifier {
  @override
  Future<List<ScanResult>> build() async => <ScanResult>[];
}

class _StubAuthService implements AuthService {
  const _StubAuthService([this._user]);
  final UserProfile? _user;

  @override
  Future<UserProfile?> getCurrentUser() async => _user;

  @override
  Future<UserProfile> login(String email, String password) async =>
      _user ?? UserProfile(uid: '1', email: email);

  @override
  Future<UserProfile> loginWithGoogle() async =>
      _user ??
      const UserProfile(
        uid: 'google_1',
        email: 'google@fruitlens.id',
        name: 'Google User',
      );

  @override
  Future<UserProfile> register(
    String email,
    String password,
    String name,
  ) async => _user ?? UserProfile(uid: '1', email: email, name: name);

  @override
  Future<void> resetPassword(String email, String newPassword) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets(
    'SplashScreen plays scanner animation and calls onCompleted at end',
    (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SplashScreen(
            duration: const Duration(milliseconds: 800),
            onCompleted: () => completed = true,
          ),
        ),
      );

      expect(find.byType(SplashScannerMark), findsOneWidget);
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.splashBadge), findsOneWidget);
      expect(find.text(AppStrings.splashTagline), findsOneWidget);
      expect(completed, isFalse);

      await tester.pump(const Duration(milliseconds: 400));
      expect(completed, isFalse);

      await tester.pumpAndSettle();
      expect(completed, isTrue);
    },
  );

  testWidgets(
    'SplashScreen respects disableAnimations and renders cleanly in dark theme',
    (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: SplashScreen(onCompleted: () => completed = true),
          ),
        ),
      );

      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(completed, isFalse);

      await tester.pump(const Duration(milliseconds: 500));
      expect(completed, isTrue);
    },
  );

  testWidgets(
    'FruitLensApp with enableSplash displays splash then fades into home screen for logged-in user',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraAccessProvider.overrideWithValue(_StubCameraAccess()),
            historyRepositoryProvider.overrideWithValue(
              InMemoryHistoryRepository(),
            ),
            historyListProvider.overrideWith(_EmptyHistoryNotifier.new),
            authServiceProvider.overrideWithValue(
              const _StubAuthService(
                UserProfile(
                  uid: 'u1',
                  email: 'user@fruitlens.id',
                  name: 'User',
                ),
              ),
            ),
          ],
          child: const FruitLensApp(enableSplash: true),
        ),
      );

      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Scan Pisang'), findsOneWidget);
    },
  );

  testWidgets(
    'FruitLensApp with enableSplash redirects unauthenticated user to AuthScreen after splash',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraAccessProvider.overrideWithValue(_StubCameraAccess()),
            historyRepositoryProvider.overrideWithValue(
              InMemoryHistoryRepository(),
            ),
            historyListProvider.overrideWith(_EmptyHistoryNotifier.new),
            authServiceProvider.overrideWithValue(const _StubAuthService(null)),
          ],
          child: const FruitLensApp(enableSplash: true),
        ),
      );

      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Masuk ke BananaLens'), findsOneWidget);
    },
  );
}
