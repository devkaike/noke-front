import '../models/clube.dart';
import 'api_client.dart';

class ClubePublicoService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Clube>> listar() async {
    final data = await _client.get('/clubes/publicos');
    return (data as List).map((e) => Clube.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Clube> detalhe(String clubeId) async {
    final data = await _client.get('/clubes/publicos/$clubeId');
    return Clube.fromJson(data as Map<String, dynamic>);
  }
}
