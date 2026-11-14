import 'package:fruitlens/data/models/chat_turn.dart';

/// Thrown when the assistant cannot answer (network, timeout, quota).
class ChatFailure implements Exception {
  const ChatFailure(this.message);

  final String message;

  @override
  String toString() => 'ChatFailure: $message';
}

/// Fruit assistant. Real Gemini implementation is owned by track B, see
/// INTEGRATION_CONTRACT.md.
abstract class ChatService {
  /// Returns the assistant reply. [scanContext] is optional, e.g.
  /// `apple, ripe`. Throws [ChatFailure] on error so the UI can offer retry.
  Future<String> send({
    required List<ChatTurn> history,
    required String message,
    String? scanContext,
  });
}
