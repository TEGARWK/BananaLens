/// Who wrote a chat message.
enum ChatRole { user, model }

/// One message in a conversation with the fruit assistant.
class ChatTurn {
  const ChatTurn({required this.role, required this.content});

  final ChatRole role;
  final String content;

  bool get isUser => role == ChatRole.user;
  String get text => content;
}
