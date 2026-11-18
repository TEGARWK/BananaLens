import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/data/models/chat_session.dart';
import 'package:fruitlens/data/models/chat_turn.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kChatSessionsKey = 'bananalens_chat_sessions_v1';
const int _kMaxSavedSessions = 25;

class ChatState {
  const ChatState({
    this.activeSessionId = '',
    this.messages = const <ChatTurn>[],
    this.sessions = const <ChatSession>[],
    this.isLoading = false,
    this.error,
    this.scanContext,
  });

  final String activeSessionId;
  final List<ChatTurn> messages;
  final List<ChatSession> sessions;
  final bool isLoading;
  final String? error;
  final String? scanContext;

  ChatState copyWith({
    String? activeSessionId,
    List<ChatTurn>? messages,
    List<ChatSession>? sessions,
    bool? isLoading,
    String? error,
    String? scanContext,
    bool clearScanContext = false,
  }) {
    return ChatState(
      activeSessionId: activeSessionId ?? this.activeSessionId,
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
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
  static const ChatTurn _initialGreeting = ChatTurn(
    role: ChatRole.model,
    content:
        'Halo! Saya asisten pintar BananaLens. Ada yang ingin kamu tanyakan seputar buah, kandungan nutrisi, cara penyimpanan, atau resep olahannya?',
  );

  @override
  ChatState build() {
    unawaited(_loadSavedSessions());
    return ChatState(
      activeSessionId: _newSessionId(),
      messages: const <ChatTurn>[_initialGreeting],
    );
  }

  String _newSessionId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _loadSavedSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kChatSessionsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded
          .whereType<Map<String, dynamic>>()
          .map(ChatSession.fromJson)
          .where((s) => s.id.isNotEmpty)
          .toList();
      if (loaded.isNotEmpty) {
        state = state.copyWith(sessions: loaded);
      }
    } catch (_) {
      // SharedPreferences unavailable in isolated unit tests; ignore safely.
    }
  }

  Future<void> _persistSessions(List<ChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_kChatSessionsKey, encoded);
    } catch (_) {
      // Ignore persistence errors in test/restricted environments.
    }
  }

  String _deriveTitle(List<ChatTurn> messages) {
    final firstUser = messages.where((m) => m.isUser).firstOrNull;
    if (firstUser == null) return 'Percakapan Baru';
    final clean = firstUser.content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= 44) return clean;
    return '${clean.substring(0, 41)}...';
  }

  List<ChatSession> _upsertCurrentSession(
    List<ChatTurn> messages,
    String? scanContext,
  ) {
    final hasUserMsg = messages.any((m) => m.isUser);
    if (!hasUserMsg) return state.sessions;

    final session = ChatSession(
      id: state.activeSessionId.isEmpty
          ? _newSessionId()
          : state.activeSessionId,
      title: _deriveTitle(messages),
      messages: List<ChatTurn>.from(messages),
      updatedAt: DateTime.now(),
      scanContext: scanContext,
    );

    final updated = <ChatSession>[
      session,
      ...state.sessions.where((s) => s.id != session.id),
    ];
    if (updated.length > _kMaxSavedSessions) {
      return updated.sublist(0, _kMaxSavedSessions);
    }
    return updated;
  }

  void setScanContext(String? context) {
    if (context == null) {
      state = state.copyWith(clearScanContext: true);
    } else {
      state = state.copyWith(scanContext: context);
    }
  }

  /// Opens a clean chat session with [context] attached (saving any active
  /// conversation that already has user messages into [sessions]).
  void openWithScanContext(String context) {
    final updatedSessions = _upsertCurrentSession(
      state.messages,
      state.scanContext,
    );
    state = ChatState(
      activeSessionId: _newSessionId(),
      messages: const <ChatTurn>[_initialGreeting],
      sessions: updatedSessions,
      scanContext: context,
    );
    unawaited(_persistSessions(updatedSessions));
  }

  /// Starts a clean chat session (saving any active conversation with user
  /// messages) and immediately sends [prompt] as a normal chat message.
  Future<void> startNewChatAndSend(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;

    final updatedSessions = _upsertCurrentSession(
      state.messages,
      state.scanContext,
    );
    state = ChatState(
      activeSessionId: _newSessionId(),
      messages: const <ChatTurn>[_initialGreeting],
      sessions: updatedSessions,
    );
    unawaited(_persistSessions(updatedSessions));
    await sendMessage(trimmed);
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
      final finalMessages = List<ChatTurn>.from(updatedList)..add(modelTurn);
      final updatedSessions = _upsertCurrentSession(
        finalMessages,
        state.scanContext,
      );

      state = state.copyWith(
        messages: finalMessages,
        sessions: updatedSessions,
        isLoading: false,
        error: null,
      );
      unawaited(_persistSessions(updatedSessions));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Gagal terhubung dengan asisten. Periksa koneksi atau coba lagi.',
      );
    }
  }

  /// Starts a fresh conversation while keeping previous chats in [sessions].
  void startNewChat() {
    final updatedSessions = _upsertCurrentSession(
      state.messages,
      state.scanContext,
    );
    state = ChatState(
      activeSessionId: _newSessionId(),
      messages: const <ChatTurn>[_initialGreeting],
      sessions: updatedSessions,
    );
    unawaited(_persistSessions(updatedSessions));
  }

  /// Switches the active view to a saved [ChatSession].
  void selectSession(String sessionId) {
    final target = state.sessions.where((s) => s.id == sessionId).firstOrNull;
    if (target == null) return;
    state = ChatState(
      activeSessionId: target.id,
      messages: List<ChatTurn>.from(target.messages),
      sessions: state.sessions,
      scanContext: target.scanContext,
    );
  }

  /// Deletes a single saved session from history.
  void deleteSession(String sessionId) {
    final updatedSessions = state.sessions
        .where((s) => s.id != sessionId)
        .toList();
    if (state.activeSessionId == sessionId) {
      state = ChatState(
        activeSessionId: _newSessionId(),
        messages: const <ChatTurn>[_initialGreeting],
        sessions: updatedSessions,
      );
    } else {
      state = state.copyWith(sessions: updatedSessions);
    }
    unawaited(_persistSessions(updatedSessions));
  }

  /// Clears all saved chat history and starts a fresh session.
  void clearAllHistory() {
    state = ChatState(
      activeSessionId: _newSessionId(),
      messages: const <ChatTurn>[_initialGreeting],
      sessions: const <ChatSession>[],
    );
    unawaited(_persistSessions(const <ChatSession>[]));
  }

  void clearConversation() {
    startNewChat();
  }
}
