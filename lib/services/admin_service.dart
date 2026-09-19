import '../models/clube.dart';
import 'api_client.dart';

class AdminService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Clube>> listarClubes({StatusClube? status}) async {
    final query = status == null ? '' : '?status=${_apiValue(status)}';
    final data = await _client.get('/admin/clubes$query');
    return (data as List).map((e) => Clube.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Clube> aprovar(String clubeId) async {
    final data = await _client.post('/admin/clubes/$clubeId/aprovar');
    return Clube.fromJson(data as Map<String, dynamic>);
  }

  Future<Clube> rejeitar(String clubeId, String motivo) async {
    final data = await _client.post('/admin/clubes/$clubeId/rejeitar', body: {'motivo': motivo});
    return Clube.fromJson(data as Map<String, dynamic>);
  }

  String _apiValue(StatusClube status) => switch (status) {
        StatusClube.pendente => 'PENDENTE',
        StatusClube.aprovado => 'APROVADO',
        StatusClube.rejeitado => 'REJEITADO',
      };
}
