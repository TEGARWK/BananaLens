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
    uid: 'user_widget_test',
    email: 'widget@fruitlens.id',
    name: 'Widget Tester',
  );

  @override
  Future<UserProfile> login(String email, String password) async =>
      UserProfile(uid: '1', email: email);

  @override
  Future<UserProfile> loginWithGoogle() async => const UserProfile(
    uid: 'google_1',
    email: 'google@fruitlens.id',
    name: 'Google User',
  );

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
  testWidgets('app boots and displays bottom navigation tabs', (tester) async {
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

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text('Scan Pisang'), findsOneWidget);
    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(find.text(AppStrings.navChat), findsOneWidget);
    expect(find.text(AppStrings.navHistory), findsOneWidget);
    expect(find.text(AppStrings.navProfile), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
