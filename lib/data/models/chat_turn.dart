/// Who wrote a chat message.
enum ChatRole { user, model }

/// One message in a conversation with the fruit assistant.
class ChatTurn {
  const ChatTurn({required this.role, required this.content});

  factory ChatTurn.fromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String? ?? 'model';
    return ChatTurn(
      role: roleName == 'user' ? ChatRole.user : ChatRole.model,
      content: json['content'] as String? ?? '',
    );
  }

  final ChatRole role;
  final String content;

  bool get isUser => role == ChatRole.user;
  String get text => content;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'role': role.name,
    'content': content,
  };
}
