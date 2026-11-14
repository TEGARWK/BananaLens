import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/data/repositories/fruit_info_repository.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/providers/scan_notifier.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/services/fake_scan_service.dart';

class _MockFruitRepo implements FruitInfoRepository {
  @override
  Future<List<FruitInfo>> getAll() async => <FruitInfo>[];

  @override
  Future<FruitInfo?> getByLabel(String label) async {
    if (label == 'apple') {
      return const FruitInfo(
        label: 'apple',
        nameId: 'Apel',
        calories: 52,
        carbs: 13.8,
        sugar: 10.4,
        fiber: 2.4,
        vitamins: 'Vitamin C',
        benefits: 'Bagus untuk diet',
        storageTips: 'Simpan di kulkas',
        allergenNote: 'Aman',
      );
    }
    return null;
  }
}

void main() {
  test(
    'ScanNotifier processes high confidence scan successfully with nutrition',
    () async {
      final container = ProviderContainer(
        overrides: [
          scanServiceProvider.overrideWithValue(
            FakeScanService(
              delay: Duration.zero,
              outcomes: const <ScanOutcome>[
                ScanSuccess(
                  fruitLabel: 'apple',
                  ripenessLabel: 'ripe',
                  fruitConfidence: 0.95,
                  ripenessConfidence: 0.90,
                ),
              ],
            ),
          ),
          fruitInfoRepositoryProvider.overrideWithValue(_MockFruitRepo()),
          historyRepositoryProvider.overrideWithValue(
            InMemoryHistoryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(scanProvider).value, isNull);

      await container.read(scanProvider.notifier).scan('test_apple.jpg');

      final report = container.read(scanProvider).value;
      expect(report, isNotNull);
      expect(report!.outcome, isA<ScanSuccess>());
      final success = report.outcome as ScanSuccess;
      expect(success.fruitLabel, 'apple');
      expect(report.fruitInfo?.nameId, 'Apel');
    },
  );

  test(
    'ScanNotifier converts low confidence below 0.6 to ScanUncertain',
    () async {
      final container = ProviderContainer(
        overrides: [
          scanServiceProvider.overrideWithValue(
            FakeScanService(
              delay: Duration.zero,
              outcomes: const <ScanOutcome>[
                ScanSuccess(
                  fruitLabel: 'apple',
                  ripenessLabel: 'ripe',
                  fruitConfidence: 0.55, // di bawah ambang 0.6
                  ripenessConfidence: 0.90,
                ),
              ],
            ),
          ),
          fruitInfoRepositoryProvider.overrideWithValue(_MockFruitRepo()),
          historyRepositoryProvider.overrideWithValue(
            InMemoryHistoryRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(scanProvider.notifier).scan('test_blur.jpg');

      final report = container.read(scanProvider).value;
      expect(report, isNotNull);
      expect(report!.outcome, isA<ScanUncertain>());
    },
  );

  test(
    'ScanNotifier saves actual ripenessConfidence to history instead of fruitConfidence',
    () async {
      final historyRepo = InMemoryHistoryRepository();
      final container = ProviderContainer(
        overrides: [
          scanServiceProvider.overrideWithValue(
            FakeScanService(
              delay: Duration.zero,
              outcomes: const <ScanOutcome>[
                ScanSuccess(
                  fruitLabel: 'banana',
                  ripenessLabel: 'rotten',
                  fruitConfidence: 0.98,
                  ripenessConfidence: 0.76,
                ),
              ],
            ),
          ),
          fruitInfoRepositoryProvider.overrideWithValue(_MockFruitRepo()),
          historyRepositoryProvider.overrideWithValue(historyRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(scanProvider.notifier).scan('test_banana.jpg');

      final saved = await historyRepo.getAll();
      expect(saved, hasLength(1));
      expect(saved.first.confidence, closeTo(0.76, 1e-6));
      expect(saved.first.confidence, isNot(closeTo(0.98, 1e-6)));
    },
  );
}
