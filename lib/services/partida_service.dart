import '../models/match.dart';
import '../models/player.dart';
import 'api_client.dart';

class PartidaService {
  final ApiClient _client = ApiClient.instance;

  Future<List<TennisMatch>> abertas({CourtType? quadra, PlayerLevel? nivel}) async {
    final params = <String, String>{};
    if (quadra != null) params['quadra'] = quadra.apiValue;
    if (nivel != null) params['nivel'] = nivel.apiValue;

    final query = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    final data = await _client.get('/partidas$query');
    return (data as List).map((e) => TennisMatch.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TennisMatch>> minhas() async {
    final data = await _client.get('/partidas/minhas');
    return (data as List).map((e) => TennisMatch.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TennisMatch> criar({
    required String clube,
    required CourtType quadra,
    required MatchMode modo,
    required PlayerLevel nivel,
    required DateTime dataHora,
    required int vagasTotais,
  }) async {
    final data = await _client.post('/partidas', body: {
      'clube': clube,
      'quadra': quadra.apiValue,
      'modo': modo.apiValue,
      'nivel': nivel.apiValue,
      'dataHora': dataHora.toIso8601String(),
      'vagasTotais': vagasTotais,
    });
    return TennisMatch.fromJson(data as Map<String, dynamic>);
  }

  Future<TennisMatch> detalhes(String partidaId) async {
    final data = await _client.get('/partidas/$partidaId');
    return TennisMatch.fromJson(data as Map<String, dynamic>);
  }

  Future<TennisMatch> atualizar(
    String partidaId, {
    required String clube,
    required CourtType quadra,
    required MatchMode modo,
    required PlayerLevel nivel,
    required DateTime dataHora,
    required int vagasTotais,
  }) async {
    final data = await _client.put('/partidas/$partidaId', body: {
      'clube': clube,
      'quadra': quadra.apiValue,
      'modo': modo.apiValue,
      'nivel': nivel.apiValue,
      'dataHora': dataHora.toIso8601String(),
      'vagasTotais': vagasTotais,
    });
    return TennisMatch.fromJson(data as Map<String, dynamic>);
  }

  Future<TennisMatch> participar(String partidaId) async {
    final data = await _client.post('/partidas/$partidaId/participar');
    return TennisMatch.fromJson(data as Map<String, dynamic>);
  }

  Future<TennisMatch> encerrar(String partidaId) async {
    final data = await _client.post('/partidas/$partidaId/encerrar');
    return TennisMatch.fromJson(data as Map<String, dynamic>);
  }
}
