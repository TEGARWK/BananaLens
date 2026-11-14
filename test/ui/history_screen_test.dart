import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/ui/screens/history_detail_screen.dart';
import 'package:fruitlens/ui/screens/history_screen.dart';

void main() {
  testWidgets('renders empty history placeholder when no scans', (
    tester,
  ) async {
    final repo = InMemoryHistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.historyTitle), findsWidgets);
    expect(find.text('Mulai Pindai Sekarang'), findsOneWidget);
  });

  testWidgets('renders list of scan history with badge and actions', (
    tester,
  ) async {
    final repo = InMemoryHistoryRepository();
    await repo.insert(
      ScanResult(
        imagePath: 'dummy.jpg',
        fruitLabel: 'apple',
        ripenessLabel: 'ripe',
        confidence: 0.95,
        createdAt: DateTime(2026, 1, 1, 12, 0),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apel'), findsOneWidget);
    expect(find.text(AppStrings.ripenessRipe), findsWidgets);
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
  });

  testWidgets('renders history detail screen with scan info and nutrition', (
    tester,
  ) async {
    final repo = InMemoryHistoryRepository();
    final item = ScanResult(
      id: 1,
      imagePath: 'dummy.jpg',
      fruitLabel: 'banana',
      ripenessLabel: 'ripe',
      confidence: 0.93,
      createdAt: DateTime(2026, 11, 9, 11, 22),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: HistoryDetailScreen(initialItem: item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail Riwayat Pindai'), findsOneWidget);
    expect(find.text('93%'), findsOneWidget);
    expect(find.text('SARAN KONSUMSI'), findsOneWidget);
    expect(find.text('DAYA SIMPAN'), findsOneWidget);
  });
}
