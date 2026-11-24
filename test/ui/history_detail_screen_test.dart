import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/repositories/fruit_info_repository.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/ui/screens/history_detail_screen.dart';

class _FakeFruitRepo implements FruitInfoRepository {
  @override
  Future<List<FruitInfo>> getAll() async => <FruitInfo>[];

  @override
  Future<FruitInfo?> getByLabel(String label) async {
    return const FruitInfo(
      label: 'banana',
      nameId: 'Pisang',
      calories: 89,
      carbs: 22.8,
      sugar: 12.2,
      fiber: 2.6,
      vitamins: 'Vitamin B6',
      benefits: 'Sumber energi cepat dan kalium yang baik untuk otot.',
      storageTips:
          'Simpan di suhu ruang. Kulit menghitam tanda sangat matang, cocok untuk smoothie.',
      allergenNote: 'Aman',
    );
  }
}

void main() {
  testWidgets(
    'displays actual saved ripeness confidence and consumption tips for ripe scan',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final item = ScanResult(
        id: 1,
        imagePath: 'dummy_ripe.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        confidence: 0.74,
        createdAt: DateTime(2026, 11, 11, 22, 53),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fruitInfoRepositoryProvider.overrideWithValue(_FakeFruitRepo()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: HistoryDetailScreen(initialItem: item),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('74%'), findsOneWidget);
      expect(find.text('Akurasi Kematangan'), findsOneWidget);
      expect(find.text(AppStrings.resultBenefits), findsOneWidget);
      expect(find.text('Vitamin B6'), findsOneWidget);
      expect(find.text('Resep'), findsOneWidget);
      expect(find.text(AppStrings.rottenAdviceTitle), findsNothing);
    },
  );

  testWidgets(
    'displays food safety warning and recycling guidance sheet for rotten scan',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final item = ScanResult(
        id: 2,
        imagePath: 'dummy_rotten.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'rotten',
        confidence: 0.83,
        createdAt: DateTime(2026, 11, 11, 22, 54),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fruitInfoRepositoryProvider.overrideWithValue(_FakeFruitRepo()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: HistoryDetailScreen(initialItem: item),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('83%'), findsOneWidget);
      expect(find.text(AppStrings.rottenAdviceTitle), findsOneWidget);
      expect(find.text(AppStrings.rottenAdviceWarning), findsOneWidget);
      expect(find.text(AppStrings.rottenEcoTitle), findsOneWidget);
      expect(find.textContaining('smoothie'), findsNothing);
      expect(find.text('Resep'), findsNothing);

      final recycleButton = find.text('Daur Ulang');
      expect(recycleButton, findsOneWidget);
      await tester.tap(recycleButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.rottenSheetTitle), findsOneWidget);
      expect(
        find.text('Pisang terdeteksi dalam kondisi busuk.'),
        findsOneWidget,
      );
    },
  );
}
