import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/data/models/scan_report.dart';
import 'package:fruitlens/providers/scan_notifier.dart';
import 'package:fruitlens/ui/screens/result_screen.dart';

class _FakeScanNotifier extends ScanNotifier {
  _FakeScanNotifier(this._report);
  final ScanReport? _report;

  @override
  ScanReport? build() => _report;
}

void main() {
  testWidgets('renders success result with nutrition and ripeness', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const report = ScanReport(
      imagePath: 'dummy.jpg',
      outcome: ScanSuccess(
        fruitLabel: 'apple',
        ripenessLabel: 'ripe',
        fruitConfidence: 0.92,
        ripenessConfidence: 0.88,
      ),
      fruitInfo: FruitInfo(
        label: 'apple',
        nameId: 'Apel',
        calories: 52,
        carbs: 13.8,
        sugar: 10.4,
        fiber: 2.4,
        vitamins: 'Vitamin C',
        benefits: 'Serat pektin',
        storageTips: 'Simpan di kulkas',
        allergenNote: 'Aman',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [scanProvider.overrideWith(() => _FakeScanNotifier(report))],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apel'), findsOneWidget);
    expect(find.text(AppStrings.ripenessRipe), findsOneWidget);
    expect(find.text('52'), findsOneWidget); // Kalori
    expect(find.text(AppStrings.resultBenefits), findsOneWidget);
  });

  testWidgets(
    'renders uncertain view with retake button when fruit not recognized',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const report = ScanReport(
        imagePath: 'dummy.jpg',
        outcome: ScanUncertain(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scanProvider.overrideWith(() => _FakeScanNotifier(report)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.resultUncertainTitle), findsOneWidget);
      expect(find.text(AppStrings.resultRetake), findsOneWidget);
    },
  );

  testWidgets(
    'renders 4-class SVM probabilities card when classProbabilities is present',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const report = ScanReport(
        imagePath: 'dummy_banana.jpg',
        outcome: ScanSuccess(
          fruitLabel: 'banana',
          ripenessLabel: 'ripe',
          fruitConfidence: 0.98,
          ripenessConfidence: 0.945,
          classProbabilities: {
            'unripe': 0.021,
            'ripe': 0.945,
            'overripe': 0.032,
            'rotten': 0.002,
          },
        ),
        fruitInfo: FruitInfo(
          label: 'banana',
          nameId: 'Pisang',
          calories: 89,
          carbs: 22.8,
          sugar: 12.2,
          fiber: 2.6,
          vitamins: 'Vitamin B6, C, Kalium',
          benefits: 'Sumber energi cepat',
          storageTips: 'Simpan pada suhu ruang',
          allergenNote: 'Jarang alergi',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scanProvider.overrideWith(() => _FakeScanNotifier(report)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lihat rincian skor AI'), findsOneWidget);
      await tester.tap(find.text('Lihat rincian skor AI'));
      await tester.pumpAndSettle();

      expect(find.text('Mentah'), findsOneWidget);
      expect(find.text('Matang'), findsWidgets);
      expect(find.text('Matang Banget'), findsOneWidget);
      expect(find.text('Busuk'), findsOneWidget);
      expect(find.text('94.5%'), findsOneWidget);
    },
  );

  testWidgets(
    'renders 3-class SVM probabilities card without overripe when absent',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const report = ScanReport(
        imagePath: 'dummy_banana.jpg',
        outcome: ScanSuccess(
          fruitLabel: 'banana',
          ripenessLabel: 'ripe',
          fruitConfidence: 0.98,
          ripenessConfidence: 0.962,
          classProbabilities: {'ripe': 0.962, 'rotten': 0.011, 'unripe': 0.027},
        ),
        fruitInfo: FruitInfo(
          label: 'banana',
          nameId: 'Pisang',
          calories: 89,
          carbs: 22.8,
          sugar: 12.2,
          fiber: 2.6,
          vitamins: 'Vitamin B6, C, Kalium',
          benefits: 'Sumber energi cepat',
          storageTips: 'Simpan pada suhu ruang',
          allergenNote: 'Jarang alergi',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scanProvider.overrideWith(() => _FakeScanNotifier(report)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lihat rincian skor AI'), findsOneWidget);
      await tester.tap(find.text('Lihat rincian skor AI'));
      await tester.pumpAndSettle();

      expect(find.text('Mentah'), findsOneWidget);
      expect(find.text('Matang'), findsWidgets);
      expect(find.text('Busuk'), findsOneWidget);
      expect(find.text('Matang Banget'), findsNothing);
    },
  );

  testWidgets(
    'shows low-confidence banner when ripenessConfidence < 60% (>= 35%)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const report = ScanReport(
        imagePath: 'dummy_transition.jpg',
        outcome: ScanSuccess(
          fruitLabel: 'banana',
          ripenessLabel: 'rotten',
          fruitConfidence: 0.48,
          ripenessConfidence: 0.57,
          classProbabilities: {'ripe': 0.424, 'rotten': 0.573, 'unripe': 0.003},
        ),
        fruitInfo: FruitInfo(
          label: 'banana',
          nameId: 'Pisang',
          calories: 89,
          carbs: 22.8,
          sugar: 12.2,
          fiber: 2.6,
          vitamins: 'Vitamin B6, C, Kalium',
          benefits: 'Sumber energi cepat',
          storageTips: 'Simpan pada suhu ruang',
          allergenNote: 'Jarang alergi',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scanProvider.overrideWith(() => _FakeScanNotifier(report)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResultScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Hasil foto kurang jelas (<60%)'),
        findsOneWidget,
      );
      expect(find.text('57%'), findsOneWidget);
    },
  );
}
