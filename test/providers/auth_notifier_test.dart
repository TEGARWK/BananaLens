import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  UserProfile? _user;

  @override
  Future<UserProfile?> getCurrentUser() async => _user;

  @override
  Future<UserProfile> login(String email, String password) async {
    _user = UserProfile(uid: 'uid_1', email: email, name: 'User');
    return _user!;
  }

  @override
  Future<UserProfile> loginWithGoogle() async {
    _user = const UserProfile(
      uid: 'uid_google_1',
      email: 'google@fruitlens.id',
      name: 'Google User',
    );
    return _user!;
  }

  @override
  Future<UserProfile> register(
    String email,
    String password,
    String name,
  ) async {
    _user = UserProfile(uid: 'uid_1', email: email, name: name);
    return _user!;
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _user = profile;
  }

  @override
  Future<void> logout() async {
    _user = null;
  }
}

void main() {
  test('AuthNotifier registers, updates profile, and logs out', () async {
    final fakeAuth = _FakeAuthService();
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(fakeAuth)],
    );
    addTearDown(container.dispose);

    expect(container.read(authNotifierProvider).value, isNull);

    // Register
    await container
        .read(authNotifierProvider.notifier)
        .register('test@example.com', 'secret', 'Budi');
    expect(container.read(authNotifierProvider).value?.name, 'Budi');

    // Update
    final current = container.read(authNotifierProvider).value!;
    await container
        .read(authNotifierProvider.notifier)
        .updateProfile(current.copyWith(age: 25, weight: 65.5));
    expect(container.read(authNotifierProvider).value?.age, 25);
    expect(container.read(authNotifierProvider).value?.weight, 65.5);

    // Logout
    await container.read(authNotifierProvider.notifier).logout();
    expect(container.read(authNotifierProvider).value, isNull);

    // Google Sign-In
    await container.read(authNotifierProvider.notifier).loginWithGoogle();
    expect(
      container.read(authNotifierProvider).value?.email,
      'google@fruitlens.id',
    );
  });
}
