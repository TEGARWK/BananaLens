import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/services/scan_service.dart';

// TODO-INTEGRASI: replace with TfliteScanService in Phase 7 (T-60).
/// Fake [ScanService] returning canned outcomes in a loop. Not a real feature.
class FakeScanService implements ScanService {
  FakeScanService({
    List<ScanOutcome>? outcomes,
    this.delay = const Duration(milliseconds: 800),
  }) : _outcomes = outcomes ?? _defaultOutcomes;

  static const List<ScanOutcome> _defaultOutcomes = <ScanOutcome>[
    ScanSuccess(
      fruitLabel: 'banana',
      ripenessLabel: 'ripe',
      fruitConfidence: 0.93,
      ripenessConfidence: 0.88,
    ),
    ScanSuccess(
      fruitLabel: 'apple',
      ripenessLabel: 'unripe',
      fruitConfidence: 0.91,
      ripenessConfidence: 0.81,
    ),
    ScanUncertain(),
  ];

  final List<ScanOutcome> _outcomes;

  /// Simulated inference latency so loading states can be exercised.
  final Duration delay;

  int _next = 0;

  @override
  Future<ScanOutcome> scan(String imagePath) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final outcome = _outcomes[_next % _outcomes.length];
    _next++;
    return outcome;
  }
}
