import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/data/models/chat_turn.dart';
import 'package:fruitlens/providers/service_providers.dart';

class ChatState {
  const ChatState({
    this.messages = const <ChatTurn>[],
    this.isLoading = false,
    this.error,
    this.scanContext,
  });

  final List<ChatTurn> messages;
  final bool isLoading;
  final String? error;
  final String? scanContext;

  ChatState copyWith({
    List<ChatTurn>? messages,
    bool? isLoading,
    String? error,
    String? scanContext,
    bool clearScanContext = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scanContext: clearScanContext ? null : (scanContext ?? this.scanContext),
    );
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return const ChatState(
      messages: <ChatTurn>[
        ChatTurn(
          role: ChatRole.model,
          content:
              'Halo! Saya asisten pintar FruitLens. Ada yang ingin kamu tanyakan seputar buah, kandungan nutrisi, cara penyimpanan, atau resep olahannya?',
        ),
      ],
    );
  }

  void setScanContext(String? context) {
    if (context == null) {
      state = state.copyWith(clearScanContext: true);
    } else {
      state = state.copyWith(scanContext: context);
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userTurn = ChatTurn(role: ChatRole.user, content: trimmed);
    final updatedList = List<ChatTurn>.from(state.messages)..add(userTurn);

    state = state.copyWith(messages: updatedList, isLoading: true, error: null);

    try {
      final chatService = ref.read(chatServiceProvider);
      final replyText = await chatService.send(
        history: updatedList,
        message: trimmed,
        scanContext: state.scanContext,
      );

      final modelTurn = ChatTurn(role: ChatRole.model, content: replyText);
      state = state.copyWith(
        messages: List<ChatTurn>.from(updatedList)..add(modelTurn),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Gagal terhubung dengan asisten. Periksa koneksi atau coba lagi.',
      );
    }
  }

  void clearConversation() {
    state = build();
  }
}
