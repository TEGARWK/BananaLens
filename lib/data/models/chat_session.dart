import 'package:fruitlens/data/models/chat_turn.dart';

/// Persisted conversation session with BananaLens AI.
class ChatSession {
  const ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.scanContext,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? const [];
    return ChatSession(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Percakapan Baru',
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map(ChatTurn.fromJson)
          .toList(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      scanContext: json['scanContext'] as String?,
    );
  }

  final String id;
  final String title;
  final List<ChatTurn> messages;
  final DateTime updatedAt;
  final String? scanContext;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
    'scanContext': scanContext,
  };

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatTurn>? messages,
    DateTime? updatedAt,
    String? scanContext,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      scanContext: scanContext ?? this.scanContext,
    );
  }
}
