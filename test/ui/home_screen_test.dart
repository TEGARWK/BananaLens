import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/ui/screens/home_screen.dart';

void main() {
  testWidgets('renders rich home screen with hero banner and tips', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = InMemoryHistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text('Mulai Scan'), findsOneWidget);
    expect(find.textContaining('Tips Hari Ini'), findsOneWidget);
    expect(find.text('Riwayat Terakhir'), findsOneWidget);
  });
}
