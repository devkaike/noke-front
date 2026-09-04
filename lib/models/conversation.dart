import 'player.dart';

class ChatMessage {
  final String text;
  final DateTime time;
  final bool fromMe;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.fromMe,
  });
}

class Conversation {
  final String id;
  final Player player;
  final List<ChatMessage> messages;

  const Conversation({
    required this.id,
    required this.player,
    required this.messages,
  });

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
