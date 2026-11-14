import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/app.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/providers/camera_providers.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:fruitlens/services/camera_access.dart';

class _FakeCameraAccess implements CameraAccess {
  @override
  Future<CameraAccessStatus> status() async => CameraAccessStatus.denied;

  @override
  Future<CameraAccessStatus> request() async => CameraAccessStatus.denied;

  @override
  Future<void> openSettings() async {}
}

class _StaticHistoryNotifier extends HistoryListNotifier {
  @override
  Future<List<ScanResult>> build() async => <ScanResult>[];
}

class _StaticAuthService implements AuthService {
  @override
  Future<UserProfile?> getCurrentUser() async => const UserProfile(
    uid: 'user_nav_test',
    email: 'nav@fruitlens.id',
    name: 'Nav Tester',
  );

  @override
  Future<UserProfile> login(String email, String password) async =>
      UserProfile(uid: '1', email: email);

  @override
  Future<UserProfile> register(
    String email,
    String password,
    String name,
  ) async => UserProfile(uid: '1', email: email, name: name);

  @override
  Future<void> resetPassword(String email, String newPassword) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  group('Bottom Navigation Tests', () {
    testWidgets('navigates through all 5 tabs successfully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cameraAccessProvider.overrideWithValue(_FakeCameraAccess()),
            historyRepositoryProvider.overrideWithValue(
              InMemoryHistoryRepository(),
            ),
            historyListProvider.overrideWith(_StaticHistoryNotifier.new),
            authServiceProvider.overrideWithValue(_StaticAuthService()),
          ],
          child: const FruitLensApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 0 (Home) aktif awal
      expect(find.text('Mulai Scan'), findsOneWidget);

      // Pindah ke Tab 1 (Tanya AI)
      await tester.tap(find.text(AppStrings.navChat));
      await tester.pumpAndSettle();
      expect(find.textContaining('Halo! Saya asisten'), findsOneWidget);

      // Pindah ke Tab 2 (Scan via FAB)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.cameraPermissionTitle), findsOneWidget);

      // Pindah ke Tab 3 (Riwayat)
      await tester.tap(find.text(AppStrings.navHistory));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.historySubtitle), findsOneWidget);

      // Pindah ke Tab 4 (Profil)
      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      expect(find.text('Nav Tester'), findsOneWidget);

      // Kembali ke Tab 0 (Home)
      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();
      expect(find.text('Mulai Scan'), findsOneWidget);
    });
  });
}
