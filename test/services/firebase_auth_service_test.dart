import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService Contracts & Mapping Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('LocalAuthService registers and logins successfully', () async {
      final auth = LocalAuthService();
      final registered = await auth.register(
        'andi@fruitlens.id',
        'rahasia123',
        'Andi Pratama',
      );

      expect(registered.email, 'andi@fruitlens.id');
      expect(registered.name, 'Andi Pratama');

      final current = await auth.getCurrentUser();
      expect(current?.email, 'andi@fruitlens.id');

      final loggedIn = await auth.login('andi@fruitlens.id', 'rahasia123');
      expect(loggedIn.uid, registered.uid);

      await auth.logout();
      expect(await auth.getCurrentUser(), isNull);
    });

    test('LocalAuthService rejects duplicate email', () async {
      final auth = LocalAuthService();
      await auth.register('test@fruitlens.id', '123456', 'Tester');

      expect(
        () => auth.register('test@fruitlens.id', '123456', 'Tester 2'),
        throwsA(isA<AuthException>()),
      );
    });

    test('UserProfile json serializes and deserializes accurately', () {
      const profile = UserProfile(
        uid: 'user_123',
        email: 'user@fruitlens.id',
        name: 'User Test',
        age: 25,
        weight: 60.5,
        goal: 'Turunkan Berat Badan',
        allergies: ['Mangga'],
      );

      final json = profile.toJson();
      final copy = UserProfile.fromJson(json);

      expect(copy.uid, profile.uid);
      expect(copy.email, profile.email);
      expect(copy.name, profile.name);
      expect(copy.age, 25);
      expect(copy.weight, 60.5);
      expect(copy.goal, 'Turunkan Berat Badan');
      expect(copy.allergies, contains('Mangga'));
    });
  });
}
