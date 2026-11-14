import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/chat_turn.dart';
import 'package:fruitlens/providers/chat_notifier.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/services/fake_chat_service.dart';

void main() {
  test(
    'ChatNotifier sends message and updates chat turns with reply',
    () async {
      final container = ProviderContainer(
        overrides: [
          chatServiceProvider.overrideWithValue(
            FakeChatService(delay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      final initialCount = container.read(chatNotifierProvider).messages.length;

      await container
          .read(chatNotifierProvider.notifier)
          .sendMessage('Berapa kalori pisang?');

      final state = container.read(chatNotifierProvider);
      expect(state.messages.length, initialCount + 2); // 1 user + 1 model
      expect(state.messages.last.role, ChatRole.model);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    },
  );

  test('ChatNotifier sets and retains scan context', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(chatNotifierProvider.notifier)
        .setScanContext('Pisang (Matang)');
    expect(container.read(chatNotifierProvider).scanContext, 'Pisang (Matang)');

    container.read(chatNotifierProvider.notifier).setScanContext(null);
    expect(container.read(chatNotifierProvider).scanContext, isNull);
  });
}
