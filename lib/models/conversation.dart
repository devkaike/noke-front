import 'player.dart';

class ChatMessage {
  final String id;
  final String remetenteId;
  final String text;
  final DateTime time;

  const ChatMessage({
    required this.id,
    required this.remetenteId,
    required this.text,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      remetenteId: json['remetenteId'].toString(),
      text: json['texto'] as String,
      time: DateTime.parse(json['enviadaEm'] as String),
    );
  }
}

enum ConversationStatus { pendente, aceita, recusada }

extension ConversationStatusX on ConversationStatus {
  static ConversationStatus fromApi(String value) => switch (value) {
        'PENDENTE' => ConversationStatus.pendente,
        'ACEITA' => ConversationStatus.aceita,
        'RECUSADA' => ConversationStatus.recusada,
        _ => ConversationStatus.pendente,
      };
}

class Conversation {
  final String id;
  final Player player;
  final ConversationStatus status;
  final bool sentByMe;
  final ChatMessage? lastMessage;

  const Conversation({
    required this.id,
    required this.player,
    required this.status,
    required this.sentByMe,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final ultima = json['ultimaMensagem'] as Map<String, dynamic>?;
    return Conversation(
      id: json['id'].toString(),
      player: Player.fromJson(json['outroJogador'] as Map<String, dynamic>),
      status: ConversationStatusX.fromApi(json['status'] as String),
      sentByMe: json['enviadoPorMim'] as bool,
      lastMessage: ultima == null ? null : ChatMessage.fromJson(ultima),
    );
  }
}
