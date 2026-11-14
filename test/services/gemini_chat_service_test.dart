import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/chat_turn.dart';
import 'package:fruitlens/services/chat_service.dart';
import 'package:fruitlens/services/gemini_chat_service.dart';

void main() {
  group('GeminiChatService Tests', () {
    test('throws ChatFailure when apiKey is empty', () async {
      final service = GeminiChatService(apiKey: '');
      expect(
        () => service.send(
          history: const <ChatTurn>[],
          message: 'Halo, pisang ini aman dimakan?',
        ),
        throwsA(
          isA<ChatFailure>().having(
            (e) => e.message,
            'message',
            contains('Kunci API Gemini belum dikonfigurasi'),
          ),
        ),
      );
    });

    test(
      'system instruction contains nutrition, culinary, guardrail, and anti-greeting guidelines',
      () {
        final instruction = GeminiChatService.systemInstruction.toLowerCase();
        expect(instruction, contains('fruitlens ai'));
        expect(instruction, contains('kematangan'));
        expect(instruction, contains('peringatan keselamatan pangan'));
        expect(instruction, contains('batasan pembahasan'));
        expect(instruction, contains('jangan pernah mengulang sapaan'));
      },
    );
  });
}
