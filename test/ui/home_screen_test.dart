import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/data/repositories/recipe_repository.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/ui/screens/home_screen.dart';
import 'package:fruitlens/ui/widgets/gallery_preview_sheet.dart';

const _testRecipesJson = '''
[
  {
    "id": 1,
    "title": "Keripik Pisang Renyah",
    "fruit_label": "banana",
    "ripeness_bucket": "unripe",
    "type": "food",
    "suitable_ripeness": ["unripe"],
    "prep_time": "25 menit",
    "difficulty": "Mudah",
    "ingredients": ["Pisang mentah"],
    "steps": ["Iris tipis dan goreng"],
    "is_reviewed": true
  },
  {
    "id": 2,
    "title": "Es Susu Pisang",
    "fruit_label": "banana",
    "ripeness_bucket": "ripe",
    "type": "drink",
    "suitable_ripeness": ["ripe"],
    "prep_time": "10 menit",
    "difficulty": "Mudah",
    "ingredients": ["Pisang matang", "Susu"],
    "steps": ["Blender semua bahan"],
    "is_reviewed": true
  }
]
''';

void main() {
  testWidgets('renders rich home screen with hero banner, stats, and tips', (
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
        overrides: [
          historyRepositoryProvider.overrideWithValue(repo),
          recipeRepositoryProvider.overrideWithValue(
            AssetRecipeRepository(loadString: (_) async => _testRecipesJson),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text('Pindai Pisang'), findsOneWidget);
    expect(find.text('Scan Pisang'), findsOneWidget);
    expect(find.text('Buka Galeri'), findsOneWidget);
    expect(find.text('Ringkasan Pindai'), findsOneWidget);
    expect(find.text('Sepanjang waktu'), findsOneWidget);
    expect(find.text('Total Pindai'), findsOneWidget);
    expect(find.text('Siap Santap'), findsOneWidget);
    expect(find.text('Mentah'), findsWidgets);
    expect(find.text('Buah Favorit'), findsNothing);
    expect(find.textContaining('Tips Hari Ini'), findsOneWidget);
    expect(find.text('Riwayat Terakhir'), findsOneWidget);
    expect(find.text('Scan Pisang Pertama'), findsOneWidget);
    expect(find.text('Resep yang Cocok untuk Pisangmu'), findsOneWidget);
  });

  testWidgets('shows explicit confidence label only when confidence > 0', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = InMemoryHistoryRepository();
    await repo.insert(
      ScanResult(
        imagePath: 'dummy1.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        confidence: 0.89,
        createdAt: DateTime(2026, 11, 25, 16, 30),
      ),
    );
    await repo.insert(
      ScanResult(
        imagePath: 'dummy2.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'unripe',
        confidence: 0.0,
        createdAt: DateTime(2026, 11, 25, 15, 10),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyRepositoryProvider.overrideWithValue(repo),
          recipeRepositoryProvider.overrideWithValue(
            AssetRecipeRepository(loadString: (_) async => _testRecipesJson),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.textContaining('16.30 · Keyakinan 89%'), findsOneWidget);
    expect(find.textContaining('15.10'), findsOneWidget);
    expect(find.textContaining('Keyakinan 0%'), findsNothing);
    expect(
      find.text('Rekomendasi berdasarkan hasil scan terakhir'),
      findsOneWidget,
    );
  });

  testWidgets('gallery preview sheet renders Lanjut Analisis and Pilih Ulang', (
    tester,
  ) async {
    GalleryPreviewAction? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showGalleryPreviewSheet(context, 'dummy.jpg');
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Pratinjau Foto Pisang'), findsOneWidget);
    expect(find.text('Pilih Ulang'), findsOneWidget);
    expect(find.text('Lanjut Analisis'), findsOneWidget);

    await tester.tap(find.text('Lanjut Analisis'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

    expect(result, GalleryPreviewAction.analyze);
  });
}
