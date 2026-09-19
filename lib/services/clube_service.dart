import '../models/clube.dart';
import '../models/match.dart';
import 'api_client.dart';

class ClubeService {
  final ApiClient _client = ApiClient.instance;

  Future<Clube> cadastrarClube({
    required String nome,
    required String rua,
    required String numero,
    required String bairro,
    required String cidade,
    required String estado,
    required String cep,
    String? fotoBase64,
  }) async {
    final data = await _client.post('/clubes', body: {
      'nome': nome,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'fotoBase64': fotoBase64,
    });
    return Clube.fromJson(data as Map<String, dynamic>);
  }

  Future<Clube> meuClube() async {
    final data = await _client.get('/clubes/me');
    return Clube.fromJson(data as Map<String, dynamic>);
  }

  Future<Clube> atualizarClube({
    required String nome,
    required String rua,
    required String numero,
    required String bairro,
    required String cidade,
    required String estado,
    required String cep,
    String? fotoBase64,
  }) async {
    final data = await _client.put('/clubes/me', body: {
      'nome': nome,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'fotoBase64': fotoBase64,
    });
    return Clube.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Quadra>> minhasQuadras() async {
    final data = await _client.get('/clubes/me/quadras');
    return (data as List).map((e) => Quadra.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Quadra> cadastrarQuadra({
    required String nome,
    required CourtType tipoQuadra,
    required bool coberta,
    required bool iluminacao,
    String? observacoes,
    List<String> fotosBase64 = const [],
  }) async {
    final data = await _client.post('/clubes/me/quadras', body: {
      'nome': nome,
      'tipoQuadra': tipoQuadra.apiValue,
      'coberta': coberta,
      'iluminacao': iluminacao,
      'observacoes': observacoes,
      'fotosBase64': fotosBase64,
    });
    return Quadra.fromJson(data as Map<String, dynamic>);
  }

  Future<Quadra> atualizarQuadra(
    String quadraId, {
    required String nome,
    required CourtType tipoQuadra,
    required bool coberta,
    required bool iluminacao,
    String? observacoes,
    List<String> fotosBase64 = const [],
  }) async {
    final data = await _client.put('/clubes/me/quadras/$quadraId', body: {
      'nome': nome,
      'tipoQuadra': tipoQuadra.apiValue,
      'coberta': coberta,
      'iluminacao': iluminacao,
      'observacoes': observacoes,
      'fotosBase64': fotosBase64,
    });
    return Quadra.fromJson(data as Map<String, dynamic>);
  }

  Future<void> removerQuadra(String quadraId) {
    return _client.delete('/clubes/me/quadras/$quadraId');
  }
}
