import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/services/chat_service.dart';
import 'package:fruitlens/services/fake_scan_service.dart';
import 'package:fruitlens/services/scan_service.dart';

void main() {
  test('providers expose services and can be overridden in tests', () async {
    final container = ProviderContainer(
      overrides: [
        scanServiceProvider.overrideWithValue(
          FakeScanService(
            delay: Duration.zero,
            outcomes: const <ScanOutcome>[ScanFailure('boom')],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final ScanService scan = container.read(scanServiceProvider);
    final ChatService chat = container.read(chatServiceProvider);

    expect(await scan.scan('x.jpg'), isA<ScanFailure>());
    expect(chat, isNotNull);
  });
}
