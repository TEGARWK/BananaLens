import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/chat_turn.dart';
import 'package:fruitlens/services/chat_service.dart';
import 'package:fruitlens/services/fake_chat_service.dart';

void main() {
  const history = <ChatTurn>[];

  test('returns a reply that includes scan context', () async {
    final service = FakeChatService(delay: Duration.zero);

    final reply = await service.send(
      history: history,
      message: 'Cara simpan?',
      scanContext: 'apple, ripe',
    );

    expect(reply, contains('Cara simpan?'));
    expect(reply, contains('apple, ripe'));
  });

  test('throws ChatFailure when configured to fail', () {
    final service = FakeChatService(delay: Duration.zero, shouldFail: true);

    expect(
      service.send(history: history, message: 'halo'),
      throwsA(isA<ChatFailure>()),
    );
  });
}
