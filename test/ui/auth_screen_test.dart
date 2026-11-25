import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/ui/screens/auth_screen.dart';
import 'package:fruitlens/ui/screens/forgot_password_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget buildApp({bool initialRegister = false}) {
    final router = GoRouter(
      initialLocation: '/auth',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Beranda Target')),
        ),
        GoRoute(
          path: '/auth',
          builder: (_, _) => AuthScreen(initialRegister: initialRegister),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, GoRouterState state) => ForgotPasswordScreen(
            initialEmail: state.uri.queryParameters['email'] ?? '',
          ),
        ),
      ],
    );

    return ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  testWidgets('shows error banner on unregistered login email', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'unknown@fruitlens.id');
    await tester.enterText(fields.at(1), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Akun dengan email ini belum terdaftar.'), findsOneWidget);
    expect(find.text('Beranda Target'), findsNothing);
  });

  testWidgets('renders Masuk dengan Google button and shows error when Firebase inactive', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Masuk dengan Google'), findsOneWidget);
    await tester.tap(find.text('Masuk dengan Google'));
    await tester.pumpAndSettle();

    expect(
      find.text('Masuk dengan Google membutuhkan layanan Firebase yang aktif.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'renders Masuk dengan Google button and shows error when Firebase inactive',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Masuk dengan Google'), findsOneWidget);
      await tester.tap(find.text('Masuk dengan Google'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Masuk dengan Google membutuhkan layanan Firebase yang aktif.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'switches Login/Register via bottom prompt and validates signup',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Switch from Login -> Register using bottom prompt
      expect(find.text('Belum punya akun?'), findsOneWidget);
      await tester.tap(find.text('Daftar di sini'));
      await tester.pumpAndSettle();

      expect(find.text('Sudah punya akun?'), findsOneWidget);
      expect(find.text('Buat Profil Sehatmu'), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sari Ayu');
      await tester.enterText(fields.at(1), 'sari@fruitlens.id');
      await tester.enterText(fields.at(2), 'rahasia123');
      await tester.enterText(fields.at(3), 'tidaksama');

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Buat Akun Sekarang'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kata sandi tidak cocok'), findsOneWidget);

      await tester.enterText(fields.at(3), 'rahasia123');
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Buat Akun Sekarang'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Beranda Target'), findsOneWidget);
    },
  );

  testWidgets('navigates to Forgot Password page and resets password', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lupa kata sandi?'));
    await tester.pumpAndSettle();

    expect(find.text('Lupa Kata Sandi?'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Simpan Kata Sandi Baru'),
      findsOneWidget,
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'budi@fruitlens.id');
    await tester.enterText(fields.at(1), 'baru654');
    await tester.enterText(fields.at(2), 'baru654');
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Simpan Kata Sandi Baru'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Kata sandi berhasil diperbarui. Silakan masuk.'),
      findsOneWidget,
    );
  });
}
