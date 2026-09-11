import '../models/formato_resultado.dart';
import '../models/match.dart';
import 'api_client.dart';

class ResultadoService {
  final ApiClient _client = ApiClient.instance;

  Future<MatchResult> registrar({
    required String partidaId,
    required FormatoResultado formato,
    required String vencedorId,
    List<SetScore> sets = const [],
  }) async {
    final data = await _client.post('/partidas/$partidaId/resultado', body: {
      'formato': formato.apiValue,
      'vencedorId': int.parse(vencedorId),
      if (sets.isNotEmpty) 'sets': sets.map((s) => s.toJson()).toList(),
    });
    return MatchResult.fromJson(data as Map<String, dynamic>);
  }
}
