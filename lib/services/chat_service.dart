import '../models/conversation.dart';
import 'api_client.dart';

class ChatService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Conversation>> conversas() async {
    final data = await _client.get('/conversas');
    return (data as List).map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Conversation>> convitesRecebidos() async {
    final data = await _client.get('/conversas/convites');
    return (data as List).map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Conversation> convidar(String jogadorId) async {
    final data = await _client.post('/conversas/convidar/$jogadorId');
    return Conversation.fromJson(data as Map<String, dynamic>);
  }

  Future<Conversation> aceitar(String conversaId) async {
    final data = await _client.post('/conversas/$conversaId/aceitar');
    return Conversation.fromJson(data as Map<String, dynamic>);
  }

  Future<Conversation> recusar(String conversaId) async {
    final data = await _client.post('/conversas/$conversaId/recusar');
    return Conversation.fromJson(data as Map<String, dynamic>);
  }

  Future<List<ChatMessage>> mensagens(String conversaId) async {
    final data = await _client.get('/conversas/$conversaId/mensagens');
    return (data as List).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChatMessage> enviar(String conversaId, String texto) async {
    final data = await _client.post('/conversas/$conversaId/mensagens', body: {'texto': texto});
    return ChatMessage.fromJson(data as Map<String, dynamic>);
  }
}
