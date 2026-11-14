import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalAuthService authService;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    authService = LocalAuthService();
  });

  group('LocalAuthService', () {
    test('rejects login when account is not registered', () async {
      expect(
        () => authService.login('belumada@fruitlens.id', 'secret123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('supports first-time demo login and persists session', () async {
      final user = await authService.login(
        LocalAuthService.demoEmail,
        LocalAuthService.demoPassword,
      );

      expect(user.email, LocalAuthService.demoEmail);
      expect(user.name, 'Budi Santoso');

      final current = await authService.getCurrentUser();
      expect(current?.email, LocalAuthService.demoEmail);

      await authService.logout();
      expect(await authService.getCurrentUser(), isNull);

      expect(
        () => authService.login(LocalAuthService.demoEmail, 'wrongpass'),
        throwsA(isA<AuthException>()),
      );
    });

    test(
      'registers user, prevents duplicates, and verifies password',
      () async {
        final created = await authService.register(
          ' Sari@FruitLens.id ',
          'rahasia123',
          'Sari Ayu',
        );
        expect(created.email, 'sari@fruitlens.id');
        expect(created.name, 'Sari Ayu');

        expect(
          () =>
              authService.register('sari@fruitlens.id', 'lainnya1', 'Duplikat'),
          throwsA(isA<AuthException>()),
        );

        await authService.logout();

        expect(
          () => authService.login('sari@fruitlens.id', 'salah999'),
          throwsA(isA<AuthException>()),
        );

        final loggedIn = await authService.login(
          'SARI@fruitlens.id',
          'rahasia123',
        );
        expect(loggedIn.name, 'Sari Ayu');
      },
    );

    test(
      'resets password for registered account and rejects unknown',
      () async {
        await authService.register('andi@fruitlens.id', 'lama123', 'Andi');
        await authService.logout();

        await authService.resetPassword('ANDI@fruitlens.id', 'baru456');

        expect(
          () => authService.login('andi@fruitlens.id', 'lama123'),
          throwsA(isA<AuthException>()),
        );

        final loggedIn = await authService.login(
          'andi@fruitlens.id',
          'baru456',
        );
        expect(loggedIn.name, 'Andi');

        expect(
          () => authService.resetPassword('tidakada@fruitlens.id', 'baru456'),
          throwsA(isA<AuthException>()),
        );
      },
    );
  });
}
