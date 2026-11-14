import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/services/fake_scan_service.dart';

void main() {
  test('FakeScanService cycles through outcomes in order', () async {
    final service = FakeScanService(
      delay: Duration.zero,
      outcomes: const <ScanOutcome>[
        ScanSuccess(
          fruitLabel: 'apple',
          ripenessLabel: 'ripe',
          fruitConfidence: 0.9,
          ripenessConfidence: 0.8,
        ),
        ScanUncertain(),
      ],
    );

    final first = await service.scan('a.jpg');
    final second = await service.scan('b.jpg');
    final third = await service.scan('c.jpg');

    expect(first, isA<ScanSuccess>());
    expect((first as ScanSuccess).fruitLabel, 'apple');
    expect(second, isA<ScanUncertain>());
    expect(third, isA<ScanSuccess>());
  });

  test('default outcomes include a success and an uncertain case', () async {
    final service = FakeScanService(delay: Duration.zero);
    final results = <ScanOutcome>[
      for (var i = 0; i < 3; i++) await service.scan('x.jpg'),
    ];

    expect(results.whereType<ScanSuccess>(), isNotEmpty);
    expect(results.whereType<ScanUncertain>(), isNotEmpty);
  });
}
