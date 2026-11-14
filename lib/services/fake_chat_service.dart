import 'package:fruitlens/data/models/chat_turn.dart';
import 'package:fruitlens/services/chat_service.dart';

// TODO-INTEGRASI: replace with GeminiChatService in Phase 7 (T-61).
/// Fake [ChatService] with a canned Indonesian reply. Not a real feature.
class FakeChatService implements ChatService {
  FakeChatService({
    this.delay = const Duration(milliseconds: 600),
    this.shouldFail = false,
  });

  final Duration delay;

  /// When true, [send] throws [ChatFailure] to exercise the error UI.
  final bool shouldFail;

  @override
  Future<String> send({
    required List<ChatTurn> history,
    required String message,
    String? scanContext,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldFail) {
      throw const ChatFailure('Koneksi gagal. Coba lagi sebentar.');
    }
    final context = scanContext == null ? '' : ' (konteks: $scanContext)';
    return 'Ini jawaban contoh untuk "$message"$context.';
  }
}
