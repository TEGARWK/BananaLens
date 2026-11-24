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
    expect(find.textContaining('95% yakin'), findsOneWidget);
    expect(find.text('1 hasil pindai'), findsOneWidget);
    expect(find.text('Matang Banget'), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
  });

  testWidgets('filters history by Matang Banget chip and search query', (
    tester,
  ) async {
    final repo = InMemoryHistoryRepository();
    await repo.insert(
      ScanResult(
        imagePath: 'dummy1.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        confidence: 0.80,
        createdAt: DateTime(2026, 11, 21, 10, 0),
      ),
    );
    await repo.insert(
      ScanResult(
        imagePath: 'dummy2.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'overripe',
        confidence: 0.74,
        createdAt: DateTime(2026, 11, 21, 11, 0),
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

    expect(find.text('2 hasil pindai'), findsOneWidget);

    await tester.tap(find.text('Matang Banget').first);
    await tester.pumpAndSettle();

    expect(find.text('1 hasil pindai'), findsOneWidget);
    expect(find.textContaining('74% yakin'), findsOneWidget);
    expect(find.textContaining('80% yakin'), findsNothing);
  });

  testWidgets('renders history detail screen with scan info and nutrition', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

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
    expect(find.text('CATATAN · PINDAI'), findsOneWidget);
    expect(find.text('93%'), findsOneWidget);
    expect(find.text('Ketuk untuk rincian'), findsOneWidget);
    expect(find.text('Per 100 g'), findsOneWidget);
    expect(find.text('Serat Pangan'), findsOneWidget);
    expect(find.text(AppStrings.resultBenefits), findsOneWidget);
    expect(find.text('Resep'), findsOneWidget);
    expect(find.text('Tanya AI'), findsOneWidget);
  });

  testWidgets(
    'renders ripeness-aware guidance for unripe and rotten history detail',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = InMemoryHistoryRepository();
      final unripeItem = ScanResult(
        id: 2,
        imagePath: 'unripe.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'unripe',
        confidence: 0.78,
        createdAt: DateTime(2026, 11, 21, 23, 49),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [historyRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: HistoryDetailScreen(initialItem: unripeItem),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.resultBenefits), findsOneWidget);
      expect(find.textContaining('Kulit menghitam'), findsNothing);
      expect(find.text('Resep'), findsOneWidget);

      final rottenItem = ScanResult(
        id: 3,
        imagePath: 'rotten.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'rotten',
        confidence: 0.55,
        createdAt: DateTime(2026, 11, 21, 23, 57),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [historyRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: HistoryDetailScreen(initialItem: rottenItem),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PERINGATAN KEAMANAN PANGAN'), findsOneWidget);
      expect(find.text('Daur Ulang'), findsOneWidget);
      expect(find.text('Tanya AI'), findsOneWidget);
    },
  );
}
