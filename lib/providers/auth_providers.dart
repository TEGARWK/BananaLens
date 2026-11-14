import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:fruitlens/services/firebase_auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  if (Firebase.apps.isNotEmpty) {
    return FirebaseAuthService();
  }
  return LocalAuthService();
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserProfile?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() {
    return ref.read(authServiceProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    final previous = state.asData?.value;
    state = const AsyncLoading();
    try {
      final user = await ref.read(authServiceProvider).login(email, password);
      state = AsyncData(user);
      // Trigger background sync for pending offline records
      unawaited(
        ref
            .read(cloudSyncServiceProvider)
            .syncPendingScans(user.uid, ref.read(historyRepositoryProvider)),
      );
    } catch (error) {
      // Restore previous session state so guest/other tabs never get stuck in error.
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    final previous = state.asData?.value;
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authServiceProvider)
          .register(email, password, name);
      state = AsyncData(user);
      unawaited(
        ref
            .read(cloudSyncServiceProvider)
            .syncPendingScans(user.uid, ref.read(historyRepositoryProvider)),
      );
    } catch (error) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String newPassword) {
    return ref.read(authServiceProvider).resetPassword(email, newPassword);
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).updateProfile(profile);
      await ref.read(cloudSyncServiceProvider).syncUserProfile(profile);
      return profile;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}
